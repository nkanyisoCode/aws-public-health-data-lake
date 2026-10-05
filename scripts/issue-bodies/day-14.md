## What we are doing today

Day 14 completes the project with **CI/CD**, a **prod environment**, and **README polish**. After today the entire codebase is on GitHub and ready for AWS deploy.

## Why it matters

- **GitHub Actions + OIDC** — deploy Terraform without storing AWS keys in GitHub secrets.
- **Separate plan/apply roles** — read-only plan on PR, write apply on merge to main.
- **checkov in CI** — block insecure Terraform before it reaches AWS.
- **Prod environment** — stricter defaults than dev (deletion protection, longer budget).

## Instructions

### Step 1 — CI/CD module
1. Create `terraform/modules/cicd/` — GitHub OIDC provider and IAM roles.

### Step 2 — GitHub Actions workflow
1. Create `.github/workflows/terraform.yml`
2. Plan on pull request, apply on merge to main (when OIDC enabled).

### Step 3 — Prod environment
1. Create `terraform/envs/prod/` — backend, variables, prod.tfvars, main.tf

### Step 4 — Final README
1. Ensure README links to all docs and diagrams.
2. Add note: AWS account required for deploy.

## After this issue — AWS deploy checklist
1. [ ] Create AWS account + MFA on root + IAM admin user
2. [ ] `aws configure`
3. [ ] `./scripts/bootstrap_tf_state.sh YOUR-NAME af-south-1`
4. [ ] Update `backend.tf` with state bucket name
5. [ ] `cd terraform/envs/dev && terraform init && terraform apply -var-file=dev.tfvars`
6. [ ] Confirm SNS email subscription
7. [ ] `./scripts/manual_ingest.sh dev $(date +%Y-%m-%d) YOUR-BUCKET`
8. [ ] Run `sql/vaccination_by_region.sql` in Athena
9. [ ] `./scripts/test_iam_least_privilege.sh` — screenshot AccessDenied
10. [ ] `terraform destroy` when done studying (save cost)

## Done when
- [ ] CI/CD workflow and prod env in repo
- [ ] README is portfolio-ready
- [ ] All 14 days of code on GitHub
- [ ] Issues #1–#14 can be closed

## AWS required?
After Day 14 code is complete — deploy is the next milestone.
