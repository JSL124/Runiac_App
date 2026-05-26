# flutter-app-shell-baseline

## Status

Active / In Progress

## Purpose

Transition the mobile app shell from the stock Flutter counter template into a minimal, static, offline Runiac app shell.

This capsule is the routing and implementation contract for the future shell patch. Activating this capsule does not itself authorize Flutter source modification. Flutter source changes require a separate implementation-approved prompt after A6_REVIEW and A8_OUTPUT_CHECKER review.

## Current Baseline

- Stock Flutter scaffold baseline exists at `implementation/mobile/runiac_app/`.
- `implementation/mobile/runiac_app/lib/` currently contains only `main.dart`.
- The current `main.dart` is the stock Flutter counter template.
- Firebase remains uninitialized.
- `flutterfire configure` has not been run.
- No Firebase config/source files are present.
- No production Runiac Flutter feature implementation has started.

## Allowed Future Implementation Files

Only these files may be modified or created by the future implementation patch:

- `implementation/mobile/runiac_app/lib/main.dart`
- `implementation/mobile/runiac_app/lib/app.dart`

Strict file layout rule:

- Do not create separate screen files in this capsule.
- Do not create `lib/screens/`.
- Do not create feature folders.
- Do not create assets.
- Do not edit `pubspec.yaml`.

## Explicitly Forbidden Files

- `implementation/mobile/runiac_app/pubspec.yaml`
- `implementation/mobile/runiac_app/lib/screens/**`
- `implementation/mobile/runiac_app/android/**`
- `implementation/mobile/runiac_app/ios/**`
- Firebase files.
- Firestore rules.
- Cloud Functions files.
- Generated Firebase options.
- Phase 02 files.
- `PRD.md`
- `docs/pdd/**`
- `docs/submissions/**`
- `diagrams/**`
- `wireframes/**`
- `implementation/roadmap/roadmap-stretch.md`
- `tools/**`
- Unrelated roadmap, capsule, or ADR files.

## Explicitly Forbidden Commands

- `flutter create`
- `flutter pub get`
- `dart pub get`
- `flutterfire configure`
- `firebase init`
- `npm install`
- `pod install`
- `flutter build`
- `flutter test`
- `firebase deploy`
- Dependency resolution commands.
- Build, deploy, scaffold, or init commands.

## Shell UI Scope

- Static/offline only.
- Default Flutter theme only.
- Placeholder labels/messages only.
- Exactly five tab destinations:
  - Home
  - Plan
  - Run
  - Explore
  - Leaderboard
- A vanilla `MaterialApp` and stock `BottomNavigationBar` pattern is acceptable for the future implementation.
- No custom design system.
- No typography system.
- No custom color token system.
- No route exploration logic.
- No leaderboard logic.
- No onboarding logic.
- No analytics.

## Backend-Owned Boundary

The Flutter client must not implement, mock, calculate, mutate, or display fake operational examples for:

- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- subscription privilege state
- expert plan publication state
- validated activity contribution state

Explicitly forbidden:

- fake XP cards
- mock leaderboard rows
- hardcoded streak examples
- hardcoded rank examples
- subscription gating logic
- local calculations that appear authoritative

Allowed only:

- static placeholder tab labels
- static placeholder screen titles/messages
- non-functional shell UI

## Validation Plan

Future implementation patch validation:

```bash
git status --short
git diff -- implementation/mobile/runiac_app/lib/main.dart implementation/mobile/runiac_app/lib/app.dart
git diff --check
flutter analyze --no-pub
```

Explicitly forbidden validation commands:

- `flutter pub get`
- `dart pub get`
- `flutter build`
- `flutter test`
- dependency resolution
- Firebase commands
- deploy/init commands

## A6_REVIEW Checklist

A6_REVIEW must verify:

- scope boundary
- scaffold boundary
- backend-owned state isolation
- no Firebase
- no native file edits
- no dependency changes
- no mock operational data
- no tab feature logic

## A8_OUTPUT_CHECKER Checklist

A8_OUTPUT_CHECKER must verify:

- output contract
- allowed files only
- validation evidence
- no forbidden commands
- routing consistency
- unexpected file modification check

## Done When

- The capsule document exists.
- `CURRENT.md` selects this capsule as the active capsule.
- `latest.md` records `d59f6f9 docs(agents): align scaffold baseline review wording` as the latest verified commit.
- No Flutter source is modified by the routing patch.
- No Firebase, native, dependency, build, init, or deploy action is performed.
- Governance CI passes.
- Patch is ready for human inspection.

## Out of Scope

- Flutter source implementation in this routing patch.
- Separate screen files.
- `lib/screens/`.
- Feature folders.
- Assets.
- `pubspec.yaml` edits.
- Firebase setup or configuration.
- Authentication.
- GPS or location permissions.
- Real onboarding.
- Real plans, routes, activities, XP, streaks, ranks, leaderboard data, subscription state, or expert plan state.
- State management libraries.
- Dependency changes.
- Backend-owned logic.
- Native Android/iOS edits.
- Phase 02 work.

## Human Approval Gates

Before Flutter source changes begin, human approval must explicitly authorize a separate implementation-approved prompt for this capsule.

Before commit, the routing patch must pass A6_REVIEW and A8_OUTPUT_CHECKER. Review output alone is not approval for broader implementation, Firebase setup, dependency resolution, native file changes, build, deploy, scaffold, or init work.

## Rollback / Recovery Note

This capsule is documentation/routing only. If routing is incorrect, recover by reverting the capsule document addition and restoring `CURRENT.md` plus `implementation/roadmap/snapshots/latest.md` to the previous no-active-capsule state. Do not modify Flutter, Firebase, native, dependency, build, or deploy files as part of rollback unless separately approved.
