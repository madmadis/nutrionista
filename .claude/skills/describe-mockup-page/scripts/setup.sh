#!/usr/bin/env bash
# Create the .venv for the describe-mockup-page skill and install dependencies.
# Run once after cloning the repo (or whenever the venv is missing).
set -euo pipefail
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
python3 -m venv "$SKILL_DIR/.venv"
"$SKILL_DIR/.venv/bin/pip" install --quiet --disable-pip-version-check pymupdf beautifulsoup4
echo "Setup complete. Test with:"
echo "  $SKILL_DIR/.venv/bin/python $SKILL_DIR/scripts/extract.py --page 1"
