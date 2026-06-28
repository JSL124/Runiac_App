# profile-persistence-rules-contract

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Firebase/Flutter profile persistence and Firestore rules contract capsule.

## Status

Status: In progress locally.

## Goal

Add the narrow Firestore-backed onboarding profile persistence path needed before account profiles can be stored: authenticated onboarding completion may write only owner-scoped `userProfiles/{uid}` onboarding/profile fields, while rules and tests continue to deny `users/{uid}` writes and backend-owned state mutation.

## Scope

Allowed implementation files:

- `firestore.rules`
- `tests/firebase-rules/**`
- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/main.dart`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart`
- `implementation/mobile/runiac_app/lib/features/account/data/**`
- `implementation/mobile/runiac_app/lib/features/account/domain/repositories/**`
- Focused Flutter tests under `implementation/mobile/runiac_app/test/`

## Required Boundaries

- `userProfiles/{uid}` is the only client profile write path in this capsule.
- The write is tied to the current authenticated user id and onboarding completion.
- The payload is limited to client-owned onboarding/profile fields: `displayName`, `avatarInitials`, `locationLabel`, `fitnessLevel`, `goals`, `availability`, `planCautiousness`, `healthSafetyReadiness`, and `updatedAt`.
- Firestore rules must deny unapproved top-level and nested profile fields.
- Firestore rules must continue to deny normal client writes to `users/{uid}`.

## Forbidden Scope

- No Firestore rules/index deployment.
- No Cloud Functions production deploy.
- No `firebase init`.
- No `flutterfire configure`.
- No `.firebaserc`.
- No OAuth provider flow.
- No route, activity, GPS trace, plan, subscription, role, progression, leaderboard, premium, or expert-plan persistence.
- No client writes to XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, `subscriptionStatus`, `userRole`, validation state, subscription privilege state, or expert publication state.

## Required Validation

- Focused Flutter profile persistence tests.
- Full Firebase rules emulator tests.
- `flutter analyze --no-pub`.
- Full Flutter test suite.
- `git diff --check`.
- Governance CI.
