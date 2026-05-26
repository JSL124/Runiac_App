# Runiac Latest Roadmap Snapshot

## Snapshot Metadata

- Last updated phase: Phase 01 - Governance CI
- Last updated capsule: `implementation/roadmap/capsules/android-ui-smoke-test-evidence.md`
- Latest verified commit: `247b4e5 feat(mobile): align static Runiac nav baseline`
- Latest roadmap checkpoint: `cbe0fe0 docs(roadmap): record static nav baseline checkpoint`
- Routing commit: `e2a96ed docs(roadmap): route flutter app shell capsule`
- Closure context: Phase 01 Governance CI is closed at `f917aab`; Artifact Inventory Schema persistence is complete; Repository Workflow Record capsule is closed; workflow memory schema migration, historical isolation check repair, historical isolation runner integration, Governance CI scaffold-baseline transition, Flutter scaffold baseline, static Flutter app shell baseline, and post-shell static UI/nav alignment checkpoint are pushed and verified; `flutter-app-shell-baseline` is closed; `android-ui-smoke-test-evidence` is selected as the next validation-only capsule.

## Current Implementation State

Approved Flutter scaffold baseline has been generated, committed, and pushed under `implementation/mobile/runiac_app/` with:

```bash
flutter create --template=app --platforms=android,ios --org com.runiac --project-name runiac_app --no-pub implementation/mobile/runiac_app
```

No `flutter pub get`, `firebase init`, `flutterfire configure`, build, deploy, or Firebase setup command was run. Worktree inspection found no Firebase project config, `firebase.json`, `.firebaserc`, `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, committed `.env*`, service account, or credentials file. The repository remains Firebase-uninitialized.

The repository is now in scaffold-baseline state, not pre-scaffold state. The stock counter template has been replaced by a static offline Runiac app shell with five placeholder tabs: Home, Plan, Run, Explore, and Leaderboard. The post-shell static UI/nav alignment checkpoint at `247b4e5 feat(mobile): align static Runiac nav baseline` updated only `implementation/mobile/runiac_app/lib/app.dart` and `implementation/mobile/runiac_app/test/widget_test.dart`. This shell baseline and alignment checkpoint do not authorize Phase 02 feature work, Firebase setup, dependency installation, builds, deploys, further custom production tests, or additional Runiac production source implementation.

The `flutter-app-shell-baseline` capsule is closed at `e48a348 feat(mobile): add static Runiac app shell`. The latest verified pushed implementation checkpoint is `247b4e5 feat(mobile): align static Runiac nav baseline`. The active routed capsule is `android-ui-smoke-test-evidence`, a validation-only capsule for Android emulator UI smoke-test evidence. Future product work requires explicit next capsule selection and approval after A6_REVIEW and A8_OUTPUT_CHECKER review.

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
- Static Flutter app shell baseline committed in `e48a348 feat(mobile): add static Runiac app shell`.
- `flutter-app-shell-baseline` capsule is closed after A6_REVIEW PASS, A8_OUTPUT_CHECKER PASS, `flutter analyze --no-pub` PASS, and Governance CI PASS.
- Static shell scope is limited to five placeholder tabs: Home, Plan, Run, Explore, and Leaderboard.
- No Firebase, GPS, authentication, leaderboard, XP, or backend-owned logic was added by the shell baseline.
- Static UI/nav alignment checkpoint committed in `247b4e5 feat(mobile): align static Runiac nav baseline`.
- Checkpoint affected files: `implementation/mobile/runiac_app/lib/app.dart`; `implementation/mobile/runiac_app/test/widget_test.dart`.
- Validation before push for `247b4e5`: `flutter analyze` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS; `git diff --check` PASS; scope review PASS.
- `247b4e5` is static UI/nav alignment only and did not start Firebase, GPS, authentication, Firestore, leaderboard, plan, profile, XP, streak, level, rank, premium-state, subscription privilege state, expert plan publication state, or backend-owned logic.
- Workflow Memory Drift Check is detection-only, WARN-only local Governance CI support. It does not automatically update workflow memory, snapshots, CURRENT.md, or capsules.
- Repository Workflow Record capsule is closed.
- `flutter-app-shell-baseline` is closed.
- `android-ui-smoke-test-evidence` is routed as a validation-only capsule to verify the current static Flutter UI baseline on Android emulator `emulator-5554`.
- Expected Android smoke-test evidence: emulator detected as `emulator-5554`, app launches successfully, bottom navigation visible with Home / Maps / Run / Leaderboard / You, no runtime crash observed, and command outputs recorded.

## Not Implemented

- Firebase project/config setup.
- Firestore rules or collections.
- Cloud Functions source.
- Production app source code beyond the static offline Flutter app shell baseline.
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
- Static Flutter app shell closure does not authorize Firebase setup, Phase 02 routing, further source expansion, dependency installation, build, deploy, init, or backend work.
- Backend-owned values remain protected: XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, and expert plan publication state.
- Android UI smoke-test evidence routing does not authorize product code edits, Flutter source/test edits, iOS/CocoaPods work, Firebase setup, GPS/tracking, authentication, Firestore, leaderboard logic, XP/streak/level/rank, premium-state, or backend-owned logic.

## Known Limitations

- Snapshot contains only compressed confirmed state.
- It does not replace `CURRENT.md`, active phase documents, active capsules, or ADRs.
- It must be updated when active phase, capsule, gate status, or implementation state changes.

## Current Active Milestone

Phase 01 - Governance CI is closed at `f917aab`. Artifact Inventory Schema persistence is complete at `7aaacf1`. Repository Workflow Record capsule is closed after `04e0972`, `0eb37c8`, `93fff5e`, schema refresh commit `9f2c832`, historical isolation repair commit `0619874`, and historical isolation runner integration commit `6d65fa1`. Governance CI scaffold-baseline transition is committed at `c8b2942`; Flutter scaffold baseline is committed and pushed at `4b375d2`; static Flutter app shell baseline is committed and pushed at `e48a348`; post-shell static UI/nav alignment checkpoint is committed and pushed at `247b4e5`; latest roadmap checkpoint is `cbe0fe0`. `flutter-app-shell-baseline` is closed. `android-ui-smoke-test-evidence` is the active validation-only capsule. The next expected milestone is execute Android UI smoke-test evidence, not automatic implementation. Phase 02 implementation, Firebase setup, `flutterfire configure`, dependency installation, build, init, deploy, source changes without separate implementation approval, custom tests, backend work, and production implementation remain unauthorized until separate explicit approval exists.
