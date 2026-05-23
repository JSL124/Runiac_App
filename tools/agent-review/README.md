# Agent Review Workflow

This folder defines a generic local runner plus project profiles for plan review before implementation. The current default profile is `runiac`.

1. Codex creates an inspect-only plan.
2. Claude Code reviews that plan in read-only plan-review mode.
3. Codex performs final review, accepts/rejects/deferred Claude feedback, and produces the final plan.
4. Codex implements only after explicit user approval.
5. The user performs `git add`, `git commit`, and push manually.

The workflow is local to this repository for now. Do not create a separate repo, Git submodule, package, or GitHub Actions workflow yet.

## Structure

```text
tools/agent-review/
  runner/
    run_plan_review.sh
    lib/
      common.sh
  profiles/
    runiac/
      README.md
      agent-review.env.example
      prompts/
        01_codex_create_plan.md
        02_claude_review_plan.md
        03_codex_final_review_decision.md
        04_codex_implement_approved_plan.md
```

- `runner/` contains generic shell helpers and subcommands. It should not include Runiac PRD/PDD/business rules.
- `profiles/<name>/` contains project-specific prompts and example settings.
- `profiles/runiac/` contains the Runiac prompt set and artifact path defaults.

## Runner Usage

Manual step-by-step usage remains supported:

```bash
tools/agent-review/runner/run_plan_review.sh plan
tools/agent-review/runner/run_plan_review.sh review
tools/agent-review/runner/run_plan_review.sh decision
tools/agent-review/runner/run_plan_review.sh implement
```

The `pipeline` subcommand is a conservative convenience wrapper for only:

```text
plan -> review -> decision
```

It runs Codex inspect-only planning, Claude read-only plan review, and Codex final decision, then prints the generated `PLAN_FILE`, `REVIEW_FILE`, `DECISION_FILE`, `git status --short`, and reminders that implementation was not run.

Dry-run preview:

```bash
TASK_PROMPT="Pipeline smoke test only. Do not modify files." \
tools/agent-review/runner/run_plan_review.sh pipeline
```

Actual run:

```bash
DRY_RUN=0 \
TASK_PROMPT="$(cat /tmp/task.md)" \
tools/agent-review/runner/run_plan_review.sh pipeline
```

You can also provide a task prompt file when `TASK_PROMPT` is unset:

```bash
DRY_RUN=0 \
TASK_PROMPT_FILE=/tmp/task.md \
tools/agent-review/runner/run_plan_review.sh pipeline
```

If both `TASK_PROMPT` and `TASK_PROMPT_FILE` are set, `TASK_PROMPT` is used and `TASK_PROMPT_FILE` is ignored.

The runner defaults to `AGENT_REVIEW_PROFILE=runiac`, which resolves prompts under:

```text
tools/agent-review/profiles/runiac/prompts/
```

You can select another profile by setting `AGENT_REVIEW_PROFILE` or by setting `AGENT_REVIEW_PROFILE_DIR` directly:

```bash
AGENT_REVIEW_PROFILE=runiac \
tools/agent-review/runner/run_plan_review.sh plan
```

Use `AGENT_REVIEW_CONFIG` only when you need to override prompt or artifact paths:

```bash
AGENT_REVIEW_CONFIG=tools/agent-review/profiles/runiac/agent-review.env.example \
tools/agent-review/runner/run_plan_review.sh plan
```

On failure, `pipeline` stops at the failed step (`plan`, `review`, or `decision`) and does not continue. It never falls back from Claude to Codex review and never starts implementation.

`pipeline` does not run implementation, `git add`, `git commit`, `git push`, tests, builds, deployment, Flutter, Firebase, or npm commands. Implementation remains a separate, user-approved step after inspecting the decision file.

## Backward Compatibility

Runiac prompts moved from:

```text
tools/agent-review/prompts/runiac/
```

to:

```text
tools/agent-review/profiles/runiac/prompts/
```

The Runiac env example moved from:

```text
tools/agent-review/config/runiac.agent-review.env.example
```

to:

```text
tools/agent-review/profiles/runiac/agent-review.env.example
```

If `AGENT_REVIEW_CONFIG` points to the old Runiac env example path and that file is no longer present, the runner falls back to the new profile env example. If an older local config still points prompt variables at the old `prompts/runiac/` files, the runner maps those prompt paths to the new profile prompt files when the old files are absent.

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
claude -p "$(cat tools/agent-review/profiles/runiac/prompts/02_claude_review_plan.md)" \
  --permission-mode plan \
  --tools "Read,Grep,Glob" \
  --append-system-prompt "$(cat CLAUDE.md)"
```

Do not allow Claude review mode to use Bash, Edit, Write, filesystem-modifying tools, `dangerously-skip-permissions`, `bypassPermissions`, `auto`, or `acceptEdits` modes.

## Future

After 3-5 real planning tasks, review whether the runner logic is stable enough to externalize. Do not create a separate repo, Git submodule, package, or GitHub Actions workflow yet.
