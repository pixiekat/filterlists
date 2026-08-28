#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/../merged_allowlist.txt"
TMPFILE=$(mktemp)

# Shared fetch/clean helpers - see lib/filterlist_helpers.sh for why upstream
# header blocks have to be stripped out of a merged list.
source "$SCRIPT_DIR/../../lib/filterlist_helpers.sh"

# List of whitelist URLs to fetch
URLS=(
  "https://badblock.celenity.dev/abp/android_whitelist.txt"
  "https://badblock.celenity.dev/abp/apple_whitelist.txt"
  "https://badblock.celenity.dev/abp/browser_whitelist.txt"
  "https://badblock.celenity.dev/abp/captive_whitelist.txt"
  "https://badblock.celenity.dev/abp/certs_whitelist.txt"
  "https://badblock.celenity.dev/abp/emergency_whitelist.txt"
  "https://badblock.celenity.dev/abp/ethical_whitelist.txt"
  "https://badblock.celenity.dev/abp/lan_whitelist.txt"
  "https://badblock.celenity.dev/abp/linux_whitelist.txt"
  "https://badblock.celenity.dev/abp/microsoft_whitelist.txt"
  "https://badblock.celenity.dev/abp/misc_whitelist.txt"
  "https://badblock.celenity.dev/abp/mobile_whitelist.txt"
  "https://badblock.celenity.dev/abp/mozilla_whitelist.txt"
  "https://badblock.celenity.dev/abp/nintendo_whitelist.txt"
  "https://badblock.celenity.dev/abp/push_whitelist.txt"
  "https://badblock.celenity.dev/abp/safe-browsing_whitelist.txt"
  "https://badblock.celenity.dev/abp/time_whitelist.txt"
  #https://badblock.celenity.dev/abp/captcha_whitelist.txt"
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
! Title: Pixiekat's Mega White List (Router)
! Version: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
! Expires: 7 days
! Homepage: https://codeberg.org/pixiekat/filterlists
! Description: Pixiekat's merged allowlist for AdGuard Home
EOF

# 2) Sort only the rules and append under the header
#echo "Sorting list..."
#sort -u "$TMPFILE" >> "$OUTPUT"

echo "Removing duplicate rules while preserving order..."
dedupe_rules "$TMPFILE" >> "$OUTPUT"

echo "Removing temp file..."
rm "$TMPFILE"

echo "Merged allowlist written to $OUTPUT"
