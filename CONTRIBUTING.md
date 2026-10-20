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

### Pre-PR Checklist

Run this sequence before opening or updating a PR, so CI failures are caught locally instead of on the PR:

1. **Format** — `terraform fmt -recursive` (or `make fmt`) at the repo root. This also formats every `examples/*/` directory, since `fmt -recursive` descends into subdirectories.
2. **Validate every root module you touched** — `terraform init -backend=false && terraform validate` run separately in the repo root **and** in each `examples/*/` directory you added or changed. Each example is its own root module with its own provider requirements; validating only the repo root does not catch a broken example.
3. **Lint** — `make lint` (tflint) from the repo root; it scans the whole tree, examples included.
4. **Security scan** — `make security-scan` (requires Docker), or `checkov --config-file .config/.checkov.yml` directly if Docker/ASH isn't available locally. If you add a skip-check to `.config/.checkov.yml`, state why in the PR description — CI's suppression-diff check flags skip-list changes for reviewer attention.
5. **Docs** — `make docs` regenerates the root `README.md` from `.header.md`. It does **not** touch example READMEs. Regenerate those separately from inside each example directory:

   ```bash
   cd examples/<name> && terraform-docs --config ../../.config/.terraform-docs.yaml --lockfile=false .
   ```

   Skipping this step is easy to miss locally and leaves an example's `README.md` silently out of sync with its own `main.tf`/`outputs.tf` — nothing fails until a reviewer (or a future contributor) notices the drift.
6. **Exercise new input validation manually.** `terraform validate` only checks syntax and types — it does not evaluate `validation` blocks, `lifecycle.precondition`s, or `check` blocks against real values. If you add or change one, confirm it actually rejects bad input by pointing a scratch root module at your local module path (`source = "/absolute/path/to/this/repo"`) with the invalid combination, running `terraform plan`, and reading the result:
   - A `lifecycle.precondition` failure shows as a hard `Error:` and stops the plan — this is what you want for a hard requirement.
   - A `check` block failure only shows as a `Warning:` — `terraform plan`/`apply` still proceeds. Don't rely on a `check` block where an invalid combination must block `apply`.
   Delete the scratch directory when done; it is not part of the module and must not be committed.
7. **If AWS credentials are available**, run a real `terraform plan` (not `apply`) against each changed or added example to confirm the resource graph matches what you expect — `validate` would not have caught the Object Lock `default_retention`-block requirement that surfaced only at `plan` time, for example.

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

In practice this means **you cannot `git push` directly to `develop` or `main`**, even as the repo owner — the push is rejected with a `GH013: Repository rule violations` error. All changes, including small docs fixes, go through a feature branch and a PR. See the Branching Strategy above.

### OIDC Federation

The `AWS_OIDC_ROLE_ARN` repository secret is set automatically during provisioning. The IAM role itself is created by the bootstrap repo's `module-infra` Terraform root (per module, hub→spoke) and its ARN written back as this secret — no manual script.

The trust policy scopes access to the Central Repo's reusable workflow path (see `docs/oidc-trust-policy.json` in the central repo).

### User Agent Validation

CI's static-tests workflow (`abp-v2-dev/central-repo`'s `tf-module-static-tests.yml`, not checked into this repo) includes a **Validate User Agent** step that fails the build if `providers.tf`'s `provider_meta "aws" { user_agent = [...] }` string doesn't match three derived values exactly:

```hcl
provider_meta "aws" {
  user_agent = ["AWS/1.0 <org>/<module>:<version>"]
}
```

| Segment | Expected value | Derived from |
|---------|-----------------|--------------|
| `<org>` | `abp-v2-dev` | The GitHub org this repo lives in |
| `<module>` | Repo name with the `terraform-aws-` prefix stripped (e.g. `813578204325-v2`) | `$GITHUB_REPOSITORY`, not a value you choose |
| `<version>` | `VERSION` file content, **without** the `v` prefix (e.g. `VERSION` = `v0.0.1` → `0.0.1`) | The `VERSION` file |

Because the check derives `<org>` and `<module>` from the repo itself, there is nothing to "fill in" freely — only `<version>` changes as you release. **Any time you bump `VERSION`, update `providers.tf`'s `user_agent` version segment in the same commit**, or the CI check fails. The three placeholders left by the template (`__ORG_NAME__`, `__MODULE_NAME__`, `__VERSION__`, see Step 1 in [AUTHOR_GUIDE.md](AUTHOR_GUIDE.md)) must all be replaced before the first PR — a leftover placeholder fails the same check with an explicit "placeholder has not been replaced" error.

This step is easy to miss because its logic is not visible anywhere in this repo; the only way to see the exact expected values is to read a failed CI run's log for the "Validate User Agent" step, or this section.

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
