# Contributing

Thank you for your interest in contributing to this module. This guide covers local development setup, CI/CD configuration, and functional test setup.

## Local Development

This module includes a Makefile for common development tasks.

### Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/install) >= 1.7.0
- [tflint](https://github.com/terraform-linters/tflint)
- [terraform-docs](https://terraform-docs.io/)
- [pre-commit](https://pre-commit.com/)
- [Docker](https://www.docker.com/) (for security scanning with ASH)

### Available Makefile Targets

| Target | Description |
|--------|-------------|
| `make init` | Run `terraform init -backend=false` |
| `make validate` | Run `terraform validate` (depends on init) |
| `make fmt` | Run `terraform fmt -recursive` |
| `make fmt-check` | Run `terraform fmt -recursive -check` (CI-style) |
| `make lint` | Run tflint with `.config/.tflint.hcl` |
| `make test` | Run `terraform test` (depends on init, requires AWS credentials) |
| `make docs` | Regenerate `README.md` via terraform-docs |
| `make security-scan` | Run ASH CLI security scan (requires Docker) |
| `make clean` | Remove `.terraform/`, lock files, and build artifacts |
| `make all` | Run fmt, validate, lint, and docs (default) |

### Running Tests Locally

Functional tests require AWS credentials and a configured `examples/basic/` directory:

```bash
export AWS_REGION=us-east-1
make test
```

## Pre-commit Hooks

Set up pre-commit hooks to auto-format code and regenerate docs on commit:

```bash
pre-commit install
```

This runs `terraform fmt` and `terraform-docs` automatically before each commit.

## Security Scanning with ASH

[Automated Security Helper (ASH)](https://github.com/awslabs/automated-security-helper) runs Checkov, tflint, and other scanners locally via Docker:

```bash
make security-scan
```

## CI/CD Setup

Most CI/CD infrastructure is automatically provisioned when a module repo is created via the bootstrap process. This section describes what exists and what (if anything) requires manual action.

### Branching Strategy

`develop` is the default and integration branch: all PRs (including fork PRs) target `develop`, so GitHub pre-selects it as the base. `main` is reserved for releases only — you only target it when cutting a release (see the release flow below). New repos start with only `main`; creating `develop` and setting it as default is a one-time setup step — see Step 0 in [AUTHOR_GUIDE.md](AUTHOR_GUIDE.md).

- **`develop`** — Default + integration branch. All PRs merge here. CI runs static tests and (for same-repo PRs) functional tests.
- **`main`** — Release branch only. Tested, approved code from `develop` is merged here. Publication triggers on `VERSION` changes.

**Flow:** Feature branch → PR to `develop` → merge → PR from `develop` to `main` → release.

### Environments (auto-provisioned)

Two GitHub environments are created automatically by the bootstrap process:

- **`functional-test`** — CI pauses here for approval before running functional tests. Reviewers: the repo's maintainer team + admin team.
- **`publication`** — CI pauses here for approval before creating a release. Restricted to deployments from `main` only.

Both environments have `prevent_self_review: true` and `can_admins_bypass: false`.

### Branch Protection (auto-provisioned)

Branch protection is enforced via org-level rulesets that engage when the repo's `tier` custom property is set to `protected`. This includes required status checks and PR review requirements on `main` and `develop`.

### OIDC Federation

The `AWS_OIDC_ROLE_ARN` repository secret is set automatically during provisioning. The IAM role itself is created by the bootstrap repo's `module-infra` Terraform root (per module, hub→spoke) and its ARN written back as this secret — no manual script.

The trust policy scopes access to the Central Repo's reusable workflow path (see `docs/oidc-trust-policy.json` in the central repo).

### Build Steps (Optional)

If your module includes application code (e.g., Lambda functions with `requirements.txt`):

1. Uncomment `run-build-step: true` in `.github/workflows/ci.yml`
2. Implement build logic in the `build` Makefile target and subdirectory Makefiles
3. The workflow will run `make all` before Terraform commands

### AI Assistant (Claude)

Maintainers can invoke Claude by commenting on a PR or issue (runs on Amazon Bedrock via OIDC; gated to `OWNER`/`MEMBER`/`COLLABORATOR`):

- **`@claude`** / **`/claude-review`** on a PR — review the diff or explain failing CI checks (advisory).
- **`/claude-fix <ask>`** on a PR — apply the fix and push to the PR branch.
- **`@claude`** on an issue — triage it (classify, assess, outline a fix path).
- **`/claude-fix <ask>`** on an issue — open a PR addressing it.

`@claude` is advisory; `/claude-fix` is the only command that writes code, and its changes still pass through tests + CODEOWNERS review (Claude can't self-merge). The workflow logic lives in the central repo (`tf-module-ai-*.yml`) and can't be modified from this repo — see the central repo's README for the full reference.

## Functional Test Setup

### SSM Parameters for Test Variables

Store sensitive test variables in AWS SSM Parameter Store. The recommended naming convention:

```
/abp/aws-ia/functional/<module-name>/terraform_tests.tfvars
```

### Customizing Pre-Entrypoint Helpers

Edit `.config/functional_tests/pre-entrypoint-helpers.sh` to fetch SSM parameters:

```bash
#!/bin/bash
# Fetch tfvars from SSM and write to tests/terraform.auto.tfvars
aws ssm get-parameter \
  --name "/abp/aws-ia/functional/${MODULE_NAME}/terraform_tests.tfvars" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > tests/terraform.auto.tfvars
```

### Post-Entrypoint Cleanup

Edit `.config/functional_tests/post-entrypoint-helpers.sh` to clean up after tests:

```bash
#!/bin/bash
rm -f tests/terraform.auto.tfvars
```
