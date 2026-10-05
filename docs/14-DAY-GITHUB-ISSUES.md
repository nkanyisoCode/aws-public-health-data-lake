# 14-Day GitHub Issues Reference

Each issue explains **what you are doing**, **why it matters**, **step-by-step instructions**, and a **done when** checklist. There are no commit message templates — focus on understanding and building.

Close each issue when that day's work is pushed to `main`.

## Issue format

Every issue body includes:

| Section | Purpose |
|---------|---------|
| **What we are doing today** | Plain-language summary of the day's goal |
| **Why it matters** | How this fits the cloud engineering portfolio |
| **Instructions** | Steps to create or paste files |
| **Done when** | Checklist before closing the issue |
| **AWS required?** | Whether you need an AWS account today |

## Iteration 1 — Days 1–5 (foundation, docs, ingest)

| Day | Issue | Label | Focus |
|-----|-------|-------|-------|
| 1 | [#1](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/1) | iteration 1 | README, .gitignore, checkov |
| 2 | [#2](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/2) | iteration 1 | Architecture + security docs |
| 3 | [#3](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/3) | iteration 1 | Cost estimate + runbook |
| 4 | [#4](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/4) | iteration 1 | Bootstrap scripts |
| 5 | [#5](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/5) | iteration 1 | Ingest Lambda |

## Iteration 2 — Days 6–10 (Lambda, SQL, Terraform core)

| Day | Issue | Label | Focus |
|-----|-------|-------|-------|
| 6 | [#6](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/6) | iteration 2 | Clean Lambda + quarantine |
| 7 | [#7](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/7) | iteration 2 | Helper scripts (S3, IAM test) |
| 8 | [#8](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/8) | iteration 2 | Athena SQL queries |
| 9 | [#9](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/9) | iteration 2 | Terraform S3 data lake module |
| 10 | [#10](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/10) | iteration 2 | Terraform ingestion + S3 events |

## Iteration 3 — Days 11–14 (analytics, security, deploy, CI/CD)

| Day | Issue | Label | Focus |
|-----|-------|-------|-------|
| 11 | [#11](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/11) | iteration 3 | Glue + Athena module |
| 12 | [#12](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/12) | iteration 3 | SNS, Budget, CloudTrail |
| 13 | [#13](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/13) | iteration 3 | Dev env + optional VPC/RDS |
| 14 | [#14](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/14) | iteration 3 | CI/CD, prod, README polish |

## Maintain issue bodies locally

Issue text lives in `scripts/issue-bodies/day-01.md` … `day-14.md`.

**Update GitHub after editing a body file:**

```bash
chmod +x scripts/update-github-issues.sh
./scripts/update-github-issues.sh
```

**UML diagrams:** [diagrams/](diagrams/)  
**Workflow:** [project-workflow-diagram.md](project-workflow-diagram.md)
