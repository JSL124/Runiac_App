## Purpose
Documents the local Firebase emulator baseline and seed data boundaries.

## Current baseline
- Root `firebase.json` defines the local Firestore emulator shell.
- Root `firestore.rules` and `firestore.indexes.json` are present.
- `tests/firebase-rules/` contains synthetic Firestore rules tests.
- `functions/` contains the emulator-only `completeRun` callable skeleton.
- The Flutter auth flow can use Firebase Auth emulator wiring for email/password signup, login, password reset, auth-state persistence, and sign-out.
- Google/OAuth is not implemented. The mobile UI keeps Google sign-in disabled instead of faking success.
- Android debug emulator auth testing requires debug cleartext traffic so the app can reach the local Auth emulator host. This is a debug/emulator boundary only and is not production Firebase configuration.
- Firestore emulator smoke validation used transient `firebase-tools@14.27.0`.

## Not implemented
- No production Firebase project or `.firebaserc`.
- No FlutterFire-generated mobile Firebase config files such as `firebase_options.dart`, `google-services.json`, or `GoogleService-Info.plist`.
- No production Auth or Firestore app wiring. Current mobile Auth support is emulator-only and uses demo runtime options.
- No auth-time Firestore profile bootstrap; signup has only email/password, so safe `userProfiles/{uid}` creation is deferred until onboarding completion. The client must not write `users/{uid}` or backend-owned role, subscription, progression, leaderboard, validation, premium, or expert-publication fields.
- No production Cloud Functions deploy target.
- No real backend-owned progression formula.
- No real GPS/private route fixtures.

## Tooling note
The latest Firebase CLI may require Java 21 or newer. Java/tooling upgrade work remains future scope.

`functions/package.json` pins Firebase emulator tooling for this capsule. Current npm audit findings are accepted for this emulator-only tooling lane because the available fix requires a breaking `firebase-tools` major upgrade and production deploy remains forbidden. Reassess before any production Functions deploy or CI hardening capsule.

## Current backend direction
The active backend direction is emulator-only validation of `completeRun` plus emulator-only Auth support for the mobile auth flow. The callable skeleton and Auth email/password flow can be tested against local emulators only; production deploy, production FlutterFire config, auth-time profile bootstrap, OAuth providers, real XP formulas, and leaderboard aggregation remain out of scope.
