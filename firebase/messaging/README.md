## Purpose
Holds future Firebase Cloud Messaging contract notes.

## Future contents
Notification payload contracts, routing assumptions, and reminder message documentation.

## Current status
- No FCM implementation exists.
- No Cloud Functions notification handlers exist.
- No production Firebase project, `.firebaserc`, FlutterFire/mobile config, Auth/Firestore app wiring, backend-owned progression logic, or real GPS/private route fixtures exist.
- The repository does have an emulator-only Firebase baseline: root `firebase.json`, `firestore.rules`, `firestore.indexes.json`, and synthetic Firestore rules tests under `tests/firebase-rules/`.

## Tooling note
Firestore emulator smoke validation used transient `firebase-tools@14.27.0`. The latest Firebase CLI may require Java 21 or newer, so Java/tooling upgrade work remains future scope.

## Next backend direction
The complete-run progression contract is planned next. Cloud Functions implementation has not started.
