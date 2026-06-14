## Purpose
Tracks the Firebase backend project area for Runiac.

## Current emulator-only baseline
- Root `firebase.json` exists for local emulator configuration.
- Root `firestore.rules` and `firestore.indexes.json` exist.
- `tests/firebase-rules/` contains synthetic Firestore rules tests.
- `functions/` contains the emulator-only `completeRun` Cloud Functions skeleton.
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
The active backend direction is the emulator-only `completeRun` Cloud Functions skeleton. It may validate raw run completion input and write backend-owned emulator documents, but production Firebase setup, FlutterFire wiring, real XP formulas, and leaderboard aggregation remain future scope.
