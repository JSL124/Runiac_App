# share-activity-card-real-data-export

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved, explicitly user-routed capsule to make the run-summary "Share Your Achievement" sheet real, mirroring the shipped Leaderboard Share-my-rank pattern.

Type: mostly Flutter client (real display values, real map/route rendering, rasterize + share/save/deep-link/upload export) plus a small ADR-003 Backend Guarded Lane slice (Firebase Storage rules) for Copy Link, reusing the already-deployed owner-scoped `share-cards/{uid}/…` path.

## Status

Status: In progress.

Routed on: 2026-07-19 Asia/Singapore.

Depends on: the shipped Leaderboard Share-my-rank cards/carousel (`share-my-rank-transparent-card-league-badge`) and export targets (`share-rank-card-export-targets`), and the existing `RouteHistoryThumbnailGenerator` feed-thumbnail pipeline for map screenshots.

Plan of record: this capsule; a detailed plan may be written separately by the orchestrator.

## Goal

Turn the run-summary "Share Your Achievement" sheet from a static mock into a real, exportable share sheet, mirroring the Leaderboard Share-my-rank pattern:

1. Rename the sheet header to "Share Your Activity".
2. Wire real `RunSummarySnapshot` display values (distance, avg pace, time, etc.) into the card body instead of placeholder text.
3. Turn the preview into a two-page carousel:
   - Page 1 (solid card): existing background art, a real map screenshot sourced from the existing `RouteHistoryThumbnailGenerator` feed-thumbnail pipeline, and the Runiac wordmark logo replacing the plain "Runiac" text.
   - Page 2 (new transparent card): wordmark, a real GPS route trace, distance hero, avg pace, and time — same transparent-over-photo pattern as the rank card, reusing `RuniacCheckerboardPainter` for the preview backdrop.
4. Wire the four real export targets, reusing the promoted `ShareCardExportService`: Instagram Stories (existing `runiac/instagram_story` channel), Save to gallery (`gal`), OS share sheet (`share_plus`), and Copy Link (owner-scoped Firebase Storage upload to `share-cards/{uid}/activity-card.png` + copy the download URL), plus Copy-Text-to-clipboard.
5. Remove the "Edit card" / "Change theme" row and the "Advanced Analysis" share button from the run-summary sheet.

All exported content is trusted display values already computed by the server (via `completeRun`) and read back by the client, or local-only privacy-masked route preview points already permitted for feed-thumbnail use — no backend-owned value is computed or written on the client; Copy Link only writes a rendered image the user chose to share.

## Allowed Scope

- `implementation/mobile/runiac_app/lib/core/share/share_card_export_service.dart` (promoted from leaderboard; reused as-is or with additive method parameters only)
- `implementation/mobile/runiac_app/lib/core/widgets/runiac_checkerboard_painter.dart` (promoted from leaderboard; reused as-is)
- The run-summary "Share Your Achievement" sheet widget(s) and their call site(s) under `implementation/mobile/runiac_app/lib/features/run/presentation/` (rename header, real data wiring, carousel, export target wiring, row/button removal)
- The existing `RouteHistoryThumbnailGenerator` call site(s) needed to source the map screenshot for the solid card (read-only reuse; no changes to its generation logic beyond call-site wiring)
- `implementation/mobile/runiac_app/test/run_flow_static_ui_test.dart` (updates for the renamed header, real data, carousel, and target wiring)
- An additive case in `tests/firebase-rules/share-card.storage.rules.test.mjs` for the `activity-card.png` filename under the existing owner-scoped `share-cards/{uid}/…` path
- This capsule and append-only routing in `implementation/roadmap/CURRENT.md`

## Forbidden Scope

- No client-side calculation or mutation of XP, level, rank, streak, leaderboard score, or any other backend-owned value (the card renders trusted `RunSummarySnapshot` values already returned by `completeRun`).
- No new dependencies beyond what is already present (`gal`, `share_plus`, `url_launcher` if already added by the rank-card export capsule).
- No native/iOS or native/Android changes (the Instagram channel, gallery, and share-sheet plumbing already exist from the rank-card export capsule).
- No `storage.rules` changes (the owner-scoped `share-cards/{uid}/…` path is already deployed; this capsule only adds a differently-named file under the same path).
- No production `runiac-fypp` deploy of any kind without separate explicit authorization.
- No committing a real Instagram/Facebook App ID or any other secret.
- No new Cloud Functions or Firestore schema changes.
- No edit or staging inside the isolated `adaptive-character-guidance` worktree.
- No commit or push without separate explicit authorization.

## Validation Plan

- `dart format` on changed Dart sources, `flutter analyze --no-pub`, `flutter test test/run_flow_static_ui_test.dart`, `flutter test test/leaderboard_static_ui_test.dart` (regression check on the promoted core files), `flutter test`, `git diff --check`.
- `tests/firebase-rules` suite for the additive `activity-card.png` Storage-rules case.
- Real Flutter surface QA on the iPhone 17 simulator (never the physical phone; `idb` for tap/screenshot) when export targets are exercised.
- Report any pre-existing baseline failures separately from this capsule's changes.

## Done When

- [ ] The sheet header reads "Share Your Activity".
- [ ] The solid and transparent cards render real `RunSummarySnapshot` values, a real map screenshot / real GPS route trace, and the Runiac wordmark logo.
- [ ] The two-page carousel and page indicator work as in the Leaderboard pattern.
- [ ] Instagram, Save, More (OS share), and Copy Link are wired to `ShareCardExportService` with a `storageFileName: 'activity-card.png'` Copy Link path; Copy-Text-to-clipboard is preserved.
- [ ] "Edit card" / "Change theme" row and "Advanced Analysis" share button are removed.
- [ ] Focused and relevant regression validation pass; pre-existing failures reported separately.
- [ ] No backend-owned value computation/mutation, no new dependency, no native change, no `storage.rules` change, and no unauthorized deploy.
