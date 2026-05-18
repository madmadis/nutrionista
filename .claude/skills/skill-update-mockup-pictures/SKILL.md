---
name: skill-update-mockup-pictures
description: Regenerates docs/mock/pictures/*.png from the Balsamiq PDF at docs/mock/nutrionista_balsamiq.pdf. Deletes all existing view-named PNGs in the pictures folder and renders fresh ones, one PNG per PDF page, named after the Vue view declared in each page's yellow-sticky metadata (e.g. "filename: LoginView.vue" → LoginView.png). Use when the user asks to refresh/update/regenerate the mockup screenshots, pictures, or PNGs, or invokes /skill-update-mockup-pictures.
---

# Update Mockup Pictures

Regenerates `docs/mock/pictures/*.png` from `docs/mock/nutrionista_balsamiq.pdf`.

## What the script does

1. **Reads view names from the PDF** — `pdftotext` scans the PDF in page order and extracts every `filename: XxxView.vue` line from the yellow-sticky metadata column on the right side of each page.
2. **Maps `???` to `OrderConfirmationView`** — page 10 carries `filename: ???.vue` (not yet annotated in the mockup); the script hard-maps it to `OrderConfirmationView`.
3. **Deletes all existing `*.png` files** in `docs/mock/pictures/`.
4. **Renders each page to PNG** with `pdftoppm -png -r 150` and saves it as `<ViewName>.png`.

## Page → PNG mapping (current PDF)

| Page | PNG file |
|------|----------|
| 1 | HomeView.png |
| 2 | LoginView.png |
| 3 | QuizView.png |
| 4 | ProfileView.png |
| 5 | WishlistView.png |
| 6 | ShopView.png |
| 7 | ProductDetailView.png |
| 8 | CartView.png |
| 9 | CheckoutView.png |
| 10 | OrderConfirmationView.png _(???.vue override)_ |
| 11 | OrderHistoryView.png |
| 12 | BlogView.png |
| 13 | ContactView.png |
| 14 | FaqView.png |

## How to run

```bash
bash .claude/skills/skill-update-mockup-pictures/scripts/update.sh
```

Optional arguments (all positional):

```bash
bash .claude/skills/skill-update-mockup-pictures/scripts/update.sh \
  <PDF_PATH> \
  <OUT_DIR> \
  <DPI>
```

| Argument | Default | Meaning |
|---|---|---|
| `PDF_PATH` | `docs/mock/nutrionista_balsamiq.pdf` | Source PDF |
| `OUT_DIR` | `docs/mock/pictures` | Destination folder |
| `DPI` | `150` | Render resolution (higher = larger files) |

### Example — default run

```bash
bash .claude/skills/skill-update-mockup-pictures/scripts/update.sh
```

### Example — higher resolution

```bash
bash .claude/skills/skill-update-mockup-pictures/scripts/update.sh \
  docs/mock/nutrionista_balsamiq.pdf \
  docs/mock/pictures \
  200
```

## Dependencies

| Tool | Package | Check |
|------|---------|-------|
| `pdftotext` | `poppler-utils` | `which pdftotext` |
| `pdftoppm` | `poppler-utils` | `which pdftoppm` |

Install if missing:

```bash
sudo apt install poppler-utils   # Debian / Ubuntu / WSL
brew install poppler             # macOS
```

## How Claude should invoke this skill

Run the script from the project root and stream output to the user:

```bash
bash .claude/skills/skill-update-mockup-pictures/scripts/update.sh
```

If the script exits 0, confirm how many PNGs were written and list them.
If it exits non-zero, show the error message and suggest installing `poppler-utils`.

## When the output looks wrong

- **"no 'filename:' entries found"** — wrong PDF path, or the PDF structure changed. Verify `pdftotext -layout <pdf> - | grep filename:`.
- **A page renders as a blank/tiny PNG** — `pdftoppm` needs at least poppler 0.59. Run `pdftoppm --version`.
- **A view is named wrong** — the yellow-sticky `filename:` annotation in the PDF changed. Re-run; the script always re-reads names live from the PDF.
- **Page 10 should have a real name now** — update the `???` guard in `scripts/update.sh` (the `if [[ "$stripped" == "???" ...` block) to map the new filename instead.