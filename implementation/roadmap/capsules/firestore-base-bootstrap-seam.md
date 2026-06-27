# firestore-base-bootstrap-seam

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Firebase/FlutterFire bootstrap foundation capsule.

## Status

Status: Implemented locally; validation passed; ready for review/commit.

## Required Agent Chain

```text
A0_ORCH -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add the Cloud Firestore Flutter SDK and a bootstrap-only `RuniacFirestoreGateway` seam so later capsules can add persistence without expanding this capsule into profile, route, activity, progression, leaderboard, subscription, role, or expert-plan data access.

## Scope

Allowed implementation files:

- `implementation/mobile/runiac_app/pubspec.yaml`
- `implementation/mobile/runiac_app/pubspec.lock`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firestore_gateway.dart`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart`
- Existing relevant tests under `implementation/mobile/runiac_app/test/`

Allowed roadmap/governance files:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/capsules/firestore-base-bootstrap-seam.md`
- `implementation/traceability/setup-gates.md`
- Governance CI allowlist files only if required for this capsule path

## Required Implementation

- Add `cloud_firestore` through Flutter/Dart dependency tooling.
- Add `RuniacFirestoreGateway` under `lib/core/firebase/`.
- Keep raw `FirebaseFirestore` private to the gateway; do not expose a public getter or field for feature code.
- Expose only inert metadata and test seams from the gateway, such as whether emulator configuration was requested and which host/port were selected.
- Wire the gateway through `RuniacFirebaseBootstrapResult`.
- Configure the Firestore emulator only when `RUNIAC_FIREBASE_EMULATOR=true`, using `RUNIAC_FIREBASE_EMULATOR_HOST` and port `8080`.

## Firestore Boundary

The Flutter client may initialize and carry a Firestore bootstrap capability after this capsule, but it must not become a Firestore data source in this capsule.

Still forbidden:

- Firestore `collection`, `collectionGroup`, `doc`, `get`, `snapshots`, `set`, `update`, `delete`, batch, transaction, query, serializer, or repository behavior in feature code.
- Auth-time profile persistence.
- Signup profile creation.
- Onboarding persistence.
- `users/{uid}` writes.
- `userProfiles/{uid}` writes.
- Route, activity, GPS trace, XP, leaderboard, subscription, role, premium, or expert-plan persistence.

## Backend-Owned Boundary

The client must not calculate, mutate, write, derive, or imply ownership of:

- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- subscription privilege state
- `subscriptionStatus`
- `userRole`
- validation state
- expert plan publication state

## Forbidden Scope

- No Phase 02 selection.
- No UI changes.
- No profile persistence.
- No Firestore collection/document reads or writes in feature code.
- No Firestore rules or indexes deployment.
- No production Cloud Functions deploy.
- No `firebase init`.
- No `flutterfire configure`.
- No `.firebaserc`.
- No new Google config files.
- No OAuth provider flow.
- No service accounts, secrets, or private GPS fixtures.
- No unrelated refactors.
- Do not stage or commit SwiftPM `Package.resolved` artifacts.

## Required Validation

Setup action already performed:

```bash
cd implementation/mobile/runiac_app && flutter pub add cloud_firestore
```

Validation commands:

```bash
git status --short --untracked-files=all
cd implementation/mobile/runiac_app && flutter pub get
cd implementation/mobile/runiac_app && flutter test test/firestore_bootstrap_contract_test.dart
cd implementation/mobile/runiac_app && flutter test test/firestore_bootstrap_contract_test.dart test/auth_service_test.dart test/run_repository_factory_test.dart
cd implementation/mobile/runiac_app && flutter test test/backend_owned_contract_test.dart test/backend_contract_read_model_test.dart test/static_repository_contract_test.dart test/firestore_bootstrap_contract_test.dart
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
./tools/governance-ci/run-all-checks.sh
git status --short --untracked-files=all
```

## Done When

- [x] This capsule is selected before Firestore edits.
- [x] `cloud_firestore` is present in `pubspec.yaml` and `pubspec.lock`.
- [x] A focused Firestore bootstrap contract test fails before the gateway exists and passes after implementation.
- [x] `RuniacFirestoreGateway` exists and exposes metadata-only public API.
- [x] `RuniacFirebaseBootstrapResult` exposes the gateway.
- [x] Emulator configuration is requested only for `RUNIAC_FIREBASE_EMULATOR=true` with port `8080`.
- [x] Static contract tests prevent feature-level Firestore reads and writes.
- [x] Auth and Run repository bootstrap behavior remains green.
- [x] Required validation passes.
- [x] Review gate confirms profile persistence, Firestore data access, backend-owned client mutation, deploy/init/config expansion, OAuth, Phase 02, and SwiftPM staging remain absent.
