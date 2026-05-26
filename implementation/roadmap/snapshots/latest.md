# Runiac Latest Roadmap Snapshot

## Snapshot Metadata

- Last updated phase: Phase 01 - Governance CI
- Last updated capsule: Flutter scaffold baseline commit and Governance CI scaffold-baseline transition
- Latest verified commit: `4b375d2 chore(mobile): add Flutter scaffold baseline`
- Routing commit: `04e0972 docs(roadmap): route repository workflow record`
- Closure context: Phase 01 Governance CI is closed at `f917aab`; Artifact Inventory Schema persistence is complete; Repository Workflow Record capsule is closed; workflow memory schema migration, historical isolation check repair, historical isolation runner integration, Governance CI scaffold-baseline transition, and Flutter scaffold baseline are pushed and verified; no active implementation capsule is selected.

## Current Implementation State

Approved Flutter scaffold baseline has been generated, committed, and pushed under `implementation/mobile/runiac_app/` with:

```bash
flutter create --template=app --platforms=android,ios --org com.runiac --project-name runiac_app --no-pub implementation/mobile/runiac_app
```

No `flutter pub get`, `firebase init`, `flutterfire configure`, build, deploy, or Firebase setup command was run. Worktree inspection found no Firebase project config, `firebase.json`, `.firebaserc`, `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, committed `.env*`, service account, or credentials file. The repository remains Firebase-uninitialized.

The repository is now in scaffold-baseline state, not pre-scaffold state. The generated baseline is stock Flutter scaffold only and does not authorize Phase 02 feature work, Firebase setup, dependency installation, builds, deploys, custom production tests, or Runiac production source implementation.

## Implemented

- Governance CI check contract committed at `implementation/roadmap/ci/governance-ci-check-contract.md`.
- Local Governance CI shell checks committed at `tools/governance-ci/` in `50be93e chore(ci): add local governance CI checks`.
- Governance CI routing hardening committed in `7ed7f27 chore(ci): harden governance CI routing`.
- `tools/governance-ci/check-roadmap-routing.sh` is generalized and `tools/governance-ci/run-all-checks.sh` is available as the local runner.
- Governance CI runner passed for Phase 01 closure review.
- Artifact Inventory Schema persisted at `docs/meta/ARTIFACT_INVENTORY_SCHEMA.md` in `7aaacf1 docs(meta): add artifact inventory schema`.
- Artifact Inventory Schema remains non-operational and schema-only.
- Documentation scope instructions committed in `bbdde20 docs(agents): add documentation scope instructions`.
- Repository Workflow Record created at `docs/meta/REPOSITORY_WORKFLOW_RECORD.md` in `04e0972 docs(roadmap): route repository workflow record`.
- Workflow memory checkpoints pushed in `0eb37c8 docs(meta): add workflow memory checkpoints`.
- Workflow Memory Drift Check pushed in `93fff5e ci(governance): add workflow memory drift check`.
- Workflow memory schema migration pushed in `9f2c832 docs(meta): standardize workflow memory schema`.
- `docs/meta/REPOSITORY_WORKFLOW_RECORD.md` now uses the standardized 7-field workflow memory checkpoint schema and deterministic confidence labels.
- Historical isolation check narrowed in `0619874 ci(governance): narrow historical isolation check` to allow legitimate `docs/meta` non-operational boundary references while preserving failure behavior for operational authority/dependency usage.
- Main Governance CI runner includes historical isolation coverage as of `6d65fa1 ci(governance): include historical isolation check`.
- Local Governance CI has been transitioned to allow the approved Flutter scaffold baseline under `implementation/mobile/runiac_app/` while continuing to block Firebase config, secrets, service accounts, credentials, signing material, Cloud Functions, Firestore rules, Storage rules, build/deploy artifacts, and unauthorized scaffold paths.
- Governance CI scaffold-baseline transition committed in `c8b2942 ci(governance): allow approved Flutter scaffold baseline`.
- Flutter scaffold baseline committed in `4b375d2 chore(mobile): add Flutter scaffold baseline`.
- Workflow Memory Drift Check is detection-only, WARN-only local Governance CI support. It does not automatically update workflow memory, snapshots, CURRENT.md, or capsules.
- Repository Workflow Record capsule is closed.

## Not Implemented

- Firebase project/config setup.
- Firestore rules or collections.
- Cloud Functions source.
- Production app source code beyond the generated Flutter scaffold baseline.
- Production tests/build/deploy pipeline.
- Artifact inventory entries.
- Repository history reconstruction.
- Timelines, Genesis material, retrospectives, or autonomous archive systems.

## Current Architecture Assumptions

- Flutter handles UI, navigation, GPS tracking UI, and local interaction.
- Firebase Authentication handles identity.
- Firestore stores users, plans, activities, routes, XP summaries, and leaderboard data.
- Cloud Functions own XP calculation, activity validation, streak update, level update, rank update, and leaderboard aggregation.

## Current Governance Assumptions

- `implementation/traceability/setup-gates.md` is the source of truth for setup-gate approval state.
- Gate-00 is `APPROVED`.
- Flutter Scaffold Gate was separately human-approved for the bounded scaffold execution. The generated scaffold baseline does not authorize Firebase setup or Phase 02 work beyond the scaffold baseline.
- Firebase Project and Config Gate is `Not Started`.
- Secret / API Key / Environment Handling Gate is `Not Started`.
- Human/project approval evidence is required before remaining setup gates become `Approved`.
- Root roadmap context protocol is active in `AGENTS.md`.
- `docs/pdd/diagrams/` is the canonical PDD diagram source; root `diagrams/` is legacy/reference-only.
- Claude deny rules and `.gitignore` cover nested `.env`, Firebase config, service account, signing, private GPS/location/route, and test-evidence artifact patterns.
- Operational authority remains with `implementation/roadmap/CURRENT.md`, active phase/capsule documents, ADRs, and validated snapshots.
- `docs/meta` remains non-operational and must not override operational-authority sources.
- `docs/meta` remains non-operational and is not approval evidence, routing authority, setup-gate authority, or implementation guidance.
- Repository Workflow Record work is closed and remains documentation/governance-only. It does not authorize implementation, setup, scaffold, source, test, build, deploy, or init work.
- Workflow Memory Drift Check warnings are detection-only and do not create approval, closure, snapshot refresh, or workflow-memory update authority.

## Known Limitations

- Snapshot contains only compressed confirmed state.
- It does not replace `CURRENT.md`, active phase documents, active capsules, or ADRs.
- It must be updated when active phase, capsule, gate status, or implementation state changes.

## Current Active Milestone

Phase 01 - Governance CI is closed at `f917aab`. Artifact Inventory Schema persistence is complete at `7aaacf1`. Repository Workflow Record capsule is closed after `04e0972`, `0eb37c8`, `93fff5e`, schema refresh commit `9f2c832`, historical isolation repair commit `0619874`, and historical isolation runner integration commit `6d65fa1`. Governance CI scaffold-baseline transition is committed at `c8b2942`; Flutter scaffold baseline is committed and pushed at `4b375d2`. No active implementation capsule is selected; next work requires explicit routing. Phase 02 implementation, Firebase setup, `flutterfire configure`, dependency installation, build, init, deploy, source changes beyond the stock scaffold baseline, custom tests, and production implementation remain unauthorized until separate explicit approval exists.
