## What we are doing today

Day 1 sets up the **foundation of your GitHub repository**. Before any AWS or Lambda code, you establish how the project is presented, what files must never be committed, and how Terraform will be scanned for security problems later in the project.

This mirrors a real team workflow: README first, guardrails second, tooling third.

## Why it matters

- **README** — recruiters and reviewers see this first; it explains the cloud engineering story (data lake, security, automation).
- **`.gitignore`** — stops secrets, Terraform state, and virtualenvs from being pushed by accident.
- **`.checkov.yml`** — prepares static security scanning for when Terraform lands in Week 2.

## Instructions

### Step 1 — README.md
1. Create `README.md` in the repo root.
2. Paste from your local complete project (or write a short overview: project name, architecture one-liner, link to docs).
3. Include: what the project does, AWS services used, repo structure outline.

### Step 2 — .gitignore
1. Create `.gitignore` in the repo root.
2. Paste from local project.
3. Confirm it excludes: `.terraform/`, `*.tfstate`, `.env`, `.aws/`, `__pycache__/`, `.venv/`.

### Step 3 — .checkov.yml
1. Create `.checkov.yml` in the repo root.
2. Paste from local project.
3. Optional test: `pip install checkov && checkov --version`

## Done when
- [ ] README visible on GitHub repo home page
- [ ] `.gitignore` and `.checkov.yml` present in repo root
- [ ] All three files pushed to `main`

## AWS required?
No — GitHub only today.

## Diagram
See `docs/diagrams/` and `docs/project-workflow-diagram.md`
