#!/bin/bash

OUTPUT="../pixiekat_mega_list_browser.txt"
TMPFILE=$(mktemp)

# List of whitelist URLs to fetch
URLS=(
  # whitelists
  "https://badblock.celenity.dev/abp/click-tracking_whitelist.txt"
  # blocklists
  "https://badblock.celenity.dev/abp/brave.txt"
  "https://badblock.celenity.dev/abp/data-brokers.txt"
  "https://badblock.celenity.dev/abp/drm.txt"
  "https://badblock.celenity.dev/abp/radar.txt"
  "https://badblock.celenity.dev/abp/unsafe.txt"
  # cosmetic
  "https://codeberg.org/celenity/BadBlock/raw/branch/pages/abp/crap.txt"
)

for url in "${URLS[@]}"; do
  echo "Fetching $url..."
  echo "" >> "$TMPFILE"
  echo "" >> "$TMPFILE"
  curl -fsSL "$url" >> "$TMPFILE"
  echo "" >> "$TMPFILE"
  echo "" >> "$TMPFILE"
done

# 1) Write metadata to OUTPUT (not to TMPFILE)
echo "Prepending metadata..."
cat <<EOF > "$OUTPUT"
! Title: Pixiekat's Mega List
! Version: $(date -u +"%d%b%Yv1")
! Expires: 7 days
! Homepage: https://codeberg.org/pixiekat/filterlists
! Description: Pixiekat's Mega List
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
