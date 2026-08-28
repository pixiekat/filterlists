#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/../pixiekat_list_for_mom_and_dad.txt"
TMPFILE=$(mktemp)

# Shared fetch/clean helpers - see lib/filterlist_helpers.sh for why upstream
# header blocks have to be stripped (Chromium uBO picks the LAST "! Title:").
source "$SCRIPT_DIR/../../lib/filterlist_helpers.sh"

# List of URLs to fetch
URLS=(
  "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Sensitive%20lists/AntiAstrologyList.txt"
  "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Pro-LED%20List.txt"
  "https://raw.githubusercontent.com/DandelionSprout/adfilt/refs/heads/master/Dandelion%20Sprout's%20Anti-Malware%20List.txt"
  "https://malware-filter.gitlab.io/malware-filter/phishing-filter.txt"
  "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
  "https://raw.githubusercontent.com/yokoffing/filterlists/refs/heads/main/enhanced_site_protection.txt"
  "https://github.com/DevSpen/scam-links/raw/refs/heads/master/src/trailing-slashes.txt"
  "https://github.com/DevSpen/scam-links/raw/refs/heads/master/src/malicious-terms.txt"
  "https://github.com/DevSpen/scam-links/raw/refs/heads/master/src/links.txt"
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
! Title: Pixiekat's Browser List for Mom & Dad
! Version: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
! Expires: 7 days
! Homepage: https://codeberg.org/pixiekat/filterlists
! Description: Pixiekat's Browser List for Mom & Dad
EOF

# 2) Sort only the rules and append under the header
#echo "Sorting list..."
#sort -u "$TMPFILE" >> "$OUTPUT"

echo "Removing duplicate rules while preserving order..."
dedupe_rules "$TMPFILE" >> "$OUTPUT"

echo "Removing temp file..."
rm "$TMPFILE"

echo "Merged allowlist written to $OUTPUT"
