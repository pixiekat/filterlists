#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/../pixiekat_mega_list_browser_extreme.txt"
TMPFILE=$(mktemp)

# List of whitelist URLs to fetch
URLS=(
  # whitelists
  # blocklists
  # cosmetic
  "https://codeberg.org/rossabaker/github-copilot-filters/raw/branch/main/filters.txt"
  "https://codeberg.org/rossabaker/github-copilot-filters/raw/branch/main/non-copilot-filters.txt"
  "https://github.com/taylr/linkedinsanity/raw/refs/heads/master/none-of-your-bezos.txt"
  "https://github.com/taylr/linkedinsanity/raw/refs/heads/master/good-sports.txt"
)

for url in "${URLS[@]}"; do
  echo "Fetching $url..."
  echo "" >> "$TMPFILE"
  echo "" >> "$TMPFILE"
  curl -fsSL "$url" >> "$TMPFILE"
  echo "" >> "$TMPFILE"
  echo "" >> "$TMPFILE"
done

# Strip only !#include lines (leave !#if, !#else, !#endif intact)
grep -v '^!#include' "$TMPFILE" > "${TMPFILE}.clean"
mv "${TMPFILE}.clean" "$TMPFILE"

# 1) Write metadata to OUTPUT (not to TMPFILE)
echo "Prepending metadata..."
cat <<EOF > "$OUTPUT"
! Title: Pixiekat's Mega List (Extreme Version 🥵)
! Version: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
! Expires: 7 days
! Homepage: https://codeberg.org/pixiekat/filterlists
! Description: Pixiekat's Mega List (Extreme Version 🥵)
EOF

echo "" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 2) Sort only the rules and append under the header
#echo "Sorting list..."
#sort -u "$TMPFILE" >> "$OUTPUT"

echo "Removing duplicates while preserving order..."
awk '!seen[$0]++' "$TMPFILE" >> "$OUTPUT"

echo "Removing temp file..."
rm "$TMPFILE"

echo "Merged allowlist written to $OUTPUT"
