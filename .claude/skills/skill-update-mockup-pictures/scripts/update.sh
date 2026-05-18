#!/usr/bin/env bash
# Regenerates docs/mock/pictures/*.png from docs/mock/nutrionista_balsamiq.pdf.
# Each PNG is named after the Vue view found in the PDF's yellow-sticky metadata
# (e.g. "filename: LoginView.vue" → LoginView.png).
# Page 10 carries "filename: ???.vue" — mapped to OrderConfirmationView.

set -euo pipefail

PDF="${1:-docs/mock/nutrionista_balsamiq.pdf}"
OUT_DIR="${2:-docs/mock/pictures}"
DPI="${3:-150}"

# ── 1. Verify dependencies ────────────────────────────────────────────────────
for cmd in pdftotext pdftoppm; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' not found. Install poppler-utils." >&2
    exit 1
  fi
done

if [[ ! -f "$PDF" ]]; then
  echo "ERROR: PDF not found at '$PDF'" >&2
  exit 1
fi

# ── 2. Extract view names in page order ──────────────────────────────────────
# pdftotext emits "filename: XxxView.vue" lines in the order they appear in
# the PDF, which matches the visual page order.
mapfile -t raw_names < <(
  pdftotext -layout "$PDF" - | grep -oP '(?<=filename: )\S+'
)

if [[ ${#raw_names[@]} -eq 0 ]]; then
  echo "ERROR: no 'filename:' entries found in PDF — wrong file?" >&2
  exit 1
fi

# Strip .vue, map ??? to OrderConfirmationView
declare -a view_names=()
for name in "${raw_names[@]}"; do
  stripped="${name%.vue}"
  if [[ "$stripped" == "???" || "$stripped" == "?" ]]; then
    view_names+=("OrderConfirmationView")
  else
    view_names+=("$stripped")
  fi
done

echo "Found ${#view_names[@]} pages in PDF:"
for i in "${!view_names[@]}"; do
  printf "  Page %2d → %s\n" "$((i+1))" "${view_names[$i]}"
done
echo ""

# ── 3. Clear output directory ─────────────────────────────────────────────────
mkdir -p "$OUT_DIR"
old_count=$(find "$OUT_DIR" -maxdepth 1 -name "*.png" | wc -l)
find "$OUT_DIR" -maxdepth 1 -name "*.png" -delete
echo "Deleted $old_count existing PNG(s) from $OUT_DIR/"

# ── 4. Render each page ───────────────────────────────────────────────────────
TMPDIR_WORK=$(mktemp -d)
trap 'rm -rf "$TMPDIR_WORK"' EXIT

total="${#view_names[@]}"
for ((i = 0; i < total; i++)); do
  page=$((i + 1))
  name="${view_names[$i]}"

  pdftoppm -png -r "$DPI" -f "$page" -l "$page" "$PDF" "$TMPDIR_WORK/p"

  src=$(ls "$TMPDIR_WORK"/p-*.png 2>/dev/null | head -1)
  if [[ -z "$src" ]]; then
    echo "WARNING: pdftoppm produced no output for page $page" >&2
    continue
  fi

  mv "$src" "$OUT_DIR/${name}.png"
  echo "  Page $page → ${name}.png"
done

echo ""
echo "Done — $total PNG(s) written to $OUT_DIR/"
