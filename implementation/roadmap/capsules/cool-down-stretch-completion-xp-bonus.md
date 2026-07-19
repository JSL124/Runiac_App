# cool-down-stretch-completion-xp-bonus

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Mode / Type

Mode: PDD_MODE governance routing (explicit user routing on 2026-07-14 Asia/Singapore). This capsule document records the approved implementation plan; it is not itself an implementation authorization to touch `functions/`, `firestore.rules`, or Flutter source beyond this governance slice.

Type: Backend Guarded Lane full-stack capsule (Cloud Functions + Firestore rules + Flutter display wiring), emulator-first per ADR-002, lane classification per ADR-003.

## Goal

Deliver a new emulator-first `completeCoolDown` Cloud Functions callable that awards a small, server-computed, idempotent XP bonus for completing the full 14-step cool-down stretch sequence after a run, plus the minimal Firestore rules protection and Flutter display-only wiring needed to request and show the trusted result. The client never calculates or fabricates the bonus; it only renders what the server returns.

## Bonus Formula (record exactly)

Given `baseEarnedXp` = the run's already-credited XP for the same activity (the value `completeRun` computed and persisted for that activity, i.e. the XP amount before any cool-down bonus):

1. `rawBonus = clamp(roundToNearest5(0.20 * baseEarnedXp), 5, 20)`
2. `appliedBonus = max(0, min(rawBonus, 100 - baseEarnedXp))` — enforces the existing 100 XP per-activity cap (`activityXpCap` in `functions/src/progression/progressionCalculator.ts`).
3. `appliedBonus` is further reduced, if necessary, so that `dailyXpTotal + appliedBonus <= 200` (the existing `dailyXpCap`/`dailyCapDateForCompletedAt` mechanism). If the day is already at or over the 200 XP cap, `appliedBonus = 0` and the reason is recorded as `cool_down_daily_cap_reached`.
4. If `baseEarnedXp` is `0` (zero-XP runs, including premium-user runs and low-data/rejected-metric runs), `appliedBonus` is always `0`. Premium users must never receive XP, rank, or leaderboard advantage — this is a non-negotiable Runiac rule, not merely a formula edge case, so the check is explicit and independent of the arithmetic above.
5. The bonus is paid only when `completedStretchCount === 14` (the full cool-down stretch sequence) is reported by the client and the payload passes validation; any lesser count, a Skip-to-Summary path, or an invalid/missing payload pays `0` and does not create a bonus event.
6. Payment is idempotent per activity via a persisted `coolDownXpAwarded` flag (and `coolDownXpAwardedAt`, `coolDownProgressionEventId`) on the activity document; a retried or duplicate `completeCoolDown` call for the same activity id returns the previously computed result without re-crediting XP.
5.1. The awarded bonus counts toward the same leaderboard/weekly/monthly XP aggregates as ordinary run XP (it is written through the existing progression/audit event pipeline, not a parallel ledger).

## Allowed Scope

- New callable `functions/src/run/completeCoolDown.ts` (region `asia-southeast1`, matching `completeRun`'s deployment posture) that: authenticates the caller, loads the caller's own activity document by id, validates the cool-down payload, computes `baseEarnedXp` from the already-persisted activity/run XP, applies the bonus formula above, and — only on first successful award — writes `coolDownXpAwarded`, `coolDownXpAwardedAt`, `coolDownProgressionEventId`, and a progression/audit event with reason `cool_down_stretch_bonus_awarded` (or `cool_down_daily_cap_reached` when the cap zeroes the bonus). All computation happens server-side; the callable returns only the trusted result (applied bonus, new total XP, reason) for client display.
- New `functions/src/run/validateCoolDownPayload.ts` validating the callable payload: activity id ownership/shape, `completedStretchCount` (integer, bounded, must equal 14 to pay), and rejection of any client-supplied XP/level/rank/streak/leaderboard field per the standard `rejectUnsupportedFields.ts` pattern already used by `completeRun`.
- New pure helper `calculateCoolDownBonus` added to `functions/src/progression/progressionCalculator.ts`, implementing the exact formula above (clamp/round/cap/daily-cap/zero-base/premium checks) so it is unit-testable independent of Firestore.
- New reason literals `cool_down_stretch_bonus_awarded` and `cool_down_daily_cap_reached` added to the reason union in `functions/src/run/runCompletionTypes.ts` and surfaced through `functions/src/progression/progressionDisplayReader.ts` for read-back display.
- Deterministic cool-down progression event id helper added alongside the existing deterministic id helpers in `functions/src/run/runCompletionArtifacts.ts`, so retries derive the same `coolDownProgressionEventId` for the same activity (supporting idempotency).
- Export addition (only) for `completeCoolDown` in `functions/src/index.ts`.
- `functions/package.json`: one additive test-script entry only (no new dependencies), mirroring the existing `test:*` script pattern.
- New tests: `functions/test/completeCoolDown.test.ts` (emulator-backed callable behavior: full-14-step award, partial/Skip-to-Summary non-payment, idempotent retry, zero-base/premium zero-bonus, 100 XP per-activity cap interaction, 200 XP daily cap interaction) and worked-example unit tests added to `functions/test/progressionCalculator.test.ts` for `calculateCoolDownBonus` (deterministic numeric worked examples at representative `baseEarnedXp` values, including boundary values around the 5/20 clamp and the two caps).
- `firestore.rules`: add `coolDownXpAwarded`, `coolDownXpAwardedAt`, `coolDownProgressionEventId` to the existing backend-owned-keys denylist for activity documents, so no client write to these fields is ever permitted.
- `tests/firebase-rules/firestore.rules.test.mjs`: one additive denial test proving a client write attempt to any of the three new backend-owned keys is rejected.
- Flutter client wiring, display-only, under `implementation/mobile/runiac_app/lib/features/run/**`: a `completeCoolDown` method added to the existing run repository interface/contract, a FlutterFire callable implementation (mirroring the existing `flutterfire_complete_run_callable.dart` pattern) that invokes the callable and returns the trusted result, and a display-merge helper that folds the returned bonus/total XP into the already-rendered run-completion/XP display without any local computation. The guided cool-down Finish action requests the bonus after the sequence completes; Skip to Summary never requests it.
- Widget/unit test updates: `test/run_flow_static_ui_test.dart` plus minimal fake/stub updates in whichever other run test files exercise the run-completion repository fakes, so the new interface method is satisfied without behavior changes to unrelated flows.
- Governance files: this capsule file, `implementation/roadmap/CURRENT.md` (append-only), `tools/governance-ci/check-diff-hygiene.sh` (routed-capsule allowlist entry only, mirroring the `is_challenge_distance_system_*` pattern).

## Forbidden Scope

- No client calculation, estimation, or fabrication of XP, level, rank, streak, leaderboard score, weekly/monthly XP, subscription privilege, or expert-plan publication state. The client only displays the server's returned bonus/total.
- No change to premium entitlement logic beyond preserving the existing non-negotiable rule that premium users receive zero XP; no new premium-only bonus multiplier or advantage of any kind.
- No payment for partial stretch completion, Skip-to-Summary, or any `completedStretchCount` other than the full 14.
- No new dependencies, no `firebase init`, no `flutterfire configure`, no production deploy, no secrets/service accounts.
- No edits to unrelated capsule scope: `realtime-social-challenge-sync.md`, `home-you-state-stability.md`, `challenge-distance-system.md`, cadence-capture-reliability-recovery, activity-history, leaderboard/XP formula files outside the additive helper above, or any file not explicitly listed in Allowed Scope.
- No modification of `docs/submissions/`, `PRD.md`, or reordering of any existing `CURRENT.md` routing bullet — additions to `CURRENT.md` are append-only.
- No silent client fallback that invents a bonus value on failure — on any `completeCoolDown` error, the client must fall back to displaying the pre-bonus (already-trusted) run-completion result and take no local corrective action.

## Exact Target Files

- `implementation/roadmap/capsules/cool-down-stretch-completion-xp-bonus.md`
- `functions/src/run/completeCoolDown.ts`
- `functions/src/run/validateCoolDownPayload.ts`
- `functions/src/run/runCompletionTypes.ts`
- `functions/src/run/runCompletionArtifacts.ts`
- `functions/src/progression/progressionCalculator.ts`
- `functions/src/progression/progressionDisplayReader.ts`
- `functions/src/index.ts`
- `functions/package.json`
- `functions/test/completeCoolDown.test.ts`
- `functions/test/progressionCalculator.test.ts`
- `firestore.rules`
- `tests/firebase-rules/firestore.rules.test.mjs`
- `implementation/mobile/runiac_app/lib/features/run/**` (repository interface addition, FlutterFire callable, display-merge helper — minimal, additive)
- `implementation/mobile/runiac_app/test/run_flow_static_ui_test.dart` (plus minimal fake updates in other run test files as needed to satisfy the new interface method)
- `implementation/roadmap/CURRENT.md` (append-only)
- `tools/governance-ci/check-diff-hygiene.sh` (routed-capsule allowlist entry only)

## Required Tests

```bash
cd functions && npm run build
cd functions && npm test
cd tests/firebase-rules && npm test
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
```

- `functions/test/completeCoolDown.test.ts`: full-14-step award happy path; partial/`Skip to Summary` non-payment; idempotent retry (same activity id does not double-credit); zero-base and premium-user zero-bonus; interaction with the 100 XP per-activity cap; interaction with the 200 XP daily cap (`cool_down_daily_cap_reached` reason).
- `functions/test/progressionCalculator.test.ts`: worked-example unit tests for `calculateCoolDownBonus`, including boundary values at the 5/20 clamp edges and both caps.
- `tests/firebase-rules/firestore.rules.test.mjs`: denial test for client writes to `coolDownXpAwarded`, `coolDownXpAwardedAt`, `coolDownProgressionEventId`.
- Flutter: `run_flow_static_ui_test.dart` updated/extended to cover the display-merge of a server-returned bonus without introducing local computation; other run test files updated minimally only where fakes must satisfy the new repository method signature.

## Required Validation

- ADR-002 emulator-first validation only, against Firestore/Functions emulators under project `runiac-functions-test` (or the existing functions test project convention) — no production deploy claim.
- A11_FIREBASE_IMPL for the callable/formula/rules work; A13_SECURITY_RULES for the backend-owned-key denylist and denial test; A10_FLUTTER_IMPL for the display-only client wiring; A6_REVIEW for boundary/consistency; A12_QA_TEST for the emulator test run; A8_OUTPUT_CHECKER before any readiness claim.
- `./tools/governance-ci/run-all-checks.sh` and `git diff --check` must pass with only this capsule's three governance files (plus, once created by their respective work, the listed Functions/rules/Flutter files) in the diff.

## Required Evidence

- Emulator test output for `functions/test/completeCoolDown.test.ts` and `functions/test/progressionCalculator.test.ts` showing all worked examples and cap-interaction cases passing.
- `tests/firebase-rules` output showing the new denial test passing.
- `flutter analyze --no-pub` and `flutter test` output for the touched Flutter files.
- `run-all-checks.sh` output confirming no forbidden/unrelated path is flagged.

## Rollback Conditions

- Any evidence that the bonus can be paid for a `completedStretchCount` other than 14, paid twice for the same activity, paid to a premium user, or paid in a way that pushes an activity or a day over the 100/200 XP caps.
- Any client code path that computes, estimates, or displays a bonus value not returned verbatim by `completeCoolDown`.
- Any modification to an unrelated capsule's files, or any reordering of an existing `CURRENT.md` routing bullet.

## Exit Criteria

- [ ] Target files completed within the exact scope above.
- [ ] Required tests passing (Functions emulator suite, Firestore rules suite, Flutter analyze/test).
- [ ] Required evidence recorded.
- [ ] `implementation/roadmap/CURRENT.md` updated (append-only) with this capsule's routing bullet.
- [ ] `tools/governance-ci/check-diff-hygiene.sh` allowlist entry added and `run-all-checks.sh` passing.

## Stop State

Stop at `Ready for commit`. No automatic staging, commit, or push is authorized by this capsule document.
