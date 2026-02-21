#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

echo "=== Running AdGuard scripts ==="
for script in adguard/scripts/*.sh; do
    [ -x "$script" ] && "$script"
done

echo "=== Running uBlock scripts ==="
for script in ublock/scripts/*.sh; do
    [ -x "$script" ] && "$script"
done

echo "=== Checking for changes ==="
git add -u

if git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

COMMIT_MSG="Automated filterlist update: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
git commit -m "$COMMIT_MSG"

# Optional: push automatically
git push

echo "Committed changes with message:"
echo "$COMMIT_MSG"
