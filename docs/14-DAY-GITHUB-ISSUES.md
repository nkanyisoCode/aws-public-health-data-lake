# 14-Day GitHub Issues Reference

Close each issue when that day's work is pushed.

## Iteration 1 — Days 1–5 (foundation, docs, ingest)

| Day | Issue | Label | Files to add |
|-----|-------|-------|--------------|
| 1 | [#1](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/1) | iteration 1 | README.md, .gitignore, .checkov.yml |
| 2 | [#2](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/2) | iteration 1 | docs/architecture.md, docs/security-decisions.md |
| 3 | [#3](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/3) | iteration 1 | docs/cost-estimate.md, docs/runbook.md |
| 4 | [#4](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/4) | iteration 1 | scripts/bootstrap_tf_state.sh, region_aliases.csv |
| 5 | [#5](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/5) | iteration 1 | lambda/ingest/* |

## Iteration 2 — Days 6–10 (Lambda, SQL, Terraform core)

| Day | Issue | Label | Files to add |
|-----|-------|-------|--------------|
| 6 | [#6](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/6) | iteration 2 | lambda/clean/* |
| 7 | [#7](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/7) | iteration 2 | scripts/clean_s3.py, manual_ingest.sh, test_iam_least_privilege.sh |
| 8 | [#8](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/8) | iteration 2 | sql/*.sql |
| 9 | [#9](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/9) | iteration 2 | terraform/modules/data_lake/* |
| 10 | [#10](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/10) | iteration 2 | terraform/modules/ingestion/* |

## Iteration 3 — Days 11–14 (analytics, security, deploy, CI/CD)

| Day | Issue | Label | Files to add |
|-----|-------|-------|--------------|
| 11 | [#11](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/11) | iteration 3 | terraform/modules/analytics/* |
| 12 | [#12](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/12) | iteration 3 | terraform/modules/security/* |
| 13 | [#13](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/13) | iteration 3 | terraform/envs/dev/*, modules/network, modules/warehouse |
| 14 | [#14](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/14) | iteration 3 | .github/workflows, terraform/envs/prod, cicd module |

**UML diagrams:** [diagrams/](diagrams/)  
**Workflow:** [project-workflow-diagram.md](project-workflow-diagram.md)
