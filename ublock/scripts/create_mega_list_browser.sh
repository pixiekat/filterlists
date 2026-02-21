#!/bin/bash

OUTPUT="../pixiekat_mega_list_browser.txt"
TMPFILE=$(mktemp)

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
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Sensitive%20lists/AntiPreacherList.txt"
  # cosmetic
  "https://badblock.celenity.dev/abp/annoyances.txt"
  "https://raw.githubusercontent.com/cpeterso/clickbait-blocklist/master/clickbait-blocklist.txt"
  "https://codeberg.org/celenity/BadBlock/raw/branch/pages/abp/crap.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/StopAutoplayOnYouTube.txt"
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
