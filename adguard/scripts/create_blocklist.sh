#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/../merged_blocklist.txt"
TMPFILE=$(mktemp)

# List of whitelist URLs to fetch
URLS=(
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Sensitive%20lists/AntiPreacherList.txt"
)

for url in "${URLS[@]}"; do
  echo "Fetching $url..."
  curl -fsSL "$url" >> "$TMPFILE"
  echo "" >> "$TMPFILE"
done

# Strip only !#include lines (leave !#if, !#else, !#endif intact)
grep -v '^!#include' "$TMPFILE" > "${TMPFILE}.clean"
mv "${TMPFILE}.clean" "$TMPFILE"

# 1) Write metadata to OUTPUT (not to TMPFILE)
echo "Prepending metadata..."
cat <<EOF > "$OUTPUT"
! Title: Pixiekat's Mega Block List (Router)
! Version: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
! Expires: 7 days
! Homepage: https://codeberg.org/pixiekat/filterlists
! Description: Pixiekat's merged blocklist for AdGuard Home
EOF

# 2) Sort only the rules and append under the header
#echo "Sorting list..."
#sort -u "$TMPFILE" >> "$OUTPUT"

echo "Removing duplicates while preserving order..."
awk '!seen[$0]++' "$TMPFILE" >> "$OUTPUT"

echo "Removing temp file..."
rm "$TMPFILE"

echo "Merged blocklist written to $OUTPUT"
