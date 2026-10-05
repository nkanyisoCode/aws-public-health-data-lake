#!/usr/bin/env bash
# Update existing GitHub issues with instruction-focused bodies (no commit messages).
# Usage: ./scripts/update-github-issues.sh [owner/repo]
set -euo pipefail

REPO="${1:-nkanyisoCode/aws-public-health-data-lake}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/issue-bodies"

for i in $(seq 1 14); do
  num=$(printf "%02d" "$i")
  body_file="${DIR}/day-${num}.md"
  if [[ ! -f "$body_file" ]]; then
    echo "Missing: $body_file" >&2
    exit 1
  fi
  echo "Updating issue #${i} from day-${num}.md ..."
  gh issue edit "$i" --repo "$REPO" --body-file "$body_file"
done

echo "Done. View: https://github.com/${REPO}/issues"
