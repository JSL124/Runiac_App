# Runiac Latest Roadmap Snapshot

## Snapshot Metadata

- Last updated phase: Phase 01 - Governance CI
- Last updated capsule: Capsule 2 - Governance CI implementation
- Last verified commit hash: `50be93e80587d67d783f1e40a579f2c04dcb9dcf`
- Closure context: Governance CI check contract and Capsule 2 local shell check implementation committed; Phase 01 post-implementation roadmap update is active.

## Current Implementation State

Pre-scaffold governance state. Worktree inspection found no committed Flutter app scaffold, Firebase project config, production source/config, `pubspec.yaml`, `firebase.json`, `.firebaserc`, app `package.json`, `google-services.json`, or `GoogleService-Info.plist`.

## Implemented

- Governance CI check contract committed at `implementation/roadmap/ci/governance-ci-check-contract.md`.
- Local Governance CI shell checks committed at `tools/governance-ci/` in `50be93e chore(ci): add local governance CI checks`.

## Not Implemented

- Flutter app scaffold.
- Firebase project/config setup.
- Firestore rules or collections.
- Cloud Functions source.
- Production app source code.
- Production tests/build/deploy pipeline.

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

## Known Limitations

- Snapshot contains only compressed confirmed state.
- It does not replace `CURRENT.md`, active phase documents, active capsules, or ADRs.
- It must be updated when active phase, capsule, gate status, or implementation state changes.

## Current Active Milestone

Phase 01 - Governance CI is active. Capsule 2 - Governance CI implementation is complete. The next expected milestone is A6_REVIEW and A8_OUTPUT_CHECKER review of the post-implementation roadmap update before any Phase 01 closure or routing update. Phase 1 implementation preparation remains approved for scaffold execution review only; actual scaffold execution remains blocked until a separate explicit execution prompt and required approvals exist.
