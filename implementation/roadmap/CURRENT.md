# Runiac Current Roadmap Context

## Current Routing

- Current track: Track A - Governance and implementation readiness
- Current phase: `implementation/roadmap/phases/phase-01-governance-ci.md`
- Current active capsule: `implementation/roadmap/capsules/run-launch-fullscreen-static-interaction.md`
- Most recent completed capsule: `implementation/roadmap/capsules/maps-tab-static-placeholder.md` (ready for commit state recorded; not staged, committed, or pushed by that pass)
- Current status: Phase 01 governance CI closed; Artifact Inventory Schema persistence completed; Repository Workflow Record capsule closed; Flutter scaffold baseline present at `implementation/mobile/runiac_app/`; `flutter-app-shell-baseline` capsule closed after static app shell implementation; post-shell static UI/nav alignment checkpoint pushed at `247b4e5 feat(mobile): align static Runiac nav baseline`; `android-ui-smoke-test-evidence` validation capsule closed; `home-dashboard-visual-polish` capsule closed after static Home dashboard visual polish; `premium-home-dashboard-static-wireframe-alignment` capsule closed after static Premium Home Dashboard wireframe alignment; `github-actions-governance-ci-baseline` capsule closed after adding the minimal GitHub Actions governance workflow; `home-dashboard-scroll-layout-stability-fix` capsule closed after stabilizing Home dashboard scroll/card layout; `run-tab-static-placeholder` capsule closed after adding the static RunLandingPage-style Run tab placeholder; `run-tab-fullscreen-map-overlay-alignment` closed after static Run tab fullscreen map overlay layout alignment; `home-dashboard-reference-layout-alignment` closed after static Home dashboard reference layout alignment; `maps-tab-static-placeholder` recorded ready for commit after static Maps tab placeholder implementation and validation; `flutter-source-structure-refactor` is ready for commit after a behavior-preserving feature-first-lite source split; `run-controls-and-plan-spacing-polish` was committed and pushed at `08bca0f fix(mobile): polish run tab controls spacing`; `run-launch-fullscreen-static-interaction` is ready for commit after static Run launch screen interaction implementation
- Current state: Scaffold-baseline governance state with the static Flutter mobile UI split into a feature-first-lite source structure; Phase 02 remains unselected; the active implementation capsule is limited to static full-screen Run launch interaction
- Current active milestone: commit `implementation/roadmap/capsules/run-launch-fullscreen-static-interaction.md` and its scoped static Run launch interaction changes only if explicitly approved later

## Required Reading Order

1. `implementation/roadmap/CURRENT.md`
2. Active phase document: `implementation/roadmap/phases/phase-01-governance-ci.md` (closed)
3. Active capsule document: `implementation/roadmap/capsules/run-launch-fullscreen-static-interaction.md`
4. Relevant ADRs listed below
5. `implementation/roadmap/snapshots/latest.md`

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

Run launch fullscreen static interaction capsule is ready for commit:

- Capsule: `implementation/roadmap/capsules/run-launch-fullscreen-static-interaction.md`
- Type: Flutter static UI interaction capsule
- Completion commit target: `feat(mobile): add static run launch interaction`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Allowed scope: static Run bottom-navigation launch interaction, full-screen slide-up Run launch route, top-left close affordance, Android back dismissal, static beginner-friendly launch copy, and widget coverage for open/close/back behavior.
- Required boundary: no Phase 02 selection, Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real map SDK, route generation, route persistence, run tracking, timer, distance, pace, duration, heart-rate, cadence, activity submission, XP/streak/level/rank/leaderboard, premium entitlement, dependency, native platform, GitHub Actions workflow, or unrelated screen changes.
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke screenshot skipped by user preference to reduce iteration time.
- Implemented scope: Run bottom-nav item now pushes an opaque full-screen slide-up Run launch route without selecting the Run tab underneath; launch screen hides the shell bottom nav while open, provides a top-left Close button, preserves Android back dismissal, keeps Start inert/static, and uses a separate floating Today’s Plan card plus independent Setting / Start / Route setup controls over the static map-like background.
- Stop state: ready for commit only; do not stage, commit, or push.

Prior completed Run polish milestone:

Run controls and plan spacing polish capsule is committed and pushed:

- Capsule: `implementation/roadmap/capsules/run-controls-and-plan-spacing-polish.md`
- Type: Flutter static UI polish capsule
- Completion commit target: `fix(mobile): polish run tab controls spacing`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Allowed scope: static Run tab spacing, constraints, hierarchy, bottom/nav clearance, and small-screen readability for Setting / Start / Switch Route.
- Required boundary: no Phase 02 selection, Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real map SDK, route generation, route persistence, run tracking, timer, distance, pace, duration, heart-rate, cadence, activity submission, XP/streak/level/rank/leaderboard, premium entitlement, dependency, native platform, GitHub Actions workflow, or unrelated screen changes.
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`.
- Implemented scope: grouped the Today’s Plan card and controls into one bottom overlay column, increased bottom clearance, capped overlay width, added compact spacing for narrow widths, kept Start visually primary, and kept Setting / Switch Route as static secondary controls with safer label fit.
- Stop state: ready for commit only; do not stage, commit, or push.

Prior ready-for-commit milestone remains uncommitted:

Flutter source structure refactor capsule is ready for commit:

- Capsule: `implementation/roadmap/capsules/flutter-source-structure-refactor.md`
- Type: Flutter source-structure refactor capsule
- Completion commit target: `chore(mobile): split static Flutter source structure`
- Chain: A0_ORCH -> A9_TRACE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`.
- Implemented scope: split the static Flutter app from monolithic `app.dart` into a thin app composition file, core theme/colors, shared visual widgets, shell navigation, and currently implemented Home, Maps, Run, Leaderboard, and You feature presentation files.
- Required boundary preserved: behavior-preserving source structure only; no UI redesign, new features, Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real map SDK, route generation, route persistence, run tracking, activity submission, backend-owned values, dependency changes, native Android/iOS changes, workflow configuration changes, Plan bottom-navigation tab, empty Plan folders, or Phase 02 selection.
- Stop state: ready for commit only; not staged, committed, or pushed.

This closed state does not approve Phase 02 implementation, Firebase setup, `flutterfire configure`, dependency installation, build, init, deploy, backend work, or additional Flutter implementation.

Maps tab static placeholder capsule is ready for commit:

- Capsule: `implementation/roadmap/capsules/maps-tab-static-placeholder.md`
- Type: Flutter UI product-code-changing capsule
- Completion commit target: `feat(mobile): add static maps tab placeholder`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`.
- Implemented scope: replaced the generic Maps placeholder with a static MapsLandingPage-style screen using a full map-like background, decorative roads/route-like shapes, marker placeholders, a top search bar, a primary-blue Saved pill control, and a draggable bottom shared route panel with safe placeholder cards.
- Required boundary preserved: static UI layout only; no Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real map SDK, route generation, route recommendation logic, saved-route persistence, fake route/place/distance/duration/difficulty/rating/saved-count/community data, dependency changes, native Android/iOS changes, workflow configuration changes, or Phase 02 selection.
- Stop state: ready for commit only; not staged, committed, or pushed.

Home dashboard reference layout alignment capsule is complete:

- Capsule: `implementation/roadmap/capsules/home-dashboard-reference-layout-alignment.md`
- Type: Flutter UI layout-alignment capsule
- Completion commit target: `fix(mobile): align home dashboard reference layout`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`.
- Implemented scope: aligned the static Home dashboard closer to the provided wireframe structure using safe placeholder copy and the section order Greeting / Today's Plan / Training Goal / Runner Progress / This Week's Plan / Last Run / Post-run Feedback / Recommended Routes.
- Required boundary preserved: static UI layout only; no Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, real map integration, timer, distance, pace, heart-rate, cadence, activity recording, activity submission, fake AI advice, fake premium entitlement, backend-owned values, dependency changes, native Android/iOS changes, or Phase 02 selection.

Run tab fullscreen map overlay alignment capsule is complete:

- Capsule: `implementation/roadmap/capsules/run-tab-fullscreen-map-overlay-alignment.md`
- Type: Flutter UI layout-alignment capsule
- Completion commit target: `fix(mobile): align run tab map overlay layout`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`.
- Implemented scope: removed the visible setup-later helper card, kept the fullscreen map-like background, preserved the floating Today's Plan card, and positioned Setting / Start / Switch Route below the card and above bottom navigation.
- Required boundary preserved: static UI layout only; no Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, real map integration, timer, distance, pace, heart-rate, cadence, activity recording, activity submission, backend-owned values, dependency changes, native Android/iOS changes, or Phase 02 selection.

Run tab static placeholder capsule is complete:

- Capsule: `implementation/roadmap/capsules/run-tab-static-placeholder.md`
- Type: Flutter UI product-code-changing capsule
- Completion commit target: `feat(mobile): add static run tab placeholder`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`
- Implemented scope: static RunLandingPage-style Run tab placeholder using a large route/map-looking visual area, static route line, marker/flag placeholders, Today's Plan card, Setting button, central Start button, Switch Route button, and safe setup-later copy.
- Preserved bottom navigation Home / Maps / Run / Leaderboard / You and the Runiac logo palette.
- No Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, real map integration, timer, distance, pace, heart-rate, cadence, activity recording, activity submission, backend-owned values, dependency changes, native Android/iOS changes, or Phase 02 selection was introduced.

Home dashboard scroll layout stability fix capsule is complete:

- Capsule: `implementation/roadmap/capsules/home-dashboard-scroll-layout-stability-fix.md`
- Type: Flutter UI bugfix capsule
- Completion commit target: `fix(mobile): stabilize home dashboard scrolling`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`
- Implemented scope: disabled Home dashboard overscroll stretch, kept clamping scroll physics, and made the route placeholder explicitly full-width with its existing fixed height.
- Preserved existing Home section order, static placeholder meaning, bottom navigation Home / Maps / Run / Leaderboard / You, and the Runiac logo palette.
- No Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, backend integration, premium entitlement logic, AI advice logic, fake backend-owned values, new product sections, dependency changes, native Android/iOS changes, or Phase 02 selection was introduced.

GitHub Actions governance CI baseline capsule is complete:

- Capsule: `implementation/roadmap/capsules/github-actions-governance-ci-baseline.md`
- Type: CI/governance documentation + workflow capsule
- Completion commit target: `ci: add governance checks workflow`
- Chain: A0_ORCH -> A9_TRACE -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `git diff --check` PASS; Governance CI PASS; local YAML inspection PASS; GitHub-hosted Actions run verification pending post-push inspection
- Implemented scope: `.github/workflows/governance-ci.yml` runs on push and pull request to `main`, uses `ubuntu-latest`, checkout with `actions/checkout@v4`, runs `git diff --check`, then runs `./tools/governance-ci/run-all-checks.sh`.
- Governance CI exact allowlist updated only for `.github/workflows/governance-ci.yml` and `implementation/roadmap/capsules/github-actions-governance-ci-baseline.md`.
- No Flutter SDK setup, `flutter pub get`, Flutter analyze/test in Actions, Android/iOS build, Firebase, secrets, environment variables, deployment, product code changes, Phase 02 selection, or product implementation capsule was introduced.
- GitHub-hosted Actions pass/fail status is not claimed in local closure evidence; it requires a real post-push run inspection.

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
