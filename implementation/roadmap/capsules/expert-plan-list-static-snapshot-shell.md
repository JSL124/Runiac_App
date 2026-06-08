# expert-plan-list-static-snapshot-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter static frontend-only You tab Expert Plan list capsule.

## Status

Status: Closed.

Routed on: 2026-06-08 Asia/Singapore.
Implemented and closed on: 2026-06-08 Asia/Singapore.

Implementation commit: `8111423de83369aec37425c1582897af9febdf59 feat(you): add expert plan list screen`.

Validation:

- `git diff --check`: PASS.
- `flutter analyze`: PASS.
- `flutter test`: PASS, `+35`.
- `./tools/governance-ci/run-all-checks.sh`: PASS.

Closure summary:

- Added a static Expert Plans list screen from `You > Plans > Expert Plans`.
- Preserved the existing bottom navigation; no new Explore tab was added.
- Rendered static filter chips with `Recommended` visually selected.
- Rendered beginner-friendly static plan cards in the approved order.
- Used `Coach reviewed` wording and did not use `Coach Verified`.
- Used `Healthy Running Starter Plan` instead of direct weight-loss framing.
- Kept `View Plan` controls visual-only/no-op.
- Added visual-only search shell and Runiac long stripe refinement while preserving static-only behavior.
- Added/updated focused widget tests for static content, entry routing, visual-only search/filter controls, no-op `View Plan`, and back-to-Plans behavior.

Backend-owned boundary preserved:

- No expert plan detail screen.
- No functional filtering, purchase, enrollment, activation, subscription unlock, publication workflow, trainer/admin role logic, or real coach verification logic.
- No Firebase/Auth/Firestore/Cloud Functions/FCM/backend calls, GPS/native work, dependency changes, services, repositories, providers, DTOs, backend contracts, or domain models.
- No client-owned mutation of XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, expert plan publication state, trusted enrollment state, or trusted progress/completion state.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add a static Expert Plan browsing list screen where beginner runners can calmly browse coach-reviewed running plans from:

`You > Plans > Expert Plans`

The screen helps users decide which plan they may want to view later. It is not a purchase, enrollment, subscription, expert publishing, real verification, or plan activation flow.

## Product Direction

- Reduce intimidation and cognitive overload.
- Make the next action obvious without aggressive competition framing.
- Prioritize supportive motivation and consistency over performance obsession.
- Keep the screen mobile-first, beginner-friendly, and low cognitive load.
- Use Runiac's existing visual identity and component language as the source of truth.
- Use the provided wireframe as information architecture inspiration only.
- Do not copy the wireframe's exact visual style if it conflicts with the current app.

## Approved UI Decisions

- Entry point is `You > Plans > Expert Plans`.
- No new Explore tab is added in this capsule.
- Screen title is `Expert Plans`.
- Subtitle is `Browse coach-reviewed plans at your own pace.`
- The screen is an Expert Plan list only; no expert plan detail screen is added.
- Filter chips are static visual controls only.
- `Recommended` is visually selected.
- Other filters are visual-only and do not filter, persist state, or fetch data.
- `View Plan` buttons are visual-only/no-op.
- Use `Coach reviewed`, not `Coach Verified`.
- Badges are static display only and must not imply real backend verification logic.
- Beginner-friendly plans appear before longer-distance advanced plans.
- Direct weight-loss framing is avoided.
- Use `Healthy Running Starter Plan`, not `Weight Loss Starter Plan`.
- Bottom note copy is:
  `Plans are reviewed for beginner suitability. This is general fitness guidance, not medical advice.`

## Required Static Content

Filter chips:

- `Recommended`
- `5K`
- `10K`
- `Consistency`
- `Healthy Running`
- `Half`
- `Full`

Plan order and card copy:

1. `First 5K Preparation`
   - `A gentle plan for building confidence toward your first 5K.`
   - `6 weeks` / `3 runs/week` / `Beginner`
   - `Reviewed by Running Coach`
2. `Build Running Consistency`
   - `Create a steady running habit with balanced, achievable workouts.`
   - `4 weeks` / `2-3 runs/week` / `Beginner`
   - `Reviewed by Fitness Trainer`
3. `10K Preparation`
   - `Build endurance and confidence for a comfortable 10K.`
   - `8 weeks` / `3 runs/week` / `Beginner`
   - `Reviewed by Running Coach`
4. `Healthy Running Starter Plan`
   - `Build a healthier running routine with steady, low-pressure sessions.`
   - `3 weeks` / `3 runs/week` / `Beginner`
   - `Reviewed by Health Advisor`
5. `Half Marathon Preparation`
   - `Step up gradually with a longer-distance plan.`
   - `12 weeks` / `3-4 runs/week` / `Intermediate`
   - `Reviewed by Running Coach`
6. `Full Marathon Preparation`
   - `A longer plan for experienced runners preparing for 42.2K.`
   - `18 weeks` / `4-5 runs/week` / `Advanced`
   - `Reviewed by Running Coach`

## Plan Card Content Model

Each card should include:

- Static illustration or thumbnail area.
- Plan title.
- Short supportive description.
- Duration.
- Runs per week.
- Level.
- Static `Coach reviewed` or `Reviewed by ...` display line.
- Visual-only `View Plan` button.

Keep each card compact enough for beginner scanning. Avoid metric overload and performance-heavy language.

## Design Constraints

- Reuse Runiac blue and orange brand accents.
- Use the white / soft off-white background family.
- Reuse existing card, button, spacing, and typography patterns where practical.
- Keep CTAs clear but non-aggressive.
- Keep copy supportive, calm, and non-shaming.
- Avoid shame, guilt, body-image pressure, aggressive competition, or performance-heavy framing.
- Preserve bottom navigation: Home / Maps / Run / Leaderboard / You.

## Allowed Scope For Future Implementation

- Static frontend-only You tab Expert Plan list UI.
- Add the Expert Plan list screen only.
- Add an entry point under `You > Plans > Expert Plans`.
- Render the approved static filter chips.
- Render the approved static plan cards and bottom note.
- Keep filters visual-only.
- Keep `View Plan` visual-only/no-op.
- Add or update focused widget tests for the new static UI and interaction boundaries.
- Use existing Flutter widgets and existing dependencies only.
- Minimal `CURRENT.md`, this capsule, and snapshot updates required by roadmap governance.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/expert_plan_list_screen.dart`
- `implementation/mobile/runiac_app/test/you_tab_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if validation proves it is unavoidable
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/expert-plan-list-static-snapshot-shell.md`

## Forbidden Scope

- No Phase 02 selection.
- No new Explore tab.
- No expert plan detail screen.
- No functional filtering.
- No `View Plan` navigation.
- No subscription purchase.
- No premium unlock.
- No entitlement mutation.
- No plan enrollment or activation.
- No trusted enrollment state mutation.
- No trusted plan progress or completion mutation.
- No expert plan publish, unpublish, approval, rejection, archive, suspension, or management behavior.
- No expert plan publication state mutation.
- No trainer/admin role logic.
- No real coach verification logic.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, backend calls, GPS/native work, scaffold, init, deploy, or build commands.
- No `flutterfire configure`.
- No new dependencies or `pubspec.yaml` changes.
- No Android/iOS native changes.
- No XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP updates.
- No subscription privilege state mutation.
- No services, repositories, providers, DTOs, backend contracts, or domain models.
- No unrelated refactors.
- No new ADRs.
- No staging, commit, or push unless separately approved.

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
- trusted plan enrollment state
- trusted plan completion/progress state
- expert plan eligibility
- coach verification state

For this capsule, expert plan titles, metadata, badge text, card order, and filter selection are literal static placeholders only. Do not derive recommendation state, eligibility, subscription access, enrollment, completion, or publication status from local logic.

## Required Validation For Future Implementation

```bash
git status --short
git diff --check
dart format implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart implementation/mobile/runiac_app/lib/features/you/presentation/expert_plan_list_screen.dart implementation/mobile/runiac_app/test/you_tab_static_ui_test.dart
cd implementation/mobile/runiac_app && flutter analyze
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short
```

For this documentation-routing step only, Flutter analyze/test/build commands are not authorized and must not be run.

## Routing Evidence

- Phase 01 Governance CI is closed.
- Phase 02 remains unselected.
- No active capsule was selected before this routing update.
- `CURRENT.md` required explicit next capsule selection before implementation.
- The latest completed capsule, `weekly-workout-detail-static-snapshot-shell`, is closed after local validation and Android emulator launch smoke.
- The current app bottom navigation is Home / Maps / Run / Leaderboard / You, so this capsule must use `You > Plans > Expert Plans` instead of a new Explore tab.
- The approved seed direction for `expert-plan-list-static-snapshot-shell` is static list/browse only.

## Risk Notes

- The wireframe includes an Explore tab, but the current app does not. Do not add a new tab in this capsule.
- `Coach reviewed` must remain static copy, not real verification.
- Filters and `View Plan` controls must not imply backend personalization, enrollment, purchase, activation, or detail navigation.
- Expert-plan governance state is backend-owned and must not move into the client.
- Avoid direct weight-loss or body-image pressure language.

## Routing Done When

- [x] Active capsule is recorded as `expert-plan-list-static-snapshot-shell`.
- [x] Capsule document records static Flutter UI-only scope.
- [x] Capsule document records entry point `You > Plans > Expert Plans`.
- [x] Capsule document records no new Explore tab.
- [x] Capsule document records Expert Plan list only, with no detail screen.
- [x] Capsule document records visual-only filters.
- [x] Capsule document records visual-only/no-op `View Plan`.
- [x] Capsule document records static `Coach reviewed` display only.
- [x] Capsule document preserves subscription, enrollment, expert publication, verification, and backend-owned state boundaries.
- [x] Next step is a separate implementation-approved Flutter UI task.
