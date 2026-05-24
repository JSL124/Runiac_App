# Codex Final Review Decision

Use A0_ORCH as the workflow owner.

Read the original Codex plan and the review artifact provided as `REVIEW_FILE`. You are reviewing a plan created in a separate Codex run. Do not defend the original plan. Evaluate the review provider output on its merits against applicable repo instructions, the plan's context class, Plan Scope, Review Scope, and any explicitly allowed reference paths. Default to Accept unless there is specific repo-context evidence for Reject or Defer.

If the provided REVIEW_FILE contains `Status: SKIPPED`, external review was explicitly skipped. You are the sole reviewer.

- Validate skipped/completed review status from REVIEW_FILE content, not from a runner environment variable.
- Treat Gemini, Claude, Codex fallback, and skipped-review artifacts as review provider outputs.
- Explicitly note external review was skipped.
- Apply elevated self-critique.
- Do not treat skipped review as approval.
- Do not treat `REVIEW_PROVIDER`, `REVIEW_ENABLED=0`, or `REVIEW_MODE` as approval.
- Do not approve implementation automatically.
- The decision artifact must include:
  - `## External Review Status`
  - `- Status: SKIPPED`
  - `- Self-critique applied: yes/no`

Do not modify, create, delete, stage, commit, run tests, run builds, run Flutter, run Firebase, run npm, deploy, or execute implementation commands.

Check the context protocol before producing the final recommendation:

- Whether the review provider accepted or challenged the `Context Class Decision`.
- Whether `Plan Scope` and `Review Scope` stayed consistent.
- Whether the plan respected the Review Scope budget and kept review files minimal.
- Whether requested additional scope requires explicit user approval.
- Whether the final implementation prompt should preserve the same `Plan Scope` and `Review Scope` boundaries.
- Whether `DEFER` is required because the class is wrong, the scope is too narrow, or sensitive/reference paths need explicit approval.

Decision meanings:

- Accept: incorporate the feedback into the final plan.
- Reject: do not incorporate, with concrete repo-context evidence.
- Defer: valid concern, but out of scope for the next implementation step.

Include this table:

| Reviewer Feedback | Decision | Reason | Final Action |
| --- | --- | --- | --- |

Output using exactly these headings:

## Final Recommendation

## Reviewer Feedback Decision Table

## Revised Final Plan

## Final Scope Boundaries

## Files To Modify If Approved

## Files To Keep Untouched

## Implementation Prompt For Later

## User Approval Required
