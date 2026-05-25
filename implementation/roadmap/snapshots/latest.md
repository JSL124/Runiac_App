# Runiac Latest Roadmap Snapshot

## Snapshot Metadata

- Last updated phase: Phase 01 - Governance CI
- Last updated capsule: Repository Workflow Record routing and documentation
- Latest verified commit: `bbdde20 docs(agents): add documentation scope instructions`
- Routing commit: `ce8a2d9 docs(roadmap): route artifact inventory schema persistence capsule`
- Closure context: Phase 01 Governance CI is closed at `f917aab`; Artifact Inventory Schema persistence is complete; Repository Workflow Record documentation/governance routing is active; no active implementation capsule is selected.

## Current Implementation State

Pre-scaffold governance state. Worktree inspection found no committed Flutter app scaffold, Firebase project config, production source/config, `pubspec.yaml`, `firebase.json`, `.firebaserc`, app `package.json`, `google-services.json`, or `GoogleService-Info.plist`.

## Implemented

- Governance CI check contract committed at `implementation/roadmap/ci/governance-ci-check-contract.md`.
- Local Governance CI shell checks committed at `tools/governance-ci/` in `50be93e chore(ci): add local governance CI checks`.
- Governance CI routing hardening committed in `7ed7f27 chore(ci): harden governance CI routing`.
- `tools/governance-ci/check-roadmap-routing.sh` is generalized and `tools/governance-ci/run-all-checks.sh` is available as the local runner.
- Governance CI runner passed for Phase 01 closure review.
- Artifact Inventory Schema persisted at `docs/meta/ARTIFACT_INVENTORY_SCHEMA.md` in `7aaacf1 docs(meta): add artifact inventory schema`.
- Artifact Inventory Schema remains non-operational and schema-only.
- Documentation scope instructions committed in `bbdde20 docs(agents): add documentation scope instructions`.
- Repository Workflow Record routing/documentation patch is active in the working tree until committed.

## Not Implemented

- Flutter app scaffold.
- Firebase project/config setup.
- Firestore rules or collections.
- Cloud Functions source.
- Production app source code.
- Production tests/build/deploy pipeline.
- Artifact inventory entries.
- Repository Workflow Record commit closure.
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
- Flutter Scaffold Gate is `APPROVED FOR SCAFFOLD EXECUTION REVIEW`; scaffold execution is not authorized.
- Firebase Project and Config Gate is `Not Started`.
- Secret / API Key / Environment Handling Gate is `Not Started`.
- Human/project approval evidence is required before remaining setup gates become `Approved`.
- Root roadmap context protocol is active in `AGENTS.md`.
- `docs/pdd/diagrams/` is the canonical PDD diagram source; root `diagrams/` is legacy/reference-only.
- Claude deny rules and `.gitignore` cover nested `.env`, Firebase config, service account, signing, private GPS/location/route, and test-evidence artifact patterns.
- Operational authority remains with `implementation/roadmap/CURRENT.md`, active phase/capsule documents, ADRs, and validated snapshots.
- `docs/meta` remains non-operational and must not override operational-authority sources.
- Repository Workflow Record work is documentation/governance-only and does not authorize implementation, setup, scaffold, source, test, build, deploy, or init work.

## Known Limitations

- Snapshot contains only compressed confirmed state.
- It does not replace `CURRENT.md`, active phase documents, active capsules, or ADRs.
- It must be updated when active phase, capsule, gate status, or implementation state changes.

## Current Active Milestone

Phase 01 - Governance CI is closed at `f917aab`. Artifact Inventory Schema persistence is complete at `7aaacf1`. Repository Workflow Record documentation/governance routing is active in the working tree and has no closure commit yet. No active implementation capsule is selected. Phase 02 implementation, Flutter scaffold execution, Firebase setup, dependency installation, build, init, deploy, source changes, tests, and production implementation remain unauthorized until separate explicit approval exists.
