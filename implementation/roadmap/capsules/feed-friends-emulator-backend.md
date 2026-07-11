# feed-friends-emulator-backend

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly approved emulator-only Backend Guarded Lane implementation follow-up to PDD commit `c8bdc039b238fec25dcbeed697d156da3ef776d3`.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Backend Guarded Lane under ADR-003 and Emulator First under ADR-002.
- Status: `Ready for user screen QA` and `Ready for manual commit`. Automated package-B proof and binding same-oracle governance review are APPROVE with high confidence; real-screen QA remains user-owned and unexecuted.
- Required terminal state: `Ready for user screen QA` and `Ready for manual commit`.
- Commit boundary: package A is committed at `c8bdc039`; package B must remain unstaged and uncommitted until the user chooses to run the explicit manual commands.
- Real-screen boundary: user-owned. Agents may run automated Flutter/widget/emulator/CLI readiness checks, but must not perform or claim real-screen interaction or visual acceptance.

## Goal

Replace the demo/session Feed with an emulator-backed own/current-friends Feed that publishes an explicitly confirmed validated activity using the exact privacy-masked Running History PNG bytes, supports deterministic pagination, likes, flat comments, reporting, deletion, lifecycle cleanup, and visibly read-only cached-offline behavior across Auth, Firestore, Functions, Storage, and Flutter.

## Required Agent / Review Chain

`A0_ORCH -> A9_TRACE -> A5_WIRE -> A11_FIREBASE_IMPL -> A10_FLUTTER_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

Sol owns routing, dependency release, shared-file integration, full-diff approval, evidence, and final readiness. Bounded Terra workers own only the exact non-overlapping files assigned to them. No worker may stage, commit, deploy, broaden scope, overwrite concurrent user work, or self-approve.

## Emulator Contract

- Project: `demo-runiac-feed` only.
- Required explicit emulator hosts: Auth `127.0.0.1:9099`, Firestore `127.0.0.1:8080`, Functions `127.0.0.1:5001`, Storage `127.0.0.1:9199`.
- Every fixture/test mutation must fail closed before mutation unless the project and all four hosts match.
- No default project from `.firebaserc`; no production project, provider, host, data, deploy, init, setup, secret, service account, or real identifier.

## Allowed Scope

Only these package-B paths may change:

### Routing

- `implementation/roadmap/capsules/feed-friends-emulator-backend.md`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`

### Firebase / Rules

- `firebase.json`
- `storage.rules`
- `firestore.rules`
- `firestore.indexes.json`
- `tests/firebase-rules/*feed*.mjs`
- `tests/firebase-rules/package.json`
- `tests/firebase-rules/package-lock.json`

### Functions

- `functions/src/feed/**`
- `functions/test/feed*.ts`
- `functions/src/index.ts`
- `functions/package.json`
- `functions/package-lock.json`

### Flutter

- `implementation/mobile/runiac_app/lib/features/feed/**`
- `implementation/mobile/runiac_app/lib/features/run/presentation/view_summary_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/share_route_to_feed_sheet.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/share_route_feed_preview.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_preview.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_snapshot_thumbnail_cache.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_thumbnail_viewport.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_mapbox_snapshot_provider.dart`
- `implementation/mobile/runiac_app/lib/core/firebase/**`
- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/pubspec.yaml`
- `implementation/mobile/runiac_app/pubspec.lock`
- `implementation/mobile/runiac_app/test/feed_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/feed_interactions_test.dart`
- `implementation/mobile/runiac_app/test/feed_display_models_test.dart`
- `implementation/mobile/runiac_app/test/feed_overflow_menu_test.dart`
- `implementation/mobile/runiac_app/test/activity_route_snapshot_thumbnail_cache_test.dart`
- `implementation/mobile/runiac_app/test/feed_firebase_repository_test.dart`
- `implementation/mobile/runiac_app/test/feed_comments_bottom_sheet_test.dart`
- `implementation/mobile/runiac_app/test/feed_publish_flow_test.dart`
- `implementation/mobile/runiac_app/test/feed_thumbnail_capture_test.dart`
- `implementation/mobile/runiac_app/test/feed_offline_state_test.dart`

### Todo 17 cross-suite/support/governance closure paths (no product scope)

- `tools/governance-ci/check-pre-scaffold-scope.sh`
- `tools/governance-ci/check-diff-hygiene.sh`
- `tests/governance/backend_functions_scope_test.sh`
- `implementation/mobile/runiac_app/test/feed_offline_state_test_support.dart`
- `implementation/mobile/runiac_app/test/backend_owned_contract_test.dart`
- `implementation/mobile/runiac_app/test/run_flow_static_ui_test.dart`

Capsule-scoped text/JSON evidence may be written under `.omo/evidence/feed-friends-emulator-backend/` and `.omo/start-work/`; evidence is excluded from manual package B unless the user separately requests it.

## Forbidden Scope

- No edit, format, restore, stage, or commit of `implementation/roadmap/capsules/adaptive-character-guidance.md`, the committed PDD package, `PRD.md`, `docs/submissions/**`, legacy root `diagrams/`, `.firebaserc`, production Firebase config, native production config, secrets, tokens, service accounts, environment files, generated/build output, or deployment state.
- No edit, format, restore, stage, commit, or content inspection beyond attribution of concurrent user-owned `implementation/mobile/runiac_app/DESIGN.md`, Leaderboard, You, unrelated tests, or `.debug-journal.md` changes. If an allowed seam becomes concurrently dirty, stop that lane and route the smallest clean non-overlapping seam.
- No `firebase init`, `flutterfire configure`, deploy, production project/host, real provider call, real user data, or production App Check claim.
- No raw GPS samples, route arrays, coordinates, addresses, private route screenshots/images, tokens, secrets, PII, or bitmap bytes in Firestore, logs, screenshots, or evidence.
- No friend-management UI, notifications, public/global/nearby/algorithmic Feed, fan-out inbox, general media posts, replies, comment reactions/likes, translation, badges, share action, moderation dashboard, report thresholds/penalties, automatic posting, popularity ranking, automatic scroll jumps, optimistic offline queues, durable sensitive thumbnail cache, or activity-delete UI.
- No direct client ownership of friend/block/hidden/count/status documents or XP, streak, level, rank, leaderboard score, weekly/monthly XP, subscription privilege, validated contribution, or expert-plan publication state.

## Required Product Contract

- Trusted reciprocal friend documents and directional blocks; either block direction revokes access and clients cannot forge relationships.
- `completeRun` never posts. `publishActivityToFeed` requires explicit confirmation, auth, an owned validated activity, and the safe owned staging PNG.
- Deterministic `postId = activityId`; one immutable active post and one final generation/hash-bound thumbnail per activity.
- Exact post/like/comment/hidden/report schemas from the PDD and plan; no route/private-profile/competitive/progression/entitlement/expert fields.
- `readFeedThumbnail` returns bounded PNG bytes, never a URL, after active/hidden/friend/both-block/path/generation/hash checks. Friends never directly read final Storage.
- One author query per owner/current friend, independent buffers/cursors, deterministic `(createdAt, postId)` newest-first merge, unique pages of 20, pull refresh, and no popularity or automatic reordering.
- User-owned likes and flat comments; trusted retry-safe recomputed counts; comments are trimmed 1-500 characters, newest-first 20-item cursor pages, author-editable/deletable, and have no replies.
- Reporter-only hide/no penalty; owner post deletion preserves activity; trusted activity deletion cascades dependents and exact thumbnail generation idempotently.
- Cached offline Feed is visibly read-only and every mutation remains disabled until server-backed state returns.
- The comment icon opens a draggable keyboard-safe Bottom Sheet with a scroll-controller-bound flat list and persistent composer above keyboard insets.
- Flutter remains non-competitive and never writes backend-owned progression, ranking, entitlement, or expert-publication state.

## Required Tests

- Functions: `npm run build`, `npm run test:feed`, full `npm test`.
- Rules: focused `npm run test:feed`, full `npm test` under explicit `demo-runiac-feed` Auth/Firestore/Functions/Storage emulators.
- Flutter: `flutter analyze --no-pub`, the exact ten focused Feed/thumbnail tests from the plan, and full `flutter test`.
- Every implementation todo records a genuine focused RED failure, the minimal GREEN result, adversarial probes, and cleanup receipt.

## Required Validation

- Guarded full emulator narrative proves own/friend/non-friend/block/revoke/publish/thumbnail/like/comment/report/delete/cascade behavior and ends with zero dependent artifacts.
- `git diff --check`, strict package-B allowlist audit, privacy/sensitive-term grep, adaptive/PDD/production-config no-touch checks, no-excuse/LOC review, and Governance CI.
- Independent F1 plan compliance, F2 code/privacy/security, F3 automated readiness, and F4 scope/output audits; each must state unconditional `APPROVE` with zero open findings.
- Significant-work five-lane review, visual code/render-readiness dual review, and a debugging-oriented audit with at least three runtime hypotheses and artifact-backed outcomes.

## Required Evidence

- Todo 5-17 artifacts named in `.omo/plans/feed-friends-emulator-backend.md`.
- RED/GREEN evidence for every production behavior.
- Emulator guard, no-production, full-suite, privacy/scope, traceability, reviewer, visual-readiness, runtime-hypothesis, cleanup, and manual-command artifacts.
- Evidence must be non-empty and redacted; no route image, coordinate, bitmap, token, secret, production identifier, raw auth header, cookie, private log, or PII.

## Rollback / Stop Conditions

- Stop and reopen the owning lane if any package-B forbidden path changes, an allowed seam is concurrently modified by another owner, adaptive/PDD/production-config state changes, a reviewer has an open/conditional finding, any suite is red, emulator guards do not fail before mutation, sensitive data reaches evidence/logs, or trusted state moves client-side.
- Stop rather than expanding scope when a correction requires a path outside this allowlist.
- Never restore concurrent user-owned work to satisfy a fingerprint; record point-in-time status/hashes and prove package-B non-interference.
- Do not stage, commit, deploy, or claim real-screen QA.

## Exit Criteria

- [ ] Todos 6-16 are complete with Sol-approved full diffs, focused reruns, RED/GREEN evidence, adversarial probes, and cleanup receipts.
- [ ] Functions focused/full and Rules focused/full suites pass under the explicit four-emulator demo project.
- [x] Flutter analyzer, exact ten focused tests, and package-B isolated full suite pass (shared tree retains five proven unrelated dirty failures).
- [ ] Full emulator narrative and production-guard failure pass with redacted evidence and zero live residue.
- [ ] Exact privacy-masked Running History bytes are reused for staging/publish and satisfy dimension/mask/metadata/size constraints.
- [ ] F1-F4 and the significant-work, visual-readiness, and runtime-hypothesis gates approve with zero open findings; binding governance review is APPROVE with high confidence.
- [ ] Full diff contains only package-B paths plus untouched concurrent user-owned paths; adaptive/PDD/production config remain unchanged.
- [x] User screen-QA checklist is complete and explicitly user-owned; no real-screen result is claimed.
- [ ] Manual commands stage only actual package-B paths and never use `git add .`.
- [x] Nothing is staged or committed; no emulator/process/temp residue remains.
- [x] `CURRENT.md`, latest snapshot, and this capsule state exactly `Ready for user screen QA` and `Ready for manual commit`.
