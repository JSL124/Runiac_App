# Runiac Agent Review Profile

This profile contains the Runiac-specific prompts and example settings used by the generic `tools/agent-review/runner/` shell runner.

## Files

- `agent-review.env.example` defines the default prompt and output artifact paths for Runiac.
- `prompts/01_codex_create_plan.md` asks Codex to create an inspect-only plan.
- `prompts/02_claude_review_plan.md` asks Claude to review that plan with read-only tools in standard mode.
- `prompts/03_codex_final_review_decision.md` asks Codex to accept, reject, or defer Claude feedback.
- `prompts/04_codex_implement_approved_plan.md` is used only after explicit user approval for implementation.
- `prompts/05_claude_review_plan_lite.md` asks Claude for a concise low-risk review in lite mode.

Plans created by `prompts/01_codex_create_plan.md` must include a `Review Scope` section. The scope lists expected changed files, likely review reads, out-of-scope files, risk tags, and a recommended review mode so Claude can review efficiently. Standard review should use that scope first and return `DEFER` with requested additional paths instead of scanning broadly when the scope is insufficient.

## Usage

The runner defaults to this profile:

```bash
TASK_PROMPT="Profile migration smoke test only. Do not modify files." \
tools/agent-review/runner/run_plan_review.sh pipeline
```

To select it explicitly:

```bash
AGENT_REVIEW_PROFILE=runiac \
TASK_PROMPT="Profile migration smoke test only. Do not modify files." \
tools/agent-review/runner/run_plan_review.sh pipeline
```

`DRY_RUN=1` remains the default, so the smoke test prints the plan-review-decision command preview without invoking Codex or Claude.

## Review Modes

`REVIEW_MODE=standard` is the default and uses `prompts/02_claude_review_plan.md`.

`REVIEW_MODE=lite` uses `prompts/05_claude_review_plan_lite.md` only when `REVIEW_PROMPT` is not explicitly set:

```bash
REVIEW_MODE=lite \
TASK_PROMPT="Lite mode smoke test only. Do not modify files." \
tools/agent-review/runner/run_plan_review.sh pipeline
```

If `REVIEW_PROMPT` is set in the environment or a config file, it takes precedence over `REVIEW_MODE`.

Use standard mode instead of lite mode for changes touching XP, streak, level, rank, leaderboard, roles, entitlements, premium fairness, Firebase ownership, Cloud Functions ownership, security rules, or submitted PDD / PRD consistency.

## Claude Review Cost Caps

The runner applies these caps only to the Claude review step:

```bash
CLAUDE_MAX_TURNS=12
CLAUDE_MAX_BUDGET_USD=0.50
```

`CLAUDE_MAX_TURNS` limits review turns. `CLAUDE_MAX_BUDGET_USD` limits review spend in US dollars. Low caps may cause Claude review to stop early before completing the requested scope.

Do not rely only on `claude --help` output to verify these flags; check local compatibility with a minimal print-mode Claude command before enabling actual runs.
