# Agent Instructions

Before doing any work in this repo, read:

1. [CONTRIBUTING.md](CONTRIBUTING.md) — local dev commands, branching/PR rules, the
   `providers.tf` user-agent validation CI enforces, and the pre-PR checklist.
2. [AUTHOR_GUIDE.md](AUTHOR_GUIDE.md) — one-time repo setup and the overall module
   authoring flow, if the repo looks unconfigured (e.g. `develop` branch missing,
   placeholders like `__ORG_NAME__` still present).

Both are written for a human contributor but apply equally to an agent working in
this repo — follow them as-is rather than re-deriving the same rules from source or
from a failed CI run.

## Before running `terraform plan` against real AWS credentials

CONTRIBUTING.md's Pre-PR Checklist includes an optional step to run a real
`terraform plan` (never `apply`) against a changed or added example. `plan` makes
live provider calls using whatever AWS credentials are currently active — default
profile, `AWS_PROFILE`, an assumed role, etc. — which may be a real account the user
does not intend to touch right now.

Before running that `plan`:

1. Check the active identity (`aws sts get-caller-identity`, and
   `aws configure list-profiles` if profiles are in use) and show it to the user.
2. Explicitly ask the user which AWS profile or account to use. Do not assume the
   currently active profile is the right one and do not proceed without asking.
3. Treat the user's answer as confirmation scoped to this one plan-only run — it
   does not authorize `apply` or any other mutating action, and does not carry over
   to a later, unrelated `plan`.

If no credentials are available, or the user declines to confirm a profile, skip
the step and say so explicitly rather than guessing at the result.
