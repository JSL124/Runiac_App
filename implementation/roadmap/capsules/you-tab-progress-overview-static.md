# you-tab-progress-overview-static

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter static frontend-only You tab progress overview capsule.

## Status

Status: Routed; implementation not started.

Routed on: 2026-06-07 Asia/Singapore.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Implement one visible static You page improvement: a beginner-friendly progress and consistency overview screen based on the approved You page wireframe and OOO interview decisions, using static read-only placeholder display data only.

## Product Direction

- The You page should help beginner runners feel consistent progress without overwhelming them with performance-heavy metrics.
- Primary purpose: progress and consistency overview.
- Keep tone supportive, calm, and non-shaming.
- Reduce intimidation and cognitive overload.
- Make the next action obvious without aggressive competition framing.
- Prioritize consistency over performance obsession.

## Approved UI Decisions

- Progress tab implemented.
- Plans tab uses a simple empty state.
- Run Level shows level label only, with no XP number.
- Streak shows a number plus rest-day protection copy.
- Recent Running shows 3 activities.
- Recent Running metrics: distance, average pace, and time.
- Calendar uses a monthly calendar.
- Brand color uses selected blue/orange accents only.
- More Activities is a static visual button only, with no navigation or action.
- Plans empty state copy: `Build your next running habit here.`

## Design Constraints

- Reuse `RuniacColors`:
  - Primary Blue `#2F50C7`
  - Accent Orange `#FC6818`
  - White `#FFFFFF`
  - Background `#F7F8FC`
  - Text Primary `#172033`
  - Text Secondary `#6B7280`
  - Border `#E6EAF2`
- Prefer existing card conventions:
  - `DashboardCard`
  - `CardTitle`
  - `SoftNotice`
  - `SkeletonLine` / `SkeletonDot` where appropriate
- Use existing Home spacing/card conventions:
  - `SafeArea`
  - `ListView`
  - `EdgeInsets.fromLTRB(16, 8, 16, 28)`
  - 10-12px vertical card gaps
- Use blue for structure and selection.
- Use orange sparingly for primary action/accent.
- Preserve bottom navigation: Home / Maps / Run / Leaderboard / You.

## Allowed Scope

- Static frontend-only You tab UI implementation.
- Replace the current generic You placeholder with a static Profile/You progress overview screen.
- Implement the approved Progress tab content.
- Implement a simple Plans tab empty state with the approved copy.
- Add static read-only placeholder display data for weekly progress, streak, calendar days, recent runs, and run level label.
- Reuse existing Flutter widgets and existing dependencies only.
- Small widget-test updates only when required to keep tests aligned with the approved static UI change.
- Minimal `CURRENT.md`, this capsule, snapshot, and governance validation documentation required by roadmap governance.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if stable expectations need update.
- Roadmap files only for routing and closure updates.

## Forbidden Scope

- No Phase 02 selection.
- No Home, Maps, Run, or Leaderboard implementation changes unless a direct shell integration dependency is discovered and explicitly justified.
- No bottom navigation replacement or reorder.
- No activity history navigation.
- No real Plans functionality.
- No More Activities navigation or action.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, or backend work.
- No `flutterfire configure`.
- No GPS/location permission, current-location state, route tracking, activity recording, activity submission, or native configuration.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No client-side mutation, write, or calculation of backend-owned values.
- No XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state logic.
- No premium gating or subscription logic.
- No expert plan publication logic.
- No aggressive competition, shame, guilt, fake ranks, fake leaderboard state, or performance-heavy framing.
- No unrelated refactors.
- No new ADRs.

## Backend-Owned Boundary

The client must not calculate, mutate, write, or imply ownership of:

- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- subscription privilege state
- expert plan publication state

For this capsule, progression values are static/read-only placeholders only.

## Suggested Placeholder Content

- This Week: `12.4 km`, `3 runs completed this week`, `82% weekly goal`.
- Streak: `6 days`, `Planned rest days keep your streak protected.`
- Plans empty state: `Build your next running habit here.`
- Recent Running: 3 static activity cards with date, run title, distance, average pace, and time.
- Run Level: `Level 12 Runner` only; no XP number.

## Required Validation

```bash
git status --short
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short
```

For this documentation-routing step only, Flutter analyze/test/build commands are not authorized and must not be run.

## Routing Evidence

- Phase 01 Governance CI is closed.
- Phase 02 remains unselected.
- No active capsule was selected before this routing update.
- `CURRENT.md` required explicit next capsule routing before implementation.
- OOO interview decisions approved on 2026-06-07 Asia/Singapore.
- Repository UI guidance confirms the static Flutter app shell already has Home / Maps / Run / Leaderboard / You bottom navigation and an existing You placeholder.
- Existing dirty Maps/widget-test files are unrelated and must not be touched by this capsule routing step.

## Risk Notes

- The You page touches protected progression language. Keep all progression values display-only and static until a backend contract exists.
- Avoid making streak copy feel punitive. Rest-day protection copy should reduce guilt.
- Avoid displaying XP numbers in the Run Level card during this capsule.
- Keep Recent Running short to avoid metric overload.
- Keep More Activities inert to avoid implying an activity history feature is implemented.

## Done When

- [ ] The current You placeholder is replaced with the approved static progress overview UI.
- [ ] Progress tab content is implemented.
- [ ] Plans tab empty state uses `Build your next running habit here.`
- [ ] Run Level shows a level label only and no XP number.
- [ ] Streak uses supportive rest-day protection copy.
- [ ] Recent Running shows exactly 3 static activities.
- [ ] Monthly calendar is static and display-only.
- [ ] More Activities remains visual-only and inert.
- [ ] Bottom navigation remains Home / Maps / Run / Leaderboard / You.
- [ ] No forbidden files or scopes are touched.
- [ ] Required validation passes during the future implementation step.
- [ ] Capsule, `CURRENT.md`, and snapshot are updated at closure.
