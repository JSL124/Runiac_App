# Runiac Phase 1 Setup Gates

## 1. Purpose and Scope

This document is a setup approval checklist and scaffold-baseline record for Phase 1 implementation preparation. It records gate state and required evidence before Firebase, Firestore, Cloud Functions, rules, secrets, API keys, production feature implementation, build, deploy, or custom test setup begins.

This document does not approve new setup or feature work. The bounded stock Flutter scaffold baseline has already been separately approved and executed. This document does not authorize another `flutter create`, `firebase init`, `flutterfire configure`, production feature creation, custom tests, builds, deployment, staging, commits, or pushes.

A0_ORCH owns the workflow. A6_REVIEW checks consistency and high-risk boundaries. A8_OUTPUT_CHECKER checks completeness and deliverable readiness. These workflow roles do not replace explicit human/project approval.

## 2. Gate Status Model

Allowed statuses:

- `Not Started`: gate is listed but has no drafted evidence.
- `Drafted`: gate checklist exists or preliminary evidence is recorded.
- `Under Review`: gate evidence has been prepared and is awaiting explicit review.
- `Approved`: explicit human/project approval evidence or a linked decision artifact exists for this gate.
- `Blocked`: gate cannot proceed because required evidence, approval, or prerequisite decisions are missing.

`Approved` requires explicit human/project approval evidence or a linked decision. Checklist completion by an agent or reviewer is not approval. A provider name, tool name, or automated review result is not an approval authority.

## 3. Gate Summary

| Gate | Current Status | Approval Evidence Required | Notes |
| --- | --- | --- | --- |
| Gate-00: Git State Baseline | APPROVED | Clean status, push baseline confirmation, no unrelated untracked/staged files, no failed traceability artifacts, explicit human/project approval evidence | Baseline readiness approved only; not scaffold execution approval. |
| Flutter Scaffold Gate | EXECUTED FOR STOCK SCAFFOLD BASELINE | Human/project approval to create Flutter scaffold and package metadata | Stock scaffold baseline exists at `implementation/mobile/runiac_app/`; no Firebase setup or feature implementation is authorized. |
| Firebase Project and Config Gate | PARTIALLY APPROVED FOR EMULATOR-ONLY ROOT FIREBASE.JSON | Human/project approval for Firebase project/config approach | Root `firebase.json` is approved only for the `firebase-emulator-shell` Firestore emulator shell; no production project, `.firebaserc`, mobile config, rules, indexes, or Functions are approved. |
| Firestore Data Model Gate | Not Started | Approved collection/access model and traceability to requirements | No collections/rules created yet. |
| Cloud Functions Boundary Gate | Not Started | Approved backend ownership boundaries | No functions source, package files, or TypeScript config yet. |
| Firestore Security Rules Gate | Not Started | Approved rules strategy and emulator test plan | No rules files yet. |
| Secret / API Key / Environment Handling Gate | Not Started | Approved secret-handling process and `.gitignore` checks | No `.env*` or service account files. |
| GPS and Location Privacy Gate | Not Started | Approved privacy masking and test-data policy | No private route fixtures. |
| XP / Streak / Level / Leaderboard Backend Ownership Gate | Not Started | Approved backend-only write policy and test strategy | No client writes to trusted fields. |
| Basic/Premium Access-Control Gate | Not Started | Approved `subscriptionStatus` enforcement plan | UI hiding alone is insufficient. |
| userRole and Expert Plan Governance Gate | Not Started | Approved role/governance transition plan | Platform Administrator remains authority. |
| AI/LLM Boundary Gate | Not Started | Approved future summary boundary and safety constraints | No LLM scoring/ranking. |
| Testing and Evidence Gate | Not Started | Approved test/evidence minimum set | No production tests created by this doc. |

## 4. Gate-00: Git State Baseline

Status: `APPROVED`

Purpose: confirm repository hygiene before any execution gate changes from `Drafted` to `Under Review` or before any scaffold/setup action is requested.

Required checks:

- `git status --short` must produce no output immediately before any scaffold/setup action is requested.
- Latest approved commits should be pushed to `origin/main` before any execution gate changes from `Drafted` to `Under Review`.
- No unrelated untracked files.
- No staged changes unrelated to the current gate.
- No pending failed traceability artifacts.
- Manual staging, if later approved, must name exact files and must not use `git add .`.

Current baseline approval note:

- `git status --short` produced no output before this document was created.
- On 2026-05-24, `git status --short` produced no output for this documentation update.
- On 2026-05-24, `git status -sb` showed `main...origin/main`, confirming local `main` was aligned with `origin/main`.
- Latest traceability setup commit `30c55b5 docs(traceability): add phase 1 implementation prep gates` was present locally.
- Gate-00 approval evidence is recorded in Section 18.
- Gate-00 approval confirms baseline repository readiness only.
- Gate-00 approval does not authorize Flutter scaffold execution.

Approval evidence recorded:

- A fresh clean `git status --short` result.
- A recorded confirmation that approved commits are pushed to `origin/main`.
- Explicit human/project approval or linked decision artifact for moving beyond baseline hygiene.

## 5. Flutter Scaffold Gate

Status: `EXECUTED FOR STOCK SCAFFOLD BASELINE`

Executed baseline:

- Stock Flutter scaffold baseline exists at `implementation/mobile/runiac_app/`.
- Scaffold command used `--no-pub`.
- `pubspec.yaml`, `lib/main.dart`, Android platform files, iOS platform files, and template baseline tests exist as generated scaffold files.
- No `flutter pub get` was run.
- No `firebase init` was run.
- `flutterfire configure` has not been run.
- Firebase config/secrets remain absent.
- Production Runiac feature implementation has not started.

Still blocked until separately approved:

- No additional `flutter create`.
- No custom production Dart source beyond scaffold baseline.
- No custom production tests beyond scaffold baseline.
- No dependency resolution or dependency changes.
- No build or deploy.
- No Firebase configuration or setup.

Required evidence before approval:

- Confirm app package name, platform targets, Flutter SDK/version approach, and allowed scaffold path.
- Confirm scaffold does not alter PRD/PDD/submitted artifacts.
- Confirm first Flutter work maps to `requirements-map.md`.

Approval evidence required:

- Explicit human/project approval or linked decision artifact authorizing Flutter scaffold creation.

## 6. Firebase Project and Config Gate

Status: `PARTIALLY APPROVED FOR EMULATOR-ONLY ROOT FIREBASE.JSON`

Approved exception:

- Root `firebase.json` is approved only for the `firebase-emulator-shell` capsule.
- The approved file is limited to Firestore emulator configuration.
- Firestore emulator host is local-only.
- No production Firebase project ID is approved.
- No `.firebaserc` is approved.
- No `firebase init` or `firebase init emulators` command is approved.
- No FlutterFire or mobile Firebase configuration is approved.
- No Cloud Functions are approved.
- No Firestore rules or indexes are approved.
- No Auth/Firestore app wiring is approved.
- No backend-owned state logic is approved.

Blocked until approved:

- No `firebase init`.
- No additional or nested `firebase.json` beyond the approved root emulator shell file.
- No `.firebaserc`.
- No Firebase production project IDs.
- No `google-services.json`.
- No `GoogleService-Info.plist`.

Required evidence before approval:

- Decide whether Firebase uses emulator-first local setup, demo project, or production project later.
- Confirm no production secrets or project IDs enter the repository.
- Confirm `.gitignore` coverage for generated and sensitive Firebase/mobile config files.

Approval evidence required:

- Explicit human/project approval or linked decision artifact authorizing Firebase setup path.

## 7. Firestore Data Model Gate

Status: `Not Started`

Required evidence before approval:

- Map collections/documents to `requirements-map.md`.
- Confirm private user data, activity history, GPS traces, training plans, notification preferences, subscription state, role state, progression records, and leaderboard records have ownership rules.
- Confirm official XP/streak/level/rank/leaderboard fields are not client-writable.
- Confirm submitted assessment/PDD references are read-only unless separately approved.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for the Firestore data model baseline.

## 8. Cloud Functions Boundary Gate

Status: `Not Started`

Blocked until approved:

- No `firebase/functions`.
- No functions `package.json`.
- No functions `tsconfig.json`.
- No Cloud Functions source files.

Required evidence before approval:

- Confirm Cloud Functions are backend enforcement only.
- Confirm Cloud Functions enforce trusted transitions, validation, XP/streak/level/rank/leaderboard updates, entitlement checks, notification checks, summary orchestration, and server-side protections.
- Confirm Cloud Functions do not replace governance authority.
- Confirm Platform Administrator remains the only authority to approve, publish, update, archive, reject, suspend, or manage expert plans.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for the backend boundary.

## 9. Firestore Security Rules Gate

Status: `Not Started`

Blocked until approved:

- No Firestore rules.
- No Storage rules.
- No rules deployment.

Required evidence before approval:

- Rule strategy for owner-only private records.
- Deny normal client writes to trusted progression/ranking fields.
- Deny normal client writes to `userRole` and protected subscription/governance fields.
- Enforce premium access where data access or generation is affected.
- Define emulator test coverage before rules are trusted.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for security rules design and initial emulator tests.

## 10. Secret / API Key / Environment Handling Gate

Status: `Not Started`

Blocked until approved:

- No `.env*` committed.
- No API keys.
- No service account files.
- No `google-services.json`.
- No `GoogleService-Info.plist`.
- No production Firebase project IDs.
- No map provider keys.
- No AI/LLM provider keys.
- No Android/iOS signing material.
- No native iOS/Android build configuration containing real keys, passwords, protected local paths, provider identifiers, or production project identifiers.

Required `.gitignore`/handling checks:

- `.env*` excluded or documented with safe examples only.
- Service account JSON files excluded.
- Firebase mobile config files excluded unless explicitly approved as non-sensitive demo config.
- Production Firebase project IDs excluded from committed docs/code unless explicitly approved.
- Secret examples use placeholder values only.

Sensitive configuration categories to split and review before approval:

- Firebase project/config identifiers.
- Firebase mobile config files, including `google-services.json` and `GoogleService-Info.plist`.
- Map provider keys.
- AI/LLM provider keys.
- Service account credentials.
- Android/iOS signing material.
- Native iOS/Android build configuration.
- Local developer-only environment variables.
- Future CI/CD environment variables.

Forbidden path and file examples unless separately approved with safe placeholder/demo content:

- `.env*`.
- `google-services.json`.
- `GoogleService-Info.plist`.
- Service account JSON files.
- `android/key.properties`.
- `android/local.properties` with real local/protected config.
- `android/gradle.properties` or Android Gradle files with real keys, signing passwords, or provider identifiers.
- `*.jks`.
- `*.keystore`.
- Future iOS signing material such as `*.p12`, `*.cer`, `*.mobileprovision`, and `*.p8`.
- `ios/**/Info.plist` with real keys.
- `ios/**/AppDelegate.swift` with real keys.
- `android/**/AndroidManifest.xml` with real keys.
- Android Gradle files with real keys.

Clarifications:

- `GoogleService-Info.plist` is Firebase iOS mobile configuration.
- `ios/**/Info.plist` is native iOS app metadata where keys may accidentally be hardcoded.

Configuration injection strategy requirement before further Firebase/mobile configuration:

- Choose and document a config injection strategy before Firebase configuration, FlutterFire configuration, or mobile configuration expansion begins.
- Compare only at a high level for now: `--dart-define`, `--dart-define-from-file`, `flutter_dotenv`, native placeholder substitution, and CI/CD environment variables.
- Do not choose the final strategy in this gate until explicit approval evidence exists.
- Client-side injection strategies do not prevent reverse-engineering of compiled binaries.
- Any value shipped inside the mobile app must be treated as potentially discoverable.
- This reinforces the strict Runiac requirement that sensitive logic and trusted values such as XP, streak, level, rank, weekly XP, monthly XP, and leaderboard scores remain backend-owned and must not be trusted from Flutter client input.

Guardrail reverse-mapping requirement before approval:

- Future setup work must align secret/config guardrails across `.gitignore`, `classify_high_risk_task.sh`, `.agents/skills/runiac-review-flow/SKILL.md`, `tools/agent-review/profiles/runiac/context-policy.yml`, and legacy `.claude/settings.json`.
- `classify_high_risk_task.sh` is a task/prompt classifier, not a git commit hook.
- Git-level enforcement is optional future work and must be handled in a separate task.
- LLM/agent-generated decisions alone are not approval.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for secret handling and any config-file exception.

## 11. GPS and Location Privacy Gate

Status: `Not Started`

Required evidence before approval:

- Confirm raw GPS route data, precise private coordinates, activity history, and location routines are sensitive.
- Define synthetic/coarse test data policy.
- Define route privacy masking expectations before any public/shared route feature.
- Confirm no private GPS data is committed in fixtures, screenshots, logs, or docs.
- Confirm user consent/permission handling expectations for location access.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for GPS/privacy handling.

## 12. XP / Streak / Level / Leaderboard Backend Ownership Gate

Status: `Not Started`

Required evidence before approval:

- Confirm Flutter may display trusted values but must not directly write official XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, or leaderboard rank.
- Confirm Cloud Functions/backend enforcement owns validation and official progression/ranking updates.
- Confirm Firestore rules deny direct client writes to trusted fields.
- Confirm test plan includes emulator rules and function integration checks.
- Confirm Premium users receive no XP/ranking/leaderboard advantage.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for backend ownership and test strategy.

## 13. Basic/Premium Access-Control Gate

Status: `Not Started`

Required evidence before approval:

- Confirm `subscriptionStatus` controls Basic/Premium access.
- Confirm Basic/Premium users are not separate subclasses.
- Confirm backend entitlement checks protect premium-only expert plans, advanced analytics, AI summaries, route tools, saved route collections, route comparison, and premium sharing templates.
- Confirm UI hiding is not the only enforcement.
- Confirm premium status does not affect official competitive scoring.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for entitlement enforcement.

## 14. userRole and Expert Plan Governance Gate

Status: `Not Started`

Required evidence before approval:

- Confirm `userRole` controls operational/governance access.
- Confirm Medical Trainer/Expert may submit draft/content only and must not publish directly.
- Confirm Platform Administrator is the only authority to approve, publish, update, archive, reject, suspend, or manage expert plans.
- Confirm Premium users can access only verified approved/published expert plans.
- Confirm Cloud Functions may enforce state transitions but do not become the governance authority.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for role/governance transitions.

## 15. AI/LLM Boundary Gate

Status: `Not Started`

Required evidence before approval:

- Confirm AI/LLM is future/Premium summary support only.
- Confirm AI/LLM output must not become official XP, streak, level, rank, leaderboard, weekly XP, monthly XP, or scoring logic.
- Confirm AI/LLM must not directly read/write Firestore from the client.
- Confirm AI/LLM summaries avoid medical diagnosis, injury prediction, unsupported health claims, and unsafe coaching instructions.
- Confirm usage/cost controls are designed before any provider integration.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for AI/LLM boundary and safety constraints.

## 16. Testing and Evidence Gate

Status: `Not Started`

Required evidence before approval:

- Minimum test layers are mapped in `requirements-map.md`.
- Firestore Emulator Rules Tests cover owner/private data, role, entitlement, and trusted field write denial.
- Cloud Functions Integration Tests cover activity validation, progression updates, entitlement checks, notification eligibility, expert-plan transitions, and AI boundary if implemented.
- Flutter Widget Tests cover user-visible flows without relying on backend trust violations.
- Manual Evidence / Screenshot is used only where visual/device behavior is necessary and must not expose private GPS or secrets.
- A8_OUTPUT_CHECKER Evidence Review confirms completeness and readiness but is not approval.

Approval evidence required:

- Explicit human/project approval or linked decision artifact for the initial test/evidence plan.

## 17. Final Setup Approval Checklist

Before any further setup or implementation action is requested:

- Gate-00 has fresh clean repository evidence.
- Required gates for the requested scaffold/setup action are `Approved`.
- Approval evidence is linked in this document.
- The requested action names exact paths and commands.
- No protected PRD/PDD/submission/diagram/wireframe file is modified.
- No secrets, API keys, production project IDs, private GPS data, or service accounts are introduced.
- No implementation expansion starts without explicit user approval.

Still forbidden until relevant gates are approved:

- No `flutter create`.
- No `firebase init`.
- No `flutterfire configure`.
- No `pubspec.yaml`.
- No additional or nested `firebase.json` beyond the approved root emulator shell file.
- No `.firebaserc`.
- No `package.json`.
- No `tsconfig.json`.
- No Firestore rules.
- No Storage rules.
- No production Flutter/Firebase source beyond the stock scaffold baseline.

## 18. Explicit Approval Evidence Log

| Date | Gate Name | Status Change | Evidence/Actor | Notes |
| --- | --- | --- | --- | --- |
| 2026-05-24 | Gate-00: Git State Baseline | `Drafted` to `Under Review` | A0_ORCH based on `git status --short` clean output, `git status -sb` showing `main...origin/main`, and latest traceability setup commit `30c55b5 docs(traceability): add phase 1 implementation prep gates` present locally | Historical note from the 2026-05-24 transition. Current Gate-00 approval evidence is recorded below. |
| 2026-05-24 | Phase 1 traceability docs | Created as `Drafted` | User approved creation of `requirements-map.md` and `setup-gates.md` only | Does not approve scaffolding or implementation. LLM/agent-generated decisions alone are not approval. |
| 2026-06-14 | Firebase Project and Config Gate | `Not Started` to `PARTIALLY APPROVED FOR EMULATOR-ONLY ROOT FIREBASE.JSON` | Lee Jinseo approved the chat phrase for Firebase Project and Config Gate emulator-only setup; capsule: `firebase-emulator-shell`; commit reference: commit pending | Approval is limited to root `firebase.json` for Firestore emulator only. Validation evidence: transient `npx firebase-tools@14`, Firestore emulator hub check, Governance CI pass, and direct forbidden artifact scan. Latest `firebase-tools` required Java 21; current smoke validation used transient `firebase-tools@14.27.0`. Java 21/tooling upgrade is future work and is not approved by this capsule. |

### Gate-00 Approval Evidence

- Status: APPROVED
- Date: 2026-05-25
- Approver: Lee Jinseo
- Conditions met:
  - clean working tree
  - branch aligned with origin/main
  - .gitignore hardened
  - traceability IDs added
  - Gate-00 reviewed while marked Under Review
  - protected materials untouched
  - Flutter/Firebase scaffold markers absent
- Known remaining risks:
  - .gitignore covers standard `.env` and `.env.*` patterns; unconventional names like `.envrc` or `.envproduction` are not explicitly covered. Assessment: low risk for FYP scope; Runiac does not currently use these patterns. Future action: add if unconventional env files are introduced.
- Authorization scope:
  - This approval authorizes preparing scaffold approval packets only.
  - This approval does not authorize running `flutter create`, `firebase init`, or `flutterfire configure`.

## Flutter Scaffold Gate Approval Evidence

- Status: APPROVED FOR SCAFFOLD EXECUTION REVIEW
- Date: 2026-05-25
- Approver: Lee Jinseo
- Conditions met:
  - clean working tree
  - branch aligned with origin/main
  - .gitignore hardened
  - traceability IDs added
  - Gate-00 approval evidence recorded
  - reverse-domain org defined
  - platforms restricted to android and ios
  - Firebase setup deferred
  - firebase_options.dart generation deferred
  - scaffold markers still absent at approval-review time
- Known remaining risks:
  - `.gitignore` covers standard `.env` and `.env.*` patterns; unconventional names like `.envrc` or `.envproduction` are not explicitly covered. Assessment: low risk for FYP scope; Runiac does not currently use these patterns. Future action: add if unconventional env files are introduced.
  - `flutter create --no-pub` support depends on the installed Flutter version and must be verified before scaffold execution.
- Authorized command for later review only:
  flutter create --template=app --platforms=android,ios --org com.runiac --project-name runiac_app --no-pub implementation/mobile/runiac_app
- Authorization scope:
  - This approval authorizes preparing and reviewing scaffold execution only.
  - This approval does not itself authorize running `flutter create`.
  - This approval does not authorize Firebase setup, `firebase init`, `flutterfire configure`, dependency resolution, builds, tests, or deployment.

### Flutter Scaffold Baseline Execution Record

- Status: EXECUTED FOR STOCK SCAFFOLD BASELINE
- Scaffold commit: `4b375d2 chore(mobile): add Flutter scaffold baseline`
- Governance transition commit: `c8b2942 ci(governance): allow approved Flutter scaffold baseline`
- State refresh commit: `7aca5ca docs(roadmap): refresh scaffold baseline state`
- Scaffold path: `implementation/mobile/runiac_app/`
- Command executed:
  flutter create --template=app --platforms=android,ios --org com.runiac --project-name runiac_app --no-pub implementation/mobile/runiac_app
- Execution constraints preserved:
  - `--no-pub` was used.
  - No `flutter pub get` was run.
  - No `firebase init` was run.
  - `flutterfire configure` has not been run.
  - No Firebase config/secrets were generated or committed.
  - Firebase Project and Config Gate remained `Not Started` at scaffold execution time. It is now partially approved only for the root Firestore emulator `firebase.json` recorded above.
  - Stock Flutter scaffold baseline is present, but production Runiac feature implementation has not started.
  - Build, deploy, custom tests, source expansion, Firebase setup, and Phase 02 feature work remain unauthorized until separately routed and approved.
