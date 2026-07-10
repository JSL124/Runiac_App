# leaderboard-production-completion

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as a bounded F8 implementation exception. This capsule does not select or authorize unrelated Phase 02 work.

## Mode / Type

Mode: IMPLEMENTATION_MODE, explicitly approved by the user's 2026-07-10 request to execute the Leaderboard plan, implement the backend, and verify it with approximately 100 distinct mock users per supported region in the configured Firestore project.

Type: monthly territorial Leaderboard backend, Firestore security, Flutter live-read integration, reversible mock-data seeding, and QA.

## Status

Status: Complete locally and deployed to `runiac-fypp` on 2026-07-10 Asia/Singapore. Ready for commit; no commit was created.

## Goal

Complete the monthly-only territorial Leaderboard for the existing 37 supported Singapore planning areas, preserve the current Iron through Challenger UI taxonomy, use the user's selected profile planning area as the backend-validated region source, and prove the result with emulator tests plus a reversible Firestore seed run.

## Agent / Review Chain

`A0_ORCH -> A9_TRACE -> A11_FIREBASE_IMPL + A10_FLUTTER_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

When the active model is GPT-5.6, this chain is executed with the native Codex harness only. No LazyCodex, Ouroboros, or external agent harness is authorized.

## Approved Product Decisions

- Leaderboard period is monthly only. Weekly Leaderboard is excluded.
- Valid weekly workout and training-plan concepts outside Leaderboard remain unchanged.
- League names/ranges remain Iron, Bronze, Silver, Gold, Platinum, Emerald, Diamond, Master, Grandmaster, and Challenger in 10-level bands.
- The 37 current profile planning-area choices are the supported Leaderboard allowlist.
- The raw GeoJSON remains a 55-feature superset; its other 18 areas stay unsupported.
- The backend derives region only from `userProfiles/{uid}.locationLabel`, never GPS or route data.
- A supported region freezes on the first eligible contribution in a monthly period; later profile edits apply next month.
- The latest backend-owned division applies to the whole monthly score.
- Premium users receive no XP, rank, score, or Leaderboard advantage.

## Approved Mock-Data Verification

- Target project is the repository-configured Firebase project `runiac-fypp`, after all emulator and local gates pass.
- Generate approximately 100 distinct synthetic profiles per supported region: 37 regions and 3,700 total synthetic profiles.
- Synthetic records must use a unique seed-run ID and UID prefix, contain no real user data, GPS, routes, emails, secrets, or Auth accounts, and remain identifiable for cleanup.
- Seeding must have `--dry-run`, explicit project/period/run-ID arguments, a manifest document, post-write count verification, and a matching cleanup command.
- Seed inputs, generated projections, and cleanup must be verified. Cleanup must delete only documents owned by that seed-run ID/prefix and rebuild affected monthly snapshots.
- Production mutation occurs only after local/emulator tests pass and the command prints the exact project, period, collections, and document counts.

## Allowed Files

- `implementation/shared/leaderboard/**`
- `tools/leaderboard/**`
- `functions/src/leaderboard/**`
- `functions/src/progression/progressionCalculator.ts`
- `functions/src/run/completeRun.ts`
- `functions/src/index.ts` only for the scheduled export
- `functions/test/monthlyLeaderboard.test.ts`
- `functions/test/progressionCalculator.test.ts`
- `functions/test/completeRun.test.ts`
- `functions/package.json` and `functions/tsconfig.json` only if seed/test script inclusion is required
- `firestore.rules`
- `firestore.indexes.json` only with concrete query evidence
- `tests/firebase-rules/firestore.rules.test.mjs`
- `implementation/mobile/runiac_app/lib/core/regions/**`
- `implementation/mobile/runiac_app/lib/features/account/domain/singapore_region_options.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/**`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart` only for repository composition
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart` only if live Leaderboard composition requires it
- `implementation/mobile/runiac_app/test/firestore_leaderboard_repository_test.dart`
- `implementation/mobile/runiac_app/test/leaderboard_static_ui_test.dart`
- This capsule, `implementation/roadmap/CURRENT.md`, and `implementation/roadmap/snapshots/latest.md`
- `.omo/evidence/leaderboard-production-completion/**`

## Forbidden Scope

- No Weekly Leaderboard implementation.
- No changes to unrelated weekly workouts, plans, schedules, Home guide agent, Run, Maps, notifications, native code, dependencies, or PDD submissions.
- No client calculation/write of XP, level, division, monthly XP, rank, score, eligibility, rollover, or aggregation.
- No GPS/geocoding-based region assignment or private location evidence.
- No production demo fallback in Flutter.
- No unbounded full-board snapshot documents.
- No `firebase init`, `flutterfire configure`, secrets, service-account files, committed tokens, or unrelated production configuration.
- No broad production collection deletion. Cleanup is seed-run/prefix scoped only.
- No commit, push, or PR without separate user authorization.

## Required Validation

- Planning-area contract proves 55 GeoJSON features, 37 supported, 18 unsupported, with exact names/codes/region codes.
- League contract proves all ten stable tier keys and current UI names/ranges.
- Functions RED/GREEN tests cover contribution idempotency, region freeze, division movement, Premium re-check, region/division partitions, top-10 and nearby-5 bounds, lease overlap, rollover, cleanup, and safe public fields.
- Firestore rules tests cover signed-in public reads, owner-only private reads, and denial of every client Leaderboard write.
- Flutter tests cover live home/region reads, no demo fallback, loading/empty/error/stale states, actual league metadata, region-required guidance, and no-rank share safety.
- Seed generator dry-run proves 3,700 unique profiles distributed across all 37 supported areas with deterministic unique mock fields.
- Emulator seed/aggregate/verify/cleanup passes before any configured-project mutation.
- Full Functions, rules, Flutter, governance, and diff checks pass.
- Android Leaderboard surface is exercised when an emulator is available.
- Configured-project seed and aggregation counts are read back and recorded without real user data.

## Done When

- [x] Monthly backend aggregation is correct, bounded, secure, and scheduled.
- [x] Flutter consumes live monthly Leaderboard documents without production demo fallback.
- [x] All 37 supported areas and current league names are enforced by shared contracts.
- [x] Reversible 3,700-profile mock seed tooling is implemented and emulator-verified.
- [x] The authorized configured-project seed run is written, aggregated, and read-back verified.
- [x] A cleanup command and exact run ID are reported to the user.
- [x] A6, A13, A12, and A8 gates approve.
- [x] Roadmap state is reconciled and the task stops Ready for commit unless commit permission is separately granted.

## Completion Evidence

- Shared contracts: 55 GeoJSON features, 37 supported planning areas, 18 unsupported areas, and the ten current UI leagues passed generator drift and contract tests.
- Functions: 86 emulator tests passed. Firestore Rules: 47 emulator tests passed. Flutter: analysis passed and the full 1,172-test suite passed.
- Production deployment completed for `completeRun`, `refreshLeaderboardSnapshots` (hourly, `asia-southeast1`), and Firestore Rules. Both functions are `ACTIVE`.
- Production seed run `leaderboard-qa-20260710` for `2026-07` wrote 3,700 synthetic profiles and contributions (11,100 source documents), then read-back verification confirmed 3,663 Basic ranks, 3,700 current views, 370 snapshots, and all 37 regions. The 37 Premium synthetic profiles are intentionally ineligible for rank.
- Android emulator was unavailable during closure; no Android manual surface claim is made.
