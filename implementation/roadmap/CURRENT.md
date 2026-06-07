# Runiac Current Roadmap Context

## Current Routing

- Current track: Track A - Governance and implementation readiness
- Current phase: `implementation/roadmap/phases/phase-01-governance-ci.md`
- Current active capsule: `implementation/roadmap/capsules/run-static-read-model-snapshot-readiness.md`.
- Most recent completed capsule: `run-static-read-model-snapshot-readiness` implemented and validated as a static frontend-only Run presentation refactor; commit and push are handled by the current capsule execution. Previous completed implementation was `you-plans-static-ui` follow-up backend-read-model readiness refactor committed and pushed at `acdbcff refactor(you): prepare static plans UI for read models`.
- Current status: Phase 01 governance CI closed; Artifact Inventory Schema persistence completed; Repository Workflow Record capsule closed; Flutter scaffold baseline present at `implementation/mobile/runiac_app/`; `flutter-app-shell-baseline` capsule closed after static app shell implementation; post-shell static UI/nav alignment checkpoint pushed at `247b4e5 feat(mobile): align static Runiac nav baseline`; `android-ui-smoke-test-evidence` validation capsule closed; `home-dashboard-visual-polish` closed after static Home dashboard visual polish; `premium-home-dashboard-static-wireframe-alignment` closed after static Premium Home Dashboard wireframe alignment; `github-actions-governance-ci-baseline` closed after adding the minimal GitHub Actions governance workflow; `home-dashboard-scroll-layout-stability-fix` closed after stabilizing Home dashboard scroll/card layout; `run-tab-static-placeholder` closed after adding the static RunLandingPage-style Run tab placeholder; `run-tab-fullscreen-map-overlay-alignment` closed after static Run tab fullscreen map overlay layout alignment; `home-dashboard-reference-layout-alignment` closed after static Home dashboard reference layout alignment; `maps-tab-static-placeholder` committed and pushed at `323507b feat(mobile): polish static maps layout`; `run-launch-fullscreen-static-interaction` committed and pushed at `b5c31ef feat(mobile): add static run launch interaction`; Run launch back-handling cleanup committed and pushed at `5851057 chore(mobile): simplify run launch back handling`; `home-dashboard-primary-action-simplification` closed after Home primary action and brand color hierarchy polish; `run-launch-brand-color-polish` closed after static Run launch brand color polish; `maps-static-discovery-hierarchy-polish` closed after static frontend-only Maps discovery hierarchy polish; `leaderboard-static-motivation-hierarchy-polish` superseded before implementation due to the refined map-first Leaderboard direction; `leaderboard-map-first-landing-shell` closed after static frontend-only Leaderboard map-first landing shell implementation; `github-actions-flutter-validation-baseline` is closed after workflow commit `587cc0e ci: add flutter validation to governance workflow`; `leaderboard-help-modal-shell` is closed after implementation commit `96a2706 feat(mobile): add leaderboard tips popup`, roadmap closure commit `2d1ec46 docs(roadmap): close leaderboard help modal capsule`, and manually confirmed hosted GitHub Actions PASS for `96a2706`; `flutter-frontend-hygiene-cleanup` is closed after implementation commit `8074092 chore(mobile): apply frontend hygiene cleanup`, local validation, and manually confirmed hosted GitHub Actions PASS for `8074092`; `leaderboard-region-preview-sheet-shell` is closed at `09d6389` with hosted GitHub Actions Governance CI #41 PASS; `leaderboard-leagues-popup-shell` is closed at `e1d8b74` with hosted GitHub Actions Governance CI #42 PASS; Run launch map UI is closed at `08c51c7` with hosted GitHub Actions Governance CI #43 PASS; Run Live Tracking compact card is closed at `b0798b0` with hosted GitHub Actions Governance CI #45 PASS; Run Live Tracking pause split controls are closed at `5cb00ad` with hosted GitHub Actions Governance CI #47 PASS; Run Hold-to-End static interaction is closed at `027c960` with hosted GitHub Actions Governance CI #49 PASS.
- Current state: Scaffold-baseline governance state with the static Flutter mobile UI split into a feature-first-lite source structure; Phase 02 remains unselected; hosted GitHub Actions now runs `git diff --check`, `./tools/governance-ci/run-all-checks.sh`, Flutter SDK setup, `flutter pub get`, `flutter analyze --no-pub`, and `flutter test`; the Leaderboard information affordance still opens a centered static Tips popup/dialog; the Leaderboard league/division pill opens a separate static Leagues taxonomy popup; the region preview sheet remains draggable and static; Run launch displays a static full-screen map-style launch UI with top close/GPS/settings controls, shared circular tap feedback, static runner marker, and a floating Today's Plan / Start Run card; the Run Live Tracking state uses a compact static progress card with no internal Today's Plan / Running header, no Heart metric, no backend-owned value mutation, and a static Pause to Resume / End interaction with shared action-area width and matching action heights; paused End now requires press-and-hold with an internal progress/fill, keeps the visible label exactly `End`, normal tap does not end, early release resets, and completed hold remains an inert/no-op boundary; `you-plans-static-ui` is committed at `6624267`; the You page presentation-layer backend-read-model readiness refactor is committed and pushed at `acdbcff`.
- Current governance decision record: ADR-003 Governance Lite Execution Lanes is adopted as a decision record only. It documents UI Fast Lane, Backend Guarded Lane, and Governance/Architecture Lane for future routed work, but does not activate or enforce a new workflow, change CI, change AGENTS instructions, authorize Flutter/Firebase/backend implementation, or select Phase 02.
- Current active milestone: Run static read-model snapshot readiness is implemented and validated as a small static frontend-only presentation refactor; Phase 02 remains unselected.

## Layered Reading Order

Use minimal context loading. CURRENT.md remains the operational source of truth, and active capsule scope isolation remains mandatory.

Hot path, read by default:

1. `implementation/roadmap/CURRENT.md`
2. Active capsule document: `implementation/roadmap/capsules/run-static-read-model-snapshot-readiness.md`
3. `implementation/roadmap/snapshots/latest.md`

Warm path, read only when triggered by routing, scope, risk, or a direct task request:

4. Active phase document: `implementation/roadmap/phases/phase-01-governance-ci.md` (closed)
5. Relevant ADRs listed below
6. Traceability, setup gates, validation/review templates, or implementation/mobile instructions when the task touches those boundaries.

Cold path, do not load during normal tasks unless explicitly requested or routed:

- `docs/meta/*`, workflow records, retrospective/history files, old review outputs, archived snapshots, `roadmap-stretch.md`, future phase documents, and broad historical planning documents.

Do not load future phase documents unless explicitly requested.

## Relevant ADRs

- `implementation/roadmap/decisions/ADR-001-tier-gate-system.md`
- `implementation/roadmap/decisions/ADR-002-emulator-first.md`
- `implementation/roadmap/decisions/ADR-003-governance-lite-execution-lanes.md`

## Allowed Work

- Maintain roadmap/context governance files under `implementation/roadmap/`.
- Maintain active and completed capsule status under `implementation/roadmap/capsules/` when explicitly routed.
- Maintain root `AGENTS.md` roadmap context protocol when required.
- Update `snapshots/latest.md` from confirmed repository state only.
- Update CURRENT.md immediately when active phase, active capsule, gate status, or forbidden scope changes.
- Use Workflow Memory Drift Check output only as detection-only local Governance CI support; it must not automatically mutate workflow memory, snapshots, CURRENT.md, or capsules.
- Maintain the scaffold baseline state only; this task has explicit implementation approval for the routed `run-static-read-model-snapshot-readiness` static frontend-only Run presentation refactor capsule.
- Apply the Safe Visible Product Acceleration Rule recorded in `implementation/roadmap/phases/phase-01-governance-ci.md` for future explicitly routed frontend prototype capsules: one visible screen-level improvement per capsule, static Flutter UI, placeholder display data, existing widgets/dependencies, small widget test updates, and minimal required capsule/snapshot updates only.

## Forbidden Work

- Do not run Flutter, Firebase, npm, build, test, deploy, scaffold, or init commands.
- Do not create production implementation code.
- Do not modify existing implementation logic.
- Do not expand the generated Flutter scaffold into Runiac production features or tests without separate approval.
- Do not run `flutterfire configure`; Firebase remains uninitialized.
- Do not treat Safe Visible Product Acceleration as approval for Firebase/Auth/Firestore/Cloud Functions setup, `flutterfire configure`, Google Maps or Mapbox SDK integration, GPS/native configuration, new dependencies without explicit approval, client-side mutation or calculation of backend-owned values, XP/streak/level/rank/leaderboard score/weekly XP/monthly XP/subscription privilege state/expert plan publication state logic, unrelated refactors, roadmap expansion, or new ADRs unless a real architecture decision is unavoidable.
- Do not modify `docs/submissions/`, `PRD.md`, or frozen submitted PDD snapshots.
- Do not load `roadmap-stretch.md`, archived snapshots, or future phase docs unless explicitly requested.
- Do not treat `docs/meta` as operational truth, approval evidence, routing authority, setup-gate authority, or implementation guidance.
- Do not create Repository Genesis material, timelines, full history reconstruction, retrospectives, artifact inventory entries, or autonomous archive/index systems.

## Next Gate

Next gate is user review of the committed `run-static-read-model-snapshot-readiness` capsule. Future Leaderboard read-model readiness work remains unrouted.

## Operational TODO / Active Capsule

Active capsule: `implementation/roadmap/capsules/run-static-read-model-snapshot-readiness.md`.

Required next-session checklist:

1. Start with required layered context loading from `implementation/roadmap/CURRENT.md`.
2. Confirm repository state with `git status --short`.
3. Load the active capsule document before any follow-up work.
4. Review the committed `acdbcff` roadmap and You page state before selecting any next refactor capsule.
5. If committing, stage only the task-relevant files listed by the final status.
6. Do not touch unrelated dirty files if any appear.
7. Do not add fake users/ranks/XP/scores/levels, plan completion calculations, completed-run calculations, remaining-run calculations, expert eligibility logic, Firebase/backend/GPS/native/dependency work, sharing integration, premium gating, subscription logic, or Phase 02 selection.

Closure validation for `leaderboard-leagues-popup-shell`:

- `git diff --check` PASS.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub` PASS.
- `cd implementation/mobile/runiac_app && flutter test` PASS.
- `./tools/governance-ci/run-all-checks.sh` PASS after adding the routed capsule document to the diff-hygiene allowlist.
- Hosted GitHub Actions Governance CI #42 PASS for commit `e1d8b74`.

Closure validation for Run launch map UI:

- Implementation commit: `08c51c7 feat(run): add floating plan launch map UI`.
- Hosted GitHub Actions Governance CI #43 PASS for commit `08c51c7b25bcdfcf8415ffcfe45a2f01a38cae9b`.
- Local validation before implementation commit: `flutter analyze` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS.
- Implemented scope: Run launch UI only, including full-screen map-style background, top-left X button, top-center GPS ready pill, top-right settings gear button, shared X/settings circular tap feedback, static runner marker, and floating Today's Plan / Start Run card.
- Required boundary preserved: bottom navigation shell unchanged; no Home, Maps, Leaderboard, or You/Profile changes; no Firebase/backend/GPS/timer/dependency changes; no XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state mutation.
- Next expected milestone: explicit next capsule selection only.

Closure validation for Run Live Tracking compact card:

- Implementation commit: `b0798b0 feat(run): compact live tracking card`.
- Hosted GitHub Actions Governance CI #45 PASS for commit `b0798b0817de38860bd74f2b430a69653db38d8f`.
- Local validation before implementation commit: `flutter analyze` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS.
- Implemented scope: Run Live Tracking compact card only, including removal of the internal Live Tracking card `TODAY'S PLAN` / `RUNNING` header row, compact progress summary row (`4.10 of 4.50 km` and `91%`), slim orange progress bar, centered `DISTANCE` / `4.10 km` block, two-metric lower row (`TIME`, `AVG PACE`), removed `HEART`, reduced metrics typography/spacing/card padding, and reduced Pause button footprint.
- Required boundary preserved: Run launch state preserved; shell and bottom navigation unchanged; no Home, Maps, Leaderboard, or You/Profile changes; no Firebase/backend/GPS/timer/dependency changes; no XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state mutation.
- Next expected milestone: explicit next capsule selection only.

Closure validation for Run Live Tracking pause split controls:

- Implementation commit: `5cb00ad feat(run): add pause split controls`.
- Hosted GitHub Actions Governance CI #47 PASS for commit `5cb00aded3ef00e2019fabd8160c435b205de4b6`; check suite `71048028715` completed with conclusion `success`, and job `governance-ci` completed with conclusion `success`.
- Local validation before implementation commit: `flutter analyze` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS.
- Implemented scope: Run Live Tracking Pause static interaction only, including Pause splitting into Resume and End, Resume returning to the live static state, End remaining static/no-op, Pause width matching the paused Resume + End action-row width, and Resume/End heights matching Pause through the shared action area.
- Required boundary preserved: compact Live Tracking metrics/card layout preserved; removed internal Live Tracking card `TODAY'S PLAN` / `RUNNING` header row not re-added; shell and bottom navigation unchanged; no Home, Maps, Leaderboard, or You/Profile changes; no Firebase/backend/GPS/timer/dependency changes; no run persistence, activity summary navigation, XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state mutation.
- Next expected milestone: explicit next capsule selection only.

Closure validation for Run Hold-to-End static interaction:

- Implementation commit: `027c960 feat(run): add hold to end interaction`.
- Hosted GitHub Actions Governance CI #49 PASS for commit `027c960793f92c4f4831b7f418389fec34de35aa`; run `26529762873` completed with status `completed` and conclusion `success`, and job `governance-ci` completed with conclusion `success`.
- Local validation before implementation commit: `flutter analyze` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS.
- Implemented scope: Run paused-state Hold-to-End static interaction only, including End requiring press-and-hold, internal hold progress/fill, visible End label remaining exactly `End`, normal tap not ending, early release resetting, and completed hold calling only the existing inert/no-op future-boundary callback.
- Required boundary preserved: compact Live Tracking metrics/card layout unchanged; Pause and Resume behavior unchanged; shell and bottom navigation unchanged; no Home, Maps, Leaderboard, or You/Profile changes; no Firebase/backend/GPS/timer/dependency changes; no real run completion, activity summary navigation, run persistence, XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state mutation.
- Next expected milestone: explicit next capsule selection only.

Recently closed CI capsule:

- Capsule: `implementation/roadmap/capsules/github-actions-flutter-validation-baseline.md`
- Type: CI workflow update / hosted validation baseline
- Routing commit: `95d1eed docs(roadmap): route flutter validation ci capsule`
- Implementation commit: `587cc0e ci: add flutter validation to governance workflow`
- Closure evidence: local `git diff --check`, `./tools/governance-ci/run-all-checks.sh`, `flutter analyze --no-pub`, and `flutter test` passed before commit; hosted GitHub Actions status for `587cc0e` was manually confirmed PASS by the user.
- Implemented workflow scope: `.github/workflows/governance-ci.yml` now runs `git diff --check`, `./tools/governance-ci/run-all-checks.sh`, Flutter SDK setup, `flutter pub get`, `flutter analyze --no-pub`, and `flutter test`.
- Required boundary preserved: no Flutter app source changes, no Flutter widget test behavior changes, no Firebase/Auth/Firestore/Cloud Functions/FCM, no Firebase init/deploy, no secrets/config/environment setup, no Android/iOS native build or release workflow, no dependency/package changes, no product feature implementation, no `leaderboard-help-modal-shell` implementation, and no Phase 02 selection.

Recently closed product capsule:

- Capsule: `implementation/roadmap/capsules/leaderboard-help-modal-shell.md`
- Completion commit: `96a2706 feat(mobile): add leaderboard tips popup`
- State: closed after local validation and manually confirmed hosted GitHub Actions PASS for `96a2706`.
- Implemented scope: existing Leaderboard information affordance opens a centered Tips popup/dialog; popup includes concise beginner-friendly help content for Leagues, Weekly vs Monthly, and Ranking readiness; close behavior is implemented; widget tests cover open/content/dismiss and forbidden fake content absence.
- Required boundary preserved: no league selector popup, region tap behavior, region preview bottom sheet, fake leaderboard rows, fake users, fake ranks, fake XP, fake scores, fake levels, fake streaks, Firebase/Auth/Firestore/Cloud Functions/FCM, GPS/location, backend work, dependency changes, workflow changes, shell changes, native Android/iOS changes, scaffold, build, init, deploy, or Phase 02 selection.

Recently closed capsule:

- Capsule: `implementation/roadmap/capsules/leaderboard-map-first-landing-shell.md`
- Type: Flutter static frontend-only Leaderboard landing shell capsule
- Completion commit: `b1ed742 feat(mobile): add leaderboard map landing shell`
- Chain completed: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Implemented scope: map-first Leaderboard landing shell, Leaderboard-only AppBar suppression through the shell, static `Weekly XP / Monthly XP` overlay, static league selector overlay, visual info button, and static user ranked-area highlight.
- Required boundary preserved: no help modal behavior, region tap behavior, region preview bottom sheet, bottom sheet visible by default, real map SDK, real map tiles, GPS/current-location behavior, real leaderboard data, leaderboard aggregation, fake users, fake ranks, fake XP, fake scores, fake streaks, fake levels, profile rows, leaderboard rows, XP/streak/level/rank/leaderboard score/weekly XP/monthly XP mutation, Firebase, Auth, Firestore, Cloud Functions, FCM, backend work, dependency changes, native Android/iOS changes, scaffold, build, init, deploy, unrelated tab changes, or Phase 02 selection.
- Validation completed before implementation commit: `git diff --check` PASS; `flutter analyze --no-pub` PASS; `flutter test` PASS; `./tools/governance-ci/run-all-checks.sh` PASS; final implementation status clean and aligned with `origin/main`.
- Stop state: closed and pushed. Do not select Phase 02 or a next capsule until separately routed.

Most recent completed capsule:

- Capsule: `implementation/roadmap/capsules/run-launch-brand-color-polish.md`
- Type: Flutter static frontend-only Run launch visual polish capsule
- Completion commit: `e1f9c6d feat(mobile): polish run launch brand colors`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Implemented scope: Start button changed to orange/action-oriented, route line remained blue, Setting and Route setup remained secondary white/blue pill actions, Today's Plan stayed calm and readable, and behavior remained unchanged.
- Required boundary preserved: no Phase 02 selection, Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real run tracking, timer, distance, pace, duration, heart-rate, cadence, calories, activity submission, route setup logic, real route generation, fake run metrics, XP/streak/level/rank/leaderboard, premium entitlement, backend-like data behavior, dependency, native platform, shell navigation, Home, Maps, or unrelated screen changes.
- Validation completed: `git diff --check` PASS; `flutter analyze --no-pub` PASS; `flutter test` PASS; Governance CI PASS.
- Stop state: closed and pushed. No next capsule is selected.

Prior completed Home milestone:

Home dashboard primary action simplification capsule is committed and pushed:

- Capsule: `implementation/roadmap/capsules/home-dashboard-primary-action-simplification.md`
- Type: Flutter static frontend-only Home dashboard polish capsule
- Completion commits: `9254faa feat(mobile): polish home primary action hierarchy`; `bd2963d feat(mobile): polish home brand action hierarchy`
- Required boundary preserved: no Phase 02 selection, Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real run tracking, timer, distance, pace, duration, heart-rate, cadence, calories, activity submission, real plan generation, XP/streak/level/rank/leaderboard, premium entitlement, backend-like data behavior, dependency, native platform, shell navigation, or unrelated screen changes.
- Stop state: closed and pushed.

Prior completed Run launch milestone:

Run launch fullscreen static interaction capsule is committed and pushed:

- Capsule: `implementation/roadmap/capsules/run-launch-fullscreen-static-interaction.md`
- Type: Flutter static UI interaction capsule
- Completion commit target: `feat(mobile): add static run launch interaction`
- Latest related cleanup commit: `5851057 chore(mobile): simplify run launch back handling`
- Required boundary preserved: no Phase 02 selection, Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real map SDK, route generation, route persistence, run tracking, timer, distance, pace, duration, heart-rate, cadence, activity submission, XP/streak/level/rank/leaderboard, premium entitlement, dependency, native platform, GitHub Actions workflow, or unrelated screen changes.
- Stop state: closed and pushed.

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

Prior ready-for-commit milestone remains awaiting manual commit:

Flutter source structure refactor capsule is ready for commit:

- Capsule: `implementation/roadmap/capsules/flutter-source-structure-refactor.md`
- Type: Flutter source-structure refactor capsule
- Completion commit target: `chore(mobile): split static Flutter source structure`
- Chain: A0_ORCH -> A9_TRACE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`.
- Implemented scope: split the static Flutter app from monolithic `app.dart` into a thin app composition file, core theme/colors, shared visual widgets, shell navigation, and currently implemented Home, Maps, Run, Leaderboard, and You feature presentation files.
- Required boundary preserved: behavior-preserving source structure only; no UI redesign, new features, Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real map SDK, route generation, route persistence, run tracking, activity submission, backend-owned values, dependency changes, native Android/iOS changes, workflow configuration changes, Plan bottom-navigation tab, empty Plan folders, or Phase 02 selection.
- Stop state: ready for commit only; awaiting manual staging, commit, and push.

This closed state does not approve Phase 02 implementation, Firebase setup, `flutterfire configure`, dependency installation, build, init, deploy, backend work, or additional Flutter implementation.

Maps tab static placeholder capsule is ready for commit:

- Capsule: `implementation/roadmap/capsules/maps-tab-static-placeholder.md`
- Type: Flutter UI product-code-changing capsule
- Completion commit target: `feat(mobile): add static maps tab placeholder`
- Chain: A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
- Validation: `flutter analyze --no-pub` PASS; `flutter test` PASS; `git diff --check` PASS; Governance CI PASS; Android smoke evidence PASS on `emulator-5554`.
- Implemented scope: replaced the generic Maps placeholder with a static MapsLandingPage-style screen using a full map-like background, decorative roads/route-like shapes, marker placeholders, a top search bar, a primary-blue Saved pill control, and a draggable bottom shared route panel with safe placeholder cards.
- Required boundary preserved: static UI layout only; no Firebase, Auth, Firestore, Cloud Functions, GPS/location permission, current location state, real map SDK, route generation, route recommendation logic, saved-route persistence, fake route/place/distance/duration/difficulty/rating/saved-count/community data, dependency changes, native Android/iOS changes, workflow configuration changes, or Phase 02 selection.
- Stop state: ready for commit only; awaiting manual staging, commit, and push.

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
- Temporary screenshot captured outside the repository at `/private/tmp/runiac-android-smoke.png`; screenshot remains outside version control.
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
