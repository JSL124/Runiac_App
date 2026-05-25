# Phase 01 - Governance CI

## Purpose

Define minimal repository governance checks before implementation work begins, without deploying, building, scaffolding, or creating production source/config files.

## Governance-CI Purpose

Provide lightweight automated checks for repository hygiene, forbidden-scope detection, and roadmap context discipline.

## Testing-Policy Purpose

Define when tests are required, which evidence must be captured, and how emulator-first validation will be introduced later.

## Commit-Policy Purpose

Keep staging explicit, prevent unrelated changes from being committed, and preserve the existing Runiac commit protocol.

## Evidence-Policy Purpose

Require concise proof for gate changes, validation claims, and readiness decisions.

## Minimal CI Philosophy

Start with the smallest checks that reduce real risk. Avoid broad CI, dependency installs, external services, or build pipelines until the relevant gates are approved.

## Implementation Status

- Capsule 2 - Governance CI implementation is complete.
- Local Governance CI shell checks were committed and pushed in `50be93e chore(ci): add local governance CI checks`.
- Implemented checks remain local-only shell scripts under `tools/governance-ci/`; no GitHub Actions, Flutter scaffold, Firebase setup, production source/config, build, deploy, dependency installation, or external service use was introduced.
- Repository state remains pre-scaffold.

## Forbidden Deployment/Build Scope

- Do not run Flutter, Firebase, npm, build, test, deploy, scaffold, or init commands unless a later active capsule explicitly authorizes them under the tier system.
- Do not create production source/config files.
- Do not connect to production Firebase.

## Required Validation

- Classify any proposed check by ADR-001 tier.
- Verify checks do not require secrets, production services, generated app scaffolds, or dependency installation.
- Preserve `setup-gates.md` as the source of truth for pre-scaffold approval state.
- Run A6_REVIEW and A8_OUTPUT_CHECKER before Ready for commit.

## Snapshot Update Requirement

Update `implementation/roadmap/snapshots/latest.md` before leaving this phase.

## CURRENT.md Update Requirement

Update `implementation/roadmap/CURRENT.md` immediately when the next phase becomes active.

## Exit Criteria

- [ ] snapshots/latest.md updated
- [ ] CURRENT.md updated to next phase
