#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/../pixiekat_mega_list_browser.txt"
TMPFILE=$(mktemp)

# Shared fetch/clean helpers - see lib/filterlist_helpers.sh for why upstream
# header blocks have to be stripped (Chromium uBO picks the LAST "! Title:").
source "$SCRIPT_DIR/../../lib/filterlist_helpers.sh"

# List of whitelist URLs to fetch
URLS=(
  # whitelists
  "https://badblock.celenity.dev/abp/click-tracking_whitelist.txt"
  # blocklists
  "https://badblock.celenity.dev/abp/amazon.txt"
  "https://badblock.celenity.dev/abp/apple.txt"
  "https://badblock.celenity.dev/abp/brave.txt"
  "https://badblock.celenity.dev/abp/data-brokers.txt"
  "https://badblock.celenity.dev/abp/drm.txt"
  "https://badblock.celenity.dev/abp/facebook.txt"
  "https://badblock.celenity.dev/abp/gaming.txt"
  "https://badblock.celenity.dev/abp/google.txt"
  "https://badblock.celenity.dev/abp/microsoft.txt"
  "https://badblock.celenity.dev/abp/monitoring.txt"
  "https://badblock.celenity.dev/abp/radar.txt"
  "https://badblock.celenity.dev/abp/tiktok.txt"
  "https://badblock.celenity.dev/abp/twitter.txt"
  "https://badblock.celenity.dev/abp/unsafe.txt"
  "https://raw.githubusercontent.com/hoshsadiq/adblock-nocoin-list/master/nocoin.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/AntiRacismList.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/AntiPepeList.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Sensitive%20lists/SayNoToRacismOnTwitch.txt"
  # cosmetic
  "https://badblock.celenity.dev/abp/annoyances.txt"
  "https://raw.githubusercontent.com/cpeterso/clickbait-blocklist/master/clickbait-blocklist.txt"
  "https://codeberg.org/celenity/BadBlock/raw/branch/pages/abp/crap.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/StopAutoplayOnYouTube.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/RedditTrashRemovalService.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/SocialShareList.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/RickrollLinkIdentifier.txt"
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
! Title: Pixiekat's Mega List
! Version: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
! Expires: 7 days
! Homepage: https://codeberg.org/pixiekat/filterlists
! Description: Pixiekat's Mega List
EOF

echo "" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 2) Sort only the rules and append under the header
#echo "Sorting list..."
#sort -u "$TMPFILE" >> "$OUTPUT"

echo "Removing duplicate rules while preserving order..."
dedupe_rules "$TMPFILE" >> "$OUTPUT"

echo "Removing temp file..."
rm "$TMPFILE"

echo "Merged allowlist written to $OUTPUT"
