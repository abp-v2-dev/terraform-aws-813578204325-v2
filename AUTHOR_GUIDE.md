# Module Author Quick-Start Guide

This guide walks you through the first steps after your module repo has been created from the template.

## What's already done for you

The bootstrap process has provisioned:

- **GitHub environments** — `functional-test` and `publication` with team-based approval gates
- **Branch protection** — Org-level rulesets enforce required status checks and PR reviews on `main` and `develop`
- **OIDC secret** — `AWS_OIDC_ROLE_ARN` is set, linking CI to your test AWS account
- **CI workflows** — `ci.yml` (static + functional tests) and `publication.yml` (release on VERSION bump)

You can start writing module code immediately.

## Step 0 — Create `develop` and make it the default branch

**Do this first, once per repo.** This module uses a two-branch model: `develop` is
the integration branch where all work and CI happen, and `main` is reserved for
releases. A freshly created repo has only `main`, so you need to create `develop` and
set it as the default — that way new PRs target `develop` automatically (instead of
you having to change the base every time), and CI reflects your integration branch.

```bash
# Create develop from main and push it
git checkout main
git pull
git checkout -b develop
git push -u origin develop

# Make develop the default branch
gh repo edit <org>/<repo-name> --default-branch develop
```

(UI equivalent: **Settings → General → Default branch → switch to `develop`**.)

After this: PRs default to `develop`; you only target `main` when cutting a release
(Step 6). See [CONTRIBUTING.md](CONTRIBUTING.md) for the full branching model.

## Step 1 — Personalize the module

Replace placeholders in these files:

| File | What to update |
|------|----------------|
| `.header.md` | Module name, description, architecture diagram |
| `providers.tf` | Replace `__ORG_NAME__` and `__MODULE_NAME__` in the `user_agent` string |
| `VERSION` | Set to your initial version (e.g., `v0.0.1`) |
| `CHANGELOG.md` | Update the `[v0.0.1]` entry with your initial feature description |

The `providers.tf` user-agent tracks module adoption via AWS API calls:

```hcl
provider_meta "aws" {
  user_agent = ["AWS/1.0 __ORG_NAME__/__MODULE_NAME__:__VERSION__"]
}
```

Replace `__ORG_NAME__` with your organization (e.g., `aws-ia`) and `__MODULE_NAME__` with your module name (e.g., `terraform-aws-vpc`). Leave `__VERSION__` as-is if it's dynamically replaced, or set it to match your `VERSION` file.

> **Note:** Edit `.header.md`, not `README.md` directly. Running `make docs` regenerates the README from `.header.md` + terraform-docs output.

## Step 2 — Write your module

Add your Terraform resources across the standard files:

```
main.tf         — Primary resources
variables.tf    — Input variables
outputs.tf      — Output values
data.tf         — Data sources
locals.tf       — Local values
providers.tf    — Required providers (already has aws >= 5.0.0)
```

## Step 3 — Create a working example

Update `examples/basic/` so it invokes your module with realistic inputs. This example is used by the mandatory functional test (`tests/01_mandatory.tftest.hcl`), which runs `plan` and `apply` against it — if it can't succeed, CI will fail.

## Step 4 — Local validation

Install tools and run checks locally:

```bash
make tools        # One-time: install tflint, terraform-docs, checkov, etc.
make check-tools  # Verify everything is available
make all          # Run fmt, validate, lint, docs
```

To run functional tests locally (requires AWS credentials):

```bash
export AWS_REGION=us-east-1
make test
```

## Step 5 — Commit and push

```bash
git checkout develop
git checkout -b feature/initial-module
# ... make your changes ...
git add .
git commit -m "feat: initial module implementation"
git push -u origin feature/initial-module
```

Open a PR targeting `develop`. CI runs static tests automatically. For same-repo PRs, functional tests run after environment approval.

## Ask Claude for help

Claude is wired into this repo's PRs and issues (running on Amazon Bedrock — no API key needed). Trigger it by **commenting** — only repo maintainers can invoke it.

| Comment | Where | What Claude does |
|---------|-------|------------------|
| `@claude` or `/claude-review` | on a **PR** | Reviews the diff / explains failing CI checks (advisory — comments only) |
| `/claude-fix <what to fix>` | on a **PR** | Applies the fix and pushes to the PR branch |
| `@claude <question>` | on an **issue** | Triages: classifies it, says whether it's actionable, outlines a fix approach |
| `/claude-fix <ask>` | on an **issue** | Opens a PR that addresses the issue |

Tips:
- **`@claude` is advisory; `/claude-fix` is the only command that changes code.**
- To iterate on a fix, comment `/claude-fix` **on the resulting PR** (it stacks onto that branch) — re-running `/claude-fix` on the *issue* starts a fresh, separate PR.
- Claude's changes still go through the normal gates: static + functional tests, CODEOWNERS review, and branch protection. It can't merge on its own.

Full command reference and how it works: see the central repo's README (the `TF Module — AI *` workflow sections).

## Step 6 — Release

When ready to publish:

1. Update `VERSION` to `v0.0.1` (or your target version)
2. Update the version in `providers.tf` `user_agent` to match (without the `v` prefix, e.g., `0.0.1`)
3. Update `CHANGELOG.md` with the release notes under `## [v0.0.1]`
4. Remove `AUTHOR_GUIDE.md` and the "Getting Started (Module Authors)" section from `.header.md` — these are onboarding aids, not part of the published module
5. Run `make docs` to regenerate the README
6. PR from `develop` → `main`
7. After merge, the publication workflow creates a GitHub release (with approval gate)

## Repository structure

```
.
├── .config/                    # Tool configuration
│   ├── .checkov.yml            # Checkov skip rules
│   ├── .mdlrc                  # Markdown linter config
│   ├── .terraform-docs.yaml    # terraform-docs config
│   ├── .tflint.hcl             # tflint config + AWS ruleset
│   ├── functional_tests/       # Pre/post entrypoint scripts for CI
│   └── static_tests/           # Static test configuration
├── .github/
│   ├── CODEOWNERS              # Review routing (admin team)
│   └── workflows/              # CI and publication caller workflows
├── examples/
│   └── basic/                  # Minimum viable example (used by tests)
├── tests/
│   └── 01_mandatory.tftest.hcl # Required: plan + apply of examples/basic
├── .header.md                  # Source for README (above terraform-docs)
├── .pre-commit-config.yaml     # Pre-commit hook definitions
├── CHANGELOG.md                # Release notes (one section per version)
├── CONTRIBUTING.md             # Dev workflow, CI/CD details, test setup
├── Makefile                    # Local dev targets (fmt, lint, test, docs)
├── VERSION                     # Current version (triggers publication)
├── main.tf / variables.tf / outputs.tf / ...  # Module source
└── README.md                   # Generated — do not edit below TF_DOCS marker
```

## Writing additional tests

The mandatory test (`tests/01_mandatory.tftest.hcl`) validates `examples/basic/`. You can add more `.tftest.hcl` files for:

- Additional examples (`examples/complete/`, etc.)
- Specific resource assertions
- Variable validation edge cases

All `.tftest.hcl` files in `tests/` are auto-discovered by `terraform test`.

## Functional test variables (SSM)

If your tests need sensitive inputs (account IDs, VPC IDs, etc.), store them in SSM Parameter Store:

```
/abp/aws-ia/functional/<module-name>/terraform_tests.tfvars
```

Edit `.config/functional_tests/pre-entrypoint-helpers.sh` to fetch them before tests run. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Further reading

- [CONTRIBUTING.md](CONTRIBUTING.md) — Full dev workflow, pre-commit hooks, security scanning, CI/CD details
- **Ask Claude for help** — `@claude` / `/claude-fix` on PRs and issues (see the section above); full reference in the central repo's README
