---
name: describe-mockup-page
description: Describes a Nutrionista mockup screen by merging two sources — the Balsamiq PDF at docs/Nutrionista balsamiq.pdf (Estonian sidebar, wireframe text, image placeholders, and yellow-sticky metadata with filename/url/API/DTO/Response/Veateated) and the Balsamiq HTML at docs/madis/nutrionista-mockup.html (semantic structure, resolved nav edges from Alpine `@click="page = '...'"`, and form fields with labels/types/placeholders). Use when the user asks about the mockup, what's on a specific page, what a screen looks like, which Vue filename/URL/API a screen maps to, where a given button navigates, or what form fields a screen has. Outputs markdown by default, JSON on request. Pages can be filtered by number; PDF zones can be filtered to one of left/center/right/all; the source can be restricted to pdf-only or html-only.
---

# Describe Mockup Page — Nutrionista

A merged view of each Nutrionista screen. Two sources contribute per page:

## Source 1: the Balsamiq PDF (`docs/Nutrionista balsamiq.pdf`)

Each page is laid out in three zones:

```
┌───────┬─────────────────────────────────────┬─────────────────────┐
│ left  │            CENTER MOCKUP            │  RIGHT METADATA     │
│       │   (the actual UI wireframe — nav,   │  (yellow stickies)  │
│ Page  │    buttons, form fields, prices,    │                     │
│ name  │    product cards, footer, etc.)     │  LABEL              │
│  +    │                                     │  filename: ...      │
│ short │                                     │  url:      ...      │
│ Esto- │                                     │  API:      ...      │
│ nian  │                                     │  DTO:      ...      │
│ desc. │                                     │  Response: ...      │
│       │                                     │  Veateated: ...     │
└───────┴─────────────────────────────────────┴─────────────────────┘
   x<60      (right boundary varies per page)
```

The right column starts at a different x-coordinate on every page (observed range: x=503 on Checkout up to x=683 on Login). The script anchors it dynamically by finding the leftmost block that contains a `filename:`/`url:`/`API:`/`DTO:`/`Response:`/`Veateated:` line and backing off 10pt so the all-caps page label above also lands in the right zone. The left zone uses a fixed `x < 60` threshold.

Per-zone parsing:

- **left** — first vertically-contiguous group of lines is the title; everything after a y-gap is the description.
- **center** — emitted as an ordered list of text lines in reading order (top-to-bottom, left-to-right). Also emits a separate **Image placeholders** list. The reliable signal for an image placeholder is the **X-cross diagonals** Balsamiq draws inside the box (a `type="fs"`, dark-stroked drawing with exactly two line segments and `max(width, height) ≥ 30`). For each X-cross we then find the largest enclosing rectangle (`re` or rounded `l/c` outline) whose area is 1.5–20× the diagonals' bbox — that range filters out both the X-cross's own near-coincident sibling rect and the full mockup canvas. The reported bbox matches the visible card; each placeholder is paired with the nearest text label horizontally aligned with it within ~80pt vertically (typically the product name on a product card).
- **right** — first non-key line is the page label (e.g. `LANDING PAGE/HOME`); everything else is key/value pairs for `filename`, `url`, `API`, `DTO`, `Response`, `Veateated` (multi-line values are kept verbatim, so JSON bodies and error lists stay readable).

## Source 2: the Balsamiq HTML (`docs/madis/nutrionista-mockup.html`)

Each Alpine page is a `<div x-show="page === 'X'">` block. For every such block we emit:

- **Structure** — semantic outline of meaningful elements with depth/kind/text. Surfaced tags: `header`, `nav`, `main`, `section`, `footer`, `form`, `h1`–`h4`, `p`, `li`, `button`, `a`, `label`, `input`, `textarea`, `select`, `ul`/`ol`, `option`. Pure layout `<div>`/`<span>` are transparent — recursed through without adding a level. Two mockup conventions are also surfaced: clickable card divs (recorded as `via=card` in nav_edges) and image-placeholder divs styled `bg-gray-*` (rendered as `kind=img_placeholder`). Material-symbols icon glyph names are filtered out of button/link text.
- **Navigation (out)** — every `@click[.prevent]="page = 'X'"` resolved to a destination Alpine id. Each edge records `via` (one of `nav`, `button`, `link`, `card`, `logo`) and the triggering element's visible label.
- **Form fields** — `<input>`/`<textarea>`/`<select>` with `type`, `name` (from `name=` or extracted from `x-model="formData['…']"`), `placeholder`, and the nearest preceding `<label>` text.

## The join

PDF pages → HTML page blocks are joined on PDF `filename` → Alpine page id:

- Rule: strip trailing `View.vue`, convert CamelCase to snake_case, lowercase. (`LoginView.vue` → `login`, `OrderHistoryView.vue` → `order_history`.)
- Overrides for the two cases the rule can't handle:
  - `HomeView.vue` → `main` (the Alpine app starts on `main`)
  - PDF page 10 (annotated `???.vue`, no filename yet) → `confirmation`

All 14 PDF pages currently map to all 14 HTML page ids.

## How to run

```bash
.claude/skills/describe-mockup-page/.venv/bin/python \
  .claude/skills/describe-mockup-page/scripts/extract.py [options]
```

If `.venv` is missing (fresh clone), recreate it:

```bash
bash .claude/skills/describe-mockup-page/scripts/setup.sh
```

### Options

| Flag | Default | Meaning |
|---|---|---|
| `PDF_PATH` (positional) | `docs/Nutrionista balsamiq.pdf` | PDF to read |
| `--page N` | (all pages) | Extract one 1-indexed page |
| `--pages 1,3,5` | (all pages) | Extract specific 1-indexed pages |
| `--format markdown\|json` | `markdown` | Output format |
| `--zone left\|center\|right\|all` | `all` | Restrict PDF zone(s) |
| `--html PATH` | `docs/madis/nutrionista-mockup.html` | HTML mockup to read |
| `--source merged\|pdf\|html` | `merged` | Restrict to one side (default merges both) |

### Common invocations

```bash
# All pages, fully merged (default)
.../extract.py

# One page, fully merged
.../extract.py --page 4

# Just the PDF metadata stickies for pages 2 and 6, as JSON
.../extract.py --pages 2,6 --zone right --source pdf --format json

# HTML-only — semantic structure + nav graph for one page
.../extract.py --page 1 --source html
```

## When the output looks wrong

- **Right metadata says `???`** — the user hasn't annotated that page yet (page 10 today; the override still picks the right HTML block). The left sidebar will also be missing, and the script may bleed mockup nav/footer into the left zone. This is an annotation-coverage gap, not a parser bug.
- **Title has a stray space mid-word** (e.g. `Sisselogimine/R egistreerimine`) — Balsamiq wraps long titles into two PDF text blocks; the script can't tell that the wrap is mid-word. The right-side `label` is canonical when this matters.
- **`Structure (HTML): _(no HTML match for this page)_`** — the filename rule produced an id that doesn't exist in the HTML. Either the filename is misspelled in the PDF or a new HTML page id needs a `FILENAME_OVERRIDES`/`PAGE_OVERRIDES` entry in `extract.py`.
- **Mockup lines have trailing spaces** — preserved from the PDF text blocks intentionally; trim downstream if needed.
