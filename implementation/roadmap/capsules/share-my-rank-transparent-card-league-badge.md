# share-my-rank-transparent-card-league-badge

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's explicit "route this as a capsule" request for the Share-my-rank cards.

Type: static Flutter frontend-only, display-only enhancement of the existing Leaderboard Share-my-rank sheet.

## Status

Status: Routed, not started.

Routed on: 2026-07-18 Asia/Singapore.

Depends on: the already-committed `share_rank_floating_panel.dart` sheet and the existing `RuniacAssets.leaderboardLeague*` badge assets and `leaderboard_league_catalog.dart` tier catalog.

Plan of record: `/Users/leejinseo/.claude/plans/share-my-rank-transparent-card-league-badge.md`.

## Goal

Extend the existing Share-my-rank bottom sheet so the user can share their rank as an overlay on their own photo, and so the league badge is always visible:

- Add a second preview card with the **same components** as the original card (region, division, rank number, league badge) but a **transparent background**, designed to sit over the user's own photo/story.
- Render the **league (division) badge** on **both** cards (the current solid card does not show it).
- Turn the preview into a two-page carousel with a live 2-dot page indicator (today the indicator is a hardcoded 3 dots over a single card).

All values remain trusted read-model strings; the client renders only. No new share-target behavior (Instagram/Save/Copy Link/More stay stubs) and no image export in this capsule.

## Allowed Scope

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/share_rank_floating_panel.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart` (Share panel call site + shared league-asset resolution only)
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/models/leaderboard_display_models.dart` (add the `divisionAssetPath` field only)
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_read_model_display_adapter.dart` (populate `divisionAssetPath` only)
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/data/leaderboard_demo_snapshots.dart` (demo parity for the new field)
- `implementation/mobile/runiac_app/lib/features/leaderboard/data/static_leaderboard_repository.dart` (static parity for the new field)
- `implementation/mobile/runiac_app/lib/features/leaderboard/domain/models/leaderboard_league_catalog.dart` or a small new `league_assets.dart` — only if the shared tier-to-asset resolver is promoted there; no generated-file regeneration or league-band edits.
- `implementation/mobile/runiac_app/test/leaderboard_static_ui_test.dart`
- `implementation/mobile/runiac_app/DESIGN.md` (only if the share-card design is documented there)
- This capsule and append-only routing in `implementation/roadmap/CURRENT.md`.
- `tools/governance-ci/check-diff-hygiene.sh` only if the new capsule path must be added to its routed-capsule allowlist.

## Behavior Contract

- Add a required `leagueBadgeAssetPath` parameter to `ShareRankFloatingPanel`; source it at `leaderboard_tab.dart:_openShareRankPanel` from a new `divisionAssetPath` on `LeaderboardDetailDisplaySnapshot`, populated in the adapter from the authoritative tier key via the same `tier_NN → RuniacAssets.leaderboardLeague*` mapping used by `_leagueAssetPath` (promote it to a shared resolver; do not string-parse the division label unless the tier key is genuinely unavailable, in which case fall back to matching `leaderboardLeagueDefinitions` with an Iron default).
- Extract the region/division/rank/badge composition into one shared inner body widget so both cards render identical content and only the backdrop differs.
- Solid card keeps its PNG background and gains the league badge, positioned so it does not collide with the baked-in artwork (verify visually).
- Transparent card renders the same body with **no background fill** — alpha must remain fully transparent so a user's photo shows through when it is eventually exported; legibility relies on the existing text shadows (an optional soft per-element shadow/scrim is acceptable, an opaque fill is not).
- Both cards keep the existing `1122/1402` aspect ratio and the existing width/height capping so neither overflows on short screens.
- The page indicator becomes exactly two dots and its active dot follows the live carousel page.
- Preserve the existing `leaderboard_copy_rank_action` copy-to-clipboard behavior exactly; leave Instagram/Save/Copy Link/More as their current "coming soon" stubs.
- Provide test keys: `leaderboard_share_rank_card_solid`, `leaderboard_share_rank_card_transparent`, and `leaderboard_share_rank_league_badge` (on the badge in each card); keep `leaderboard_share_rank_page_indicator`.

## Forbidden Scope

- No Firebase, Auth, Firestore, Cloud Functions, rules, indexes, or repository/backend I/O.
- No client-side calculation or mutation of XP, level, rank, streak, league/division, leaderboard score, weekly XP, monthly XP, subscription privilege, or expert-plan publication state.
- No image rasterization, native share sheet, gallery save, deep link, or activation of the Instagram/Save/Copy Link/More stubs (separate future increment).
- No third card, no shell/navigation change, no new dependencies, no native/Android/iOS changes, no generated-file regeneration or league-band edits.
- No deployment, and no edit to or staging within the isolated `adaptive-character-guidance` worktree. Existing unrelated Leaderboard/functions working-tree changes stay unstaged and untouched.
- No commit or push without separate explicit authorization.

## Validation Plan

- Start the focused share-rank widget assertions in red (both card keys, badge on each card, 2-dot live indicator on swipe), then verify green after implementation.
- Run `dart format` on changed Dart sources, `flutter analyze --no-pub`, `flutter test test/leaderboard_static_ui_test.dart`, `flutter test`, and `git diff --check`.
- Real Flutter surface QA on the iPhone 17 simulator (never the physical phone; `idb` for tap/screenshot): open Leaderboard → Share your rank → confirm the league badge on the solid card, swipe to the transparent card, confirm identical components with the background gone (scaffold/checkerboard visible through it), at a couple of widths for long region/name truncation.
- Report any pre-existing baseline failures separately from this capsule's changes.

## Done When

- [ ] The Share-my-rank sheet shows a two-page carousel with a live 2-dot indicator.
- [ ] The solid card renders the league badge without colliding with its background art.
- [ ] The transparent card renders the same components with a fully transparent background.
- [ ] The league badge asset is sourced from the trusted read model's division/tier, not computed on the client.
- [ ] Copy-to-clipboard behavior and the remaining stub targets are unchanged.
- [ ] Focused and relevant regression validation pass, with any pre-existing failures reported separately.
- [ ] No backend, persistence, progression, entitlement, navigation, export, or unrelated UI behavior is introduced.
