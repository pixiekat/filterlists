#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/../merged_blocklist.txt"
TMPFILE=$(mktemp)

# Shared fetch/clean helpers - see lib/filterlist_helpers.sh for why upstream
# header blocks have to be stripped out of a merged list.
source "$SCRIPT_DIR/../../lib/filterlist_helpers.sh"

# List of whitelist URLs to fetch
URLS=(
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Sensitive%20lists/AntiPreacherList.txt"
)

for url in "${URLS[@]}"; do
  # Fetches, strips the upstream "! Title: ... ! Description: ..." block and
  # any !#include lines, then appends the rules under a plain credit comment.
  fetch_filterlist "$url" "$TMPFILE"
done

# Safety net: remove any list-level metadata that survived further down in a
# source file, so ours is the only "! Title:"/"! Expires:" in the merged output.
echo "Removing leftover upstream metadata..."
strip_list_metadata "$TMPFILE"

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

echo "Removing duplicate rules while preserving order..."
dedupe_rules "$TMPFILE" >> "$OUTPUT"

echo "Removing temp file..."
rm "$TMPFILE"

echo "Merged blocklist written to $OUTPUT"
