#!/usr/bin/env python3
"""Parse the Balsamiq HTML mockup into per-Alpine-page structure.

Each Balsamiq HTML page is a `<div x-show="page === 'X'">` block. For every
such block we emit:
  - `structure`     : flat outline of meaningful elements with depth/kind/text
  - `nav_edges`     : Alpine click handlers resolved to destination page ids
  - `form_fields`   : inputs/textareas/selects with type, name, placeholder, label

The structural outline keeps pure-layout `<div>`/`<span>` transparent (we
recurse through them without adding a level) but surfaces semantic tags:
header/nav/main/section/footer, h1-h4, p, button, a, label, input, textarea,
select, ul/ol, li, option. Two cosmetic conventions used in this mockup are
also surfaced: clickable card divs (recorded as `via=card` in nav_edges) and
image-placeholder divs styled `bg-gray-*` (rendered as `kind=img_placeholder`).
"""
from __future__ import annotations

import re
from pathlib import Path

from bs4 import BeautifulSoup, NavigableString, Tag

PAGE_ID_RE = re.compile(r"page === '([^']+)'")
CLICK_RE = re.compile(r"page\s*=\s*'([^']+)'")
XMODEL_FORMDATA_RE = re.compile(r"formData\['([^']+)'\]")

LEAF_TAGS = {"h1", "h2", "h3", "h4", "p", "button", "a", "label",
             "input", "textarea", "li", "option", "img"}


def _text_of(el: Tag) -> str:
    """Visible text, but skip `<span class="material-symbols-outlined">`
    contents — those are icon glyph names ("shopping_cart") that would
    otherwise contaminate adjacent button/link labels."""
    if not isinstance(el, Tag):
        return ""
    parts: list[str] = []
    for desc in el.descendants:
        if isinstance(desc, NavigableString):
            if isinstance(desc.parent, Tag):
                cls = desc.parent.get("class") or []
                if "material-symbols-outlined" in cls:
                    continue
            parts.append(str(desc))
    return re.sub(r"\s+", " ", " ".join(parts)).strip()


def _click_target(el: Tag) -> str | None:
    for attr in ("@click", "@click.prevent", "x-on:click", "x-on:click.prevent"):
        val = el.attrs.get(attr)
        if not val:
            continue
        m = CLICK_RE.search(val)
        if m:
            return m.group(1)
    return None


def _x_model_name(val: str) -> str:
    m = XMODEL_FORMDATA_RE.search(val or "")
    return m.group(1) if m else (val or "")


def _is_image_placeholder(el: Tag) -> bool:
    """Balsamiq-style gray-fill image placeholder: a div whose class list
    starts with `bg-gray-` and that contains only short text (the alt label)."""
    if el.name != "div":
        return False
    classes = el.get("class") or []
    if not any(c.startswith("bg-gray") for c in classes):
        return False
    txt = _text_of(el)
    return 0 < len(txt) <= 80 and not el.find(["h1", "h2", "h3", "h4", "p", "button"])


def parse_html(path: str | Path) -> dict[str, dict]:
    soup = BeautifulSoup(Path(path).read_text(encoding="utf-8"), "html.parser")
    pages: dict[str, dict] = {}
    for div in soup.find_all("div", attrs={"x-show": True}):
        m = PAGE_ID_RE.search(div.get("x-show", ""))
        if not m:
            continue
        page_id = m.group(1)
        pages[page_id] = _parse_page(div, page_id)
    return pages


def _parse_page(root: Tag, page_id: str) -> dict:
    state = {
        "structure": [],
        "nav_edges": [],
        "form_fields": [],
        "last_label": None,
    }
    _walk(root, depth=0, in_nav=False, in_header=False, in_footer=False, state=state)
    state.pop("last_label", None)
    state["page_id"] = page_id
    return state


def _record_edge(node: Tag, target: str, in_nav: bool, in_header: bool, in_footer: bool, state):
    tag = node.name
    if in_nav:
        via = "nav"
    elif tag == "button":
        via = "button"
    elif tag == "a":
        via = "link"
    elif tag in ("div", "section"):
        via = "card"
    elif tag == "span" and (in_header or in_footer):
        via = "logo"
    else:
        via = tag

    if tag in ("a", "button", "span"):
        label = _text_of(node)
    else:
        heading = node.find(["h1", "h2", "h3", "h4"])
        label = _text_of(heading) if heading else _text_of(node)
        if len(label) > 60:
            label = label[:60].rstrip() + "…"

    state["nav_edges"].append({
        "label": label,
        "target": target,
        "via": via,
        "control_id": node.get("data-control-id"),
    })


def _walk(node, depth, in_nav, in_header, in_footer, state):
    if not isinstance(node, Tag):
        return

    tag = node.name
    structure = state["structure"]

    target = _click_target(node)
    if target:
        _record_edge(node, target, in_nav, in_header, in_footer, state)

    # Image placeholder shortcut — emit and stop
    if _is_image_placeholder(node):
        structure.append({
            "depth": depth,
            "kind": "img_placeholder",
            "text": _text_of(node),
            "control_id": node.get("data-control-id"),
        })
        return

    next_depth = depth
    is_leaf = False

    if tag in ("header", "nav", "main", "section", "footer", "form", "ul", "ol"):
        entry = {"depth": depth, "kind": tag}
        if tag in ("ul", "ol"):
            entry["count"] = len(node.find_all("li", recursive=False))
        structure.append(entry)
        next_depth = depth + 1
    elif tag in ("h1", "h2", "h3", "h4", "p", "li"):
        structure.append({
            "depth": depth, "kind": tag, "text": _text_of(node),
            "control_id": node.get("data-control-id"),
        })
        is_leaf = True
    elif tag in ("button", "a"):
        entry = {
            "depth": depth, "kind": tag, "text": _text_of(node),
            "control_id": node.get("data-control-id"),
        }
        if target:
            entry["target"] = target
        structure.append(entry)
        is_leaf = True
    elif tag == "label":
        text = _text_of(node)
        state["last_label"] = text
        # A <label> often wraps an <input>; recurse so the input is still seen
        structure.append({
            "depth": depth, "kind": "label", "text": text,
            "control_id": node.get("data-control-id"),
        })
        next_depth = depth + 1
    elif tag in ("input", "textarea", "select"):
        field = {
            "type": node.get("type", tag),
            "name": _x_model_name(node.get("x-model", "")) or node.get("name", ""),
            "placeholder": node.get("placeholder", ""),
            "label": state.get("last_label"),
            "control_id": node.get("data-control-id"),
        }
        state["form_fields"].append(field)
        structure.append({"depth": depth, "kind": "input", **field})
        is_leaf = True
    elif tag == "option":
        structure.append({"depth": depth, "kind": "option", "text": _text_of(node)})
        is_leaf = True

    if is_leaf:
        return

    if tag == "nav":
        in_nav = True
    if tag == "header":
        in_header = True
    if tag == "footer":
        in_footer = True

    for child in node.children:
        _walk(child, next_depth, in_nav, in_header, in_footer, state)


if __name__ == "__main__":
    import json
    import sys
    path = sys.argv[1] if len(sys.argv) > 1 else "docs/madis/nutrionista-mockup.html"
    print(json.dumps(parse_html(path), indent=2, ensure_ascii=False))
