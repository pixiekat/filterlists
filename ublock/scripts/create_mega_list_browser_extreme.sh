#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$SCRIPT_DIR/../pixiekat_mega_list_browser_extreme.txt"
TMPFILE=$(mktemp)

# Shared fetch/clean helpers - see lib/filterlist_helpers.sh for why upstream
# header blocks have to be stripped (Chromium uBO picks the LAST "! Title:").
source "$SCRIPT_DIR/../../lib/filterlist_helpers.sh"

# List of whitelist URLs to fetch
URLS=(
  # whitelists
  # blocklists
  # cosmetic
  "https://codeberg.org/rossabaker/github-copilot-filters/raw/branch/main/filters.txt"
  "https://codeberg.org/rossabaker/github-copilot-filters/raw/branch/main/non-copilot-filters.txt"
  "https://github.com/Stevoisiak/Stevos-AI-Blocklist/raw/refs/heads/main/GenAI-Blocklist-Extra.txt"
  "https://github.com/taylr/linkedinsanity/raw/refs/heads/master/none-of-your-bezos.txt"
  "https://github.com/taylr/linkedinsanity/raw/refs/heads/master/good-sports.txt"
  "https://raw.githubusercontent.com/kowith337/PersonalFilterListCollection/master/filterlist/specific/AntiAPKMirrorCountdown.txt"
  #"https://raw.githubusercontent.com/WhyIsEvery4thYearAlwaysBad/anti-cancer-filter-lists/master/anti_trash_youtube.txt"
  "https://tetrax-10.github.io/imdb-clean-as-fuck/imdb-clean-as-fuck-with-better-styles.txt"
  "https://raw.githubusercontent.com/yokoffing/filterlists/refs/heads/main/adult_annoyance_list.txt"
  "https://raw.githubusercontent.com/yokoffing/filterlists/refs/heads/main/clean_reading_experience.txt"
  "https://github.com/yokoffing/filterlists/raw/refs/heads/main/privacy_essentials.txt"
  # cosmetic
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Imperial%20Units%20Remover.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/EmptyPaddingRemover.txt"
  "https://github.com/DandelionSprout/adfilt/raw/refs/heads/master/Dandelion%20Sprout's%20Website%20Stretcher.txt"
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

echo "Removing duplicate rules while preserving order..."
dedupe_rules "$TMPFILE" >> "$OUTPUT"

echo "Removing temp file..."
rm "$TMPFILE"

echo "Merged allowlist written to $OUTPUT"
