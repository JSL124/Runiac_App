# Codex Output Template

## Purpose

This is a reusable reference artifact for Codex final outputs in Runiac implementation-approved, plan-only, inspect-only, and review-only tasks.

Use it to reduce manual handoff friction by keeping final responses consistent and evidence-based.

## Authority Boundary

This template is reference-only. It does not create workflow authority, approve work, replace prompt profiles, or override `implementation/roadmap/CURRENT.md`, active phase documents, active capsule documents, ADRs, `AGENTS.md`, folder-specific instructions, or Governance CI.

Governance CI remains the official operational harness. This template only standardizes how Codex reports work already performed or inspected.

## Required Output Format

### 1. Understanding

- Restate the task in 1-3 concise bullets.
- Identify the workflow owner and mode.

### 2. Assumptions

- List assumptions used to complete the task.
- Use `N/A` if no assumptions were required.

### 3. Mode

- State the requested mode, such as `inspect-only`, `plan-only`, `review-only`, or `implementation-approved`.
- State whether file edits were allowed.

### 4. Scope Boundary

- List in-scope files, paths, and actions.
- List out-of-scope files, paths, and actions.
- Confirm that no forbidden Flutter, Firebase, build, scaffold, init, deploy, dependency, staging, commit, or push command was run unless explicitly approved.

### 5. Files Changed

- List every modified, created, deleted, or renamed file explicitly.
- Use `N/A - no files changed` for inspect-only or plan-only work with no file changes.
- Do not claim completion if changed files are unknown or summarized vaguely.

### 6. Commands Run

- List commands actually run.
- Include only commands that were executed, not planned commands.
- Use `N/A - no commands run` when applicable.

### 7. Validation Results

- Report validation output for implementation-approved work.
- Use `PASS`, `FAIL`, or `N/A` for each validation item.
- Use explicit `N/A` with a reason when validation is not applicable.
- Do not claim completion without validation output or a clear explanation for skipped validation.

### 8. Governance CI Result

- Report whether Governance CI was run.
- Include the command used, exit status, and result summary.
- Use `N/A` only when Governance CI was not applicable or was explicitly out of scope, and explain why.

### 9. Unexpected Changes

- Disclose dirty worktree entries, unrelated changes, generated files, or files changed outside scope.
- Use `N/A - no unexpected changes found` when none were found.

### 10. Remaining Concerns

- List unresolved risks, follow-up checks, or known limitations.
- Use `N/A` if none remain.

### 11. MUST FIX

- List blockers that must be fixed before Ready for commit or completion.
- Use `N/A` if there are no blockers.

### 12. SHOULD FIX

- List non-blocking improvements that should be considered soon.
- Use `N/A` if none.

### 13. FUTURE IMPROVEMENT

- List deferred improvements that are not part of the current task.
- Use `N/A` if none.

### 14. READY / NOT READY Verdict

- State exactly one: `READY` or `NOT READY`.
- `READY` requires scoped changes, validation evidence, and final `git status --short`.
- `NOT READY` requires a short reason and next action.

## Completion Rules

- Require validation evidence for implementation-approved work.
- Require final `git status --short` after changes.
- Require explicit modified-file listing.
- Require explicit `N/A` instead of omitted sections.
- Forbid claiming completion without validation output or an explained validation exception.
- Do not treat skipped review, context packet generation, prompt templates, or this template as approval.

## Non-Goals

- This template does not run checks.
- This template does not approve implementation.
- This template does not replace A6_REVIEW, A8_OUTPUT_CHECKER, Governance CI, or human approval.
- This template does not create a new harness framework.
