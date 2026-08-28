#!/bin/bash
# ---------------------------------------------------------------------------
# filterlist_helpers.sh
#
# Shared helpers for every merge script in this repo
# (adguard/scripts/*.sh and ublock/scripts/*.sh).
#
# WHY THIS EXISTS
# ---------------
# A filter list file can carry "list metadata" in its leading comment block:
#
#     [Adblock Plus 3.13]
#     ! Title: Somebody's Great List
#     ! Expires: 1 day
#     ! Homepage: https://example.invalid/
#     ! Description: ...
#
# When we naively cat several upstream lists together, ALL of those metadata
# blocks end up inside our merged file. Blockers disagree about which one wins:
#
#   * uBO on Firefox happens to keep the FIRST "! Title:" it sees, which is
#     ours, so the list looks correct there.
#   * uBO on Chromium builds (Vivaldi, Chrome, Edge, Brave...) ends up showing
#     the LAST "! Title:" in the file, so our list gets named after whichever
#     upstream list happened to be merged last.
#
# The same ambiguity applies to "! Expires:" (an upstream "1 day" could make
# every subscriber re-download us daily) and, much worse, to "! Redirect:"
# (a parser that honours it would swap our whole list out for someone else's).
#
# The fix is to stop shipping other people's metadata at all: strip each
# upstream header block on the way in, and replace it with a plain,
# non-metadata comment that credits the list by name and URL.
#
# Usage from a merge script (which lives one level down, in */scripts/):
#
#     source "$SCRIPT_DIR/../../lib/filterlist_helpers.sh"
#     fetch_filterlist "$url" "$TMPFILE"      # per source, appends to TMPFILE
#     strip_list_metadata "$TMPFILE"          # safety net before writing OUTPUT
#     dedupe_rules "$TMPFILE" >> "$OUTPUT"    # drop repeated rules, keep layout
# ---------------------------------------------------------------------------

# Metadata keys that a blocker actually interprets as describing the list as a
# whole. Deliberately narrow: keys like "! Source:" or "! License:" are often
# used mid-list as plain attribution and are harmless, so they are left alone
# outside the header block.
#
# Matching is case-insensitive at the call sites, because upstream lists are
# inconsistent about "Last modified" vs "Last Modified".
FILTERLIST_META_KEYS='Title|Description|Expires|Homepage|Redirect|Version|Last[ -]modified|Last[ -]updated|Diff-Path|Diff-Expires|Diff-Name|Checksum'

# ---------------------------------------------------------------------------
# read_meta_value <file> <key-regex>
#
# Echo the value of the first "! Key: value" line in <file>, or nothing if the
# key is absent. Used to build the credit banner before we throw the header
# away.
# ---------------------------------------------------------------------------
read_meta_value() {
  local file="$1" key="$2"

  # -m1 stops at the first hit; the sed strips "! Key:" and any padding, and
  # the trailing sed drops carriage returns from CRLF-formatted upstreams.
  grep -m1 -iE "^![[:space:]]*(${key})[[:space:]]*:" "$file" \
    | sed -E "s/^![[:space:]]*(${key})[[:space:]]*:[[:space:]]*//I" \
    | tr -d '\r'
}

# ---------------------------------------------------------------------------
# strip_source_header <file>
#
# Print <file> to stdout with its leading metadata/header block removed.
#
# The rule: starting at the top of the file, drop comment lines and blank lines
# until we reach something that is clearly list *content*. The header ends at
# the first of:
#
#   * a real filter rule (any line that is not a comment and not blank),
#   * a "!#" preprocessor directive (!#if / !#else / !#endif) - that is logic,
#     not metadata, and uBO needs it kept in place,
#   * a "!!" comment - by convention in these lists that is a section heading
#     ("!! LinkedIn"), i.e. the author has moved on from the header.
#
# Everything after the header is passed through completely untouched, so
# mid-file comments, section headings and rules all survive.
# ---------------------------------------------------------------------------
strip_source_header() {
  awk '
    BEGIN { in_header = 1 }

    # Past the header: pass everything through verbatim.
    !in_header { print; next }

    # --- still inside the leading header block -------------------------
    # Syntax markers like "[Adblock Plus 3.13]". Only the one at the very top
    # of the merged file is meaningful, and that one is ours, so drop these.
    /^[ \t]*\[[Aa]dblock/ { next }

    # Preprocessor directives are real behaviour - keep them and stop stripping.
    /^!#/ { in_header = 0; print; next }

    # "!!" section headings mean the header is over. Keep and stop stripping.
    /^!!/ { in_header = 0; print; next }

    # Any other comment inside the header block is metadata or boilerplate.
    /^[ \t]*!/ { next }

    # Blank padding inside the header block.
    /^[ \t]*$/ { next }

    # First real filter rule: the header is over.
    { in_header = 0; print }
  ' "$1"
}

# ---------------------------------------------------------------------------
# fetch_filterlist <url> <destination>
#
# Download one upstream list, strip its header block and "!#include" lines,
# and append a credited copy to <destination>.
#
# The credit banner deliberately uses wording that is NOT a recognised metadata
# key ("Source list:", "Provided by:", "Fetched from:") so that no blocker
# mistakes it for our own list's Title/Homepage.
# ---------------------------------------------------------------------------
fetch_filterlist() {
  local url="$1" dest="$2"
  local raw title homepage

  raw=$(mktemp)

  echo "Fetching $url..."
  if ! curl -fsSL "$url" > "$raw"; then
    echo "  !! WARNING: fetch failed, skipping $url" >&2
    rm -f "$raw"
    return 1
  fi

  # Pull the credit details out before the header is discarded.
  title=$(read_meta_value "$raw" 'Title')
  homepage=$(read_meta_value "$raw" 'Homepage')
  [ -z "$title" ] && title="(untitled upstream list)"

  {
    echo ""
    echo "! ==========================================================================="
    echo "! Source list: $title"
    [ -n "$homepage" ] && echo "! Provided by: $homepage"
    echo "! Fetched from: $url"
    echo "! Upstream header removed on merge; all credit to the original author."
    echo "! ==========================================================================="
  } >> "$dest"

  # Strip the header block, then drop "!#include" lines (we cannot resolve the
  # relative paths they point at). "!#if"/"!#else"/"!#endif" are left alone.
  strip_source_header "$raw" | grep -v '^!#include' >> "$dest"

  echo "" >> "$dest"

  rm -f "$raw"
}

# ---------------------------------------------------------------------------
# strip_list_metadata <file>
#
# Safety net, run once over the merged body just before it is appended under
# our own header.
#
# strip_source_header only cleans the TOP of each upstream file. If a list
# repeats its metadata further down (some do, after a "!#endif" block, or
# because two lists were concatenated upstream), that stray "! Title:" would
# still be the last one in our merged file and Chromium uBO would show it.
# This pass removes those leftovers wherever they are.
#
# Our own header is written straight to OUTPUT and never passes through here,
# so it is not at risk.
# ---------------------------------------------------------------------------
strip_list_metadata() {
  local file="$1"
  local cleaned="${file}.nometa"

  grep -viE "^![[:space:]]*(${FILTERLIST_META_KEYS})[[:space:]]*:" "$file" > "$cleaned"
  mv "$cleaned" "$file"
}

# ---------------------------------------------------------------------------
# dedupe_rules <file>
#
# Print <file> with duplicate filter *rules* removed - first occurrence wins,
# original order preserved.
#
# Comments and blank lines are deliberately passed through untouched. They have
# no blocking behaviour, so deduplicating them buys nothing, and a plain
# "awk '!seen[$0]++'" over the whole file collapses every repeated line of our
# per-source credit banners (the "! ====" bars, the boilerplate credit line)
# into their first appearance, leaving later banners squashed and unreadable.
# ---------------------------------------------------------------------------
dedupe_rules() {
  awk '
    /^[ \t]*!/ { print; next }   # comments: always kept, they cost nothing
    /^[ \t]*$/ { print; next }   # blank spacing: always kept, for readability
    !seen[$0]++                  # actual rules: first occurrence only
  ' "$1"
}
