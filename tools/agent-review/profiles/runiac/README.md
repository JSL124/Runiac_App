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

## Context Selection

Runiac uses the generic progressive context selection protocol: cheap inventory, user-declared or conservative context class, `Plan Scope`, inspect-only plan, `Review Scope`, scope-limited Claude review, and final Codex decision.

Supported context classes are `workflow`, `docs`, `implementation_prep`, `feature`, `security`, `architecture`, and `unknown`. Prefer a user-declared class. If Codex infers the class, it must explain why in 1-2 sentences. `unknown` must stop with clarification/escalation instead of broad scanning.

Runiac separates two layers:

- Layer A: always-on Runiac invariants. XP/streak/level/rank/leaderboard stay backend-owned; Flutter may display trusted values but must not write official XP/rank/leaderboard values; `subscriptionStatus` controls Basic/Premium access; `userRole` controls operational/governance roles; Medical Trainer/Expert submits draft expert plans only; Platform Administrator approves/rejects/publishes/archives expert plans; AI/LLM must not become official XP/rank/leaderboard logic; no secrets, API keys, production project IDs, or precise private GPS data should be committed.
- Layer B: class-specific context scope. For `workflow`, use runner scripts, agent prompts, workflow docs, `.claude/settings.json`, and process automation only; do not read PRD/PDD, submitted assessment docs, PDFs, images, diagrams, generated assets, Flutter/Firebase source, tests, or test evidence unless the user provides explicit Allow paths.

For `docs`, read only directly relevant docs and local instructions. For `implementation_prep`, selectively read PRD/PDD markdown if needed. For `feature`, `security`, and `architecture`, consult requirement and architecture references as needed while avoiding broad scans and large/generated assets. Review Scope must stay inside Plan Scope allowed paths or explicit Allow paths.

`Planning Evidence Read` records files actually read, files intentionally skipped, and why large/reference/irrelevant files were skipped.

Token/Context Discipline: avoid reading long files unless directly required, avoid dumping large file contents into the plan, summarize findings, and keep inspect-only workflow plans concise.

Review Scope is not an inventory list. `Files Claude may need to read for review` should be minimal. For `workflow` context, include at most 6 review files unless explicit expanded review is allowed. Inspect-only workflow smoke tests should use representative files only, not every prompt/config/runner file.

DEFER recovery: add explicit Allow paths when the class is too restrictive, re-run with the correct class when the class is wrong, split oversized plans, or approve exact sensitive/reference paths when needed.

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
