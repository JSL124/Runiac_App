## Purpose
Tracks the Firebase backend project area for Runiac.

## Current emulator-only baseline
- Root `firebase.json` exists for local emulator configuration.
- Root `firestore.rules` and `firestore.indexes.json` exist.
- `tests/firebase-rules/` contains synthetic Firestore rules tests.
- Firestore emulator smoke validation used transient `firebase-tools@14.27.0`.

## Not implemented
- No production Firebase project or `.firebaserc`.
- No FlutterFire/mobile Firebase config.
- No Cloud Functions source.
- No Auth or Firestore app wiring.
- No backend-owned progression logic.
- No real GPS/private route fixtures.

## Tooling note
The latest Firebase CLI may require Java 21 or newer. Java/tooling upgrade work remains future scope.

## Next backend direction
The complete-run progression contract is planned next. Cloud Functions implementation has not started.
