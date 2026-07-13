# challenge-distance-system

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved (explicit user routing on 2026-07-13 Asia/Singapore: "Implement this plan").

Type: Backend Guarded Lane full-stack Challenge distance system capsule (Cloud Functions + Firestore rules + Flutter surfaces), emulator-first per ADR-002, lane classification per ADR-003.

## Status

Status: Backend deployed to `runiac-fypp` on 2026-07-13 Asia/Singapore after explicit user authorization; Flutter implementation remains separately in progress. All expected Functions are ACTIVE, Challenge indexes are present, and the unauthenticated catalog probe reaches the deployed callable and returns `UNAUTHENTICATED` rather than 404.

Routed on: 2026-07-13 Asia/Singapore.

Depends on:
- Nine-badge asset/case work completed at `e26c8a10 feat(account): refine challenge badge case layout` (badge assets `41e6b72d`, case `cc000e98`, preview `a3d31a79`).
- Friends reciprocal contract: `functions/src/feed/relationship.ts` (`evaluateFeedRelationship`) plus `users/{uid}/friends` reciprocal storage from `feed-friends-emulator-backend`.
- Plan of record: `.omo/drafts/challenge-distance-balance.md` and the approved challenge-distance-balance work plan (13 todos + F1–F4).

This routing is append-only. It does not supersede, modify, or reopen `cadence-capture-reliability-recovery` (still the active cadence capsule), `activity-history-feed-upload`, `run-completion-authoritative-result-recovery`, `friends-row-add-pending-icons`, or any other concurrent capsule.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A10_FLUTTER_IMPL -> A5_WIRE -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

Execution model: Fable orchestrates and reviews every diff; Opus workers implement; a wave advances only after the orchestrator accepts the diff.

## Goal

Deliver the complete solo-or-friends distance Challenge system launching all nine tiers together: server-owned versioned catalog, invitation/lobby/slot transactions, validated-run contribution with immediate target completion, leave/abandon/deadline settlement with idempotent badge grants, privacy-safe notifications and durable history, member-scoped security rules, and the Flutter catalog/lobby/Home/Progress/result/history/badge-collection surfaces.

## Launch Catalog (all nine tiers active, versioned `challenge-distance-v1`)

| Tier | Difficulty label (EN) | Duration | Max participants (owner incl.) | Max invited friends | Solo target | Group personal minimum |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 10K | Beginner | 1 week | 2 | 1 | 10,000 m | 3,000 m |
| 20K | Easy | 2 weeks | 2 | 1 | 20,000 m | 5,000 m |
| 42K | Normal | 3 weeks | 3 | 2 | 42,000 m | 7,000 m |
| 100K | Challenging | 4 weeks | 4 | 3 | 100,000 m | 13,000 m |
| 200K | Hard | 6 weeks | 5 | 4 | 200,000 m | 20,000 m |
| 250K | Hard+ | 7 weeks | 5 | 4 | 250,000 m | 25,000 m |
| 300K | Very Hard | 8 weeks | 5 | 4 | 300,000 m | 30,000 m |
| 500K | Extreme | 9 weeks | 7 | 6 | 500,000 m | 36,000 m |
| 1000K | Legend | 14 weeks | 8 | 7 | 1,000,000 m | 63,000 m |

All 300K/500K/1000K tiers are active launch scope, not future scope. Eligibility and aggregation use integer metres from validated activities only; `0.1 km` rounding is display-only.

## Locked UI/Copy Decisions (user-approved 2026-07-13)

- All Challenge copy is English. The original plan's Korean strings are superseded by this canonical table:
  - `챌린지 시작` → `Start challenge`; `남은 시간` → `Time left`; `결과 계산 중` → `Calculating results…` (Home short form `Calculating…`); `이미 진행 중인 챌린지가 있어요` → `You already have a challenge in progress`; `진행 중인 챌린지 보기` → `View current challenge`; `챌린지 나가기` → `Leave challenge`; `챌린지 포기` → `Abandon challenge`; `나간 참가자` → `Left the challenge`; `혼자 도전 중` → `Solo challenge`; `개인 최소 Xkm` → `Personal minimum X km`; `개인 최소 거리 미달` → `Personal minimum not reached`.
- Hub landing is the Explore 3x3 badge grid (tile = badge + tier title + difficulty caption) with header icon actions for Invitations (pending-count badge) and History. No segmented hub.
- Tier detail: badge hero, rules card (target, duration, max participants, personal minimum, group rule, solo full-target warning), single primary `Create challenge` CTA; solo vs group resolves at lobby start.
- Lobby: roster with Pending/Accepted/Declined chips, `Lobby closes in HH:MM:SS`, owner-only `Start challenge`/`Cancel challenge`, member `Leave lobby`, friend picker capped at tier invite cap.
- Home active control: circular 60–64px header-control-decorated circle below the Streak pill containing only the tier badge, with fixed-width `DD:HH:MM:SS` beneath; whole area one semantic button to Progress; absent (no gap) when no active/settling challenge; `Calculating…` while settling; disappears when result-ready; minute-level screen-reader summary.
- Progress: tier badge centered in circular team-progress ring (blue track, orange arc), team `X.X / Y.Y km`, `Time left DD:HH:MM:SS`, personal-minimum mini bar with `Minimum reached` state, participant rows (You first, active by km desc), separate muted `Left the challenge` group, owner-only `Abandon challenge` (red) vs non-owner-only `Leave challenge`, confirmation bottom sheets.
- Results: full-screen, presented once, five variants (badge earned; team success + `Personal minimum not reached`; deadline failure; cancelled by owner; you left). History rows reopen result details.
- Every tier badge rendering anywhere uses the user-created assets via `RuniacAssets.challengeBadge10k` … `challengeBadge1000k`; locked/unearned states dim/desaturate the same PNGs; never icons, emoji, or generated art. The badge-case artwork, slot geometry, and semantics from `e26c8a10` are preserved.

## Core Behavioral Contract

- One server-owned slot per user (`challengeSlots/{uid}`) covering owned lobby or accepted/active membership; pending invitations reserve nothing; accepted+pending invitees never exceed `maxParticipants - 1`.
- Lobby expires 24h after server `createdAt`; owner start atomically locks roster, expires unanswered invitations, snapshots mode (SOLO = 1 locked participant, GROUP = 2+), catalog version, target, personal minimum, `startsAt`, `scheduledEndsAt`; all immutable after start.
- Contribution: `completeRun` seam credits integer `distanceMeters` once per deterministic activity ID, only while participant ACTIVE, instance ACTIVE, and server receipt before `scheduledEndsAt`; no offline/late-upload grace; client `completedAt` must be within window and never admits late receipt.
- First transaction reaching target clamps display progress, closes credit, snapshots eligibility (non-LEFT participants at/above snapshotted minimum), records server completion, transitions ACTIVE → SETTLING.
- Non-owner leave: participant LEFT, metres retained in team total, slot released, no rejoin, badge eligibility irrevocably lost. Owner cannot leave alone; owner abandon cancels for everyone, releases all slots, invalidates rewards, preserves cancelled history, notifies participants.
- Deadline without target = total failure, no badges. Idempotent grants via `challengeRewardGrants/{challengeId_uid}`; one badge ownership doc per tier (`users/{uid}/challengeBadges/{tierId}`) regardless of repeat successes; slots release before retryable grant completion.
- State machines: instance `RECRUITING -> ACTIVE -> SETTLING -> SUCCEEDED | FAILED | CANCELLED | EXPIRED`; invitation `PENDING -> ACCEPTED | DECLINED | REVOKED | EXPIRED`; participant `ACCEPTED -> ACTIVE | LEFT | CANCELLED | SUCCEEDED | INELIGIBLE | FAILED`; reward `NOT_ELIGIBLE | PENDING | ISSUED`.
- Firestore rules: deny every client create/update/delete on trusted challenge/reward/slot/history/badge data; instance/participant reads only by snapshotted participants; slot/history/badge reads owner-only; invitation reads owner-or-recipient; no broadened profile/activity reads. Participant identity comes only from minimal backend-authored `displayNameSnapshot`/`avatarInitialsSnapshot`; never expose routes, coordinates, run timestamps, or activity history.
- Notifications: deterministic delivery keys (challengeId + kind + recipient + terminal version); minimal allowlisted payload; terminal state never depends on delivery; denied permission still yields inbox/history.

## Allowed Files

Backend (new under `functions/src/challenge/` and tests under `functions/test/`): `challengeTypes.ts`, `challengeCatalog.ts`, `challengeStateMachine.ts`, `challengeContribution.ts`, lobby/settlement/notification challenge modules, `functions/src/index.ts` (export additions only), `functions/package.json` (`test:challenge` script only, no dependencies), corresponding `functions/test/challenge*.test.ts` files, minimal notification-kind extensions under `functions/src/notifications/`, `functions/src/run/completeRun.ts` (contribution-seam hook call only, after existing validation/replay logic) and `functions/test/completeRun.test.ts` (additive regression coverage only — existing tests stay green).

Persistence: `firestore.rules` (challenge sections added), `firestore.indexes.json` (challenge indexes added), `tests/firebase-rules/challenge.firestore.rules.test.mjs` (new) plus its package test-script wiring.

Flutter (new under `implementation/mobile/runiac_app/lib/features/challenge/` and tests): domain models/repositories, data adapters, presentation screens/widgets for Explore/detail/picker/lobby/invitations/progress/result/history, Home stage-map header active-control integration (`home_stage_map.dart`, `home_tab.dart`), Social menu Challenge navigation replacement, `account_challenge_badge_case.dart` earned/unearned-state extension (geometry/assets preserved), `runiac_assets.dart` (only if a new constant is required), `app.dart` (composition/routing seams only), new/updated widget tests, `DESIGN.md` component sections.

Governance: this capsule file, `implementation/roadmap/CURRENT.md` (append-only), `implementation/roadmap/snapshots/latest.md` (append-only), `tools/governance-ci/check-diff-hygiene.sh` (routed-capsule allowlist entry only), `.omo/evidence/challenge-distance-balance/*` evidence.

## Forbidden Scope

- No client calculation/write of target progress, validated contribution, eligibility, completion, reward/slot ownership, or terminal state; no XP/streak/level/rank/leaderboard formula changes; no premium/XP advantages.
- No late joining, participant replacement, ownership transfer, multiple simultaneous slots, non-friend/link/contact invitations, over-capacity invitations, post-start threshold changes, offline/late-upload grace.
- No leaderboards/winners/pace competition/chat/reactions/photo feeds/route sharing/shame copy inside Challenge.
- No Platform Administrator challenge CRUD (catalog is a versioned backend constant).
- No `firebase init`, `flutterfire configure`, production deploy, secrets/service accounts, cost-affecting production operations, or new dependencies. Emulator-first only; physical FCM delivery is a release checkpoint, not an automated readiness claim.
- No edits to cadence/activity-history/feed/leaderboard/XP capsule scope, raw GPS persistence, Android/iOS native configuration, `docs/submissions/`, `PRD.md`, or unrelated files. The committed badge-case artwork/geometry from `e26c8a10` is preserved.

## Validation Plan

```bash
cd functions && npm run build
cd functions && npm run test:challenge
cd tests/firebase-rules && npm test
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
git diff --check
./tools/governance-ci/run-all-checks.sh
```

Evidence root: `.omo/evidence/challenge-distance-balance/`. Emulator + simulator QA precede readiness claims; F1–F4 audit wave precedes closure.

## Stop State

Stop at `Ready for commit`. No automatic staging, commit, or push. Manual git commands are provided at the end; suggested atomic commit order follows the plan's Commit strategy.
