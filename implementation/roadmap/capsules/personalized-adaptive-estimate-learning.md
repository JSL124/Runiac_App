# personalized-adaptive-estimate-learning

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's `ulw-loop` execution request.

Type: Firebase guarded backend-owned adaptive estimate capsule.

## Status

Status: Complete locally.

## Goal

Add the smallest backend-owned personalized adaptive estimate learning slice for generated beginner plans: after `completeRun` accepts a validated run, update a trusted per-user adaptive estimate document from the completed run evidence so future plan work has a backend-owned learning state to consume.

## Agent Chain

`A0_ORCH -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Scope

Allowed implementation files:

- `functions/src/run/completeRun.ts`
- `functions/src/run/runCompletionTypes.ts` only if the callable return contract needs an explicit non-sensitive reference.
- `functions/src/plan/adaptiveEstimate.ts`
- `functions/test/completeRun.test.ts`
- `firestore.rules`
- `tests/firebase-rules/firestore.rules.test.mjs`
- `tests/firebase-rules/support/firestore_rules_test_support.mjs` only if a reusable synthetic adaptive estimate fixture is needed.

Allowed roadmap/workflow artifacts:

- `implementation/roadmap/capsules/personalized-adaptive-estimate-learning.md`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `.omo/ulw-loop/adaptive-estimate-learning-20260707/**`
- `.omo/evidence/adaptive-estimate-learning/**`
- `.omo/plans/personalized-adaptive-estimate-learning.md`

## Required Boundaries

- Adaptive estimate learning is trusted backend-owned state.
- The mobile client must not calculate, create, update, delete, or reset learned adaptive estimate fields.
- `completeRun` may update an owner-scoped `adaptivePlanEstimates/{uid}` document only after payload validation succeeds.
- The learned state must be derived only from accepted run completion payload fields and trusted server-side plan context already available inside the transaction.
- Duplicate `clientRunSessionId` submissions must remain idempotent and must not double-count adaptive estimate learning.
- Low-data or zero-distance saves must not create misleading positive readiness or pace estimates.
- Owner read access may be allowed for display/debug readiness, but client writes must remain denied.

## Forbidden Scope

- No Firebase deploy, Firestore rules/index deploy, Cloud Functions production deploy, or `firebase init`.
- No `flutterfire configure`.
- No `.firebaserc`.
- No secrets, service accounts, API keys, plist/resource config changes, or committed tokens.
- No route trace upload.
- No GPS sample persistence.
- No shared route generation.
- No background tracking.
- No Auto Pause or Moving Time engine implementation.
- No XP formula, level formula, rank formula, weekly XP, monthly XP, leaderboard score, or leaderboard aggregation.
- No premium entitlement logic.
- No expert-plan publication logic.
- No Phase 02 selection.
- No client-side mutation or calculation of backend-owned adaptive estimate state.
- No broad generated-plan regeneration or AI/LLM plan adaptation in this capsule.

## Required Validation

- RED to GREEN Functions test proving a valid run creates or updates `adaptivePlanEstimates/{uid}`.
- RED to GREEN Functions test proving duplicate run completion does not double-count adaptive estimate learning.
- RED to GREEN Functions test proving low-data confirmed runs keep adaptive estimate state conservative.
- RED to GREEN Firestore rules test proving owner read and denied cross-owner/client writes for `adaptivePlanEstimates/{uid}`.
- `git diff --check`.
- `cd functions && npm test`.
- `cd tests/firebase-rules && npm test`.
- ULW final quality gate evidence for code review, QA review, and gate review.

## Done When

- [x] A valid accepted run writes backend-owned adaptive estimate state for the authenticated owner.
- [x] The adaptive estimate state records the latest accepted activity, completed run count, last run timing/distance/duration, average recent pace, readiness band, source, and update timestamp.
- [x] Duplicate completion for the same `clientRunSessionId` is idempotent and does not increment completed run count twice.
- [x] Confirmed low-data runs do not create misleading positive readiness or pace estimates.
- [x] Firestore rules allow owner read and deny cross-owner reads plus all client create/update/delete writes.
- [x] Existing streak, plan progress, cadence, duration, run summary, generated plan, and profile rules behavior remains green.
- [x] No forbidden route/GPS/background/XP/leaderboard/premium/expert/Phase 02 scope is introduced.
- [x] Final automated validation and ULW quality gate evidence are captured.

## Closure Evidence

- RED Functions: `.omo/evidence/adaptive-estimate-learning/c001-red-functions.txt`.
- GREEN Functions: `.omo/evidence/adaptive-estimate-learning/c001-green-functions.txt` passes 41/41.
- RED rules: `.omo/evidence/adaptive-estimate-learning/c002-red-rules.txt`.
- GREEN rules: `.omo/evidence/adaptive-estimate-learning/c002-green-rules.txt` passes 34/34.
- Regression: `.omo/evidence/adaptive-estimate-learning/c003-regression-diff-check.txt`, `.omo/evidence/adaptive-estimate-learning/c003-regression-functions.txt`, and `.omo/evidence/adaptive-estimate-learning/c003-regression-rules.txt`.
