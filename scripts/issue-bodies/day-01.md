## Summary
Set up the repository foundation: README, gitignore, and security scan config.

## Prerequisites
- GitHub repo `aws-public-health-data-lake` cloned locally
- None — this is Day 1

## What we are doing today
You establish how the project is presented on GitHub and which files must never be committed. No AWS or Lambda code yet — just the repo skeleton and guardrails.

## Why it matters
Reviewers see the README first. A proper `.gitignore` prevents secrets and Terraform state from leaking. `.checkov.yml` prepares static security scanning before infrastructure code arrives in later iterations.

## Step-by-step instructions

### Step 1 — README.md
1. Create `README.md` at the repo root.
2. Write a project title and one-line description: cloud-native data lake for public OWID vaccination data.
3. Add a simple ASCII or text architecture flow: OWID → Ingest Lambda → S3 raw → Clean Lambda → S3 clean/curated → Glue → Athena.
4. List AWS services the project will use (S3, Lambda, EventBridge, Glue, Athena, IAM, Terraform).
5. Add a repo structure outline showing planned folders: `docs/`, `lambda/`, `scripts/`, `sql/`, `terraform/`.
6. Note that AWS deploy comes after all code is on GitHub.

### Step 2 — .gitignore
1. Create `.gitignore` at the repo root.
2. Ignore Terraform artifacts: `.terraform/`, `*.tfstate`, `*.tfplan`, `.terraform.lock.hcl`.
3. Ignore Python: `__pycache__/`, `.venv/`, `venv/`, `*.pyc`.
4. Ignore secrets: `.env`, `*.pem`, `.aws/`.
5. Ignore Lambda build zips and IDE/OS junk files.

### Step 3 — .checkov.yml
1. Create `.checkov.yml` at the repo root.
2. Set framework to `terraform`.
3. Add skip rules only where you have a documented reason (e.g. logs bucket not logging to itself).

## Files to create
- `README.md`
- `.gitignore`
- `.checkov.yml`

## Done when
- [ ] README renders on the GitHub repo home page
- [ ] `.gitignore` covers Terraform, Python, and secrets
- [ ] `.checkov.yml` exists for future IaC scanning
- [ ] All three files pushed to `main`

## AWS required?
No
