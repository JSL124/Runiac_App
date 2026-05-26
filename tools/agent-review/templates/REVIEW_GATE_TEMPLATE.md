# Review Gate Template

## Purpose

This is a reusable reference template for A6_REVIEW and A8_OUTPUT_CHECKER review packets in Runiac workflow tasks.

Use it to standardize review evidence without creating new agent roles, replacing existing prompt profiles, or changing governance authority.

## Authority Boundary

This template is a review artifact only. It does not approve work by itself, replace `AGENTS.md`, override `implementation/roadmap/CURRENT.md`, active phase documents, active capsule documents, ADRs, setup gates, prompt profiles, or Governance CI.

A6_REVIEW and A8_OUTPUT_CHECKER remain review lenses. They do not replace explicit human approval when a gate or high-risk action requires it.

## Input Required From Codex

- Task mode and workflow owner.
- Scope boundary and active routing context.
- Files changed or planned to change.
- Commands actually run.
- Validation output with `PASS`, `FAIL`, or `N/A`.
- Governance CI result or explicit `N/A` reason.
- Final `git status --short`.
- Unexpected changes, if any.

## A6_REVIEW Checklist

A6_REVIEW focuses on consistency, boundaries, and high-risk workflow safety.

- Architecture boundary: Flutter, Firebase Auth, Firestore, and Cloud Functions responsibilities remain separated.
- Active capsule scope: work stays inside the active capsule or explicitly approved task boundary.
- Backend-owned state isolation: Flutter/client does not calculate or write XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, subscription governance, `userRole`, or expert-publication authority.
- Forbidden command exposure: no unapproved Flutter, Firebase, build, scaffold, init, deploy, dependency, staging, commit, or push command was run.
- Firebase absence: Firebase config, rules, functions, project IDs, secrets, and mobile config files remain absent unless explicitly approved.
- Flutter/Firebase phase boundary: scaffold-baseline state is not treated as Phase 02, Firebase, or production implementation approval.
- Diff/scope hygiene: changed files match the approved scope and unrelated changes are disclosed.
- Validation sufficiency: validation evidence is appropriate for the task risk and mode.

## A8_OUTPUT_CHECKER Checklist

A8_OUTPUT_CHECKER focuses on completeness, evidence, and readiness claims.

- Final output matches the work actually performed.
- Validation output is present or explicitly marked `N/A` with a reason.
- Modified files are listed explicitly.
- `PASS`, `FAIL`, and `N/A` are clearly distinguished.
- Completion or readiness claims are supported by evidence.
- Unexpected changes are disclosed.
- Governance CI result is reported or explicitly marked `N/A`.
- Final `git status --short` is reported.

## Review Verdict Options

- `APPROVE`: No blockers; output and evidence support Ready for commit or completion.
- `APPROVE_WITH_REVISIONS`: No blockers, but minor wording or evidence improvements should be made before final handoff.
- `BLOCK`: A safety, scope, validation, authority, or forbidden-command issue prevents readiness.
- `NOT_READY`: Evidence is incomplete or the task is unfinished, but no immediate safety violation is confirmed.

## Required Review Output Format

### A. Verdict

- Verdict: `APPROVE | APPROVE_WITH_REVISIONS | BLOCK | NOT_READY`
- Reviewer lens: `A6_REVIEW`, `A8_OUTPUT_CHECKER`, or `A6_REVIEW + A8_OUTPUT_CHECKER`

### B. Summary

- Concise review summary.
- State whether scope and evidence are aligned.

### C. MUST FIX

- Blocking issues that must be resolved before Ready for commit or completion.
- Use `N/A` if none.

### D. SHOULD FIX

- Non-blocking issues that should be addressed soon.
- Use `N/A` if none.

### E. FUTURE IMPROVEMENT

- Deferred improvements outside the current task.
- Use `N/A` if none.

### F. Evidence Checked

- Files reviewed.
- Commands reviewed.
- Validation output reviewed.
- Git status reviewed.
- Use explicit `N/A` for categories not applicable to the task.

### G. Final READY / NOT READY

- State exactly one: `READY` or `NOT READY`.
- If `NOT READY`, state the reason and next required action.

## Non-Goals

- This template does not create new numbered agents.
- This template does not replace existing Runiac prompt profiles.
- This template does not wire templates into automation.
- This template does not replace Governance CI.
- This template does not authorize Flutter, Firebase, build, scaffold, init, deploy, dependency, staging, commit, or push actions.
