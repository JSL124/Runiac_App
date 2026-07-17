# Runiac Current Roadmap Context

## Current Routing

- Current track: Track A - Governance and implementation readiness
- Current phase: `implementation/roadmap/phases/phase-01-governance-ci.md`
- Current active capsule: `implementation/roadmap/capsules/adaptive-character-guidance.md`. The user explicitly authorized the remaining privacy-consent and App Check gates, implementation validation, commit, secret rotation, and production deployment on 2026-07-15 Asia/Singapore. Existing Leaderboard working-tree changes remain unrelated and must stay unstaged.
- Most recent pushed / hosted-CI-verified completed capsule: `goal-plan-detail-header-timeline-alignment` implemented, pushed at `7798f058ae1b272e8eca6dd8a31cba4490c8faa1 feat(you): refine goal plan detail week list`, and verified by hosted Governance CI #65 PASS for run ID `27160664756`.
- Most recent locally closed implementation milestone: `personalized-adaptive-estimate-learning` completed locally after RED/GREEN Functions and Firestore rules evidence on 2026-07-07 Asia/Singapore.
- Current status in this isolated worktree: Home/You state-stability is implemented and verified with focused Home/You tests, analyze, diff hygiene, and real-screen simulator evidence. Full `flutter test --no-pub` still fails only the seven known baseline failures recorded in the capsule. Activity History durable preview/feed recovery, Activity Summary Agent Feedback, cadence capture reliability recovery, prior Feed/Friends, and unrelated work remain separate and untouched.
- Current state: worktree baseline was cleaned at `c85eb1f7 fix(shell): refresh progress on day rollover` before this capsule routing. The open adaptive-character capsule and concurrent user-owned Leaderboard/You/design/test changes remain unrelated and untouched.
- Current governance decision record: ADR-003 classifies this work as Backend Guarded Lane; ADR-002 requires Emulator First. Project `demo-runiac-feed` and explicit Auth/Firestore/Functions/Storage host guards are mandatory before any fixture mutation.
- Current active milestone: `adaptive-character-guidance`. Phase 02 remains unselected.
- Newly routed backed Friends MVP on 2026-07-13 Asia/Singapore: `implementation/roadmap/capsules/friends-backend-mvp.md` now integrates the authenticated nickname/profile callables, atomic request/friend/block transitions, rate/cooldown limits, Unicode migration, owner Rules/indexes, and the callable-backed Flutter Friends/Profile client. Suggested is removed; Friends / Search / Requests / Blocked use backed owner lists and callables. The exact ten Friends/nickname Functions and Friends indexes are deployed to `runiac-fypp`, focused backend/Rules/Flutter tests and fresh simulator visual QA pass, and unrelated Challenge/Run work remains outside this client commit. The stricter Firestore Rules remain a coordinated client-cutover step until legacy direct nickname writers are confirmed absent.
- Newly routed capsule in the main worktree on 2026-07-12 Asia/Singapore: `implementation/roadmap/capsules/home-social-dropdown-friends-shell.md`. The user explicitly routed a Safe Visible Product Acceleration frontend capsule adding a static Home stage-map `Social` dropdown (Friends navigation plus Challenge Coming-soon stub) and a new static demo-data Friends feature module with Friends / Search / Suggested / Requests tabs. It is frontend-only: no feed changes, no Firebase/Firestore/Cloud Functions work, no `users/{uid}/friends` I/O, no XP/level/rank/streak calculation or mutation, no new dependencies, and no shell/navigation changes. This routing is append-only and does not modify or supersede the `activity-history-durable-preview-recovery` capsule in its separate isolated worktree.
- Newly routed Friends-row refinement on 2026-07-13 Asia/Singapore: `implementation/roadmap/capsules/friends-row-add-pending-icons.md` is an in-progress, static frontend-only follow-up to the Friends shell. It keeps Friends, Search, Suggested, and Requests tabs; makes Friends rows badge-plus-name only; adds session-local Add then noninteractive Pending icon states to Search/Suggested; and preserves Requests unchanged. It permits only supplied-asset registration and no dependency changes. No Firebase/Firestore/Cloud Functions work, relationship/request I/O, persistence, feed change, navigation change, or XP/level/rank/streak mutation is authorized. This append-only routing does not supersede the active cadence capsule or concurrent work.
- Newly routed Challenge distance system on 2026-07-13 Asia/Singapore: `implementation/roadmap/capsules/challenge-distance-system.md` is an explicitly user-routed Backend Guarded Lane full-stack capsule (ADR-002 emulator-first, ADR-003 lane rules) delivering all nine distance-challenge tiers (10K–1000K, versioned catalog `challenge-distance-v1`), server-owned lobby/slot/invitation/start transactions, validated-run contribution through the `completeRun` seam, leave/abandon/deadline settlement with idempotent badge grants, member-scoped Firestore rules, privacy-safe notifications/history, and Flutter Explore/detail/lobby/invitations/Home-control/Progress/result/history/badge-collection surfaces with English copy and the user-created badge assets. Prerequisites verified at routing: badge work committed at `e26c8a10`, reciprocal-friend contract present in `functions/src/feed/relationship.ts`, clean worktree. A later explicit user authorization permitted the scoped backend production deploy and commit: `runiac-fypp` now reports all 40 expected Functions ACTIVE, the Challenge indexes present, and the catalog callable reachable with authentication enforced. Flutter completion remains separately in progress; client-side trusted-value writes, late-upload grace, admin challenge CRUD, secrets/dependencies, and cadence/activity-history/feed/leaderboard/XP scope edits remain forbidden.
- Newly routed real-time social/challenge sync on 2026-07-14 Asia/Singapore: `implementation/roadmap/capsules/realtime-social-challenge-sync.md` is an explicitly user-routed **client-only** capsule making Friends (send/accept/block/unblock/remove), Challenge invitations (invite/respond), and Challenge lobby/progress (join/withdraw/start/leave/abandon, headcount, status) reflect cross-device changes in real time by subscribing to Firestore snapshots for reads only, while all writes stay on the existing authenticated callables. Key finding: Firestore Rules already permit these authenticated owner/member reads and deny all client writes, and the friend/request/block and invitation/participant docs carry the denormalized fields needed to render, so no Rules/index/Functions change is required. The lobby/roster level label uses the no-server-change hybrid (membership/role/headcount/status live from snapshot; level label best-effort seeded from the last callable). This routing stays outside the ADR-003 Backend Guarded Lane, forbids any `functions/`/Rules/index/dependency edit and any backend-owned value write, and does not modify or supersede the active `home-you-state-stability` capsule or the Challenge distance-system capsule.
- Newly routed cool-down stretch completion XP bonus on 2026-07-14 Asia/Singapore: `implementation/roadmap/capsules/cool-down-stretch-completion-xp-bonus.md` is an explicitly user-routed Backend Guarded Lane full-stack capsule (ADR-002 emulator-first, ADR-003) adding the server-owned `completeCoolDown` callable that awards an idempotent, capped cool-down stretch-completion XP bonus (20% of the activity's credited run XP, nearest-5, min 5 / max 20, bounded by the 100 XP per-activity and 200 XP daily caps, zero for zero-XP/premium bases), rules protection for the new backend-owned activity keys, and display-only Flutter wiring where the guided cool-down Finish action requests the bonus and merely merges/displays the trusted server result — Skip to Summary and partial stretch completion never pay, failures fall back silently to the pre-bonus result. Note it is append-only and does not supersede other active capsules.
- Newly routed profile lifetime-stats backend deploy on 2026-07-16 Asia/Singapore: `implementation/roadmap/capsules/profile-lifetime-stats-backend.md` is an explicitly user-routed Backend Guarded Lane capsule (ADR-002 emulator-first, ADR-003) for the Profile-page Max streak / Total distance values. It adds server-owned self-healing recompute inside the existing `completeRun` transaction — lifetime `totalDistanceMeters`/`totalDistanceLabel` = sum of every validated run's distance, and `longestStreak`/`longestStreakLabel` = the peak streak reconstructed from validated-run history (never-regress) — reusing the already-fetched activity snapshots (no extra reads, idempotent on replay), plus `firestore.rules` backend-owned-key protection for those four keys, and display-only Flutter relay (client renders the labels and shows an em-dash when unpublished; no client-side backend-owned calculation). Emulator-first evidence: completeRun 76/76, Firestore rules suite PASS, Flutter analyze + full suite PASS, and governance CI PASS. The user explicitly authorized a scoped production deploy to `runiac-fypp` limited to `functions:completeRun` and `firestore:rules` on 2026-07-16 Asia/Singapore. Forbidden: full-backend deploy, any agent/LLM/feed/challenge/notification/leaderboard/scheduled function change or deploy, client-side backend-owned value writes, new dependencies, and unrelated scope. This append-only routing does not supersede other active capsules.

- Newly routed admin config control plane on 2026-07-16 Asia/Singapore: `implementation/roadmap/capsules/admin-config-control-plane.md` is an explicitly user-routed (plan-approved) Backend Guarded Lane full-stack capsule (ADR-002 emulator-first, ADR-003) that moves hard-coded progression/XP/cool-down/level-curve, badge thresholds, leaderboard eligibility, feature-access policy, and a marketing thin slice (hero/pricing/announcement) from code constants into Firestore `config/*` + `badgeConfigs/{id}` documents that Cloud Functions read/validate at runtime (deep-merge over DEFAULTS, fall back to DEFAULTS on invalid; zero-regression because DEFAULTS equal current constants), plus a per-user operations console (account/role/subscription/direct XP-level correction/activity invalidation/badge/leaderboard/moderation) written only via the admin website's Admin-SDK path with explicit before/after `adminAuditLogs` audit. The admin website (separate `website/` repo, `firebase-admin` Auth+Firestore only) cannot call callables, so all admin writes are Admin-SDK Firestore writes. Refactor seam: `calculateProgressionAudit()` (`functions/src/progression/progressionAudit.ts:50`), call site `functions/src/run/completeRun.ts:173`, and `completeCoolDown.ts`. Executed as orchestrator (plan of record in `/Users/leejinseo/.claude/plans/`) delegating to workers wave-by-wave. Forbidden: any `runiac-fypp` deploy without separate authorization, client-side backend-owned value writes, mobile dynamic feature gating (deferred), generated league-band editing, new dependencies/secrets, and collision with the isolated `adaptive-character-guidance` worktree. This append-only routing does not supersede other active capsules.

Run Tracking M4-A/M4-B/M4-C1/M4-C2 reconciliation:

- M4-A Local Run Tracking Engine is complete at `c3ee282 fix(run): harden local tracking engine`.
- M4-B Foreground GPS Permission + Provider is complete at `adad6f4 feat(run): add foreground GPS provider`.
- M4-B permission guidance is complete at `f9fe044 fix(run): improve foreground location permission guidance`.
- M4-C1 Local Map Follow Runner UI is complete at `b5124dd feat(run): add local map follow UI`.
- M4-C2 Mapbox Run Map Surface is complete at `4ac294c feat(run): add Mapbox run map surface`.
- Foreground GPS provider exists.
- Local runner marker, route polyline, follow mode, and recenter UI exist.
- Mapbox SDK is integrated for the run map surface behind `MAPBOX_PUBLIC_ACCESS_TOKEN`.
- Missing-token placeholder fallback remains available and Android no-token fallback QA passed.
- Token-backed Mapbox demo readiness is pending real demo-token QA.
- Mapbox styles, tiles, resource requests, and SDK telemetry/network boundary are documented in the mobile app README.
- Raw route/GPS samples remain local-only; only a 3-decimal privacy-masked route preview without timestamps, altitude, accuracy, or speed may be persisted for same-account history thumbnail recovery.
- `completeRun` persists validated activity and run summary documents, backend-owned streak progression audit/state, duration-field split values, and eligible planned-workout progress; route/GPS trace persistence remains out of scope.
- Android permissions are foreground-only.
- iOS permission is when-in-use only.
- Manual/emulator QA passed for the M4-B permission guidance path.
- Still not implemented: route trace backend upload, GPS trace persistence, shared route auto-generation, background tracking, production Firestore deploy, XP/level/rank formulas, and leaderboard aggregation.
- M4-C2 remains demo-gated by a Mapbox public token supplied outside committed source; no real Mapbox token is committed.
- M4-F GPS Quality Diagnostics is implemented locally with scalar diagnostics only: received/accepted/rejected timestamps, accepted/rejected counts, latest rejection reason, latest horizontal accuracy bucket, and iOS precise/reduced/unknown/notChecked accuracy status.
- M4-F blocker-fix validation passed locally after adding non-finite distance rejection evidence, accuracy bucket edge-case evidence, and deterministic event-order handling for latest accepted/rejected GPS status.
- M4-F physical iPhone manual QA passed after `07dd96e fix(ios): raise deployment target to 15` and `832761d fix(run): polish GPS startup UI`: iPhone build/install/launch succeeded, Flutter debug attach succeeded, Run Launch GPS pill was readable, active tracking GPS pill was readable, intrusive orange readiness guidance box was removed, and run tracking UI behaved normally.
- Generated SwiftPM artifacts were cleaned after physical iPhone QA; SwiftPM `Package.resolved` files must remain unstaged and must not be committed as M4-F or Mapbox QA evidence.
- Auto Pause and Moving Time remain future M4-G scope.
- Next recommended work: token-backed Mapbox QA with a real demo public token, or a separately selected roadmap capsule.

## Layered Reading Order

Use minimal context loading. CURRENT.md remains the operational source of truth, and active capsule scope isolation remains mandatory when a capsule is selected.

Hot path, read by default:

1. `implementation/roadmap/CURRENT.md`
2. Active capsule document, if a future task selects one. The most recently reconciled Run Tracking capsule document is `implementation/roadmap/capsules/complete-run-cloud-functions-emulator-skeleton.md`.
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
- Maintain the scaffold baseline state only; the latest completed implementation approval was limited to the routed `goal-plan-detail-static-snapshot-shell` static frontend-only You tab Goal Plan Detail capsule.
- Apply the Safe Visible Product Acceleration Rule recorded in `implementation/roadmap/phases/phase-01-governance-ci.md` for future explicitly routed frontend prototype capsules: one visible screen-level improvement per capsule, static Flutter UI, placeholder display data, existing widgets/dependencies, small widget test updates, and minimal required capsule/snapshot updates only.

## Forbidden Work

- Do not run Flutter, Firebase, npm, build, test, deploy, scaffold, or init commands unless the current task explicitly authorizes validation commands.
- Do not create production implementation code or modify implementation logic outside the explicitly selected active capsule.
- Do not expand the generated Flutter scaffold into Runiac production features or tests without separate approval.
- Do not run or expand `flutterfire configure`; do not add production Firebase config beyond the committed `runiac-fypp` Auth/mobile config at `478898c0` without separate approval.
- Do not treat Safe Visible Product Acceleration as approval for further production Firebase/Auth/Firestore/Cloud Functions setup, `flutterfire configure`, Google Maps or Mapbox SDK integration, GPS/native configuration, new dependencies without explicit approval, client-side mutation or calculation of backend-owned values, XP/streak/level/rank/leaderboard score/weekly XP/monthly XP/subscription privilege state/expert plan publication state logic, unrelated refactors, roadmap expansion, or new ADRs unless a real architecture decision is unavoidable.
- Do not modify `docs/submissions/`, `PRD.md`, or frozen submitted PDD snapshots.
- Do not load `roadmap-stretch.md`, archived snapshots, or future phase docs unless explicitly requested.
- Do not treat `docs/meta` as operational truth, approval evidence, routing authority, setup-gate authority, or implementation guidance.
- Do not create Repository Genesis material, timelines, full history reconstruction, retrospectives, artifact inventory entries, or autonomous archive/index systems.

## Next Gate

Next gate is the user-owned real-screen emulator checklist. Package B is exactly `Ready for user screen QA` plus `Ready for manual commit`; real-screen acceptance remains user-owned and has not been claimed. The isolated task-only Flutter suite passed 1,348/1,348, while the shared tree has five proven unrelated dirty failures. No Phase 02 selection, production service, deploy, secret, automatic staging, or automatic commit is authorized.

## Operational TODO / Active Capsule

Current capsule package: `implementation/roadmap/capsules/adaptive-character-guidance.md`. The package includes the server-owned versioned consent record/callable, consent-before-activity-read enforcement, Flutter consent/revocation UI, Firebase App Check client activation for debug and production attestation providers, App Check enforcement on the two OpenAI-backed callables, focused tests, production secret rotation, and deployment evidence. Existing Leaderboard changes remain unrelated, unstaged, and untouched.

Newly routed capsule package in the main worktree: `implementation/roadmap/capsules/home-social-dropdown-friends-shell.md`. It authorizes only the static Home stage-map `Social` dropdown trigger/menu/barrier, the new static demo-data Friends feature module (models, repository interface, static repository, demo snapshots, 4-tab screen), `home_tab.dart` wiring with an optional `friendsRepository` seam, two new widget-test files, two DESIGN.md component sections, and minimal capsule/routing/diff-hygiene governance updates. Forbidden: feed code, Firebase/Firestore/Cloud Functions, `users/{uid}/friends` I/O, Challenge behavior beyond a Coming-soon SnackBar, XP/level/rank/streak calculation or mutation, new dependencies, shell/navigation changes, and badge-collection UI. Stop state is `Ready for user screen QA` plus `Ready for manual commit`; no staging, commit, or push is authorized.

Required next-session checklist:

1. Start with required layered context loading from `implementation/roadmap/CURRENT.md`.
2. Confirm the logical working root is `/Users/leejinseo/Desktop/FYP_Runiac`; do not launch from the `/Users/leejinseo/Documents/FYP_Runiac` symlink, and keep generated plans, evidence commands, and file links on the Desktop root.
3. Confirm repository state with `git status --short`.
4. Read the active capsule document before further action if one has been selected.
5. Do not load future phase documents or route another capsule unless explicitly requested.
6. Treat the Goal Plan Detail, Weekly Workout Detail, Expert Plan List, Expert Plan Detail, and Goal Plan Detail header/timeline alignment capsules as closed unless a future explicit task reopens one of them.
7. If committing, stage only the task-relevant files listed by the final status.
8. Do not touch unrelated dirty files if any appear.
9. For the active Activity Summary Agent Feedback capsule, send only derived metrics to the server-side agent; do not send raw GPS geometry, route names, persistent activity IDs, demo-only values, prompts, or generated feedback to durable storage.
10. Do not resume adaptive-character implementation, select Phase 02, touch concurrent Activity History Feed upload, Feed/Friends, Leaderboard/You/design/test work, mutate production state, deploy, initialize/reconfigure Firebase, add secrets, or broaden the routed product scope.
11. `goal-plan-detail-header-timeline-alignment` closure preserves static sample daily rows as preview-only display data; they must not create enrollment, persistence, onboarding mutation, trusted current-week calculation, or backend-owned plan progress behavior.

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

Historical completed capsule:

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
- Firebase was uninitialized for that historical static UI/nav checkpoint; later `478898c0` connected bounded production Firebase Auth/mobile config for `runiac-fypp`.
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
- Firebase was uninitialized at the stock scaffold baseline; later `478898c0` connected bounded production Firebase Auth/mobile config for `runiac-fypp`.
- FlutterFire-generated mobile config is now present only for the committed production Auth connection; do not expand `flutterfire configure` or Firebase setup without separate approval.
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

## Concurrent Run Completion Reliability Routing

- Concurrent capsule: `implementation/roadmap/capsules/run-completion-authoritative-result-recovery.md`. The user explicitly routed this IMPLEMENTATION_MODE reliability fix on 2026-07-13 Asia/Singapore. It preserves local-first completion durability and stable retry identity while requiring the injected repository's trusted `completeRun` result to drive XP, level, streak, canonical validated activity identity, guided/skip Cool-down propagation, and Feed eligibility. The current active capsule remains `cadence-capture-reliability-recovery`; this append-only route does not supersede or modify cadence scope/evidence. Firebase Emulator Suite and iOS Simulator QA must use synthetic data and report limitations truthfully. No automatic commit, push, deploy, Firebase initialization, raw GPS expansion, or client-side progression calculation is authorized.
