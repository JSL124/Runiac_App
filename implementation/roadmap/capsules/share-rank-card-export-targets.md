# share-rank-card-export-targets

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's explicit "make the share targets real (all four)" request on 2026-07-18.

Type: mostly Flutter client (rasterize + share/save/deep-link) plus a small ADR-003 Backend Guarded Lane slice (Firebase Storage rules) for Copy Link.

## Status

Status: In progress.

Routed on: 2026-07-18 Asia/Singapore.

Depends on: `share-my-rank-transparent-card-league-badge` (the two share cards and carousel this exports from).

Plan of record: `/Users/leejinseo/.claude/plans/share-rank-card-export-targets.md` (to be written) and this capsule.

## Goal

Turn the four Share-my-rank targets from "coming soon" stubs into real actions that share the currently-visible card (solid or transparent):

1. **Save** — rasterize the current card to a PNG and save it to the device gallery.
2. **More** — rasterize and hand the PNG to the OS share sheet.
3. **Instagram** — deep-link the PNG into Instagram Stories.
4. **Copy Link** — upload the PNG to Firebase Storage under an owner-scoped path and copy a shareable download URL.

The transparent card must export with true alpha: the checkerboard preview backdrop is hidden during capture. All exported content is trusted display values (rank/region/league) — no backend-owned value is computed or written on the client; Copy Link only writes a rendered image the user chose to share.

## Phasing

- **P1 (client-only):** RepaintBoundary rasterization (built-in) + Save (`gal`) + More (`share_plus`). iOS `NSPhotoLibraryAddUsageDescription`.
- **P2 (client-only):** Instagram Stories deep link (`url_launcher` + pasteboard/intent). Requires a Facebook App ID (user-supplied value) and iOS `LSApplicationQueriesSchemes` + Android `<queries>`.
- **P3 (Backend Guarded Lane, emulator-first):** Copy Link — client upload to `share-cards/{uid}/…png` + `storage.rules` addition (owner create, controlled read) + copy the download URL. No production deploy without separate explicit authorization.

## Allowed Scope

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/share_rank_floating_panel.dart` (capture wiring, export-mode flag)
- A new `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/share_rank_export_service.dart` (rasterize/save/share/link)
- `implementation/mobile/runiac_app/pubspec.yaml` (add `share_plus`, `gal`, `url_launcher` only)
- `implementation/mobile/runiac_app/ios/Runner/Info.plist` (photo add permission; Instagram query scheme + FB App ID)
- `implementation/mobile/runiac_app/android/app/src/main/AndroidManifest.xml` (Instagram `<queries>`)
- `storage.rules` (P3 only, owner-scoped share-card path)
- Focused tests under `implementation/mobile/runiac_app/test/` and `tests/firebase-rules/` (P3)
- This capsule and append-only routing in `implementation/roadmap/CURRENT.md`.

## Forbidden Scope

- No client-side calculation or mutation of XP, level, rank, streak, league, or leaderboard values (export renders trusted labels only).
- No production `runiac-fypp` deploy (Functions, rules, Storage) without separate explicit authorization; P3 is emulator-first.
- No new Cloud Functions, Firestore schema, or dependencies beyond the three named packages.
- No committing a real Facebook App ID / secrets into source; the Instagram App ID is supplied at build/runtime.
- No edit or staging inside the isolated `adaptive-character-guidance` worktree.
- No commit or push without separate explicit authorization.

## Validation Plan

- `dart format`, `flutter analyze --no-pub`, focused widget tests for the export service (mock the platform channels for `gal`/`share_plus`/`url_launcher`), `flutter test`, `git diff --check`.
- P3: `tests/firebase-rules` suite for the new Storage-rules path, emulator-first upload/read check.
- Real-device note: Save/More/Instagram need physical-device or configured-simulator verification; the iPhone 17 simulator cannot fully exercise Instagram or the OS share sheet.

## Done When

- [ ] Save writes the current card PNG to the gallery (with permission handling).
- [ ] More opens the OS share sheet with the PNG.
- [ ] Instagram deep-links the PNG into Stories (plumbing complete; App ID supplied externally).
- [ ] Copy Link uploads to owner-scoped Storage and copies a working URL (emulator-first).
- [ ] Transparent card exports with true alpha (checkerboard hidden on capture).
- [ ] Focused + relevant regression validation pass; pre-existing failures reported separately.
- [ ] No backend-owned value computation/mutation and no unauthorized deploy.
