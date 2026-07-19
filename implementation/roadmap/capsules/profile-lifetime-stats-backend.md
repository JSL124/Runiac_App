# Capsule: Profile Lifetime Stats Backend (Max Streak / Total Distance)

- Type: Backend Guarded Lane full-stack capsule (ADR-002 emulator-first, ADR-003 lane rules)
- Routed: 2026-07-16 Asia/Singapore, explicitly by the user.
- Status: Implemented + emulator-verified; scoped production deploy authorized.

## Goal

Surface real, backend-owned **Max streak** (longest streak ever) and **Total
distance** (lifetime distance run) on the Profile page, replacing the earlier
fabricated demo values, without the client ever computing backend-owned values.

## Scope (implemented)

- **Server truth — `functions/src/run/completeRun.ts`**: inside the existing
  run-completion transaction, self-healing recompute of two backend-owned
  profile fields from the full validated activity history already fetched in the
  transaction (no extra reads, idempotent on replay):
  - `totalDistanceMeters` / `totalDistanceLabel` = sum of every validated run's
    `distanceMeters`.
  - `longestStreak` / `longestStreakLabel` = peak streak reconstructed from the
    validated-run history via the existing `calculateStreakStateFromRuns`
    reducer over date-ordered prefixes; never regresses below the stored value.
  - Label formatting helpers added to `functions/src/run/runCompletionArtifacts.ts`
    (`formatLongestStreakLabel`, `formatTotalDistanceLabel`).
- **Rules — `firestore.rules`**: `longestStreak`, `longestStreakLabel`,
  `totalDistanceMeters`, `totalDistanceLabel` added to `backendOwnedKeys()` so
  the client can only render, never write them (Admin SDK in the Function
  bypasses rules and remains the sole writer).
- **Client (display-only)**: `UserProgressReadModel` already exposes the two
  labels; `FirestoreUserProgressRepository` relays them; the Profile screen
  renders them and shows an em-dash when the backend has not published them yet.
  No client-side calculation of backend-owned values.

## Emulator-first evidence

- `functions/` completeRun suite: 76/76 PASS (incl. longest-streak survives a
  missed-day reset, total distance accumulates without double-counting duplicate
  sessions, and backfill from a pre-existing validated run).
- `tests/firebase-rules/` suite PASS (new deny test for the four keys).
- Flutter analyze + full suite PASS; `./tools/governance-ci/run-all-checks.sh` PASS.

## Authorized production deploy (runiac-fypp)

The user explicitly authorized a **scoped** production deploy to `runiac-fypp`
on 2026-07-16 Asia/Singapore, limited to:

```
firebase deploy --only functions:completeRun,firestore:rules
```

This redeploys `completeRun` with the recompute and publishes the Firestore
rules key protection. Firestore indexes are unchanged (the feature needs none).

## Forbidden

- Full-backend deploy; any change/deploy of agent/LLM, feed, challenge,
  notification, leaderboard, or scheduled functions under this capsule.
- Client-side mutation or calculation of any backend-owned value.
- New dependencies, secrets rotation, or unrelated scope edits.
- Modifying `docs/submissions/` or frozen submitted PDD snapshots.
