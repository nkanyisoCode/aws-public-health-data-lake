# 14-Day GitHub Issues Reference

These match the issues created on GitHub. Close each issue when that day's work is pushed.

| Day | Issue title | Files to add |
|-----|-------------|--------------|
| 1 | Day 1: Repository foundation | README.md, .gitignore, .checkov.yml |
| 2 | Day 2: Architecture documentation | docs/architecture.md, docs/security-decisions.md |
| 3 | Day 3: Cost and runbook docs | docs/cost-estimate.md, docs/runbook.md |
| 4 | Day 4: Bootstrap scripts | scripts/bootstrap_tf_state.sh, scripts/region_aliases.csv |
| 5 | Day 5: Ingest Lambda | lambda/ingest/* |
| 6 | Day 6: Clean Lambda | lambda/clean/* |
| 7 | Day 7: Helper scripts | scripts/clean_s3.py, manual_ingest.sh, test_iam_least_privilege.sh |
| 8 | Day 8: Athena SQL | sql/*.sql |
| 9 | Day 9: Terraform data lake module | terraform/modules/data_lake/* |
| 10 | Day 10: Terraform ingestion module | terraform/modules/ingestion/* |
| 11 | Day 11: Terraform analytics module | terraform/modules/analytics/* |
| 12 | Day 12: Terraform security module | terraform/modules/security/* |
| 13 | Day 13: Dev environment + network | terraform/envs/dev/*, modules/network, modules/warehouse |
| 14 | Day 14: CI/CD and prod | .github/workflows, terraform/envs/prod, cicd module |

**Diagrams:** [project-workflow-diagram.md](project-workflow-diagram.md)

**Full plan PDF:** see `cloud-engineer-aws-2week-plan/` on your machine.
