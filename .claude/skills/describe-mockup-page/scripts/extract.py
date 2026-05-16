#!/usr/bin/env python3
"""Extract per-page screen descriptions from the Nutrionista Balsamiq mockup.

Two sources are merged per page:
  - PDF zones (`docs/Nutrionista balsamiq.pdf`):
      * left margin  : Estonian page-name title + description sidebar
      * center       : wireframe text + image placeholders
      * right margin : yellow-sticky metadata (label, filename, url, API, DTO,
                       Response, Veateated)
  - HTML mockup (`docs/madis/nutrionista-mockup.html`):
      * semantic structure of each Alpine `<div x-show="page === 'X'">` block
      * resolved nav edges (`@click="page = '...'"`)
      * form fields (type, name, placeholder, label)

The two sides are joined on PDF `filename` → HTML Alpine page id, using a
filename-to-id rule (strip `View.vue`, CamelCase → snake_case, lowercase)
plus a tiny override table for the two non-derivable cases:
  - `HomeView.vue` → `main`
  - PDF page whose filename is annotated `???.vue` → `confirmation`

Usage:
  extract.py [PDF_PATH] [--page N | --pages 1,3,5] [--format markdown|json]
             [--zone left|center|right|all] [--html HTML_PATH]
             [--source merged|pdf|html]
"""
import argparse
import json
import re
import sys
from pathlib import Path

import fitz  # PyMuPDF

sys.path.insert(0, str(Path(__file__).parent))
from html_extract import parse_html  # noqa: E402

DEFAULT_HTML_PATH = "docs/madis/nutrionista-mockup.html"

PAGE_OVERRIDES: dict[int, str] = {
    10: "confirmation",
}

FILENAME_OVERRIDES: dict[str, str] = {
    "HomeView.vue": "main",
}

LEFT_MAX_X = 60.0
RIGHT_MIN_X_FALLBACK = 590.0
METADATA_KEYS = ("filename", "url", "API", "DTO", "Response", "Veateated")
KEY_LINE_RE = re.compile(r"^(filename|url|API|DTO|Response|Veateated)\s*:\s*(.*)$")
CAMEL_RE = re.compile(r"(?<!^)(?=[A-Z])")


def _detect_right_min_x(blocks) -> float:
    """The yellow-sticky right column starts at a different x on each page
    (range observed: 502-683). Anchor it by finding the leftmost block that
    contains a metadata key like `filename:` or `url:`, then back off slightly
    so the all-caps label sitting above also falls into the right zone."""
    candidate_x = None
    for x0, _y0, _x1, _y1, text, *_ in blocks:
        for line in text.splitlines():
            if KEY_LINE_RE.match(line.strip()):
                if candidate_x is None or x0 < candidate_x:
                    candidate_x = x0
                break
    return candidate_x - 10.0 if candidate_x is not None else RIGHT_MIN_X_FALLBACK


def _normalize(text: str) -> str:
    return text.replace("\r", "").strip()


def _blocks_in_zone(blocks, zone: str, right_min_x: float, with_coords: bool = False):
    out = []
    for x0, y0, x1, y1, text, *_ in blocks:
        keep = (
            (zone == "left" and x0 < LEFT_MAX_X)
            or (zone == "right" and x0 >= right_min_x)
            or (zone == "center" and LEFT_MAX_X <= x0 < right_min_x)
        )
        if keep:
            out.append((y0, x0, y1, text))
    out.sort(key=lambda t: (t[0], t[1]))
    if with_coords:
        return [(y0, x0, y1, _normalize(t)) for (y0, x0, y1, t) in out if _normalize(t)]
    return [_normalize(t[3]) for t in out if _normalize(t[3])]


def _parse_right_metadata(lines):
    """Right-zone lines form the yellow sticky block. First non-key line is the
    page label (e.g. 'LANDING PAGE/HOME'). Remaining lines are key:value pairs;
    values can be multi-line (JSON bodies, error lists)."""
    label = None
    fields = {k: "" for k in METADATA_KEYS}
    current_key = None
    for raw in lines:
        for piece in raw.split("\n"):
            piece = piece.strip()
            if not piece:
                if current_key:
                    fields[current_key] += "\n"
                continue
            m = KEY_LINE_RE.match(piece)
            if m:
                current_key = m.group(1)
                fields[current_key] = m.group(2).strip()
            elif current_key is None and label is None:
                label = piece
            elif current_key is None:
                label = (label + " " + piece) if label else piece
            else:
                fields[current_key] += ("\n" if fields[current_key] else "") + piece
    return {"label": label, **{k: fields[k].strip() for k in METADATA_KEYS}}


def _parse_left_sidebar(blocks_with_coords):
    """Left-zone blocks: the first vertically-contiguous group of lines is the
    title (in Estonian); after a y-gap the description starts. The narrow column
    causes both title and description to wrap across multiple PDF blocks."""
    if not blocks_with_coords:
        return {"title": "", "description": ""}
    groups = []
    current = []
    prev_y1 = None
    Y_GAP = 3.5  # bigger than typical line-height inside a paragraph
    for y0, x0, y1, text in blocks_with_coords:
        if prev_y1 is not None and y0 - prev_y1 > Y_GAP:
            groups.append(current)
            current = []
        current.append(text)
        prev_y1 = y1
    if current:
        groups.append(current)

    def _flatten(g):
        return re.sub(r"\s+", " ", " ".join(g).replace("\n", " ")).strip()

    title = _flatten(groups[0]) if groups else ""
    description = _flatten([t for g in groups[1:] for t in g]) if len(groups) > 1 else ""
    return {"title": title, "description": description}


def _detect_image_placeholders(page, blocks, right_min_x: float):
    """Detect Balsamiq image placeholders inside the mockup canvas.

    The reliable signal is the X-cross diagonals: a drawing with `ops="ll"`,
    `type=fs`, a dark stroke, and `max(width, height) >= 30`. Rounded-corner
    rectangle outlines on their own are ambiguous (panels and section
    backgrounds use the same path shape), so we never report a placeholder
    without diagonals. For each X-cross we find the smallest enclosing visible
    rectangle (either a plain `re` or a rounded `l/c` outline) so the reported
    bbox matches what the eye sees, not just the thin diagonal stroke."""
    drawings = page.get_drawings()
    placeholders = []
    for d in drawings:
        items = d.get("items", [])
        ops = "".join(it[0] for it in items)
        if ops != "ll":
            continue
        if d.get("type") != "fs":
            continue
        if not _has_dark_stroke(d.get("color")):
            continue
        rect = d.get("rect")
        if not rect or max(rect.width, rect.height) < 30:
            continue
        if rect.x0 < LEFT_MAX_X or rect.x0 >= right_min_x:
            continue
        merged = _smallest_enclosing_rect(rect, drawings)
        label = _nearest_label_below(merged, blocks)
        placeholders.append({
            "x": round(merged.x0, 1),
            "y": round(merged.y0, 1),
            "width": round(merged.width, 1),
            "height": round(merged.height, 1),
            "label": label,
        })
    placeholders.sort(key=lambda p: (p["y"], p["x"]))
    return placeholders


def _is_white(fill) -> bool:
    return bool(fill and len(fill) >= 3 and min(fill[:3]) > 0.95)


def _has_dark_stroke(stroke) -> bool:
    return bool(stroke and len(stroke) >= 3 and max(stroke[:3]) < 0.6)


def _smallest_enclosing_rect(diag_rect, drawings):
    """Find the visible rectangle that surrounds the X-cross diagonals. The
    Balsamiq image-placeholder shape can be either a plain `re` rectangle or
    a rounded `l/c` outline; both qualify here. Bounds:

      * Lower (1.5× area) — skip the X-cross's own near-coincident white-fill
        rect that PDFKit emits as a sibling drawing.
      * Upper (20× area) — skip the full mockup canvas.

    Among the candidates that pass, prefer the LARGEST. That way page 1's
    products pick up the outer rounded card outline (10× area) instead of the
    tighter sibling rect (1.8×), while pages whose only enclosure IS that
    tight rect (e.g. page 7) still get a sensible answer."""
    diag_area = max(diag_rect.width * diag_rect.height, 1.0)
    best = None
    best_area = None
    for d in drawings:
        items = d.get("items", [])
        if not items:
            continue
        ops = "".join(it[0] for it in items)
        is_rect_shape = (ops == "re") or ("l" in ops and "c" in ops)
        if not is_rect_shape:
            continue
        r = d.get("rect")
        if not r:
            continue
        if not (r.x0 <= diag_rect.x0 + 5 and r.x1 >= diag_rect.x1 - 5
                and r.y0 <= diag_rect.y0 + 5 and r.y1 >= diag_rect.y1 - 5):
            continue
        area = r.width * r.height
        if area < diag_area * 1.5 or area > diag_area * 20:
            continue
        if best_area is None or area > best_area:
            best, best_area = r, area
    return best or diag_rect


def _nearest_label_below(rect, blocks):
    """Pick the topmost text block horizontally aligned with the placeholder,
    scanning from the placeholder's top edge down to ~80pt below it. In
    Balsamiq cards the product name often overlaps the placeholder's bounding
    box rather than sitting strictly under it, so we don't require y0 > y1."""
    placeholder_center = (rect.x0 + rect.x1) / 2
    candidates = []
    for x0, y0, x1, y1, text, *_ in blocks:
        if y0 < rect.y0 - 5 or y0 > rect.y1 + 80:
            continue
        if x1 < rect.x0 - 10 or x0 > rect.x1 + 10:
            continue
        clean = text.strip().replace("\n", " ")
        if not clean:
            continue
        x_center = (x0 + x1) / 2
        candidates.append((y0, abs(x_center - placeholder_center), clean))
    if not candidates:
        return None
    # Prefer topmost; break ties by closest horizontal center
    candidates.sort(key=lambda t: (t[0], t[1]))
    return candidates[0][2]


def _filename_to_page_id(filename: str) -> str | None:
    """`HomeView.vue` → `home` (via override → `main`); `OrderHistoryView.vue`
    → `order_history`. Returns None if the filename is missing or unparseable."""
    if not filename or filename in ("???.vue", "???"):
        return None
    if filename in FILENAME_OVERRIDES:
        return FILENAME_OVERRIDES[filename]
    stem = filename[:-len("View.vue")] if filename.endswith("View.vue") else filename
    return CAMEL_RE.sub("_", stem).lower()


def _resolve_html_page(pdf_page_number: int, metadata: dict, html_pages: dict) -> tuple[str | None, dict | None]:
    """Find the HTML page block that matches this PDF page. Order:
    (1) explicit `PAGE_OVERRIDES` by PDF page number;
    (2) derive from `metadata['filename']`. Returns (page_id, page_data) or
    (None, None) if no match could be found."""
    if pdf_page_number in PAGE_OVERRIDES:
        pid = PAGE_OVERRIDES[pdf_page_number]
        return (pid, html_pages.get(pid))
    pid = _filename_to_page_id(metadata.get("filename", ""))
    if pid and pid in html_pages:
        return (pid, html_pages[pid])
    return (None, None)


def extract_page(page, page_index: int, html_pages: dict | None = None) -> dict:
    blocks = page.get_text("blocks")
    right_min_x = _detect_right_min_x(blocks)
    left = _blocks_in_zone(blocks, "left", right_min_x, with_coords=True)
    center = _blocks_in_zone(blocks, "center", right_min_x)
    right = _blocks_in_zone(blocks, "right", right_min_x)
    images = _detect_image_placeholders(page, blocks, right_min_x)
    metadata = _parse_right_metadata(right)

    result = {
        "page": page_index + 1,
        "sidebar": _parse_left_sidebar(left),
        "mockup": [ln for raw in center for ln in raw.split("\n") if ln.strip()],
        "metadata": metadata,
        "images": images,
    }
    if html_pages is not None:
        page_id, html_data = _resolve_html_page(page_index + 1, metadata, html_pages)
        result["html_page_id"] = page_id
        result["html"] = html_data
    return result


def _render_structure_line(item: dict) -> str:
    indent = "  " * item["depth"]
    kind = item["kind"]
    text = item.get("text", "")
    target = item.get("target")
    suffix = f" → {target}.vue" if target else ""
    if kind in ("header", "nav", "main", "section", "footer", "form"):
        return f"{indent}- <{kind}>"
    if kind in ("ul", "ol"):
        return f"{indent}- <{kind}> ({item.get('count', 0)} items)"
    if kind == "img_placeholder":
        return f"{indent}- [img] {text}"
    if kind == "input":
        bits = [item.get("label") or item.get("placeholder") or item.get("name", "")]
        meta = []
        if item.get("type"):
            meta.append(item["type"])
        if item.get("placeholder") and item.get("label"):
            meta.append(f"placeholder=\"{item['placeholder']}\"")
        meta_str = f" ({', '.join(meta)})" if meta else ""
        return f"{indent}- input: {bits[0]}{meta_str}"
    if kind in ("button", "a"):
        return f"{indent}- <{kind}> \"{text}\"{suffix}"
    if kind in ("h1", "h2", "h3", "h4"):
        return f"{indent}- {kind}: \"{text}\""
    if kind == "label":
        return f"{indent}- label: \"{text}\""
    if kind == "p":
        return f"{indent}- p: \"{text}\""
    if kind == "li":
        text = re.sub(r"^[•·∙‧⋅▪◦•]+\s*", "", text)
        return f"{indent}- • {text}"
    if kind == "option":
        return f"{indent}- option: \"{text}\""
    return f"{indent}- <{kind}> {text}"


def _render_html_section(html: dict, out: list):
    out.append("\n**Structure (HTML):**")
    for item in html["structure"]:
        out.append(_render_structure_line(item))

    if html["nav_edges"]:
        out.append("\n**Navigation (out):**")
        for e in html["nav_edges"]:
            out.append(f"- {e['via']}: \"{e['label']}\" → {e['target']}.vue")

    if html["form_fields"]:
        out.append("\n**Form fields:**")
        for f in html["form_fields"]:
            label = f.get("label") or f.get("placeholder") or f.get("name") or "(unnamed)"
            ph = f" — placeholder \"{f['placeholder']}\"" if f.get("placeholder") and f.get("label") else ""
            out.append(f"- {label} ({f.get('type', 'text')}){ph}")


def render_markdown(pages, zones, include_html: bool, include_pdf: bool):
    out = []
    for p in pages:
        out.append(f"## Page {p['page']}")
        if include_pdf and "right" in zones:
            md = p["metadata"]
            out.append(f"**Label:** {md.get('label') or '(none)'}")
            for k in METADATA_KEYS:
                v = md.get(k, "")
                if v:
                    if "\n" in v:
                        out.append(f"**{k}:**")
                        out.append("```\n" + v + "\n```")
                    else:
                        out.append(f"**{k}:** {v}")
                else:
                    out.append(f"**{k}:** _(empty)_")
        if include_pdf and "left" in zones:
            sb = p["sidebar"]
            out.append(f"\n**Title (left sidebar):** {sb['title']}")
            if sb["description"]:
                out.append(f"**Description:** {sb['description']}")
        if include_pdf and "center" in zones:
            out.append("\n**Mockup content:**")
            for line in p["mockup"]:
                out.append(f"- {line}")
            if p.get("images"):
                out.append("\n**Image placeholders:**")
                for img in p["images"]:
                    suffix = f" — near \"{img['label']}\"" if img["label"] else ""
                    out.append(f"- ({img['x']}, {img['y']}) {img['width']}×{img['height']}{suffix}")
        if include_html:
            if p.get("html"):
                page_id = p.get("html_page_id")
                if page_id:
                    out.append(f"\n_HTML page id: `{page_id}`_")
                _render_html_section(p["html"], out)
            elif "html" in p:
                out.append("\n**Structure (HTML):** _(no HTML match for this page)_")
        out.append("")
    return "\n".join(out)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pdf", nargs="?", default="docs/Nutrionista balsamiq.pdf",
                    help="Path to the PDF (default: docs/Nutrionista balsamiq.pdf)")
    ap.add_argument("--page", type=int, help="Extract a single 1-indexed page")
    ap.add_argument("--pages", help="Comma-separated 1-indexed page list, e.g. 1,3,5")
    ap.add_argument("--format", choices=["markdown", "json"], default="markdown")
    ap.add_argument("--zone", choices=["left", "center", "right", "all"], default="all",
                    help="Which PDF zone(s) to include (default: all)")
    ap.add_argument("--html", default=DEFAULT_HTML_PATH,
                    help=f"Path to the HTML mockup (default: {DEFAULT_HTML_PATH})")
    ap.add_argument("--source", choices=["merged", "pdf", "html"], default="merged",
                    help="merged (default) joins PDF + HTML; pdf or html restrict to one side")
    args = ap.parse_args(argv)

    include_pdf = args.source in ("merged", "pdf")
    include_html = args.source in ("merged", "html")

    pdf_path = Path(args.pdf)
    if include_pdf and not pdf_path.exists():
        print(f"PDF not found: {pdf_path}", file=sys.stderr)
        return 1

    html_pages: dict | None = None
    if include_html:
        html_path = Path(args.html)
        if html_path.exists():
            html_pages = parse_html(html_path)
        else:
            print(f"warning: HTML not found at {html_path}; continuing PDF-only",
                  file=sys.stderr)
            include_html = False
            if args.source == "html":
                return 1

    doc = fitz.open(pdf_path)
    if args.page:
        indices = [args.page - 1]
    elif args.pages:
        indices = [int(p) - 1 for p in args.pages.split(",")]
    else:
        indices = list(range(doc.page_count))

    pages = []
    for i in indices:
        if 0 <= i < doc.page_count:
            pages.append(extract_page(doc[i], i, html_pages=html_pages if include_html else None))

    zones = {"left", "center", "right"} if args.zone == "all" else {args.zone}

    if args.format == "json":
        filtered = []
        for p in pages:
            obj = {"page": p["page"]}
            if include_pdf:
                if "left" in zones:
                    obj["sidebar"] = p["sidebar"]
                if "center" in zones:
                    obj["mockup"] = p["mockup"]
                    obj["images"] = p.get("images", [])
                if "right" in zones:
                    obj["metadata"] = p["metadata"]
            if include_html:
                obj["html_page_id"] = p.get("html_page_id")
                obj["html"] = p.get("html")
            filtered.append(obj)
        print(json.dumps(filtered, indent=2, ensure_ascii=False))
    else:
        print(render_markdown(pages, zones, include_html=include_html, include_pdf=include_pdf))
    return 0


if __name__ == "__main__":
    sys.exit(main())
