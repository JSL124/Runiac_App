# expert-plan-detail-static-snapshot-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by explicit `ooo run` request.

Type: Flutter static frontend-only You tab Expert Plan Detail capsule.

## Status

Status: Closed after implementation commit, push, and hosted Governance CI verification.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add a static `ExpertPlanDetailScreen` opened from the existing `First 5K Preparation` card's `View Plan` control so beginner runners can preview an expert-reviewed plan safely before any enrollment or backend-owned state exists.

The screen renders a static display snapshot only. It must not calculate, mutate, persist, or infer expert plan selection, enrollment, progress, completion, subscription privilege, coach verification, publication state, or training progression on the client.

## Implemented Scope

- Added a static Expert Plan Detail screen for `First 5K Preparation`.
- Opened the detail screen only from the first Expert Plans list card.
- Kept all other Expert Plans `View Plan` controls visual-only/no-op.
- Kept the `Plan Preview` app bar fixed while detail content scrolls so Back remains available after scrolling down.
- Refined the `Plan Preview` app bar to match the Expert Plans list header pattern with a left-aligned `arrow_back` control, left-aligned title, and matching header padding/height.
- Added the long blue/orange accent strip below the fixed header as the first detail content element, matching the long accent strip used on the You/Expert Plans content surface.
- Added a long static top banner / hero strip below the `Plan Preview` app bar.
- Added static coach insight, coach verification display copy, plan summary, six-week expandable timeline preview, disabled `Select This Plan` CTA, preview boundary note, and medical guidance note.
- Removed `Who this is for` and `What you'll do` from the detail screen after timeline refinement.
- Refined `Plan Timeline` so all weeks are collapsed by default, leaving and re-entering the detail screen restores that collapsed default, each week row independently expands or collapses when tapped, multiple weeks may remain expanded together, each row is tappable with a chevron, each expanded week shows three static bullet items, rows are separated by dividers, and the left timeline circle aligns with the `Week` label.
- Preserved the existing bottom navigation shell.
- Added focused widget coverage for first-card detail entry, static content, disabled CTA no-op behavior, forbidden enrollment/premium activation copy absence, and back-to-list behavior.
- Updated Governance CI diff-hygiene routing for this capsule document only.

## Backend-Owned Boundary

The implementation introduced no Firebase, Auth, Firestore, Cloud Functions, backend logic, persistence, GPS/native behavior, dependency changes, entitlement logic, coach verification logic, expert publication logic, enrollment logic, plan progress mutation, XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP mutation.

The client must continue not to calculate, mutate, write, derive, or imply ownership of:

- subscription privilege state
- expert plan publication state
- trusted plan enrollment state
- trusted plan completion/progress state
- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP

Static display values remain presentation-only placeholders until backend read models and trusted action flows are explicitly routed.

## Forbidden Scope

- No Phase 02 selection.
- No enrollment, selection, activation, saving, unlocking, or purchase behavior.
- No enabled `Select This Plan` CTA.
- No reuse of the First 5K detail screen for unrelated expert plan cards.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No client-side mutation, write, persistence, or calculation of backend-owned values.
- No unrelated refactors.
- No new ADRs.

## Validation Evidence

Implementation closure evidence:

- Implementation commit: `bd5c4b2c118bf0ce3776747418a40aa0d8e14007 feat(you): add expert plan detail preview`.
- Hosted Governance CI #63 PASS for run ID `27151963998`.
- Hosted Governance CI head SHA: `bd5c4b2c118bf0ce3776747418a40aa0d8e14007`.

Local implementation validation before commit:

- `cd implementation/mobile/runiac_app && flutter test test/you_tab_static_ui_test.dart` PASS.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub` PASS.
- `cd implementation/mobile/runiac_app && flutter test` PASS.
- `git diff --check` PASS.
- `./tools/governance-ci/run-all-checks.sh` PASS.
- Android emulator launch smoke PASS on `emulator-5554`.
- Emulator surface smoke PASS: navigated You > Plans > Explore Expert Plans > first `View Plan`, confirmed `Plan Preview` top banner and static First 5K content rendered with bottom navigation preserved, confirmed all weeks are collapsed by default, confirmed Week 1 and Week 2 can remain expanded together, confirmed tapping Week 2 again collapses Week 2 while Week 1 remains expanded, confirmed re-entering the detail screen restores the all-collapsed default, scrolled to the disabled `Select This Plan` CTA and boundary notes, and tapped the disabled CTA without dialog, snackbar, enrollment, or state-change screen.

Governance CI note:

- `check-workflow-memory-drift` emitted a WARN because `tools/governance-ci/check-diff-hygiene.sh` changed to allowlist the new routed capsule document.
- The warning is reviewed as expected and does not indicate a failing gate; all Governance CI checks completed with PASS.
- The pushed implementation commit was later verified by hosted Governance CI #63 PASS for run ID `27151963998` at exact head SHA `bd5c4b2c118bf0ce3776747418a40aa0d8e14007`.

## Done When

- [x] `View Plan` from `First 5K Preparation` opens `ExpertPlanDetailScreen`.
- [x] Other Expert Plans cards remain visual-only/no-op for this capsule.
- [x] Bottom navigation remains visible.
- [x] Back returns to the Expert Plans list.
- [x] `Plan Preview` header and Back control remain visible while detail content scrolls.
- [x] Detail header uses the Expert Plans-style left-aligned `arrow_back` layout.
- [x] Detail header padding/height matches the Expert Plans header pattern.
- [x] Detail content starts with the long blue/orange accent strip.
- [x] Static `First 5K Preparation` detail snapshot renders.
- [x] Long static top banner / hero strip renders under the app bar.
- [x] All timeline weeks are collapsed by default.
- [x] Leaving and re-entering the detail screen restores the collapsed default.
- [x] Timeline weeks expand and collapse independently.
- [x] Multiple timeline weeks can remain expanded together.
- [x] Each expanded week shows exactly three static bullet items.
- [x] Week rows include dividers, chevrons, and aligned timeline circles.
- [x] `Who this is for` and `What you'll do` are removed.
- [x] `Select This Plan` is visible but disabled.
- [x] Disabled CTA performs no enrollment, selection, save, premium unlock, or backend-like state change.
- [x] No Firebase, Firestore, Cloud Functions, persistence, calculation, or progression logic was introduced.
- [x] Required validation passed.
