# leaderboard-jurong-east-seed-verification

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as a narrowly approved implementation follow-up. This capsule does not select Phase 02 or authorize unrelated product work.

## Mode / Type

Mode: IMPLEMENTATION_MODE, explicitly approved for a bounded replacement of marker-owned synthetic Leaderboard data in `runiac-fypp`.

Type: monthly territorial Leaderboard seed-tooling correction, emulator-first verification, reversible production mock-data replacement, and read-back evidence.

## Status

Status: Active / Production confirmation pending. The scoped seed tooling, tests, optimization, local QA, and five-lane final review are complete and Ready for commit. The production read-only inventory and cleanup preview are recorded in this capsule and `.omo/evidence/leaderboard-production-inventory-20260710.md`; no production-data mutation has occurred under this capsule. Because the original tool output did not retain a raw log or absolute timestamp, a fresh inventory remains mandatory immediately before any production mutation.

## Goal

Replace every existing marker-owned Leaderboard mock run in `runiac-fypp` with exactly 100 distinct, realistic synthetic profiles in Jurong East for period `2026-07`.

The resulting synthetic cohort must contain 99 Basic Users who are ranked and one Premium User who is explicitly ineligible for rank. The leaderboard remains monthly-only and backend-owned.

## Approved Product Decisions

- The selected planning area is Jurong East only: `regionId: jurong-east`, `locationLabel: Jurong East, Singapore`.
- The period is exactly `2026-07` and uses `Asia/Singapore` monthly boundaries.
- The new synthetic cohort contains exactly 100 distinct synthetic UIDs, profiles, and contribution documents: 99 Basic Users and one Premium User.
- The Premium User must have `ineligible_premium`, no rank projection, no leaderboard score, no XP advantage, and no competitive advantage.
- The expected isolated projection result is 10 Jurong East league snapshots, 99 user-rank projections, 100 current-view projections, and public top-row bounds of 10 with owner-nearby bounds of 5.
- Existing marker-owned mock runs must be replaced, not retained. A production read-only inventory must identify their manifest IDs, marker counts, UID prefixes, affected projections, and exact deletion candidates before any delete operation.
- The real-user data boundary is absolute: never delete or alter a non-marker-owned `users`, `userProfiles`, contribution, rank, current-view, snapshot, activity, run summary, route, GPS, Auth, or other user document.
- No Firebase Authentication accounts may be created. Synthetic data contains no real names, emails, GPS coordinates, route traces, secrets, or credentials.
- Weekly Leaderboard remains excluded. Existing weekly training-plan concepts remain unaffected.

## Agent / Review Chain

`Sol orchestration -> Terra worker: seed-tooling and Functions tests -> Terra worker: production inventory/cleanup evidence -> Terra worker: Flutter/read-contract and rules review -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

Sol owns routing, scope control, confirmation pauses, the final production decision, and evidence reconciliation. Terra workers own only their assigned bounded lane and must not perform production mutation unless Sol has recorded the required confirmation gate.

## Allowed Files

- `functions/src/leaderboard/**`
- `functions/src/leaderboard/leaderboardMockDataset.ts`
- `functions/src/leaderboard/leaderboardMockProfiles.ts`
- `functions/src/leaderboard/leaderboardSeedArguments.ts`
- `functions/src/leaderboard/leaderboardSeedCommandTypes.ts`
- `functions/src/leaderboard/leaderboardSeedDataset.ts`
- `functions/src/leaderboard/leaderboardSeedFirestore.ts`
- `functions/src/leaderboard/leaderboardSeedInventory.ts`
- `functions/src/leaderboard/leaderboardSeedMutation.ts`
- `functions/src/leaderboard/leaderboardSeedVerification.ts`
- `functions/src/leaderboard/seedLeaderboardMockData.ts`
- `functions/test/monthlyLeaderboard.test.ts`
- `functions/test/leaderboardMockDataset.test.ts`
- `functions/test/seedLeaderboardCleanup.test.ts`
- `functions/test/seedLeaderboardInventory.test.ts`
- `functions/test/seedLeaderboardMockData.test.ts`
- `functions/package.json` and `functions/tsconfig.json` only if required by the scoped seed/test command
- `tests/firebase-rules/firestore.rules.test.mjs` only for a concrete Leaderboard rule regression
- `implementation/mobile/runiac_app/lib/features/leaderboard/**` and `implementation/mobile/runiac_app/test/firestore_leaderboard_repository_test.dart` only for a concrete read-contract regression
- `firestore.rules` and `firestore.indexes.json` only when a demonstrated Leaderboard query/rule gap requires it
- This capsule, `implementation/roadmap/CURRENT.md`, `implementation/roadmap/snapshots/latest.md`, and capsule-scoped evidence files

## Forbidden Scope

- No Weekly Leaderboard, weekly ranking, or competitive Premium feature.
- No modification of XP, level, rank, division, eligibility, or aggregation ownership outside the existing trusted backend path.
- No client-side trusted-value calculation or write.
- No real-user, Auth, GPS, route, activity, run summary, plan, notification, or unrelated collection deletion.
- No broad collection delete, no `firebase init`, no `flutterfire configure`, no service account, no secret, no committed credential, and no new dependency unless separately approved.
- No production deployment, commit, push, or PR without separate explicit user authorization.
- No production mutation before the confirmation gates below are satisfied.

## Required Implementation and Verification

1. Implement an allowlisted Jurong East-only seed option and deterministic synthetic cohort. The seed dry run must report 100 profiles, 99 Basic Users, one Premium User, 300 source documents, deterministic UID prefix, and the selected planning area.
2. Fix scoped seed verification so it remains valid when unrelated real or synthetic current-period snapshots exist. It must validate only the new run's marked inputs and exact affected Jurong East projections; it must not require the whole production period to contain one region.
3. Add RED/GREEN Functions coverage for the 100-profile Jurong East-only dataset: expected per-league ordering/counts, 99 ranks, 100 current views, one Premium exclusion, top-10, nearby-5, safe public fields, and cleanup isolation.
4. Run all required emulator-first Functions, rules, and Flutter read-contract validation before any production mutation. Record command, project, run ID, period, expected counts, actual counts, and outcome in capsule-scoped evidence.
5. Run a production read-only inventory. It must enumerate marker-owned mock manifests and documents, identify all prefixes/run IDs to remove, and show that non-marker-owned data is excluded from deletion candidates.
6. After confirmed seed only, dry-run, seed, refresh, and read back the single Jurong East cohort. Confirm the exact expected counts and Premium exclusion before any old-run cleanup.
7. After confirmed cleanup only, delete only inventory-approved marker-owned old-run documents and prefix-scoped projections, then perform the final trusted refresh, read-back verification, and inventory. Record zero remaining old marker-owned mock documents and the intact new Jurong East cohort.
8. Retain the new manifest/run ID and provide a matching prefix-scoped cleanup command. Do not execute that final cleanup unless separately directed.

## Production Confirmation Gates

No production command is authorized by this routing document alone.

1. **Inventory gate:** Sol records a read-only inventory for `runiac-fypp`, including exact old run IDs, prefixes, collection/document counts, and a statement that no real-user/Auth/GPS/route data is a candidate. No deletion occurs in this step.
2. **Seed gate:** After emulator evidence and the inventory are shown, the user must explicitly confirm the exact new run ID, project `runiac-fypp`, period `2026-07`, Jurong East-only scope, and expected 100/99/1 counts before any production seed, refresh, or verification command.
3. **Cleanup gate:** After the new cohort has passed production read-back, the user must explicitly confirm the exact project and exact enumerated old run IDs/prefixes for deletion. The confirmation must state that marker-owned mock data only may be removed. A stale, partial, or ambiguous inventory requires a new read-only inventory rather than deletion.
4. **Closure gate:** Production read-back must show the new manifest and expected counts. Any discrepancy, unexpected unmarked deletion candidate, missing Premium exclusion, or unscoped snapshot verification result stops the workflow and requires Sol review; it must not be repaired by broad deletion or reseeding.

## Required Production Sequence

1. Read-only inventory of all existing marker-owned Leaderboard mock runs.
2. User-confirmed Jurong East-only production dry run, seed, trusted monthly refresh, and read-back verification for the new unique run ID.
3. User-confirmed, run-ID/prefix-scoped production cleanup of only the inventory candidates after the new cohort has passed read-back.
4. Final trusted refresh, read-back verification, and inventory showing no old marker-owned mock documents remain and the new cohort is intact.
6. Evidence review plus A13, A6, A12, and A8 approval; stop Ready for commit. Do not commit, push, or deploy.

## Recorded Read-Only Production Inventory

On 2026-07-10, the compiled CLI completed the following read-only commands
against `runiac-fypp` using Firebase CLI authentication:

```sh
node lib/src/leaderboard/seedLeaderboardMockData.js \
  --project runiac-fypp \
  --inventory \
  --firebase-cli-auth

node lib/src/leaderboard/seedLeaderboardMockData.js \
  --project runiac-fypp \
  --period 2026-07 \
  --run-id leaderboard-qa-20260710 \
  --users-per-region 100 \
  --preview-cleanup \
  --firebase-cli-auth
```

The inventory returned `status: ready` with one run:
`leaderboard-qa-20260710`, prefix
`lbmock_leaderboard-qa-20260710_`, period `2026-07`, manifest status
`verified`, 3,700 users, 3,700 profiles, 3,700 contributions, 3,663 ranks,
3,700 current views, and no issues. The cleanup preview also returned
`status: ready`, with 11,100 source documents, 3,663 rank documents, 3,700
current-view documents, and no issues. No production write occurred.

Evidence limitation: the completed tool output did not retain a raw log or an
absolute start/end timestamp. These values were transcribed from that output;
therefore this record supports routing only. Inventory and preview must be
rerun and reviewed immediately before any production mutation.

## Optimized CLI Safety Contract

The implementation review added the following fail-closed behavior:

- Verification reads ranks only for the affected snapshot IDs, in batches of
  ten, rather than scanning every rank in the month.
- Inventory builds one-pass run indexes and emits a non-PII
  `cleanupInventoryFingerprint` that changes with the manifest or candidate
  counts.
- Seed source writes and the manifest use one atomic batch; oversized seed
  requests fail before creating a manifest.
- Cleanup persists its original candidate counts, observes every BulkWriter
  operation result, and can resume from an exact remaining subset or zero
  remaining candidates without losing the original deletion count.
- Every production mutation requires Firebase CLI authentication. Production
  cleanup additionally requires exact project/period/region/users/run
  confirmations, the current inventory fingerprint, and a distinct verified
  replacement run with the exact Jurong East 100/99/1 contract.

Local validation on 2026-07-10 passed:

- Functions build and full emulator suite: 121/121 tests.
- Firestore Rules emulator suite: 47/47 tests.
- Manual compiled CLI dry run: 100 profiles, 99 Basic, one Premium, 300 source
  writes.
- Manual emulator lifecycle: 300 source writes; refresh 10 snapshots, 99
  ranks, 100 views; verification passed; cleanup deleted 499 documents; zero
  run-owned documents remained.

No production access or mutation occurred during this optimization review.
The consolidated local code-quality, security, context, and manual-QA record
is `.omo/evidence/leaderboard-seed-final-review-summary.md`.

## Current Operator Command Shape

All commands run from `functions/`. `npm run leaderboard:seed --` builds the
TypeScript CLI before invoking it.

Read-only inventory and preview:

```sh
npm run leaderboard:seed -- \
  --project runiac-fypp \
  --inventory \
  --firebase-cli-auth

npm run leaderboard:seed -- \
  --project runiac-fypp \
  --period 2026-07 \
  --run-id leaderboard-qa-20260710 \
  --users-per-region 100 \
  --preview-cleanup \
  --firebase-cli-auth
```

After the user confirms the exact new run ID, the Jurong East seed/refresh and
verification commands must include:

```sh
--project runiac-fypp --period 2026-07 --run-id <new-run-id> \
--region-id jurong-east --users-per-region 100 \
--confirm-project runiac-fypp --confirm-period 2026-07 \
--confirm-region jurong-east --confirm-users 100 --firebase-cli-auth
```

After that replacement run is `verified`, a fresh old-run preview supplies
`<current-fingerprint>`. The old all-region run cleanup command is:

```sh
npm run leaderboard:seed -- \
  --project runiac-fypp \
  --period 2026-07 \
  --run-id leaderboard-qa-20260710 \
  --users-per-region 100 \
  --confirm-project runiac-fypp \
  --confirm-period 2026-07 \
  --confirm-region all \
  --confirm-users 100 \
  --confirm-cleanup leaderboard-qa-20260710 \
  --confirm-inventory <current-fingerprint> \
  --replacement-run-id <new-run-id> \
  --firebase-cli-auth \
  --cleanup
```

Placeholders are not valid confirmations. Sol must substitute the exact values
from the immediately preceding production read-back and obtain the applicable
user confirmation before execution.

## Done When

- [x] Emulator-first tests and scoped cleanup/verification evidence pass.
- [x] Production read-only inventory is complete and reviewed for routing; rerun it immediately before mutation because the original raw log/timestamp was not retained.
- [ ] User has confirmed the exact new Jurong East-only seed run.
- [ ] The new Jurong East cohort passes production read-back before cleanup begins.
- [ ] User has confirmed the exact scoped cleanup candidates.
- [ ] All old marker-owned Leaderboard mock runs are removed without touching real-user/Auth/GPS/route data.
- [ ] `runiac-fypp` has exactly 100 new marker-owned Jurong East synthetic profiles for `2026-07`: 99 Basic ranked and one Premium ineligible.
- [ ] Production read-back confirms expected snapshots, ranks, current views, bounds, ordering, and safety fields.
- [x] Matching new-run/old-run cleanup command shape is documented but not executed; exact placeholders remain confirmation-gated.
- [x] Pre-production implementation A13_SECURITY_RULES, A6_REVIEW, A12_QA_TEST, and A8_OUTPUT_CHECKER pass; rerun closure checks after production mutation.
- [ ] Work stops Ready for commit; no commit, push, or PR is created without separate authorization.
