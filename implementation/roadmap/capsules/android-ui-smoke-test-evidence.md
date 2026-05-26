# android-ui-smoke-test-evidence

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Validation-only.

## Goal

Verify the current static Flutter UI baseline on Android emulator `emulator-5554` before any further product UI changes.

This capsule records evidence only. It does not authorize product code changes, source expansion, dependency changes, Firebase setup, or Phase 02 work.

## Allowed Scope

- Run the listed validation commands from the repository or Flutter app root as appropriate.
- Confirm Android emulator `emulator-5554` is detected.
- Launch the current static app on Android emulator `emulator-5554`.
- Visually confirm the app opens successfully.
- Visually confirm bottom navigation is visible with Home / Maps / Run / Leaderboard / You.
- Record command outputs and concise Android smoke-test evidence during closure.
- Manually stop `flutter run -d emulator-5554` after visual verification if needed.

## Forbidden Scope

- No product code edits.
- No Flutter source edits.
- No Flutter test edits.
- No `pubspec.yaml` or dependency changes.
- No Android native edits.
- No iOS or CocoaPods work.
- No Firebase setup, Firebase files, `firebase init`, or FlutterFire commands.
- No scaffold, build, init, deploy, or dependency-resolution commands.
- No GPS, tracking, authentication, Firestore, leaderboard, plan, profile, XP, streak, level, rank, premium-state, subscription privilege, expert-plan publication, or backend-owned logic.
- No Phase 02 selection.

## Exact Target Files

Routing files:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/android-ui-smoke-test-evidence.md`

Expected product files modified: none.

## Required Tests

No new tests are created in this capsule.

Existing validation command:

```bash
flutter test
```

## Required Validation

Run:

```bash
git status --short
flutter devices
flutter analyze --no-pub
flutter test
flutter run -d emulator-5554
./tools/governance-ci/run-all-checks.sh
git diff --check
git status --short
```

Manual evidence note:

- `flutter run -d emulator-5554` may require manual stop after visual verification.

## Required Evidence

Record during closure:

- `git status --short` output before validation.
- `flutter devices` output showing Android emulator `emulator-5554`.
- `flutter analyze --no-pub` result.
- `flutter test` result.
- `flutter run -d emulator-5554` launch evidence.
- Visual confirmation that the app launches successfully.
- Visual confirmation that bottom navigation shows Home / Maps / Run / Leaderboard / You.
- Confirmation that no runtime crash was observed during the smoke test.
- `./tools/governance-ci/run-all-checks.sh` result.
- `git diff --check` result.
- Final `git status --short` output.

## Rollback Conditions

Stop and do not close the capsule if:

- Android emulator `emulator-5554` is not detected.
- The app does not launch.
- A runtime crash is observed during smoke testing.
- Bottom navigation labels are not visible as Home / Maps / Run / Leaderboard / You.
- Product files are modified.
- Firebase, native, dependency, build, init, deploy, GPS, authentication, Firestore, leaderboard, XP, streak, level, rank, premium-state, or backend-owned logic appears.

## Exit Criteria

- [ ] Android emulator `emulator-5554` detected.
- [ ] App launches successfully on Android emulator.
- [ ] Bottom navigation visible with Home / Maps / Run / Leaderboard / You.
- [ ] No runtime crash observed during smoke test.
- [ ] Required command outputs recorded.
- [ ] No product files modified.
- [ ] Final git status reviewed.
- [ ] Snapshot updated if state changed.
- [ ] CURRENT.md updated if active capsule, phase, gate status, or forbidden scope changed.
