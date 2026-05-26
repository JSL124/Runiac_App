# github-actions-flutter-validation-baseline

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: CI workflow update / hosted validation baseline.

## Status

Status: Closed.

Routed on: 2026-05-27 Asia/Singapore.

Completed on: 2026-05-27 Asia/Singapore.

Routing commit: `95d1eed docs(roadmap): route flutter validation ci capsule`.

Implementation commit: `587cc0e ci: add flutter validation to governance workflow`.

Hosted GitHub Actions status for `587cc0e`: PASS, manually confirmed by the user.

Closure review:

- A9_TRACE PASS.
- A6_REVIEW PASS.
- A12_QA_TEST PASS.
- A8_OUTPUT_CHECKER PASS.
- `git diff --check` PASS before workflow commit.
- `./tools/governance-ci/run-all-checks.sh` PASS before workflow commit.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub` PASS before workflow commit.
- `cd implementation/mobile/runiac_app && flutter test` PASS before workflow commit.
- Hosted GitHub Actions PASS for `587cc0e`, manually confirmed by the user.

This capsule is closed. Do not add further work to it.

Depends on:

- `implementation/roadmap/capsules/github-actions-governance-ci-baseline.md` closed after adding the minimal hosted governance workflow.
- GitHub Actions inspect-only review confirming the hosted workflow currently runs governance checks but not Flutter analyze/test.
- `implementation/roadmap/capsules/leaderboard-help-modal-shell.md` remains routed and deferred pending hosted CI validation parity.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add hosted GitHub Actions validation parity for the Flutter app so CI runs governance checks plus Flutter analyze/test before continuing product implementation.

## Starting Context

- Existing workflow: `.github/workflows/governance-ci.yml`.
- Existing hosted workflow runs on push and pull request to `main`.
- Existing hosted workflow runs `git diff --check`.
- Existing hosted workflow runs `./tools/governance-ci/run-all-checks.sh`.
- Existing hosted workflow does not set up Flutter.
- Existing hosted workflow does not run `flutter analyze --no-pub`.
- Existing hosted workflow does not run `flutter test`.
- The deferred `leaderboard-help-modal-shell` capsule expects Flutter analyze/test as future validation.

## Allowed Future Implementation Files

- `.github/workflows/governance-ci.yml`
- `implementation/roadmap/CURRENT.md` only if required by closure
- `implementation/roadmap/snapshots/latest.md` only if required by closure
- `implementation/roadmap/capsules/github-actions-flutter-validation-baseline.md` only for closure
- `tools/governance-ci/*` only if necessary and explicitly justified

## Forbidden Future Scope

- No Flutter app source changes.
- No Flutter widget test behavior changes unless strictly required by CI path discovery.
- No Firebase, Auth, Firestore, Cloud Functions, or FCM.
- No Firebase init or deploy.
- No secrets, config, or environment setup.
- No Android/iOS native build or release workflow.
- No dependency or package changes unless separately approved.
- No product feature implementation.
- No `leaderboard-help-modal-shell` implementation.
- No Phase 02 selection.

## Intended Future Workflow Behavior

- Trigger on push to `main`.
- Trigger on pull request to `main`.
- Check out the repository safely.
- Run `git diff --check`.
- Run `./tools/governance-ci/run-all-checks.sh`.
- Set up Flutter SDK with an explicit stable version compatible with the app SDK constraint in `implementation/mobile/runiac_app/pubspec.yaml`.
- Run `cd implementation/mobile/runiac_app && flutter analyze --no-pub`.
- Run `cd implementation/mobile/runiac_app && flutter test`.
- Do not run Firebase commands.
- Do not run deploy commands.
- Do not run native release builds.

## Validation Plan For Future Implementation

```bash
git status --short
git diff --stat
git diff --check
./tools/governance-ci/run-all-checks.sh
git status --short
```

Hosted validation must be checked after push in a separate post-push inspection if the workflow change is committed and pushed.

## A12_QA_TEST Notes

- Flutter SDK setup should use an explicit stable version compatible with the app SDK constraint.
- Working directories must be explicit; Flutter commands must run from `implementation/mobile/runiac_app`.
- CI runtime may increase when Flutter SDK setup and tests are added.
- Caching is optional and should be conservative; do not let caching introduce dependency or artifact churn.
- Do not add Firebase, deployment, Android/iOS release build, secrets, environment setup, or dependency mutation steps.

## Done Criteria

- [x] Capsule exists.
- [x] `CURRENT.md` selected this capsule as active during implementation.
- [x] `snapshots/latest.md` records that help modal implementation was deferred pending CI parity.
- [x] Hosted CI now runs governance checks plus Flutter analyze/test.
- [x] Workflow implementation was committed in `587cc0e ci: add flutter validation to governance workflow`.
- [x] No Flutter source, Flutter test, Firebase/backend, dependency, native platform, init, build, deploy, or help modal implementation work was introduced.
- [x] Required local validation passed.
- [x] Hosted GitHub Actions status for `587cc0e` was manually confirmed PASS by the user.

## Rollback Conditions

Stop and do not close this capsule if the work:

- Adds Firebase init/deploy, secrets/config setup, Android/iOS release builds, dependency/package changes, product features, or Phase 02 selection.
- Modifies Flutter source or tests outside a separately approved reason.
- Mixes help modal implementation with CI workflow work.
- Fails required validation.
