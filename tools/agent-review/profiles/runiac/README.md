# Runiac Agent Review Profile

This profile contains the Runiac-specific prompts and example settings used by the generic `tools/agent-review/runner/` shell runner.

## Files

- `agent-review.env.example` defines the default prompt and output artifact paths for Runiac.
- `context-policy.yml` documents schema-only Runiac context selection policy for future integration.
- `prompts/01_codex_create_plan.md` asks Codex to create an inspect-only plan.
- `prompts/02_claude_review_plan.md` asks Claude to review that plan with read-only tools in standard mode.
- `prompts/03_codex_final_review_decision.md` asks Codex to accept, reject, or defer Claude feedback.
- `prompts/04_codex_implement_approved_plan.md` is used only after explicit user approval for implementation.
- `prompts/05_claude_review_plan_lite.md` asks Claude for a concise low-risk review in lite mode.

Plans created by `prompts/01_codex_create_plan.md` must include a `Review Scope` section. The scope lists expected changed files, likely review reads, out-of-scope files, risk tags, and a recommended review mode so Claude can review efficiently. Standard review should use that scope first and return `DEFER` with requested additional paths instead of scanning broadly when the scope is insufficient.

Review mode controls review depth, not context breadth. Context breadth is controlled by Context Class, Plan Scope, Review Scope, and explicit Allow paths. Lite review is low-risk and plan-first; standard review is deeper within the approved scope.

## Context Policy

`context-policy.yml` documents Runiac-specific context policy. It is schema-only in this batch: no runner reads it yet, and no YAML parsing or context packet builder has been added.

The policy keeps Runiac always-on invariants in `non_negotiable_invariants`, including backend ownership for XP/streak/level/rank/leaderboard, Basic/Premium access through `subscriptionStatus`, operational/governance roles through `userRole`, expert-plan draft submission by Medical Trainer/Expert, Platform Administrator approval/publishing authority, and the rule that AI/LLM must not become official XP/rank/leaderboard logic.

Class-specific allowed paths live under `allowed_paths`. Workflow scope is limited to `tools/agent-review/**` and `.claude/settings.json`; docs scope is Markdown documentation; implementation preparation includes traceability, `PRD.md`, and PDD Markdown; feature/security/architecture scopes add the relevant implementation, Firebase, and PDD areas.

Within each context class, `allowed_path_keys` may reference named `allowed_paths` groups or the top-level `always_read` list. Future schema validation must reject unknown references before runner integration.

Excluded paths document sensitive, large, and generated areas. Runiac policy excludes submitted artifacts, PDFs, images, SVGs, dependency/build folders, Dart tool output, test evidence, `.env` files, and `secrets/**` from default context breadth.

Before any parser or context packet builder treats Runiac policy as authoritative, validate required top-level keys, `schema_version`, context class keys, `allowed_path_keys` references, `allowed_paths` groups, `excluded_paths` groups, `review_file_budgets`, `unknown_context_behavior`, and `explicit_allow_behavior`.

`context-policy.yml` remains schema-only until that parser or context packet builder is explicitly added.

External review on/off behavior is documented in the top-level README. For Runiac, `REVIEW_ENABLED=0` is an explicit skip, not approval, and should not be used for high-risk areas such as XP, leaderboard, roles, entitlements, Firebase/Cloud Functions ownership, security rules, production source code, or PRD/PDD consistency.

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

Compact workflow smoke-test plan:

- Use concise bullets.
- Avoid long explanatory sections.
- Summarize evidence instead of expanding every detail.
- Avoid repeating the same excluded paths in multiple sections.
- Avoid listing more than 3 representative files under `Files actually read` unless necessary.
- Avoid listing more than 3 representative files under `Files Claude may need to read for review` for lite review.
- If more files are needed, recommend standard review or `DEFER`.

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

Lite review reads the Codex plan first, prefers judging from plan content only, and reads project files only when needed to identify a `MUST_FIX` issue. For workflow smoke tests, lite review should read at most 2-3 representative files besides the plan and must return `DEFER` with standard mode recommended when broader validation is needed.

## Claude Review Cost Caps

The runner applies these caps only to the Claude review step:

```bash
CLAUDE_MAX_TURNS=12
CLAUDE_MAX_BUDGET_USD=0.50
```

`CLAUDE_MAX_TURNS` limits review turns. `CLAUDE_MAX_BUDGET_USD` limits review spend in US dollars. Low caps may cause Claude review to stop early before completing the requested scope.

Do not rely only on `claude --help` output to verify these flags; check local compatibility with a minimal print-mode Claude command before enabling actual runs.
