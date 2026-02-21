#!/bin/bash

CRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/../pixiekat_list_for_mom_and_dad.txt"
TMPFILE=$(mktemp)

# List of URLs to fetch
URLS=(
  "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Sensitive%20lists/AntiAstrologyList.txt"
  "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Pro-LED%20List.txt"
  "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Dandelion%20Sprout's%20Anti-Malware%20List.txt"
  "https://malware-filter.gitlab.io/malware-filter/phishing-filter.txt"
  "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
)

for url in "${URLS[@]}"; do
  echo "Fetching $url..."
  curl -fsSL "$url" >> "$TMPFILE"
  echo "" >> "$TMPFILE"
done

# 1) Write metadata to OUTPUT (not to TMPFILE)
echo "Prepending metadata..."
cat <<EOF > "$OUTPUT"
! Title: Pixiekat's Browser List for Mom & Dad
! Version: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
! Expires: 7 days
! Homepage: https://codeberg.org/pixiekat/filterlists
! Description: Pixiekat's Browser List for Mom & Dad
EOF

# 2) Sort only the rules and append under the header
#echo "Sorting list..."
#sort -u "$TMPFILE" >> "$OUTPUT"

echo "Removing duplicates while preserving order..."
awk '!seen[$0]++' "$TMPFILE" >> "$OUTPUT"

echo "Removing temp file..."
rm "$TMPFILE"

echo "Merged allowlist written to $OUTPUT"
