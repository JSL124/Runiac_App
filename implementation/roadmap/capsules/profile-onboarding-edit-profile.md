# profile-onboarding-edit-profile

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Flutter profile onboarding, account profile edit, and Firestore rules contract capsule.

## Status

Status: In progress locally.

## Goal

Add the signup-time personal profile step before onboarding, persist the combined personal/onboarding profile into owner-scoped `userProfiles/{uid}`, and let users edit personal profile fields or retake onboarding from Account > Manage > Edit profile.

## Scope

Allowed implementation files:

- `firestore.rules`
- `tests/firebase-rules/**`
- `implementation/mobile/runiac_app/DESIGN.md`
- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/main.dart`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart`
- `implementation/mobile/runiac_app/lib/features/auth/**`
- `implementation/mobile/runiac_app/lib/features/onboarding/**`
- `implementation/mobile/runiac_app/lib/features/account/**`
- `implementation/mobile/runiac_app/lib/features/home/**`
- `implementation/mobile/runiac_app/lib/features/shell/**`
- `implementation/mobile/runiac_app/lib/features/training/**`
- Focused Flutter tests under `implementation/mobile/runiac_app/test/`

## Required Boundaries

- `userProfiles/{uid}` is the only client profile write path in this capsule.
- Signup must collect personal profile fields after account creation and before onboarding step 1.
- Personal profile fields are client-owned: `displayName`, `fullName`, `nickname`, `avatarInitials`, `ageYears`, `weightKg`, `locationLabel`, and `updatedAt`.
- Onboarding-derived profile fields remain client-owned only for onboarding output: `fitnessLevel`, `goals`, `availability`, `planCautiousness`, `healthSafetyReadiness`, and `updatedAt`.
- Email is read-only from Firebase Authentication state and must not be persisted into `userProfiles/{uid}`.
- Account > Manage > Edit profile may update only the approved personal profile fields plus `updatedAt`.
- Retaking onboarding must run through a separate route/screen, preserve the old plan/profile when cancelled or when persistence fails, and replace the active generated plan only after the new onboarding result is generated and persistence succeeds.
- Firestore rules must deny unapproved top-level and nested profile fields.
- Firestore rules must continue to deny normal client writes to `users/{uid}`.

## Forbidden Scope

- No Firestore rules/index deployment.
- No Cloud Functions production deploy.
- No `firebase init`.
- No `flutterfire configure`.
- No `.firebaserc`.
- No OAuth provider flow.
- No email update flow.
- No route, activity, GPS trace, plan document, subscription, role, progression, leaderboard, premium, or expert-plan persistence.
- No client writes to XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, `subscriptionStatus`, `userRole`, validation state, subscription privilege state, or expert publication state.

## Required Validation

- Focused Flutter tests for signup profile collection, onboarding persistence, Account display, Edit profile save, and onboarding retake.
- Focused Firebase rules tests for approved personal profile fields, rejected invalid personal fields, rejected email persistence, rejected backend-owned fields, and denied `users/{uid}` writes.
- `flutter analyze --no-pub`.
- Full Flutter test suite.
- Full Firebase rules emulator tests with `cd tests/firebase-rules && npm test`.
- `git diff --check`.
