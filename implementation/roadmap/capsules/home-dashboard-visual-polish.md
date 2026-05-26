# home-dashboard-visual-polish

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Flutter UI product-code-changing capsule.

## Status

Status: Routed.

This capsule is routed for future implementation. It does not implement Home UI polish yet.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Improve the static Home dashboard visual quality and beginner-friendly presentation without adding backend behavior or fake backend-owned values.

## Allowed Future Implementation Scope

- Improve Home dashboard spacing.
- Improve typography hierarchy.
- Improve card/button visual structure.
- Improve Start Run CTA presentation.
- Improve beginner-friendly guidance text.
- Improve static empty-state or supportive copy.
- Preserve bottom navigation order: Home / Maps / Run / Leaderboard / You.
- Keep the app static UI only.

## Forbidden Future Implementation Scope

- No Firebase.
- No Auth.
- No Firestore.
- No Cloud Functions.
- No GPS/tracking.
- No real run recording.
- No fake XP.
- No fake streak.
- No fake level.
- No fake rank.
- No fake leaderboard score.
- No fake premium state.
- No fake run history.
- No backend-owned values.
- No dependency changes.
- No native Android/iOS changes.

## Expected Future Modified Files

- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if text expectations must change
- Roadmap files during closure only

## Required Validation For Future Implementation

- `flutter analyze --no-pub`
- `flutter test`
- `git diff --check`
- `./tools/governance-ci/run-all-checks.sh`
- Android smoke check if the UI surface changes significantly

## A5_WIRE Responsibilities

- Confirm beginner-friendly UX.
- Confirm low cognitive load.
- Confirm supportive tone.
- Confirm CTA clarity.
- Confirm no metric overload.
- Confirm no shame/guilt/aggressive competition.
- Confirm visual polish stays aligned with wireframe intent.

## A10_FLUTTER_IMPL Responsibilities

- Implement approved Flutter UI/layout changes only.
- Preserve static UI-only behavior.
- Preserve the bottom navigation contract.
- Avoid dependencies.
- Avoid fake backend-owned values.

## A12_QA_TEST Responsibilities

- Run `flutter analyze --no-pub`.
- Run `flutter test`.
- Confirm widget test expectations.
- Recommend Android smoke evidence if the UI changed significantly.
- Record factual validation evidence.

## Done Criteria For Future Implementation

- [ ] Home visual polish implemented within approved scope.
- [ ] Tests/analyze pass.
- [ ] Governance CI passes.
- [ ] No product-code scope drift.
- [ ] No backend-owned values added.
- [ ] Capsule closure recorded after implementation.

## Rollback Conditions

Stop and do not close the capsule if future implementation:

- Modifies files outside the allowed implementation scope.
- Adds Firebase, Auth, Firestore, Cloud Functions, GPS/tracking, native Android/iOS, dependency, or backend behavior.
- Adds fake XP, streak, level, rank, leaderboard score, premium state, run history, or any backend-owned value.
- Changes bottom navigation away from Home / Maps / Run / Leaderboard / You.
- Fails required validation.
