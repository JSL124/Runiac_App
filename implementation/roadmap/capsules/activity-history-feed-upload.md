# activity-history-feed-upload

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly routed IMPLEMENTATION_MODE follow-up for Activity History to Feed publishing.

## Goal

Allow backend-validated Activity History run records to open a Feed-specific Share Your Achievement-style bottom sheet and publish through the existing callable-backed Feed publishing flow, while fixing Activity History route thumbnails so they render route polylines without start/end marker dots.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Flutter client integration with existing Feed backend contract; no production deploy or backend ownership migration.
- Status: `In progress`.
- Required terminal state: `Ready for user screen QA` and `Ready for manual commit`.
- Real-screen boundary: user-owned. Agents may run automated Flutter/widget/readiness checks, but must not claim real-screen visual acceptance.
- Commit boundary: stop at Ready for manual commit unless the user explicitly grants commit authority for this execution turn.

## Required Agent / Review Chain

`A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

Use A13_SECURITY_RULES if any Firestore Rules, Storage Rules, Functions, or trusted publish contract changes become necessary. The intended implementation must not require those backend changes.

## Allowed Scope

- Activity History read-model provenance and publish eligibility for owner-owned backend-validated activity-backed rows.
- Activity History to View Summary navigation source propagation.
- Existing View Summary Share Route / Feed publish confirmation flow.
- Feed publish client artifact resolution and staging through the existing `FeedPublishService`.
- Feed upload bottom sheet visual refactor to use Share Your Achievement-style card language without external share targets.
- Activity History route thumbnail rendering and snapshot thumbnail request cleanup to remove start/end marker dots while preserving route polyline layout.
- Focused Flutter tests, existing Feed publish tests, and evidence under `.omo/evidence/activity-history-feed-upload/`.
- Roadmap routing files for this capsule only.

## Forbidden Scope

- No comments, replies, reactions, translations, moderation dashboard, pagination expansion, public/global/nearby feed, or external sharing targets.
- No direct client write of Feed post documents; publishing must remain callable-backed through `FeedPublishService`.
- No client ownership of XP, streak, level, rank, leaderboard score, weekly/monthly XP, subscription privilege state, validated contribution state, or expert-plan publication state.
- No raw GPS backfill, durable sensitive route image retention, route-name/location labels in generated Feed thumbnails, coordinates in logs/evidence, or invented route geometry for legacy records.
- No Firebase init, FlutterFire configure, production Firebase config, production deploy, production project access, secrets, tokens, service accounts, or native Android/iOS configuration changes.
- No edit, format, restore, stage, or commit of `implementation/roadmap/capsules/adaptive-character-guidance.md`, frozen PDD submissions, `PRD.md`, unrelated Leaderboard/design work, or unrelated debug artifacts.
- No automatic commit unless separately authorized.

## Exact Target Files

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/activity-history-feed-upload.md`
- `implementation/mobile/runiac_app/lib/features/you/data/firestore_activity_history_repository.dart`
- `implementation/mobile/runiac_app/lib/features/you/domain/models/activity_history_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/activity_history_display_controller.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_preview.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_snapshot_thumbnail_cache.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_thumbnail_viewport.dart`
- `implementation/mobile/runiac_app/lib/features/run/domain/models/run_activity_display_model.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/view_summary_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/share_route_to_feed_sheet.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/share_achievement_sheet.dart`
- `implementation/mobile/runiac_app/lib/core/widgets/runiac_share_bottom_sheet.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/feed_publish/**`
- `implementation/mobile/runiac_app/test/firestore_activity_history_repository_test.dart`
- `implementation/mobile/runiac_app/test/run_flow_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/activity_route_snapshot_thumbnail_cache_test.dart`
- `implementation/mobile/runiac_app/test/feed_thumbnail_capture_test.dart`
- `implementation/mobile/runiac_app/test/feed_publish_flow_test.dart`

## Required Tests

- Focused RED/GREEN tests for Activity History publish eligibility and canonical backend `activityId` propagation.
- Focused RED/GREEN tests proving route thumbnails render polyline-only with no start/end marker overlays and keep projected points inside preview bounds.
- Focused RED/GREEN tests for route-thumbnail artifact precedence and metric-only privacy-safe legacy fallback.
- Focused widget/service tests for Feed upload sheet style, disabled state, cancel, success, failure, duplicate publish, and current-session regression.
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub`
- `cd implementation/mobile/runiac_app && flutter test`
- `git diff --check`
- `./tools/governance-ci/run-all-checks.sh`
- `cd functions && npm run test:feed` only if Functions or Feed PNG validator compatibility is exercised by generated artifacts.

## Required Validation

- A9_TRACE confirms the feature is limited to Activity History/Feed publishing and does not move backend-owned state into Flutter.
- A5_WIRE confirms the bottom sheet follows Share Your Achievement visual language while staying Feed-specific and beginner-friendly.
- A6_REVIEW confirms privacy boundaries, canonical backend activity identity, idempotent publish contract, and no raw route leakage.
- A12_QA_TEST records exact focused and full command results.
- A8_OUTPUT_CHECKER confirms target-file-only diff, no unrelated staging, cleanup of temporary debug artifacts, and Ready for manual commit state.

## Required Evidence

- `.omo/evidence/activity-history-feed-upload/C001-happy.md`
- `.omo/evidence/activity-history-feed-upload/C002-edge.md`
- `.omo/evidence/activity-history-feed-upload/C003-regression.md`
- Focused RED/GREEN command outputs for each implementation seam.
- Final diff/scope review and cleanup receipt.
- User-owned real-screen QA checklist handoff without claiming actual screen acceptance.

## Rollback / Stop Conditions

- Stop if implementation requires Functions, Firestore Rules, Storage Rules, native configuration, production Firebase setup, or route data persistence beyond the allowed scope.
- Stop if Activity History publishability cannot be proven from owner-owned backend-validated activity records.
- Stop if route thumbnails require raw GPS backfill or route/location labels in generated Feed thumbnails.
- Stop if unrelated dirty files appear in a target seam and cannot be separated safely.
- Stop if any final reviewer has an unresolved or conditional finding.

## Exit Criteria

- [ ] Backend-validated Activity History rows can open the Feed upload sheet and call `FeedPublishService` only after explicit confirmation.
- [ ] Pending, local, unvalidated, orphaned, wrong-owner, and insufficient-data records cannot publish.
- [ ] Current-session summary Feed publishing still works.
- [ ] Activity History and Feed route thumbnails render polylines without start/end marker dots.
- [ ] Legacy no-thumbnail records use privacy-safe metric-only generated thumbnails.
- [ ] Share Achievement-style Feed upload sheet hides external share targets and uses real run data.
- [ ] Required focused and full validations are recorded.
- [ ] Snapshot updated if state changed.
- [ ] CURRENT.md updated for active capsule routing.
- [ ] Temporary debug artifacts removed.
- [ ] Ready for user screen QA and Ready for manual commit.
