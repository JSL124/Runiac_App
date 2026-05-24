# Runiac Agent Review TODO

Implementation remains user-approved only. The pipeline may prepare plans, reviews, and decisions, but it must not implement, commit, push, test, build, deploy, run Flutter, run Firebase, or run npm.

## Current Completed Milestones

- [x] Local agent-review scaffold created
- [x] Codex exec compatibility fixed
- [x] Claude CLI compatibility fixed
- [x] Authenticated Claude print mode working
- [x] Manual plan/review/decision workflow tested
- [x] Pipeline subcommand added
- [x] Pipeline actual run tested
- [x] Pipeline traceability records committed
- [x] Generic core + Runiac profile migration completed
- [x] `REVIEW_MODE=standard|lite` implemented and tested
- [x] Claude review cost caps implemented and tested:
  - `CLAUDE_MAX_TURNS`
  - `CLAUDE_MAX_BUDGET_USD`
- [x] Claude read protection guardrails added through `.claude/settings.json`
- [x] Generic context selection protocol documented
- [x] `context-policy.yml` schema files added for:
  - `tools/agent-review/profiles/generic/context-policy.yml`
  - `tools/agent-review/profiles/runiac/context-policy.yml`
- [x] `REVIEW_ENABLED` on/off policy documented
- [x] `REVIEW_ENABLED` runner support implemented:
  - `REVIEW_ENABLED=1` runs Codex read-only review
  - `REVIEW_ENABLED=0` skips review with `SKIP_REASON`
  - skipped-review artifact is created
  - Codex final decision still runs
- [x] `REVIEW_ENABLED=0` actual smoke test passed:
  - Codex plan was created
  - review was skipped
  - `_external_review_skipped.md` artifact was created
  - Codex decision completed
  - implementation was not run
- [x] `REVIEW_ENABLED=1` lite dry-run regression passed
- [x] Future context packet builder design documented
- [x] `inventory_limits` added to generic and Runiac `context-policy.yml` files
- [x] Standalone `build_context_packet.sh` helper implemented and smoke-tested
- [x] Future context packet runner integration design documented
- [x] Opt-in `CONTEXT_PACKET_ENABLED` runner integration implemented:
  - `CONTEXT_PACKET_ENABLED=0` is the default
  - `CONTEXT_PACKET_ENABLED=1` calls `build_context_packet.sh` before Codex planning
  - context packet is prepended to the Codex planning prompt
  - packet size limit is enforced
  - builder failure stops the pipeline with no broad repo scan fallback
- [x] Context packet dry-run regression passed
- [x] Actual `CONTEXT_PACKET_ENABLED=1` + `REVIEW_ENABLED=0` smoke test passed
- [x] Smoke-test traceability artifact committed:
  - `docs(traceability): record context packet integration smoke test`
- [x] First deterministic high-risk auto-routing guard implemented:
  - `HIGH_RISK_GUARD_ENABLED=1` is the default
  - block-level high-risk dry-runs stop unless approved
  - `HIGH_RISK_APPROVED=1` requires non-empty `HIGH_RISK_REASON`
  - `REVIEW_ENABLED`, `REVIEW_MODE`, and `CONTEXT_PACKET_ENABLED` remain separate from high-risk approval
- [x] External provider routing abandoned and simplified:
  - Claude review repeatedly hit the local budget cap
  - Gemini actual headless provider smoke tests repeatedly hung
  - active workflow is now Codex-only for feasibility, reliability, and efficiency
- [x] Codex-only review cleanup completed:
  - `REVIEW_ENABLED=1` runs Codex read-only plan review
  - `REVIEW_ENABLED=0` skipped-review behavior remains available with `SKIP_REASON`
  - Gemini and Claude provider routing are no longer active in `run_plan_review.sh`
  - implementation remains separate and requires explicit user approval

## Current Important Limits

- [ ] TODO auto-updater is postponed
- [ ] Flutter/Firebase implementation has not started

## Next Planned Steps

- [ ] Return to Runiac Phase 1 implementation preparation:
  - `implementation/traceability/requirements-map.md`
  - `implementation/traceability/setup-gates.md`
- [ ] Do not start Flutter/Firebase scaffolding until setup gates approve it

## Postponed TODO Automation

- [ ] Do not implement TODO automation now
- [ ] Prefer deterministic script first
- [ ] Add marker-delimited TODO sections later if needed
- [ ] Add optional Codex review later if useful
- [ ] Git hooks or GitHub Actions should warn/check first, not auto-edit

## Later Efficiency Work

- [ ] Defer `DECISION_POLICY=if-needed`

## Phase 1 Runiac Implementation Preparation

- [ ] Create `implementation/traceability/requirements-map.md` later
- [ ] Create `implementation/traceability/setup-gates.md` later
- [ ] Verify submitted PDD PDF readable text first
- [ ] Compare submitted PDD baseline with `docs/pdd/` only for implementation-relevant deltas
- [ ] Map MVP features F1, F2, F3, F4, F6, F9
- [ ] Mark deferred features F5, F7, F8, F10 unless user decides otherwise
- [ ] Clarify expert/admin governance scope

## Do Not Do Yet

- [ ] Do not run `flutter create`
- [ ] Do not run `firebase init`
- [ ] Do not run `npm`
- [ ] Do not run tests
- [ ] Do not run builds
- [ ] Do not run deployment
- [ ] Do not create `firebase/functions`
- [ ] Do not create `firebase/firestore`
- [ ] Do not create `pubspec.yaml`
- [ ] Do not create `firebase.json`
- [ ] Do not create `package.json`
- [ ] Do not create Firestore rules
- [ ] Do not create Storage rules
- [ ] Do not create GitHub Actions
- [ ] Do not create production source code

## Next Codex Prompt Topic

Return to Phase 1 implementation preparation by drafting `implementation/traceability/requirements-map.md` and `implementation/traceability/setup-gates.md`.
