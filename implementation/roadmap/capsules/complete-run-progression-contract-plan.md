# complete-run-progression-contract-plan

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved.

Type: Backend Guarded Lane contract/design capsule.

## Status

Status: Contract plan completed and locally validated on 2026-06-14 Asia/Singapore. Cloud Functions implementation has not started.

## Required Agent Chain

```text
A0_ORCH -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Define the backend contract for completing a run and producing trusted progression outputs, without implementing Cloud Functions, XP formulas, leaderboard aggregation, FlutterFire wiring, production Firebase, secrets, service accounts, or real GPS/private route fixtures.

## Current Baseline

- Emulator-only Firebase baseline exists.
- Root `firebase.json` defines the local Firestore emulator shell.
- Root `firestore.rules` and `firestore.indexes.json` exist.
- Synthetic Firestore rules tests exist under `tests/firebase-rules/`.
- Rules currently allow an authenticated owner to create a raw pending `activities` document with safe activity fields.
- Rules deny client writes to `runSummaries`, `progressionEvents`, and `leaderboardSnapshots`.
- Rules deny client writes to backend-owned progression, role, entitlement, validation, moderation, and publication fields.
- No production Firebase project, `.firebaserc`, FlutterFire/mobile config, Cloud Functions source, Auth/Firestore app wiring, backend-owned progression logic, or real GPS/private route fixtures exist.

## Scope

Allowed files for this capsule:

- `implementation/roadmap/capsules/complete-run-progression-contract-plan.md`
- `tools/governance-ci/check-diff-hygiene.sh` only if needed to allowlist this exact capsule path for Governance CI

Allowed work:

- Define raw run completion payload fields.
- Define future backend validation responsibilities.
- Define backend-owned output/read model boundaries.
- Define Firestore write ownership.
- Define future Cloud Function API boundary.
- Define emulator test strategy.
- Define future implementation file scope.
- Define forbidden scope and drift risks.

## Forbidden Scope

- No Cloud Functions implementation.
- No `functions/` or `firebase/functions/` directory.
- No Functions package files, `package.json`, `tsconfig.json`, or source files.
- No XP formula implementation.
- No leaderboard aggregation implementation.
- No FlutterFire/mobile Firebase wiring.
- No production Firebase project.
- No `.firebaserc`.
- No deploy.
- No service accounts, secrets, `.env*`, API keys, or credentials.
- No Firebase commands.
- No npm commands.
- No real GPS/private route data or fixtures.
- No Firestore rules, index, emulator config, or rules test changes in this capsule.
- No Flutter implementation changes.
- No Phase 02 selection or setup gate opening.

## Raw Run Payload Contract

Flutter may submit only a raw client-observed run completion payload. All raw metrics are untrusted until validated by the backend.

Required future payload fields:

- `clientRunSessionId`
- `startedAt`
- `completedAt`
- `durationSeconds`
- `distanceMeters`
- `avgPaceSecondsPerKm`
- `source`
- `routePrivacy`

Optional future payload fields:

- `routeLabel`
- `avgHeartRate`
- `caloriesEstimate`
- `planEnrollmentId`
- `scheduledWorkoutId`
- `deviceRecordedAt`
- `clientAppVersion`

Untrusted client-observed values:

- Timestamps.
- Duration.
- Distance.
- Pace.
- Heart rate.
- Calories.
- Route label.
- Route privacy selection.
- Plan or scheduled workout references.
- Device/app metadata.
- Local session ID.

The client must not submit trusted replacements for:

- XP.
- Streak.
- Level.
- Rank.
- Leaderboard score.
- Weekly XP.
- Monthly XP.
- Validation status.
- Contribution status.
- `subscriptionStatus`.
- `userRole`.
- Admin or expert privilege state.
- Expert plan publication state.
- Validated activity contribution state.

## Backend Validation Contract

A future Cloud Function must validate the raw payload before persistence, progression, summaries, or leaderboard effects.

Future validation responsibilities:

- Require authenticated Firebase identity.
- Confirm the authenticated user owns the completion request.
- Validate required fields and field types.
- Confirm `completedAt > startedAt`.
- Confirm `durationSeconds` roughly matches the timestamp delta within an approved tolerance.
- Check plausible beginner-running bounds for duration, distance, and pace.
- Treat heart-rate and calories as optional, plausibility-checked, non-authoritative client observations.
- Enforce duplicate/idempotency behavior by `clientRunSessionId`.
- Enforce route privacy safety.
- Exclude precise GPS/private route traces from this capsule.
- Confirm `planEnrollmentId` and `scheduledWorkoutId`, when present, belong to the authenticated user and are eligible for this run.
- Reject or ignore client-submitted trusted progression, entitlement, role, validation, contribution, and publication fields.
- Confirm Premium status gives no XP, rank, leaderboard score, weekly/monthly XP, level, streak, or competitive advantage.
- Ensure activity validation precedes progression contribution.

Validation outcomes should be explicit:

- `validated`: activity may contribute to official activity history and future progression.
- `needs_review`: activity is retained for safe review or later backend handling but does not contribute to progression.
- `rejected`: activity is retained or rejected according to future retention policy and does not contribute to progression.

Exact thresholds, XP formula, streak formula, rank formula, and leaderboard aggregation rules remain out of scope.

## Backend-Owned Output Contract

The future backend must clearly separate raw client input, official validated activity state, read-only run summary, progression event, and deferred leaderboard aggregation.

### `activities`

Purpose: official activity record rooted in raw client input plus backend validation state.

Future fields may include:

- `ownerUid`
- `status`
- `source`
- `activityType`
- `startedAt`
- `endedAt`
- `durationSeconds`
- `distanceMeters`
- `averagePaceSecondsPerKm`
- `routePrivacy`
- `clientRunSessionId`
- `planEnrollmentId`
- `scheduledWorkoutId`
- `createdAt`
- `updatedAt`
- `processedAt`
- `validationStatus`
- `validatedActivityContributionState`
- `countsTowardProgression`
- `validationReason`

Client-owned part: raw observed fields only, if rules continue allowing pending activity creation.

Backend-owned part: `validationStatus`, `validatedActivityContributionState`, `countsTowardProgression`, processed status transitions, and any official contribution decision.

### `runSummaries`

Purpose: read-only backend-produced completion summary for the user.

Future fields may include:

- `ownerUid`
- `activityId`
- `title`
- `startedAt`
- `endedAt`
- `distanceMeters`
- `durationSeconds`
- `averagePaceSecondsPerKm`
- `displayDistance`
- `displayDuration`
- `displayPace`
- `routeLabel`
- `createdAt`

The client reads this output but does not create, update, or delete it.

### `progressionEvents`

Purpose: append-only backend-produced progression event describing trusted effects of a validated activity.

Future fields may include:

- `ownerUid`
- `activityId`
- `eventType`
- `status`
- `createdAt`
- `xpDelta`
- `previousTotalXp`
- `nextTotalXp`
- `previousLevel`
- `nextLevel`
- `previousStreak`
- `nextStreak`
- `countsTowardLeaderboard`
- `reason`

This capsule defines the event boundary only. XP/streak/level formulas are not implemented or approved here.

### `leaderboardSnapshots`

Purpose: backend-produced read model for future leaderboard display.

Future fields may include:

- `period`
- `region`
- `division`
- `generatedAt`
- `entries`

Leaderboard aggregation remains deferred. A run completion may eventually feed trusted aggregates only after backend validation and a separately approved aggregation capsule.

## Firestore Write Plan

Current rules baseline:

- Client can create a raw pending `activities` document only when rules allow the exact safe field set.
- Client cannot write backend-owned validation or progression contribution fields.
- Client cannot create, update, or delete `runSummaries`.
- Client cannot create, update, or delete `progressionEvents`.
- Client cannot create, update, or delete `leaderboardSnapshots`.

Future intended ownership:

- Backend owns activity validation fields and official status transitions.
- Backend owns `runSummaries`.
- Backend owns `progressionEvents`.
- Backend owns `leaderboardSnapshots`.
- Client reads backend-produced trusted outputs only.
- Direct pending `activities` creation may later be narrowed or replaced by callable-only completion if the callable design becomes the primary API.

## Cloud Function Boundary

Preferred future API:

```text
completeRun(payload) -> read-only completion result
```

Callable function is preferred because it provides:

- Authenticated request/response.
- Controlled validation before writes.
- Idempotency by `clientRunSessionId`.
- Immediate UX result for the completion screen.
- A clear boundary that avoids client-triggered progression writes.
- A single place to reject or ignore trusted client-submitted fields.

The response should be read-only and may include:

- `activityId`
- `summaryId`
- `progressionEventId`
- `validationStatus`
- `runSummary`
- `progressionDisplay`
- `message`

Firestore triggers may be considered later for backend-internal reconciliation only. A trigger must not become the primary client API for trusted progression.

## Emulator Test Strategy

Future Function emulator tests:

- Valid payload succeeds and returns a read-only completion result.
- Missing auth fails.
- Owner mismatch fails.
- Duplicate `clientRunSessionId` is idempotent.
- Implausible metrics are rejected or marked `needs_review`.
- Client XP/progression/role/entitlement/publication fields are ignored or rejected.
- Premium users receive no XP, rank, leaderboard score, weekly/monthly XP, level, streak, or competitive advantage.
- No precise GPS/private route traces are persisted.
- Plan/workout references that do not belong to the user fail.

Future Firestore rules regression tests:

- Client can create only a raw pending activity if direct pending activity creation remains allowed.
- Client cannot write `validationStatus`.
- Client cannot write `validatedActivityContributionState`.
- Client cannot write `countsTowardProgression`.
- Client cannot write XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription privilege state, userRole/admin/expert privilege state, or expert plan publication state.
- Client cannot create, update, or delete `runSummaries`.
- Client cannot create, update, or delete `progressionEvents`.
- Client cannot create, update, or delete `leaderboardSnapshots`.
- Synthetic rules fixtures do not contain real GPS/private route data.

No emulator tests are added by this contract capsule.

## Files Likely to Create Later

Future only, after separate Cloud Functions implementation approval:

- `functions/src/run/completeRun.ts`
- `functions/src/run/validateRunPayload.ts`
- `functions/src/run/runCompletionTypes.ts`
- `functions/src/progression/progressionEventWriter.ts`
- `functions/test/completeRun.test.ts`
- `tests/firebase-rules/firestore.rules.test.mjs` updates
- `firestore.rules` updates if needed

Do not create these files in this capsule.

## Existing Flutter Static Boundary

Existing static Flutter run completion/read-model files are future-facing presentation contracts only:

- `RunCompletedPayload` already describes client-observed raw run metrics for a future backend boundary.
- `CompleteRunResult` combines display-only summary and XP update display models.
- XP labels in static Flutter display models must remain presentation-only placeholders until backend-produced trusted progression output exists.

Flutter must not calculate, persist, upload, sync, validate, or submit trusted progression outputs in this capsule.

## Risks / Drift Concerns

- Existing direct pending `activities` creation may later be narrowed by callable-first completion design.
- Static Flutter `CompleteRunResult` has XP display labels; those must remain display-only until backend produces trusted values.
- XP formula pressure should be resisted until a separate XP formula contract or implementation capsule is approved.
- Leaderboard aggregation pressure should be resisted until a separate aggregation capsule is approved.
- Real GPS/private route traces remain out of scope and must not enter fixtures, docs, logs, screenshots, or test evidence.
- Firebase README files now reflect the emulator-only baseline, but future backend work must keep them aligned with actual setup state.

## Required Validation

```bash
git status --short --untracked-files=all
git diff --check
./tools/governance-ci/run-all-checks.sh
tools/governance-ci/check-sensitive-paths.sh
find . -path ./.git -prune -o \( -name .firebaserc -o -name firebase_options.dart -o -name google-services.json -o -name GoogleService-Info.plist -o -type d -name functions -o -name .env -o -name '.env.*' -o -name '*.env' -o -iname '*service-account*.json' -o -iname 'serviceAccount*.json' -o -iname '*-service-account.json' -o -iname '*.credentials.json' \) -print
```

The direct forbidden artifact scan may report the known ignored Flutter ephemeral env file under `implementation/mobile/runiac_app/ios/Flutter/ephemeral/`; it must not report Firebase config, Functions, secrets, service accounts, or credentials.

## Done When

- [x] Raw run payload contract is documented.
- [x] Backend validation contract is documented.
- [x] Backend-owned output contract is documented.
- [x] Firestore write plan is documented.
- [x] Cloud Function boundary is documented.
- [x] Emulator test strategy is documented.
- [x] Future implementation file scope is documented as future-only.
- [x] Forbidden scope remains explicit.
- [x] Required validation passes.
- [x] No Cloud Functions, Firebase config, rules, tests, FlutterFire wiring, secrets, service accounts, or GPS/private route fixtures are created.
