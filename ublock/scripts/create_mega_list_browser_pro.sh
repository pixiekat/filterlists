#!/bin/bash

OUTPUT="../pixiekat_mega_list_browser_pro.txt"
TMPFILE=$(mktemp)

# List of whitelist URLs to fetch
URLS=(
  # whitelists
  "https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/adblock/spam-tlds-adblock-allow.txt"
  # blocklists
  "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/adblock/spam-tlds-ublock.txt"
  "https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/adguard.txt"
  "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/stayingonbrowser/Staying%20On%20The%20Phone%20Browser"
  # cosmetic
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Imperial%20Units%20Remover.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/EmptyPaddingRemover.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Dandelion%20Sprout's%20Website%20Stretcher.txt"
  "https://github.com/taylr/linkedinsanity/raw/refs/heads/master/fi-nuance.txt"
  "https://raw.githubusercontent.com/taylr/linkedinsanity/refs/heads/master/linkedinsanity.txt"
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
! Title: Pixiekat's Mega List (Extended and Paranoid)
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
