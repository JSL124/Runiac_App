# feed-friends-pdd-traceability-alignment

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly approved PDD_MODE alignment follow-up. This capsule does not select Phase 02 or authorize implementation.

## Mode / Lane / Status

- Mode: PDD_MODE.
- Lane: Governance / Architecture Lane under ADR-003.
- Status: Closed for PDD design work. `PDD package Ready for commit; implementation blocked on user commit`. Terminal handoff state: `Ready for manual commit` with no staged or committed file.
- Package boundary: this PDD package must reach `Ready for manual commit` and be manually committed by the user before any `feed-friends-emulator-backend` implementation capsule may be created or routed.
- Preserved work: `adaptive-character-guidance` remains open and byte-for-byte unchanged. All existing Leaderboard changes remain unrelated, user-owned, unstaged, and outside this capsule.

## Goal

Align Runiac's canonical PDD architecture, data/security model, diagrams, and Feed/comments wireframe contract for a friends-only Feed built from explicitly shared validated activities, without changing product code or opening implementation work.

## Required Agent / Review Chain

`A0_ORCH -> A9_TRACE -> A1_APP -> A2_PHYS -> A3_COMP -> A4_CLASS -> A5_WIRE -> A13_SECURITY_RULES -> A6_REVIEW -> A8_OUTPUT_CHECKER`

Sol owns routing, capsule state, evidence, aggregate diff approval, and the final readiness decision. Bounded Terra specialists own only the canonical PDD or review paths assigned to them. No specialist may stage, commit, or broaden scope.

## Allowed Scope

Only these task paths may change:

- `implementation/roadmap/capsules/feed-friends-pdd-traceability-alignment.md`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `docs/pdd/01-application-architecture.md`
- `docs/pdd/02-physical-architecture.md`
- `docs/pdd/03-component-diagram.md`
- `docs/pdd/04-class-diagram.md`
- `docs/pdd/05-wireframe-description.md`
- `docs/pdd/diagrams/application-architecture.puml`
- `docs/pdd/diagrams/application-architecture.png`
- `docs/pdd/diagrams/physical-architecture.puml`
- `docs/pdd/diagrams/physical-architecture.png`
- `docs/pdd/diagrams/component-diagram.puml`
- `docs/pdd/diagrams/component-diagram.png`
- `docs/pdd/diagrams/class-diagram.puml`
- `docs/pdd/diagrams/class-diagram.png`

Capsule-scoped orchestration evidence is recorded separately under `.omo/evidence/feed-friends-emulator-backend/`; it is not a product deliverable and is excluded from manual package A unless the user separately requests it.

## Forbidden Scope

- No Flutter, Firebase configuration, Firestore Rules/indexes, Storage Rules, Cloud Functions, backend, tests, dependency, native, build, generated, deployment, secret, or production-service change.
- No `PRD.md`, `docs/submissions/**`, submitted/frozen PDD, legacy root `diagrams/`, wireframe screenshot/image assets, prompt assets, or unrelated support-document change.
- No edit, format, restore, stage, or commit of `implementation/roadmap/capsules/adaptive-character-guidance.md` or any existing Leaderboard path.
- No friend-management UI, notifications, public/global/nearby or algorithmic Feed, general media posts, replies, comment likes/reactions, translation, badges, share action, moderation dashboard, report penalties, automatic posting, optimistic offline mutation, or activity-delete UI.
- No direct client ownership of friend/block/hidden/count/status documents or XP, streak, level, rank, leaderboard, subscription privilege, or expert-plan publication state.
- No raw GPS samples, route arrays, exact coordinates, addresses, private route images, secrets, tokens, PII, or sensitive evidence artifacts.
- No real-screen QA claim. Real-screen interaction and visual acceptance remain user-owned.

## Canonical Contract to Align

- Feed visibility is limited to the owner's posts and posts from current accepted friends. Accepted friendship is reciprocal trusted-backend/Admin-fixture state at `users/{uid}/friends/{friendUid}`; `users/{uid}/blockedUsers/{blockedUid}` is directional and either block direction revokes access.
- `completeRun` never posts automatically. `publishActivityToFeed` runs only after explicit `Post to Feed` confirmation and accepts one owned validated activity plus its safe owner staging thumbnail.
- One validated activity maps to at most one active immutable `feedPosts/{activityId}` snapshot. The snapshot contains trusted activity metrics and sanitized author display data but no raw GPS, route arrays, coordinates, addresses, competitive fields, or private profile read dependency.
- The exact privacy-masked 88-logical-pixel Running History thumbnail bytes are reused for Feed. Owner-only staging is promoted to an immutable server-owned final object with generation and SHA-256 binding.
- `readFeedThumbnail(postId)` returns bounded PNG bytes, never a signed URL, only after resolving the active post and checking current friendship, both block directions, the caller's hidden marker, and the recorded object path/generation/hash.
- Likes and flat comments are user-owned documents; trusted triggers own counts. Comments use newest-first 20-item cursor pages, 1-500 trimmed characters, author-only edit/delete, and no replies.
- The Feed is newest-first with global pages of 20 from buffered one-author queries, deterministic `(createdAt, postId)` merging, pull-to-refresh, and no popularity ranking or automatic scroll reordering.
- Offline Feed is visibly cached and read-only. Publish, like, comment, edit, delete, and report stay disabled until server-backed state returns.
- Reporting hides only for the reporter. Owner Feed-post deletion preserves the source activity; trusted source-activity deletion cascades through the post, engagement, markers/reports, and exact thumbnail generation. All cleanup and counts are retry-safe and non-competitive.
- Tapping the comment icon opens a draggable, keyboard-safe comments Bottom Sheet with a scroll-controller-bound flat list and persistent composer; the focused composer and create/edit action remain visible and tappable above nonzero keyboard insets.

## Exact Target Files

The complete target set is the sixteen paths listed under Allowed Scope. No alternate PDD, legacy diagram, implementation, or support path is authoritative for this capsule.

## Requirement-to-PDD Trace Matrix

Each validated Seed acceptance criterion appears exactly once below.

| ID | Validated criterion | Canonical PDD destination | Required evidence |
| --- | --- | --- | --- |
| FF-AC-01 | Reviewed PDD/traceability covers Feed components, entities, trust boundaries, privacy, lifecycle, and comments Bottom Sheet before implementation. | `01`-`05` canonical PDD files and all four canonical diagrams | A13, A6, and A8 unconditional approvals |
| FF-AC-02 | Any later implementation is emulator-only across Auth, Firestore, Functions, and Storage and never contacts/deploys production. | Application and physical architecture | Explicit physical trust boundary and out-of-scope wording |
| FF-AC-03 | Own/current-friend reads succeed; missing friendship, non-friend, either block, and revoked access fail; clients cannot forge friend/block state. | Application, component, and class/data model | Reciprocal friend and directional block contracts |
| FF-AC-04 | Explicit publish rejects invalid identity/activity/thumbnail states and idempotently creates one immutable post/object from a validated owned activity. | Application, component, and class/data model | `publishActivityToFeed` authority and lifecycle sequence |
| FF-AC-05 | Feed post is a server-derived immutable activity/author snapshot with no raw route/GPS or sensitive metadata. | Class/data model and diagrams | Exact entity fields/boundaries and privacy prohibition |
| FF-AC-06 | One privacy-masked Running History/Feed PNG is reused with bounded dimensions, masks, size, and metadata. | Application, physical, component, class/data model, and wireframe | Shared source-of-truth thumbnail contract |
| FF-AC-07 | One author query per owner/friend is buffered and deterministically merged into unique newest-first global pages of 20 without gaps/duplicates. | Application and component architecture | Per-author cursor and k-way merge contract |
| FF-AC-08 | `readFeedThumbnail` rejects invalid, stale, hidden, revoked, or blocked reads and returns only exact generation/hash-matched bytes. | Application, physical, component, and class/data model | Three-check trusted-read contract; never a signed URL |
| FF-AC-09 | Likes are idempotent per user/post; trusted aggregation owns `likeCount`; clients never write the count. | Component and class/data model | Like ownership and server-count boundary |
| FF-AC-10 | Comments Bottom Sheet is draggable/keyboard-safe, cursor-paged, author-editable/deletable, validated, and has no replies/excluded reference features. | Canonical wireframe plus component/class contracts | All interaction and exclusion states documented |
| FF-AC-11 | Comment aggregation remains retry-safe through create/edit/delete/duplicate delivery/cascade; client never writes `commentCount`. | Component and class/data model | Server-derived count and cleanup boundary |
| FF-AC-12 | Reporting atomically creates one report and one private hidden marker; only the reporter loses visibility. | Component, class/data model, and wireframe | Reporter-only hide and no-penalty contract |
| FF-AC-13 | Online unfriend/block revokes rows and later reads; offline cached rows are visibly stale/read-only until resynchronization. | Application, component, class/data model, and wireframe | Revoked/offline state transitions |
| FF-AC-14 | Owner Feed-post deletion blocks new access, cleans dependents and thumbnail, and preserves the source activity. | Component, class/data model, and wireframe | Deleting/deleted state and cleanup direction |
| FF-AC-15 | Trusted source-activity deletion removes related Feed artifacts idempotently without adding activity-delete UI. | Component and class/data model | Activity-to-post cascade and UI exclusion |
| FF-AC-16 | Loading, empty, recoverable error, refresh, pagination, offline, deleted, and revoked states are explicit; all offline mutations are disabled. | Canonical wireframe | Complete Feed/comments state matrix |
| FF-AC-17 | Focused automated architecture/render/diff/governance evidence is complete without secrets, coordinates, route images, or Leaderboard changes. | Capsule validation/evidence sections | Exact command outputs and protected-state fingerprints |
| FF-AC-18 | Final A13/A6/A8 gates approve security, consistency, completeness, scope, and rendered outputs with zero open findings. | Capsule review gate | Non-empty independent review artifacts with `APPROVE` |
| FF-AC-19 | PDD Wave 0 ends at `Ready for manual commit`; real-screen QA is not claimed and later implementation remains blocked on the user's PDD commit. | Capsule status, `CURRENT.md`, and latest snapshot | Exact terminal status and manual staging commands |

## Required Tests and Validation

Product tests are not applicable because this is PDD_MODE and product files are forbidden. Required validation is:

- Exact `plantuml -checkonly` for each of the four canonical `.puml` sources.
- Regeneration of the four canonical PNGs and non-empty file checks.
- Canonical grep/consistency checks for `feedPosts`, `readFeedThumbnail`, `blockedUsers`, validated activity, exact Running History thumbnail reuse, Bottom Sheet behavior, and no replies.
- `git diff --check -- docs/pdd implementation/roadmap`.
- `./tools/governance-ci/run-all-checks.sh` with any failure attributed exactly and all capsule-caused findings resolved within approved scope.
- Baseline-versus-final Wave 0 allowed-path audit; empty adaptive-capsule diff; and point-in-time Leaderboard path/status, tracked-diff, and aggregate-content fingerprints. Concurrent user-owned Leaderboard writes must be timestamp-attributed and preserved without content inspection or restoration. The gate proves Wave 0 non-interference, not permanent immutability of unrelated external content after the observation.
- Independent A13 security review, then independent A6 consistency review, then independent A8 completeness/output review. Each must record unconditional `APPROVE` with zero open findings.

## Required Evidence

- Baseline RED and protected-state evidence under `.omo/evidence/feed-friends-emulator-backend/`.
- `task-01-pdd-routing.txt`.
- `task-02-pdd-architecture.txt` and `task-02-pdd-diagram-render.txt`.
- `task-03-pdd-wireframe.txt`.
- `task-04-pdd-review.md`, `task-04-pdd-output-checker.md`, and `task-04-pdd-status.txt`.
- Independent reviewer artifacts for A13, A6, and A8.
- `orchestration-ledger.md` with Sol's full-diff inspection, focused reruns, corrections, and explicit approval for every Terra unit.

## Rollback / Stop Conditions

- Stop and reopen the owning unit if any forbidden path changes, the adaptive fingerprint changes, Wave 0 causes a Leaderboard fingerprint change, concurrent Leaderboard drift is unattributed or restored instead of preserved, any canonical term/diagram diverges, any route data or signed-URL path is exposed, any client-owned trusted value appears, or any reviewer has an open/conditional finding.
- Stop rather than broadening scope if Governance CI requires a change outside this capsule's explicit allowlist.
- Do not create or route the implementation capsule before the user manually commits package A.
- Do not stage, commit, deploy, or claim real-screen QA.

## Exit Criteria

- [x] All five canonical PDD files align to the confirmed Feed/Friends contract.
- [x] All four canonical PlantUML sources pass `-checkonly` and their canonical PNGs are regenerated and non-empty.
- [x] The nineteen-row trace matrix maps every validated Seed acceptance criterion exactly once.
- [x] A13 records unconditional `APPROVE` with zero open security/privacy findings.
- [x] A6 records unconditional `APPROVE` with zero open cross-document findings.
- [x] A8 records unconditional `APPROVE` with zero missing output, path, render, or scope findings.
- [x] Diff, canonical consistency, render, protected-state, and governance evidence is recorded with exact commands and exit codes.
- [x] The full diff contains only the Wave 0 allowlist plus pre-existing Leaderboard dirty paths untouched by this package; concurrent user-owned transitions are timestamp-attributed with baseline and final point-in-time fingerprints, and the adaptive capsule has an empty diff.
- [x] `CURRENT.md` and `snapshots/latest.md` state `PDD package Ready for commit; implementation blocked on user commit`.
- [x] Manual commands stage only task-relevant package A paths and never use `git add .`.
- [x] No file is staged or committed, no implementation capsule exists, and the terminal state is `Ready for manual commit`.
