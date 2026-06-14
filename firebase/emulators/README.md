## Purpose
Documents the local Firebase emulator baseline and seed data boundaries.

## Current baseline
- Root `firebase.json` defines the local Firestore emulator shell.
- Root `firestore.rules` and `firestore.indexes.json` are present.
- `tests/firebase-rules/` contains synthetic Firestore rules tests.
- `functions/` contains the emulator-only `completeRun` callable skeleton.
- Firestore emulator smoke validation used transient `firebase-tools@14.27.0`.

## Not implemented
- No production Firebase project or `.firebaserc`.
- No FlutterFire/mobile Firebase config.
- No Auth or Firestore app wiring.
- No production Cloud Functions deploy target.
- No real backend-owned progression formula.
- No real GPS/private route fixtures.

## Tooling note
The latest Firebase CLI may require Java 21 or newer. Java/tooling upgrade work remains future scope.

`functions/package.json` pins Firebase emulator tooling for this capsule. Current npm audit findings are accepted for this emulator-only tooling lane because the available fix requires a breaking `firebase-tools` major upgrade and production deploy remains forbidden. Reassess before any production Functions deploy or CI hardening capsule.

## Current backend direction
The active backend direction is emulator-only validation of `completeRun`. The callable skeleton can be tested against local emulators only; production deploy, FlutterFire client wiring, real XP formulas, and leaderboard aggregation remain out of scope.
