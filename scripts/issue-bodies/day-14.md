## Summary
Add CI/CD with GitHub OIDC, prod environment, and final README polish — complete the codebase.

## Prerequisites
- Issue #13 closed — dev environment wires all modules

## What we are doing today
You finish the project: GitHub Actions pipeline (checkov + terraform plan/apply), a prod environment with stricter defaults, and a portfolio-ready README linking all documentation and diagrams.

## Why it matters
CI/CD without stored AWS keys (OIDC) is industry standard. Separate plan and apply roles show security maturity. Prod env proves you understand environment isolation. After today, the full codebase is on GitHub and ready for AWS deploy.

## Step-by-step instructions

### Step 1 — terraform/modules/cicd/
Implement:
1. GitHub OIDC provider for `token.actions.githubusercontent.com`.
2. IAM trust policy scoped to your repo (`repo:YOUR_USER/aws-public-health-data-lake:*`).
3. **Plan role** — read-only for terraform plan in CI.
4. **Apply role** — write access for merge to main (document if broader than ideal for learning).

### Step 2 — .github/workflows/terraform.yml
Write workflow that:
1. Triggers on PR and push to main (terraform/lambda paths).
2. Runs checkov on `terraform/` directory.
3. Runs `terraform fmt -check`, `init`, `validate`, `plan` on PR.
4. Runs `terraform apply` on push to main (when AWS OIDC vars configured).
5. Uses `aws-actions/configure-aws-credentials` with OIDC — no access keys in secrets.

### Step 3 — terraform/envs/prod/
Create prod copies of backend, variables, prod.tfvars, main.tf with:
- Stricter RDS settings (deletion_protection, skip_final_snapshot false)
- Higher budget default
- `enable_network = true` by default; RDS still off unless needed

### Step 4 — README polish
Update README to link: architecture, security, cost, runbook docs; UML diagrams folder; GitHub issues; note AWS deploy steps come after all code is merged.

## After this issue — AWS deploy checklist
1. Create AWS account, MFA on root, IAM admin user
2. `aws configure`
3. Run `./scripts/bootstrap_tf_state.sh YOUR-NAME af-south-1`
4. Update `terraform/envs/dev/backend.tf` with state bucket name
5. `cd terraform/envs/dev && terraform init && terraform apply -var-file=dev.tfvars`
6. Confirm SNS email subscription
7. Run manual ingest script with your bucket name
8. Run `sql/vaccination_by_region.sql` in Athena
9. Run IAM least-privilege test — screenshot AccessDenied
10. `terraform destroy` when done studying

## Files to create
- `terraform/modules/cicd/variables.tf`
- `terraform/modules/cicd/main.tf`
- `terraform/modules/cicd/outputs.tf`
- `.github/workflows/terraform.yml`
- `terraform/envs/prod/backend.tf`
- `terraform/envs/prod/variables.tf`
- `terraform/envs/prod/prod.tfvars`
- `terraform/envs/prod/main.tf`
- Update `README.md`

## Done when
- [ ] GitHub Actions workflow runs checkov and terraform plan on PR
- [ ] Prod environment exists with stricter defaults than dev
- [ ] README is portfolio-ready with links to all docs
- [ ] All 14 days of work on GitHub; issues #1–#14 can be closed

## AWS required?
After Day 14 — deploy is the next milestone.
