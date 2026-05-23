# Claude Review Codex Plan

Review the Codex-generated plan only. Do not edit files. Do not propose implementation patches. Do not run commands. Do not use Bash, Edit, Write, or filesystem-modifying tools.

Read the Codex plan first. Use its `Review Scope` section to bound the review.

Check these scope-control sections before reviewing implementation details:

- `Context Class Decision`
- `Plan Scope`
- `Review Scope`
- Plan Scope vs Review Scope consistency

Scope rules:

- Do not perform a full repository scan.
- Confirm whether the selected context class is reasonable. If the class appears wrong, return `DEFER`.
- Confirm that `unknown` did not silently fall back to a broader class.
- Confirm that Review Scope files stay within Plan Scope allowed paths or explicit Allow paths.
- Treat `Files Claude may need to read for review` as a minimum review set, not an inventory list.
- For `workflow` context, treat a Review Scope with more than 6 review files as too broad unless explicit expanded review is allowed.
- Use files listed under `Files expected to change` as the primary review target.
- Prefer files listed under `Files Claude may need to read for review` for supporting context.
- Treat files listed under `Files explicitly out of scope` as excluded unless the user explicitly expands scope.
- Use Glob/Grep only to resolve explicitly named paths or patterns from `Review Scope`.
- Do not use Glob/Grep to discover unrelated files.
- Read at most 6 project files besides the plan unless the task explicitly requires more.
- If more files are needed, return `DEFER` instead of continuing to scan.
- If the review cannot be completed within the provided `Review Scope`, return `DEFER`, include `Requested additional scope` with specific paths or reasons, and do not continue scanning broadly.
- For `workflow` context, check whether PRD/PDD reads or checks were skipped appropriately unless the user provided explicit Allow paths.

Use standard-level scrutiny for high-risk changes touching XP, streak, level, rank, leaderboard, roles, entitlements, premium fairness, Firebase ownership, Cloud Functions ownership, security rules, PRD/PDD consistency, or production source code.

Focus on:

- Risky assumptions.
- Missing constraints.
- Unsafe file operations.
- Flutter/Firebase convention conflicts.
- PRD/submitted-PDD/current-PDD mismatch only when those files are in Plan Scope or explicit Allow paths.
- Overengineering beyond the submitted baseline or current phase.
- Missing approval gates before implementation.
- Whether the plan keeps user commits manual.

Output exactly:

## Verdict

ACCEPT / MUST_FIX / DEFER

## Summary

## Risks

| Risk | Severity | File/Area | Mitigation |
| --- | --- | --- | --- |

## Missing Constraints

## Context Scope Issues

## Unsafe Operations

## PRD/PDD Consistency Issues

## Overengineering Concerns

## Requested Additional Scope

## Recommendations
