# 14-Day GitHub Issues Reference

Each issue tells you **what to build that day** — no copy-paste from elsewhere. You write the files yourself following the instructions.

Close each issue when that day's work is pushed to `main`.

## Issue format

| Section | Purpose |
|---------|---------|
| **Summary** | One-sentence goal |
| **Prerequisites** | Prior issues that must be done |
| **What we are doing today** | Plain-language overview |
| **Why it matters** | Portfolio / cloud engineering context |
| **Step-by-step instructions** | What to create and what content belongs in each file |
| **Files to create** | Paths only |
| **Done when** | Checklist before closing |
| **AWS required?** | Whether you need AWS today |

## Iteration 1 — Days 1–5

| Day | Issue | Label | Focus |
|-----|-------|-------|-------|
| 1 | [#1](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/1) | iteration 1 | README, .gitignore, checkov |
| 2 | [#2](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/2) | iteration 1 | Architecture + security docs |
| 3 | [#3](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/3) | iteration 1 | Cost estimate + runbook |
| 4 | [#4](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/4) | iteration 1 | Bootstrap scripts |
| 5 | [#5](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/5) | iteration 1 | Ingest Lambda |

## Iteration 2 — Days 6–10

| Day | Issue | Label | Focus |
|-----|-------|-------|-------|
| 6 | [#6](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/6) | iteration 2 | Clean Lambda + quarantine |
| 7 | [#7](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/7) | iteration 2 | Helper scripts |
| 8 | [#8](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/8) | iteration 2 | Athena SQL |
| 9 | [#9](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/9) | iteration 2 | Terraform S3 module |
| 10 | [#10](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/10) | iteration 2 | Terraform ingestion |

## Iteration 3 — Days 11–14

| Day | Issue | Label | Focus |
|-----|-------|-------|-------|
| 11 | [#11](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/11) | iteration 3 | Glue + Athena module |
| 12 | [#12](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/12) | iteration 3 | SNS, Budget, CloudTrail |
| 13 | [#13](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/13) | iteration 3 | Dev env + VPC/RDS |
| 14 | [#14](https://github.com/nkanyisoCode/aws-public-health-data-lake/issues/14) | iteration 3 | CI/CD, prod, README |

## Sync issue text to GitHub

Issue bodies live in `scripts/issue-bodies/day-01.md` … `day-14.md`.

```bash
./scripts/update-github-issues.sh
```

**Diagrams:** [diagrams/](diagrams/)
