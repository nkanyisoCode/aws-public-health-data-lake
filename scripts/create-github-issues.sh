#!/usr/bin/env bash
# Create 14 GitHub issues from scripts/issue-bodies/day-NN.md
# Usage: ./scripts/create-github-issues.sh [owner/repo]
set -euo pipefail

REPO="${1:-nkanyisoCode/aws-public-health-data-lake}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BODIES="${DIR}/issue-bodies"

gh label create "iteration 1" --repo "$REPO" --color "1D76DB" --description "Days 1-5: docs, scripts, ingest Lambda" 2>/dev/null || true
gh label create "iteration 2" --repo "$REPO" --color "FBCA04" --description "Days 6-10: clean Lambda, SQL, Terraform core" 2>/dev/null || true
gh label create "iteration 3" --repo "$REPO" --color "D93F0B" --description "Days 11-14: analytics, security, dev/prod, CI/CD" 2>/dev/null || true

create_issue() {
  local title="$1"
  local label="$2"
  local body_file="$3"
  gh issue create --repo "$REPO" --title "$title" --body-file "$body_file" --label "$label"
}

create_issue "Day 1: Repository foundation"           "iteration 1" "${BODIES}/day-01.md"
create_issue "Day 2: Architecture documentation"     "iteration 1" "${BODIES}/day-02.md"
create_issue "Day 3: Cost estimate and runbook"      "iteration 1" "${BODIES}/day-03.md"
create_issue "Day 4: Bootstrap scripts"              "iteration 1" "${BODIES}/day-04.md"
create_issue "Day 5: Ingest Lambda"                  "iteration 1" "${BODIES}/day-05.md"
create_issue "Day 6: Clean Lambda"                   "iteration 2" "${BODIES}/day-06.md"
create_issue "Day 7: Helper scripts"                 "iteration 2" "${BODIES}/day-07.md"
create_issue "Day 8: Athena SQL queries"             "iteration 2" "${BODIES}/day-08.md"
create_issue "Day 9: Terraform data lake module"     "iteration 2" "${BODIES}/day-09.md"
create_issue "Day 10: Terraform ingestion module"    "iteration 2" "${BODIES}/day-10.md"
create_issue "Day 11: Terraform analytics module"   "iteration 3" "${BODIES}/day-11.md"
create_issue "Day 12: Terraform security module"    "iteration 3" "${BODIES}/day-12.md"
create_issue "Day 13: Dev environment and optional network" "iteration 3" "${BODIES}/day-13.md"
create_issue "Day 14: CI/CD, prod environment, final polish" "iteration 3" "${BODIES}/day-14.md"

echo "Done. View issues: https://github.com/${REPO}/issues"
