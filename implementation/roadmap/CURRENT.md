# Runiac Current Roadmap Context

## Current Routing

- Current track: Track A - Governance and implementation readiness
- Current phase: `implementation/roadmap/phases/phase-01-governance-ci.md`
- Current active capsule: none selected
- Most recent completed capsule: `implementation/roadmap/capsules/premium-home-dashboard-static-wireframe-alignment.md`
- Current status: Phase 01 governance CI closed; Artifact Inventory Schema persistence completed; Repository Workflow Record capsule closed; Flutter scaffold baseline present at `implementation/mobile/runiac_app/`; `flutter-app-shell-baseline` capsule closed after static app shell implementation; post-shell static UI/nav alignment checkpoint pushed at `247b4e5 feat(mobile): align static Runiac nav baseline`; `android-ui-smoke-test-evidence` validation capsule closed; `home-dashboard-visual-polish` capsule closed after static Home dashboard visual polish; `premium-home-dashboard-static-wireframe-alignment` capsule closed after static Premium Home Dashboard wireframe alignment
- Current state: Scaffold-baseline governance state with the Premium Home Dashboard static wireframe alignment capsule closed; Phase 02 remains unselected; no active implementation capsule is selected
- Current active milestone: select the next capsule explicitly before further implementation

## Required Reading Order

1. `implementation/roadmap/CURRENT.md`
2. Active phase document: `implementation/roadmap/phases/phase-01-governance-ci.md` (closed)
3. Relevant ADRs listed below
4. `implementation/roadmap/snapshots/latest.md`

Do not load future phase documents unless explicitly requested.

## Relevant ADRs

- `implementation/roadmap/decisions/ADR-001-tier-gate-system.md`
- `implementation/roadmap/decisions/ADR-002-emulator-first.md`

## Allowed Work

- Maintain roadmap/context governance files under `implementation/roadmap/`.
- Maintain completed governance capsule status under `implementation/roadmap/capsules/` when explicitly routed.
- Maintain root `AGENTS.md` roadmap context protocol when required.
- Update `snapshots/latest.md` from confirmed repository state only.
- Update CURRENT.md immediately when active phase, active capsule, gate status, or forbidden scope changes.
- Use Workflow Memory Drift Check output only as detection-only local Governance CI support; it must not automatically mutate workflow memory, snapshots, CURRENT.md, or capsules.
- Maintain the scaffold baseline state only; any further Flutter source/test expansion requires explicit routing and approval.

## Forbidden Work

- Do not run Flutter, Firebase, npm, build, test, deploy, scaffold, or init commands.
- Do not create production implementation code.
- Do not modify existing implementation logic.
- Do not expand the generated Flutter scaffold into Runiac production features or tests without separate approval.
- Do not run `flutterfire configure`; Firebase remains uninitialized.
- Do not modify `docs/submissions/`, `PRD.md`, or frozen submitted PDD snapshots.
- Do not load `roadmap-stretch.md`, archived snapshots, or future phase docs unless explicitly requested.
- Do not treat `docs/meta` as operational truth, approval evidence, routing authority, setup-gate authority, or implementation guidance.
- Do not create Repository Genesis material, timelines, full history reconstruction, retrospectives, artifact inventory entries, or autonomous archive/index systems.

## Next Gate

No active capsule is selected.

The next milestone is explicit next capsule selection. This closed state does not approve Phase 02 implementation, Firebase setup, `flutterfire configure`, dependency installation, build, init, deploy, backend work, or additional Flutter implementation. Future Flutter UI work requires a newly routed active capsule and the required review chain for that capsule.

Premium Home Dashboard static wireframe alignment capsule is complete:

- Capsule: `implementation/roadmap/capsules/premium-home-dashboard-static-wireframe-alignment.md`
- Type: Flutter UI product-code-changing
- Completion commit target: `feat(mobile): align premium home dashboard static UI`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS after one layout fix rerun; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`
- Implemented scope: static Home dashboard section order aligned to the Premium Home Dashboard wireframe structure, placeholder-only Today's Plan, Goal Preparation, Runner Progress, This Week's Plan, Last Run, Advice, and Recommended Community Route sections
- Bottom navigation remains Home / Maps / Run / Leaderboard / You.
- No Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, real run recording, premium entitlement logic, AI advice logic, fake XP, fake streak, fake level, fake rank, fake leaderboard score, fake weekly/monthly XP, fake subscription state, fake premium state, fake run history, fake route data, backend-owned values, dependency changes, or native Android/iOS changes were introduced.
- Phase 02 remains unselected.

Home dashboard visual polish capsule is complete:

- Capsule: `implementation/roadmap/capsules/home-dashboard-visual-polish.md`
- Type: Flutter UI product-code-changing
- Completion commit target: `feat(mobile): polish static home dashboard`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`
- Implemented scope: static Home dashboard spacing, hierarchy, Runiac logo palette baseline, `Start Run` CTA presentation, supportive guidance card, and empty-state copy
- Bottom navigation remains Home / Maps / Run / Leaderboard / You.
- No Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, real run recording, fake XP, fake streak, fake level, fake rank, fake leaderboard score, fake premium state, fake run history, backend-owned values, dependency changes, or native Android/iOS changes were introduced.

Android UI smoke-test evidence capsule is complete:

- Capsule: `implementation/roadmap/capsules/android-ui-smoke-test-evidence.md`
- Type: validation-only
- Evidence: Android emulator `emulator-5554` detected; app launched successfully; bottom navigation visible with Home / Maps / Run / Leaderboard / You; old Plan / Explore bottom-navigation labels were not visible; no runtime crash observed.
- Temporary screenshot captured outside the repository at `/private/tmp/runiac-android-smoke.png`; screenshot is not committed.
- No product files were modified.
- iOS/Xcode/CocoaPods issues remain out of scope for this capsule.

Artifact Inventory Schema persistence is complete:

- Routing commit: `ce8a2d9 docs(roadmap): route artifact inventory schema persistence capsule`
- Completion commit: `7aaacf1 docs(meta): add artifact inventory schema`
- Created document: `docs/meta/ARTIFACT_INVENTORY_SCHEMA.md`

No implementation authorization should be inferred from this completed work.

Flutter app shell baseline capsule is complete:

- Completion commit: `e48a348 feat(mobile): add static Runiac app shell`
- Capsule: `implementation/roadmap/capsules/flutter-app-shell-baseline.md` (closed)
- Implemented scope: static offline Runiac app shell with five placeholder tabs: Home, Plan, Run, Explore, and Leaderboard
- Firebase remains uninitialized.
- No Firebase, GPS, authentication, leaderboard, XP, or backend-owned logic was added.

Post-shell static UI/nav alignment checkpoint is verified:

- Checkpoint commit: `247b4e5 feat(mobile): align static Runiac nav baseline`
- Follows the closed static app shell baseline at `e48a348 feat(mobile): add static Runiac app shell`
- Affected files: `implementation/mobile/runiac_app/lib/app.dart`; `implementation/mobile/runiac_app/test/widget_test.dart`
- Validation before push: `flutter analyze` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS; `git diff --check` PASS; scope review PASS
- Interpretation: static UI/nav alignment only; no Firebase, GPS, authentication, Firestore, leaderboard, plan, profile, XP, streak, level, rank, premium-state, or backend-owned logic was started.

This post-completion state records the already-approved Flutter scaffold baseline, closed static app shell baseline, closed static UI/nav alignment checkpoint, Android smoke-test evidence, and closed Home dashboard visual polish capsule. It does not approve Phase 02 implementation, Firebase setup, `flutterfire configure`, dependency installation, build, init, deploy, tests, source changes beyond a future explicitly routed capsule, or production implementation.

Flutter scaffold baseline is present:

- Scaffold commit: `4b375d2 chore(mobile): add Flutter scaffold baseline`
- Governance transition commit: `c8b2942 ci(governance): allow approved Flutter scaffold baseline`
- Scaffold path: `implementation/mobile/runiac_app/`
- Firebase remains uninitialized.
- `flutterfire configure` has not been run.
- No production Runiac feature implementation is authorized by this state.
- No build, deploy, source expansion, or test expansion is authorized unless separately routed.
- Flutter may later display trusted XP, streak, level, rank, weekly XP, monthly XP, leaderboard, subscription, and expert-plan state, but the client must not write backend-owned progression, entitlement, ranking, or expert-publication fields.

Repository Workflow Record capsule is complete:

- Routing and record commit: `04e0972 docs(roadmap): route repository workflow record`
- Workflow memory checkpoints commit: `0eb37c8 docs(meta): add workflow memory checkpoints`
- Workflow Memory Drift Check commit: `93fff5e ci(governance): add workflow memory drift check`
- Created record: `docs/meta/REPOSITORY_WORKFLOW_RECORD.md`
- Capsule: `implementation/roadmap/capsules/repository-workflow-record.md` (closed)

Workflow Memory Drift Check is detection-only and WARN-only local Governance CI support. It does not approve, close, refresh, or update records automatically.

`docs/meta` remains non-operational and cannot override `CURRENT.md`, active roadmap capsules, ADRs, setup gates, validated snapshots, or active `AGENTS.md` instructions.
