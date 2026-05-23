# Codex Create Inspect-Only Plan

Use A0_ORCH as the workflow owner.

Create an inspect-only plan for the requested Runiac task. Do not modify, create, delete, stage, commit, run tests, run builds, run Flutter, run Firebase, run npm, deploy, or execute production-affecting commands.

Use progressive context selection. Start with cheap inventory only, prefer a user-declared context class when provided, and otherwise classify conservatively from the task text. Do not perform a broad repository scan.

Token/Context Discipline:

- Avoid reading long files unless directly required.
- Avoid dumping large file contents into the plan.
- Summarize findings instead of reproducing file content.
- Keep inspect-only workflow plans concise.

Generic context classes:

- `workflow`: runner scripts, agent prompts, review workflow docs, `.claude/settings.json`, and repo process automation.
- `docs`: documentation-only changes that do not affect implementation behavior.
- `implementation_prep`: requirements maps, setup gates, scaffolding decisions, architecture mapping, and implementation planning.
- `feature`: product feature planning or implementation work.
- `security`: security rules, sensitive data, auth, permissions, entitlement, secrets, or privacy work.
- `architecture`: system architecture, data ownership, module boundaries, deployment shape, or cross-component design.
- `unknown`: insufficient information to choose safely.

Context class ownership:

- Prefer the user-declared context class when the user provides one.
- If the user does not provide a class, classify conservatively from the task text.
- Explain the classification in 1-2 sentences.
- `unknown` must not fall back to a broader class automatically.
- If the context class is `unknown`, stop with a clarification/escalation note instead of doing a broad scan.

Progressive context protocol:

1. Cheap inventory first.
2. User-declared context class when available.
3. Conservative context class decision when not declared.
4. Plan Scope.
5. Codex inspect-only plan.
6. Codex-generated Review Scope.
7. Claude scope-limited review.
8. Codex final decision based on plan and review.

Layer A: always-on Runiac invariants that apply to every plan/review regardless of context class:

- Flutter owns UI, navigation, GPS tracking UI, local interaction, and client integration.
- Firebase Authentication owns identity.
- Cloud Firestore stores app data.
- XP/streak/level/rank/leaderboard must be backend-owned.
- Flutter may display trusted values but must not directly write official XP/rank/leaderboard values.
- Cloud Functions own trusted XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, validation, aggregation, entitlement, and expert-plan governance logic.
- `subscriptionStatus` controls Basic/Premium access.
- `userRole` controls operational/governance roles.
- Medical Trainer/Expert submits draft expert plans only.
- Medical Trainer/Expert cannot publish expert plans directly.
- Platform Administrator approves, rejects, publishes, and archives expert plans.
- Premium must not create XP, rank, leaderboard score, or competitive advantages.
- AI/LLM must not become official XP/rank/leaderboard logic.
- No secrets, API keys, production project IDs, or precise private GPS data should be committed.

Layer B: class-specific context scope controls what files should be read:

- For `workflow`, use runner scripts, agent prompts, review workflow docs, `.claude/settings.json`, and repo process automation. Do not read product requirements, submitted assessment docs, PDFs, images, diagrams, generated assets, Flutter/Firebase source, tests, or test evidence unless explicitly allowed by the user. If the workflow task explicitly asks for product-requirement alignment, require explicit Allow paths rather than auto-expanding.
- For inspect-only workflow smoke tests, select representative files only, not every prompt/config/runner file.
- For `docs`, read only directly relevant docs and local instructions. Avoid PDFs/images/generated assets unless explicitly allowed.
- For `implementation_prep`, selectively read PRD/PDD markdown if needed. Avoid submitted PDFs/images/generated assets unless explicitly allowed.
- For `feature`, `security`, and `architecture`, consult requirement and architecture references as needed, avoid broad repo scans and large binary/generated assets, and include high-risk review mode guidance.

Output using exactly these headings:

## Goal

## Repo Context Checked

## Planning Evidence Read

Include:

- Files actually read
- Files intentionally skipped
- Reason for skipping large/reference/irrelevant files

## Context Class Decision

Include:

- Selected context class
- Reason
- Excluded classes and why
- Whether user-declared or Codex-inferred

## Plan Scope

Include:

- Allowed planning files/paths
- Excluded planning files/paths
- Large or expensive assets to avoid
- Explicit Allow paths from the user, if any
- Escalation triggers

## Review Scope

Include:

- Files expected to change
- Files Claude may need to read for review
- Files explicitly out of scope
- Risk tags:
  - touches XP/streak/level/rank/leaderboard: yes/no
  - touches Firebase ownership or Cloud Functions ownership: yes/no
  - touches roles/entitlements/premium fairness: yes/no
  - touches security rules: yes/no
  - touches PRD/PDD consistency: yes/no
  - touches production source code: yes/no
- Recommended review mode: lite or standard

Review Scope is not an inventory list. `Files Claude may need to read for review` must be the minimum review set needed to assess the plan. For `workflow` context, include at most 6 files unless the user explicitly allows expanded review. For inspect-only workflow smoke tests, choose representative files only. If more than 6 review files seem necessary, return a DEFER/escalation note instead of silently expanding Review Scope.

Recommend lite only for low-risk documentation or workflow changes. Recommend standard for anything touching XP, streak, level, rank, leaderboard, roles, entitlements, Firebase ownership, Cloud Functions ownership, security rules, PRD/PDD consistency, or production source code.

Review Scope consistency check:

- Review Scope files must stay within Plan Scope allowed paths or explicit Allow paths.
- If any Review Scope file is outside Plan Scope, flag it as an error and stop instead of silently expanding scope.

## Proposed Plan

## Files Affected If Executed

## Files That Must Remain Untouched

## Risks

## Approval Gate
