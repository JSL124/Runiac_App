# Codex Implement Approved Plan

Use this prompt only after the user explicitly approves the final plan.

Use A0_ORCH as the workflow owner. Implement only the approved scope from the final plan. Do not broaden scope. Do not modify PRD, submitted PDD, or unrelated files unless the approved plan explicitly says to do so.

Before edits:

- Run `git status --short`.
- Identify unrelated existing changes and leave them unstaged.
- Reconfirm the approved files and untouched files.

During implementation:

- Follow the closest `AGENTS.md`.
- Keep Flutter tests inside the future Flutter app root when applicable.
- Keep Firebase CLI/generated files out of scope unless explicitly approved.
- Preserve backend ownership of XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, entitlement checks, and expert-plan governance.
- Preserve `subscriptionStatus` for Basic/Premium and `userRole` for operational/governance roles.

After edits:

- Run `git status --short`.
- Run only checks approved by the plan.
- Do not run `git add`, `git commit`, or `git push`.

Output:

## Files Changed

## Checks Run

## Git Status

## Suggested Git Commands
