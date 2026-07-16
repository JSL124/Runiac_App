# adaptive-character-guidance

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly approved, isolated implementation follow-up. This capsule does not select Phase 02 and does not alter the active Leaderboard capsule on the main worktree.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE, explicitly approved for the adaptive character-guidance feature.
- Execution lane: Backend Guarded Lane under ADR-003, because the work spans Cloud Functions, Firestore rules, emulator workflows, trusted activity evidence, privacy-sensitive aggregates, and Flutter integration.
- Status: Implementation is complete locally and ready for scoped backend production deployment plus registered-debug-client verification. App Store-grade iOS App Attest remains externally blocked by the current Apple Personal Team provisioning profile.
- Main-worktree protection: `leaderboard-jurong-east-seed-verification` remains Active / Production confirmation pending on the main worktree. This capsule neither closes, supersedes, mutates, nor authorizes production activity for it.

## Goal

Deliver an authenticated, server-owned adaptive daily coaching bundle with a local three-message Flutter cycle: a bounded today-plan summary, a contextual running tip, and a deterministic trusted progression check-in. Server code alone may assemble trusted aggregate evidence, reserve daily model attempts, call the provider, validate output, and manage the cache.

## Required Agent / Review Chain

`A0 -> A9 -> A5 -> A11 -> A10 -> A13 -> A6 -> A12 -> A8`

The chain is mandatory because the capsule combines user-facing guidance with Firebase/Firestore boundaries, trusted activity evidence, privacy-sensitive data minimization, and a Cloud Functions provider call.

## Allowed Scope

- The adaptive guide domain/adapter/cycle and Home Stage Map bubble only under `implementation/mobile/runiac_app/lib/features/home/`, with the directly related tests and the Home-guide section of `implementation/mobile/runiac_app/DESIGN.md`.
- The App Check bootstrap/dependency wiring separately authorized for this production rollout.
- Server-only adaptive guidance modules and the existing `homeGuideAgent` callable under `functions/src/agent/`, with focused Functions tests and the canonical Functions test script only when required by the route.
- An explicit `agentGuidanceDaily/{uid_YYYY-MM-DD}` client-deny rule and focused Firestore rules tests.
- Emulator-only synthetic, non-identifying test fixtures and capsule-scoped evidence.
- This capsule plus the minimal routing/closure updates to `implementation/roadmap/CURRENT.md` and `implementation/roadmap/snapshots/latest.md`.

## Forbidden Scope

- No production deploy, production Firebase connection, real provider call, secret creation/access, service account, `firebase init`, `flutterfire configure`, App Check setup, dependency change, commit, push, or PR without separate explicit user authorization.
- No raw GPS/route/cadence/profile-health data, precise timestamps, activity identifiers, plan identifiers, prompts, provider errors, or private fixture values in provider input, cached documents, logs, or evidence.
- No client-side calculation or writing of progression evidence, quota/cache state, XP, level, rank, streak, leaderboard score, weekly/monthly XP, subscription privilege state, or expert-plan publication state.
- No medical diagnosis/advice, competitive or shaming coaching copy, fabricated progress, or model-performed arithmetic.
- No alternate callable or legacy provider path that bypasses the shared quota/cache coordinator.
- No changes to Leaderboard, Run tracking, native files, unrelated dependencies, PDD/submission artifacts, roadmap phases, or the main worktree's production-pending Leaderboard capsule.

## Trusted Data and Privacy Boundary

- The callable authenticates before UID-only trusted reads. Flutter supplies only bounded, untrusted today-plan display context; the active-plan marker is read server-side only as a cache-invalidation marker, never as progression evidence.
- Trusted evidence is limited to allowlisted scalar fields from validated run activities: run frequency, total distance, active duration, and eligible weighted pace. Basic and Premium validated runs are treated equally; plan adherence is excluded until a trustworthy immutable backend denominator exists.
- The daily cache contains only the approved minimal schema and never exposes its fingerprint to Flutter. Client access to `agentGuidanceDaily` is explicitly denied.
- The provider receives only sanitized aggregate evidence and may select bounded fact IDs; server code renders numeric claims and validates every final message.

## Production-Deployment Gate

Production deployment was explicitly approved on 2026-07-15 Asia/Singapore. The versioned disclosure, explicit grant/withdrawal flow, server-side consent check before activity reads, iOS App Attest with DeviceCheck fallback, Android Play Integrity, debug-provider client path, and callable App Check enforcement are implemented. A signed iOS release build proved that the current Apple Personal Team cannot provision the App Attest capability; registered debug-provider verification is permitted for the current FYP device, while App Store-grade iOS enforcement remains blocked until an Apple Developer Program team and provisioning profile are available.

## Required Tests and Validation

- TDD evidence for the trusted evidence builder, Flutter typed bundle/adapter, Firestore client denial, quota/cache transaction behavior, provider/output validation, local cycle, Home bubble, callable surface, and Android emulator interaction.
- Emulator-only provider fakes must fail closed unless `FUNCTIONS_EMULATOR == 'true'`, project ID is `runiac-functions-test`, and the explicit test flag is present.
- Before any readiness claim, run relevant Functions, Firestore rules, Flutter, Android-emulator, `git diff --check`, and canonical governance checks as specified by the approved implementation plan. A skipped relevant test is a recorded blocker, not a pass.

## Required Evidence

- Routing preflight, scope manifests, and production-deploy-blocked record: `.omo/evidence/character-agent-adaptive-feedback/01-routing/`.
- Each implementation todo records RED/GREEN or equivalent factual evidence under `.omo/evidence/character-agent-adaptive-feedback/<todo>/`.
- Final A6, A8, A12, and A13 review outcomes plus the approved scope manifest are required before closure.

## Rollback / Stop Conditions

- Stop before a provider/network call if the emulator-only guard, authentication boundary, trusted-field allowlist, client-deny rule, daily-attempt cap, or strict response validation is absent or failing.
- Stop and return to the owning todo if tests show a stale-fingerprint cache response, provider retry/bypass, client cache access, privacy leakage, fabricated numeric claim, unexpected scope diff, or any production operation request without its separate approval.

## Exit Criteria

- [ ] All approved adaptive-character todos and their required evidence are complete.
- [ ] A13 confirms authenticated server-only access, data minimization, secret handling, and no client bypass.
- [ ] A6 confirms architecture, fairness, and backend-owned-state boundaries.
- [ ] A12 reconciles automated and Android emulator evidence; A8 confirms deliverables and factual claims.
- [ ] Production privacy-disclosure/consent and App Check are implemented and approved; registered-debug-client live verification remains, while App Store-grade iOS App Attest is externally blocked by Personal Team provisioning.
- [ ] `CURRENT.md` and the latest snapshot are updated from factual final results only.
