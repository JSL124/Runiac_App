## Purpose
Documents the local Firebase emulator baseline and seed data boundaries.

## Current baseline
- Root `firebase.json` defines the local Firestore emulator shell.
- Root `firestore.rules` and `firestore.indexes.json` are present.
- `tests/firebase-rules/` contains synthetic Firestore rules tests.
- `functions/` contains the emulator-only `completeRun` callable skeleton.
- The Flutter auth flow can use Firebase Auth emulator wiring for email/password signup, login, password reset, auth-state persistence, and sign-out.
- Production Firebase Auth/mobile config is connected for project `runiac-fypp` as of `478898c0 feat(auth): connect production firebase auth`; emulator Auth/Functions behavior remains guarded by `RUNIAC_FIREBASE_EMULATOR=true`.
- Google/OAuth is not implemented. The mobile UI keeps Google sign-in disabled instead of faking success.
- Android debug emulator auth testing requires debug cleartext traffic so the app can reach the local Auth emulator host. This is a debug/emulator boundary only and is not production Firebase configuration.
- Firestore emulator smoke validation used transient `firebase-tools@14.27.0`.
- Local Firestore rules tests cover the narrow onboarding `userProfiles/{uid}` profile persistence contract.

## Not implemented
- No `.firebaserc`.
- No Firestore rules/index deployment. Production use of onboarding profile persistence still requires deploying the matching reviewed rules contract.
- No broad production Firestore feature wiring beyond the narrow onboarding `userProfiles/{uid}` profile path.
- No auth-time Firestore profile bootstrap; signup has only email/password. Safe `userProfiles/{uid}` creation is tied to onboarding completion. The client must not write `users/{uid}` or backend-owned role, subscription, progression, leaderboard, validation, premium, or expert-publication fields.
- No Google/OAuth provider flow.
- No production Cloud Functions deploy target.
- No real backend-owned progression formula.
- No real GPS/private route fixtures.

## Tooling note
The latest Firebase CLI may require Java 21 or newer. Java/tooling upgrade work remains future scope.

`functions/package.json` pins Firebase emulator tooling for this capsule. Current npm audit findings are accepted for this emulator-only tooling lane because the available fix requires a breaking `firebase-tools` major upgrade and production deploy remains forbidden. Reassess before any production Functions deploy or CI hardening capsule.

## Current backend direction
The active emulator direction is local validation of `completeRun`, emulator Auth support for the mobile auth flow when `RUNIAC_FIREBASE_EMULATOR=true`, and Firestore rules validation for onboarding `userProfiles/{uid}` profile persistence. Production Firebase Auth/mobile config for `runiac-fypp` exists, but Firestore rules deployment, auth-time profile bootstrap, OAuth providers, real XP formulas, and leaderboard aggregation remain out of scope.
