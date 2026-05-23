# Agent Review Workflow

This folder defines a Runiac-local workflow for plan review before implementation:

1. Codex creates an inspect-only plan.
2. Claude Code reviews that plan in read-only plan-review mode.
3. Codex performs final review, accepts/rejects/deferred Claude feedback, and produces the final plan.
4. Codex implements only after explicit user approval.
5. The user performs `git add`, `git commit`, and push manually.

The workflow is local to this repository for now. Do not create a separate repo, Git submodule, package, or GitHub Actions workflow yet.

## Layers

- `runner/` contains generic shell helpers and subcommands. It should not include Runiac PRD/PDD/business rules.
- `prompts/runiac/` contains Runiac-specific prompts for Codex and Claude.
- `config/` contains project-specific example settings.

## Safety

The runner uses subcommands instead of an automatic loop. It defaults to `DRY_RUN=1`; use `DRY_RUN=0` only when you intentionally want it to invoke Codex or Claude. In dry-run mode, if configured output directories do not exist, the runner prints the command preview to stdout instead of creating directories. Actual runs create configured output directories and refuse to overwrite existing output files.

Command examples use read-only Codex execution for plan and decision steps:

```bash
codex --sandbox read-only --ask-for-approval never -C . exec
```

First implementation runs should use interactive Codex only after explicit user approval:

```bash
codex --sandbox workspace-write --ask-for-approval on-request -C .
```

The workflow forbids `danger-full-access` and forbids combining `workspace-write` with `--ask-for-approval never`.

Claude plan review must use read-only tools:

```bash
claude --bare -p "$(cat tools/agent-review/prompts/runiac/02_claude_review_plan.md)" \
  --permission-mode plan \
  --tools "Read,Grep,Glob" \
  --append-system-prompt "$(cat CLAUDE.md)"
```

Do not allow Claude review mode to use Bash, Edit, Write, filesystem-modifying tools, `dangerously-skip-permissions`, `bypassPermissions`, `auto`, or `acceptEdits` modes.

## Future

After 3-5 real planning tasks, review whether the runner logic is stable enough to externalize. Do not create a separate repo, Git submodule, package, or GitHub Actions workflow yet.
