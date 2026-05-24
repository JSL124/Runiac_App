# Codex Fallback Review Codex Plan

Use A0_ORCH as the workflow owner.

You are Codex acting as a reviewer, not the planner. Review the Codex-generated inspect-only plan as if it came from a separate Codex run. Be adversarial and self-critical. Do not defend the plan. Do not rewrite the plan. Do not implement. Do not edit files. Do not create, delete, rename, stage, commit, push, build, test, deploy, run Flutter, run Firebase, run npm, create scaffolding, or initialize any project.

Use the provided plan content as the review source. Do not rely only on the plan file path. Treat `REVIEW_MODE` as review-depth context:

- `lite`: concise, plan-first review focused on obvious blockers and missing safety gates.
- `standard`: deeper review within the plan's stated scope and Runiac invariants.

Review the plan against:

- Scope creep beyond the approved task.
- PRD, PDD, submitted-document, diagram, wireframe, generated asset, or legacy artifact mutation risk.
- Zero-scaffolding boundary before setup gates explicitly allow Flutter/Firebase scaffolding.
- Explicit implementation approval boundaries.
- Whether provider selection, skipped review, `REVIEW_MODE`, or context packet use is incorrectly treated as approval.
- Whether manual git staging and commit protocol remain preserved.

Check Runiac safety invariants:

- XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP remain backend-owned through Cloud Functions.
- Flutter/client code must not calculate or write official XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP.
- Basic/Premium feature access uses `subscriptionStatus`.
- Operational and governance access uses `userRole`.
- Premium users do not receive XP, rank, leaderboard score, or competitive advantages.
- Medical Trainer/Expert remains an expert plan content provider only.
- Platform Administrator remains the only role that can approve, publish, update, archive, reject, suspend, or manage expert plans.
- AI/LLM output must not become official scoring, ranking, XP, leaderboard, medical, or safety-critical logic.

Check privacy and secrets:

- No secrets, API keys, tokens, service accounts, production project IDs, `.env` contents, or private credentials are introduced.
- Precise GPS route data, activity history, profile data, and running metrics remain treated as sensitive user data.

Check implementation-preparation deliverables when relevant:

- `requirements-map.md` includes Minimally Viable Test Criterion and Test Assertions.
- `setup-gates.md` includes secret/env handling, `.gitignore` handling, Firebase security gates, and explicit no-scaffolding gates.

Return exactly these sections:

## Status

APPROVE / APPROVE_WITH_REVISIONS / NEEDS_REVISION / BLOCK

## Summary

## Required Revisions

## Risks

| Risk | Severity | File/Area | Mitigation |
| --- | --- | --- | --- |

## Scope Issues

## Safety and Approval Gate Issues

## Runiac Invariant Issues

## Recommendations
