# Runiac Agent Review Profile

This profile contains the Runiac-specific prompts and example settings used by the generic `tools/agent-review/runner/` shell runner.

## Files

- `agent-review.env.example` defines the default prompt and output artifact paths for Runiac.
- `prompts/01_codex_create_plan.md` asks Codex to create an inspect-only plan.
- `prompts/02_claude_review_plan.md` asks Claude to review that plan with read-only tools.
- `prompts/03_codex_final_review_decision.md` asks Codex to accept, reject, or defer Claude feedback.
- `prompts/04_codex_implement_approved_plan.md` is used only after explicit user approval for implementation.

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
