# Capsule: Character Premium-Access Gating

Status: implemented locally on 2026-07-24. Ready for commit (manual).
Routed: 2026-07-24 Asia/Singapore (explicit user request).
Lane: Config Control Plane full-stack. Adds one new admin-owned config
document and a client-side lock; no XP/level/rank/leaderboard formula, no
production deploy.

The four guide characters (`RunnerCharacter` enum:
`blue`=Bolt, `cap`=Cap, `pink`=Mila, `purple`=Ivy in
`implementation/mobile/runiac_app/lib/core/characters/runner_character.dart`)
were all freely selectable. The character is display-only cosmetic
personalization persisted **locally only**
(`local_selected_runner_character_storage.dart`) — it never writes to Firestore
and never touches XP, level, rank, streak, or leaderboard values.

This capsule gates **Cap** and **Ivy** behind Premium while keeping **Bolt**
and **Mila** open to Basic, and makes the split reconfigurable by the Platform
Administrator from the admin console.

## Design decisions

- **Client-side config gate only.** The feature is purely cosmetic with zero
  server-side state to protect — a tampered Basic client that forces Cap/Ivy
  gains only a different sprite, no XP/rank/data/competitive value. The PDD
  "premium must not rely only on hiding UI" rule targets functional/competitive
  features (like `shareRouteToFeed`, which writes a real feed post, or challenge
  lobby creation); it is satisfied here because there is no server operation to
  enforce against and the PDD explicitly permits selling
  presentation/personalization value. Adding a callable + `users/{uid}` write +
  rules for a device-local cosmetic value would be overengineering.
- **New `config/characterAccess` document**, mirroring `config/challengeAccess`:
  `{ premiumOnlyCharacters: ["cap","purple"], version: 1 }`. A present-but-empty
  list opens every character; a missing document uses the shipped defaults.
- **Grandfather existing picks.** `RuniacCharacterSelectionGate` short-circuits
  when a selection already exists, so a runner who already chose Cap/Ivy keeps
  it and never re-sees the gated picker. No migration code.

## Changes

- **Backend (`functions/src/config/configLoader.ts` + test):**
  `CharacterAccessConfig` type, `DEFAULT_CHARACTER_ACCESS_CONFIG`,
  `validateCharacterAccessConfig` (known ids `blue|cap|pink|purple`, no
  unknowns, no duplicates), and `loadCharacterAccessConfig`, mirroring the
  `challengeAccess` loader contract. No callable consumes it — it exists for the
  admin config plane and the cross-repo drift check.
- **Rules (`firestore.rules`):** `characterAccess` added to the signed-in
  client-readable config allowlist; writes stay Admin-SDK only. Rules test
  (`tests/firebase-rules/firestore.config.rules.test.mjs`) extended.
- **Admin console (`website/`, separate repo, not gated by this repo's CI):**
  `config-validation` mirror, live-data loader, data getter, `saveCharacterAccessConfig`
  action, a "Character access" editor section in `PolicySettings`, and a config
  summary entry. Vitest for the validator and the editor.
- **Flutter client:** `CharacterAccessReadModel`, `CharacterAccessRepository`
  (+ Firestore + static impls), `CurrentSessionCharacterAccess` store/scope
  wired through `app.dart` and `runiac_firebase_bootstrap.dart`. The picker
  (`character_selection_screen.dart`) locks premium-only characters for Basic
  runners with a lock badge + "Premium" label and routes their tap to the
  paywall (`interceptWithPaywallIfBasic`); Premium runners select normally.

## Validation

- Functions: `npm run build` clean, `configLoader.test.ts` 63/63.
- Config contract drift: PASS (compares `DEFAULT_CHARACTER_ACCESS_CONFIG`,
  `validateCharacterAccessConfig`).
- Flutter: `flutter analyze` clean; full `flutter test --no-pub` 1950/1950;
  new `character_selection` premium-gating + `character_access_read_model` tests.
- Admin console: `tsc --noEmit` clean, eslint clean, new vitest 7/7.

## Forbidden

Any production `runiac-fypp` deploy without separate authorization; any
Cloud Function callable, `users/{uid}` write, or Firestore-persisted character
(the feature stays local/cosmetic); reset/migration of existing local
selections; any XP/level/rank/leaderboard change; new dependencies or secrets;
and any edit or staging inside the isolated `adaptive-character-guidance`
worktree. This append-only routing does not supersede other active capsules.
