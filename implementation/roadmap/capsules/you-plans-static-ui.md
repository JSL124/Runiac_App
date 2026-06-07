# you-plans-static-ui

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter static frontend-only You tab Plans UI capsule.

## Status

Status: Implemented and committed at `6624267 feat(you): add static plans tab`; follow-up presentation-layer backend-read-model readiness refactor committed and pushed at `acdbcff refactor(you): prepare static plans UI for read models`.

Routed on: 2026-06-07 Asia/Singapore.
Implemented on: 2026-06-07 Asia/Singapore.
Commit status: Static Plans UI committed at `6624267`; follow-up readiness refactor committed and pushed at `acdbcff`.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Replace the current You tab Plans empty state with one beginner-friendly static Plans page that combines active plan tracking and plan discovery, with active plan tracking visually dominant.

## Product Direction

- The Plans tab helps beginner runners understand the current goal, this week's plan, and coach-created plan options without pressure.
- Keep the screen static, read-only, supportive, and low-cognitive-load.
- Use the provided Plans screenshot as hierarchy/content reference only, not as a new purple-gradient design system.
- Use Runiac white cards with blue/orange accents.

## Approved UI Decisions

- Scope is static UI only with placeholder/read-only data.
- Current Goal card shows goal/progress first and next milestone second.
- Completion percentage `43%` may be shown only as static read-only placeholder.
- Weekly counters are Planned / Completed / Remaining.
- Weekly schedule shows all 7 days.
- Rest days use lower-emphasis styling.
- Run statuses are Completed / Upcoming / Rest Day only.
- Do not use `Missed`.
- Row actions, `View Goal Plan`, and `Explore Expert Plans` are static visual-only.
- Expert plan options are First 5K, 10K, Half Marathon, and Full Marathon.
- Half Marathon and Full Marathon remain visible but less visually dominant than First 5K and 10K.
- Coach-created wording may be mentioned lightly.
- Do not show Premium, subscription, locked, approval, publication, entitlement, or admin-review UI.
- Brand style is mostly white cards with Runiac blue/orange accents.

## Required Static Content

- Current Goal card:
  - `10K Preparation`
  - `Week 3 of 8`
  - `43% completed`
  - visual progress indicator
  - `Next Milestone`
  - `Complete 6 km comfortably`
  - `View Goal Plan` as static visual-only control
- Weekly Plan Summary card:
  - `This Week's 10K Preparation Plan`
  - `3 Planned Runs`
  - `2 Completed`
  - `1 Remaining`
  - supportive, low-pressure copy if space allows
- Weekly Schedule card:
  - Mon: Rest Day
  - Tue: `15 min walk-run` / `Completed`
  - Wed: Rest Day
  - Thu: `20 min easy run` / `Upcoming · 7:30 AM`
  - Fri: Rest Day
  - Sat: `20 min easy run` / `Completed`
  - Sun: Rest Day
- Expert Goal Plan exploration card:
  - `Explore expert goal plan`
  - `Browse coach-created plans and apply one to your current goal plan.`
  - `Coach-created`
  - `First 5K`
  - `10K`
  - `Half Marathon`
  - `Full Marathon`
  - `Explore Expert Plans` as static visual-only control

## Design Constraints

- Reuse `RuniacColors`:
  - Primary Blue `#2F50C7`
  - Accent Orange `#FC6818`
  - White `#FFFFFF`
  - Background `#F7F8FC`
  - Text Primary `#172033`
  - Text Secondary `#6B7280`
  - Border `#E6EAF2`
- Prefer existing You/Home card conventions:
  - `DashboardCard`
  - `SafeArea`/`ListView`-style mobile scrolling
  - `EdgeInsets.fromLTRB(16, 8, 16, 28)`
  - 10-12px vertical card gaps
  - 8px card radius and subtle borders
- Keep text readable on small mobile widths.
- Avoid heavy shadows and purple-gradient visual-system changes.

## Allowed Scope

- Static frontend-only Plans tab UI inside the existing You tab.
- Replace the current Plans empty state in `you_tab.dart`.
- Add/update focused widget tests for the Plans tab.
- Use static read-only placeholder display data only.
- Reuse existing Flutter widgets and existing dependencies only.
- Minimal `CURRENT.md`, this capsule, snapshot, and Governance CI allowlist updates required by roadmap governance.

## Allowed Files

- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/runiac_app/test/you_tab_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if validation proves it is unavoidable
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/you-plans-static-ui.md`
- `tools/governance-ci/check-diff-hygiene.sh` only to allowlist this capsule path

## Forbidden Scope

- No Phase 02 selection.
- No Home, Maps, Run, Leaderboard, Shell, navigation, theme, shared widget, dependency, or unrelated file changes.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No real Plans functionality.
- No real plan completion calculation.
- No real activity history.
- No navigation from rows or buttons.
- No Premium/subscription UI.
- No locked states.
- No expert plan approval, publication, admin-review, or entitlement logic.
- No client-side mutation, write, or calculation of backend-owned values.
- No shame, guilt, aggressive competition messaging, fake ranks, fake leaderboard state, or performance-heavy framing.
- No unrelated refactors.
- No new ADRs.
- No staging, commit, or push in this task.

## Backend-Owned Boundary

The client must not calculate, mutate, write, derive, or imply ownership of:

- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- subscription privilege state
- expert plan publication state
- plan completion
- completed run status
- remaining runs
- expert plan eligibility

For this capsule, `43%`, Planned/Completed/Remaining counters, and schedule statuses are literal static placeholders only. Do not derive them from local arrays or helper calculations.

## Required Validation

```bash
git status --short
git diff --check
./tools/governance-ci/check-roadmap-routing.sh
./tools/governance-ci/run-all-checks.sh
cd implementation/mobile/runiac_app && flutter test test/you_tab_static_ui_test.dart --plain-name "You page shows static plans overview when Plans is selected"
dart format implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart implementation/mobile/runiac_app/test/you_tab_static_ui_test.dart
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short
```

## Manual QA

If Android emulator `emulator-5554` is available and stable:

1. Open the app.
2. Navigate to You.
3. Tap Plans.
4. Confirm Current Goal, weekly plan, schedule, and expert plan cards are visible.
5. Confirm no overflow/crash.
6. Capture screenshot evidence.

If emulator is unavailable or unstable, record the blocker and do not claim manual QA pass.

## Routing Evidence

- Phase 01 Governance CI is closed.
- Phase 02 remains unselected.
- `you-tab-progress-overview-static` preserves a simple Plans empty state and does not authorize this richer Plans page.
- The user explicitly approved implementation mode for the Plans static UI task.
- The previous ULW plan `.omo/plans/you-plans-static-ui.md` requires a Plans-specific capsule before Flutter edits.

## Risk Notes

- The Plans tab touches protected plan progress language; keep all values display-only and literal.
- The expert plan card touches expert-plan governance; do not imply real publication, approval, entitlement, or admin-review state.
- Avoid intimidating beginners with the longer-distance options by making First 5K and 10K more approachable.
- Keep controls inert to avoid implying navigation or real Plans functionality.

## Done When

- [ ] Plans-specific capsule is selected before Flutter edits.
- [ ] Focused Plans widget test fails before production implementation.
- [ ] Plans tab replaces the empty state with the approved static UI.
- [ ] Current Goal, weekly summary, seven-day schedule, and expert plan discovery are visible.
- [ ] All Plans controls remain visual-only.
- [ ] No forbidden terms or backend-owned calculations are introduced.
- [ ] Progress tab and shell navigation regressions remain covered.
- [ ] Required validation passes.
- [ ] Manual QA is run or the emulator blocker is recorded.
- [x] Final status reached committed and pushed for the follow-up readiness refactor at `acdbcff`.
