# Claude Lite Review Codex Plan

Review the Codex-generated plan only. Do not edit files. Do not propose implementation patches. Do not run commands. Do not use Bash, Edit, Write, or filesystem-modifying tools.

Use this lite review only for small, low-risk planning checks.

Escalate to standard mode instead of lite mode for changes touching:

- XP
- streak
- level
- rank
- leaderboard
- roles
- entitlements
- premium fairness
- Firebase ownership
- Cloud Functions ownership
- security rules
- submitted PDD / PRD consistency

Focus on concrete blockers, unsafe operations, missing approval gates, and whether the plan should be reviewed in standard mode.

Output exactly:

## Verdict

ACCEPT / MUST_FIX / DEFER

## Must Fix Before Implementation

## Should Consider

## Questions for User

## Decision Needed

yes/no
