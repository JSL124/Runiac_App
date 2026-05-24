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
    build_context_packet.sh
    classify_high_risk_task.sh
    run_plan_review.sh
    lib/
      common.sh
  profiles/
    generic/
      README.md
      context-policy.yml
    runiac/
      README.md
      context-policy.yml
      agent-review.env.example
      prompts/
        01_codex_create_plan.md
        02_claude_review_plan.md
        03_codex_final_review_decision.md
        04_codex_implement_approved_plan.md
        05_claude_review_plan_lite.md
```

- `runner/` contains generic shell helpers and subcommands. It should not include Runiac PRD/PDD/business rules.
- `profiles/<name>/` contains project-specific prompts and example settings.
- `profiles/generic/` contains a reusable schema template with no project-specific invariants.
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

Codex plans must include a `Review Scope` section. This gives Claude a focused list of expected changes, files worth reading, out-of-scope paths, risk tags, and the recommended review mode so review does not require unnecessary repository scanning. Standard review is still risk-aware, but it should stay inside the Review Scope and return `DEFER` with requested additional paths when the scope is not enough.

Review mode controls review depth, not context breadth. Context breadth is controlled by Context Class, Plan Scope, Review Scope, and explicit Allow paths. Lite review is low-risk and plan-first; standard review is deeper within the approved scope, but it should not broaden context on its own.

## Context Policy Files

Profile `context-policy.yml` files are read by `build_context_packet.sh` only. `run_plan_review.sh` does not parse YAML directly; when `CONTEXT_PACKET_ENABLED=1`, it calls the builder and uses the generated Markdown packet.

With `CONTEXT_PACKET_ENABLED=0`, which is the default, prompts and human review remain authoritative and current runner behavior is preserved.

The schema separates:

- Layer A: `non_negotiable_invariants`, always-on domain rules.
- Layer B: `allowed_paths` and `excluded_paths`, class-specific context scope.

Within `context_classes`, `allowed_path_keys` may refer to either named groups under `allowed_paths` or the top-level `always_read` list. Future integration must resolve both reference types explicitly.

Review mode controls review depth, not context breadth. Context breadth is controlled by context class, allowed paths, excluded paths, and explicit `Allow: <path>` entries. `unknown_context_behavior: "reject"` means unknown context must not auto-expand into feature, security, or architecture scope.

Before any runner integration treats `context-policy.yml` as authoritative, add schema validation for required top-level keys, `schema_version`, context class keys, `allowed_path_keys` references, `allowed_paths` groups, `excluded_paths` groups, `review_file_budgets`, `inventory_limits`, `unknown_context_behavior`, and `explicit_allow_behavior`.

The generic profile must not contain project-specific invariants. Project profiles may add domain-specific invariants and forbidden content patterns.

## build_context_packet.sh

`tools/agent-review/runner/build_context_packet.sh` is a standalone context packet builder for generic agent-review context selection. It can be run directly, and `run_plan_review.sh` can optionally call it before Codex inspect-only planning when `CONTEXT_PACKET_ENABLED=1`.

The builder converts a task prompt plus a profile `context-policy.yml` into a bounded Markdown packet. It keeps context selection separate from review execution: the packet guides planning context, while `REVIEW_MODE` continues to control review depth and `REVIEW_ENABLED` continues to control whether external review runs.

Standalone usage:

```bash
TASK_PROMPT="Context packet smoke test only. Context Class: workflow" \
CONTEXT_CLASS=workflow \
PROFILE=runiac \
tools/agent-review/runner/build_context_packet.sh
```

Inputs:

- `PROFILE`, default `runiac`.
- `TASK_PROMPT` or `TASK_PROMPT_FILE`.
- `CONTEXT_CLASS`, optional.
- `ALLOW_PATHS`, optional comma-separated list.
- `REVIEW_ENABLED`, optional, default `1`.
- `REVIEW_MODE`, optional, default from context policy class metadata when available; otherwise `standard`.

The script reads only `tools/agent-review/profiles/<PROFILE>/context-policy.yml` content plus shell metadata from `git status --short` and limited `git ls-files`. It does not read PRD/PDD/PDF/image/source file contents, does not write files by default, and does not run Codex, Claude, Flutter, Firebase, npm, tests, builds, deployment, `git add`, `git commit`, or `git push`.

The script validates the policy in two steps:

- YAML syntax validation with Ruby stdlib `YAML.load_file`.
- Required top-level key validation for `schema_version`, `context_classes`, `always_read`, `allowed_paths`, `excluded_paths`, `review_file_budgets`, `inventory_limits`, `unknown_context_behavior`, `explicit_allow_behavior`, `non_negotiable_invariants`, and `forbidden_content_patterns`.

If Ruby is unavailable, the script fails clearly. It does not require `yq`, npm, Python packages, Firebase, Flutter, or external dependencies.

Design boundary:

- The builder remains standalone and may be used directly.
- Runner integration is opt-in through `CONTEXT_PACKET_ENABLED=1`; `CONTEXT_PACKET_ENABLED=0` preserves current behavior.
- Do not add `PLAN_CONTEXT`, high-risk auto-routing, review skip guards based on policy, context-policy schema migration, or implementation auto-run.

The builder output is a Markdown packet with these schemas.

`Context Class Decision`:

- `selected_class`: one of `context_classes`.
- `reason`: 1-2 sentence explanation.
- `excluded_classes_considered`: informational, not exhaustive.
- `source`: `user-declared | inferred`.
- If `source` is `user-declared`, `excluded_classes_considered` may be `N/A — user explicitly declared class.`

`Plan Scope`:

- `allowed_planning_paths`: list of paths Codex may inspect during planning.
- `excluded_planning_paths`: list of paths blocked or excluded during planning.
- `inventory_summary`: compact inventory output.
- `applied_invariants`: all `non_negotiable_invariants` from the profile.
- Do not filter `non_negotiable_invariants` by context class.
- If the invariant list is large, group by category instead of dumping a long flat list.

`Review Budget Hint`:

- `review_enabled`: `1 | 0`.
- `review_mode`: `lite | standard`.
- `file_budget`: integer from `review_file_budgets`.
- `skip_reason_required`: `yes | no`.

`Forbidden Content Pattern Summary`:

- Include the description for each category from `forbidden_content_patterns`.
- Do not dump raw regex, grep, or scanner patterns into the packet.
- If a category has more than 5 patterns, summarize it as `<category description> (N patterns, see context-policy.yml)`.

Cheap inventory protocol:

- Use shell-level discovery before file content reads.
- File content reads happen only after inventory is built, the context class is decided, and target paths are validated against `allowed_paths` and explicit Allow paths.
- Inventory output itself counts toward token budget, so limits are mandatory.

Examples:

```bash
git status --short
git ls-files | head -<max_listed_files>
find . -maxdepth <max_directory_depth> -type f | head -<max_listed_files>
```

`inventory_limits` are documented defaults for future integration:

- `max_listed_files`: maximum listed paths retained in the packet inventory.
- `max_directory_depth`: maximum directory depth for fallback `find` discovery.
- `max_inventory_bytes`: maximum inventory bytes retained before truncation.

The standalone builder uses these values for packet inventory limits. The runner does not parse these values directly.

Standalone partial failure behavior has three tiers.

Hard stop:

- Unknown context class when `unknown_context_behavior` is `reject`.
- Invalid YAML syntax.
- Missing required schema keys.
- All Allow paths invalid.
- `REVIEW_ENABLED=0` without `SKIP_REASON`.
- Required schema keys without documented defaults are missing.

Soft handling:

- Some Allow paths invalid: warn, drop invalid ones, and continue with valid ones.
- Inventory exceeds `max_listed_files` or `max_inventory_bytes`: truncate with an explicit `truncated` marker.
- Optional schema keys missing: use documented defaults only if the default is explicitly documented.

User confirmation required:

- Allow paths point into `excluded_paths`; standalone mode warns and marks them `[OVERRIDE]`, while runner integration may require explicit confirmation later.
- Sensitive paths are requested.
- Broad scope expansion is requested after `DEFER`.
- Review skip is requested for high-risk work.

DEFER recovery design intent:

- The user may re-run with explicit Allow paths.
- The user may split the plan into smaller plans.
- The user may escalate from `REVIEW_MODE=lite` to `REVIEW_MODE=standard`.
- The builder re-runs from the start.
- Do not implement automatic DEFER re-run in this batch.

Packet output format:

- Markdown.
- Stdout by default.
- Optional future `--output <path>`.
- Packet sections:
  - `## Context Class Decision`
  - `## Plan Scope`
  - `## Review Budget Hint`
  - `## Forbidden Content Pattern Summary`
  - `## Inventory`
- When `CONTEXT_PACKET_ENABLED=1`, the runner prepends this packet to the original task prompt before Codex inspect-only planning.

Future tool-smoke-test artifacts should be stored at:

```text
implementation/traceability/tool-smoke-tests/<timestamp>_context-packet-smoke.md
```

Do not create that folder or artifact from the standalone builder by default.

## Context packet runner integration

This section documents the implemented opt-in runner integration. It does not change default pipeline behavior and does not add a high-risk auto-routing guard.

Opt-in behavior:

- `CONTEXT_PACKET_ENABLED=0` by default. `context-packet-opt-in`
- `CONTEXT_PACKET_ENABLED=0` preserves current pipeline behavior.
- `CONTEXT_PACKET_ENABLED=1` enables context packet generation before the Codex plan step.
- Supported values are only `1` and `0`; unsupported values fail clearly.
- Context packet builder integration remains opt-in.

Execution order when enabled:

1. Validate task prompt. `context-packet-execution-order`
2. Run `build_context_packet.sh`.
3. Capture the Markdown packet.
4. Check packet size against the 8000 byte limit.
5. Combine the packet with the original task prompt.
6. Run the existing Codex inspect-only plan step.
7. Continue existing `REVIEW_ENABLED` / `REVIEW_MODE` behavior.

Task prompt validation boundary:

- The task prompt must be non-empty. `task-prompt-validation-boundary`
- The runner should not duplicate context class detection logic.
- Missing context class failure should be handled inside `build_context_packet.sh` through `unknown_context_behavior=reject`.
- The runner validates only basic task prompt presence before calling the builder.

YAML reader boundary:

- `build_context_packet.sh` remains the only component that reads `context-policy.yml`. `yaml-reader-builder-only`
- `run_plan_review.sh` calls the builder and does not parse YAML directly.

Failure behavior:

- If `CONTEXT_PACKET_ENABLED=1` and the builder fails, the pipeline stops. `broad-scan-fallback-forbidden`
- Do not fall back to broad repo scanning.
- Do not silently continue without the packet.
- Missing context class should fail through the builder unless the user provides `CONTEXT_CLASS` or the task prompt contains `Context Class`.

Packet size limit:

- Recommended maximum packet size: 8000 bytes. `packet-size-limit`
- Rationale: the packet should guide planning, not dominate the task prompt.
- If the packet exceeds 8000 bytes, fail clearly and tell the user to reduce scope with a narrower `CONTEXT_CLASS` or fewer `ALLOW_PATHS`.
- Do not silently truncate the Codex prompt.
- Future configuration via `context-policy.yml` may be added later.

Prompt capture and injection:

- The runner captures `build_context_packet.sh` stdout to a shell variable.
- Combined prompt structure: `prompt-not-mutated`

```text
[Context Packet Markdown]
---
[Original Task Prompt]
```

- Both parts must be present.
- The Codex plan phase receives the combined prompt.
- The original task prompt must not be mutated, overwritten, or dropped.

Review variable separation:

- `CONTEXT_PACKET_ENABLED` controls planning context. `review-variable-separation`
- `REVIEW_ENABLED` controls external review on/off.
- `REVIEW_MODE` controls review depth only when review is enabled.
- These variables must remain separate.

Future smoke tests:

- F1: `CONTEXT_PACKET_ENABLED=0` dry-run regression. `dry-run-integration-matrix`
- F2: `CONTEXT_PACKET_ENABLED=1` dry-run integration.
- F3a: `CONTEXT_PACKET_ENABLED=1` + `REVIEW_ENABLED=0` + `DRY_RUN=1` integrated dry-run.
- F3b: `CONTEXT_PACKET_ENABLED=1` + `REVIEW_ENABLED=0` + `DRY_RUN=0` actual smoke test.
- F4: missing context class failure test.

## External Review On/Off Policy

The runner supports `REVIEW_ENABLED` for explicitly running or skipping the external Claude review step. There is no `REVIEW_PROVIDER=none`, there is no `REVIEW_MODE=off`, and implementation is not auto-run from this policy.

`REVIEW_ENABLED` controls whether an external review step runs. `REVIEW_MODE` controls review depth only when external review is enabled. `REVIEW_MODE` remains `lite|standard`; do not use `REVIEW_MODE=off`.

Defaults:

- For `pipeline`, `REVIEW_ENABLED=1` by default.
- `REVIEW_MODE=standard` remains the default depth when review is enabled.
- Low-risk workflow/documentation tasks may use `REVIEW_ENABLED=0`.
- High-risk tasks should keep review enabled.

Behavior:

- `REVIEW_ENABLED=1` runs the existing Claude review step.
- `REVIEW_ENABLED=0` explicitly skips the external Claude review step.
- Supported values are only `1` and `0`; any other value fails before agent commands run.
- Skipping review must never be silent.
- Skipping review must never be treated as approval.
- Skipping review must never auto-run implementation.

Skip review justification:

- `REVIEW_ENABLED=0` must require a non-empty `SKIP_REASON` environment variable or equivalent future flag.
- Missing `SKIP_REASON` is a hard stop.
- `SKIP_REASON` is stored verbatim in the skipped-review artifact.
- This prevents accidental skipping when `REVIEW_ENABLED=0` remains in the shell environment.

Skipped-review artifact specification:

- Location: `implementation/traceability/reviews/`
- Filename: `<timestamp>_external_review_skipped.md`
- The artifact must be created before Codex final decision so the decision phase can reference it.
- For `REVIEW_ENABLED=0`, the skipped-review artifact path is assigned to `REVIEW_FILE`, using the same decision-phase passing convention as completed Claude reviews.
- Required sections:
  - `External Review Status`
  - `Status: SKIPPED`
  - `Reason: <SKIP_REASON>`
  - `Context Class at Time of Skip`
  - `Risk Tags at Time of Skip`
  - `Skip Justification`
  - `Implications`
  - `Codex decision proceeds without external validation.`
  - `Implementation still requires explicit user approval.`
  - `Claude review was not run.`
  - `This skipped review is not approval.`
  - `Codex final decision must treat this as an unreviewed plan and apply elevated self-critique.`

Codex final decision behavior when review is skipped:

- Decision phase still runs.
- Input is Codex plan plus the skipped-review artifact.
- Decision prompt must explicitly state: "External review was explicitly skipped. You are the sole reviewer."
- Decision must apply elevated self-critique.
- Decision artifact must include `External Review Status: SKIPPED`.
- Decision artifact must include `Self-critique applied: yes/no`.

Implementation gating when review is skipped:

- Runner does not chain implementation after skipped review.
- Even if a future auto-implement flag exists, skipped review blocks chained implementation.
- User must run implementation as a separate explicit invocation.
- High-risk plus skipped review should block implementation entirely unless a future explicit override mechanism is added.

High-risk classification responsibility:

- Primary future responsibility: runner compares plan risk tags and changed paths against `context-policy.yml` signals, including `non_negotiable_invariants`, feature/security paths, and `forbidden_content_patterns`.
- Secondary signal: user may declare `Risk: high` or `Risk: low` in task input.
- If user-declared and runner-detected risk disagree, runner-detected risk wins and warns the user.
- Codex self-classification alone must not be authoritative because of self-serving bias risk.

High-risk areas where external review should not be skipped:

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
- production source code
- PRD/PDD consistency

Safe skip candidates:

- README-only changes
- prompt wording cleanup
- schema-only documentation
- traceability documentation
- workflow smoke-test evidence
- non-production process automation notes

## High-Risk Guard

`tools/agent-review/runner/classify_high_risk_task.sh` is a deterministic local guard that checks explicit task input before Codex planning and before implementation prompts. It does not use an LLM, scan the repository, inspect secret contents, parse `context-policy.yml`, or replace human approval.

Controls:

- `HIGH_RISK_GUARD_ENABLED=1` by default. Set to `0` only with explicit approval; the runner prints a warning when disabled.
- `HIGH_RISK_APPROVED=0` by default. Set to `1` only after explicit user approval for a known high-risk task.
- `HIGH_RISK_REASON` is required when `HIGH_RISK_APPROVED=1`.

Guard output includes:

- `HIGH_RISK_LEVEL=none|warning|block`
- `HIGH_RISK_SIGNALS=<comma-separated signals or none>`
- `HIGH_RISK_APPROVAL_REQUIRED=yes|no`
- `HIGH_RISK_MESSAGE=<short explanation>`

Block-level signals stop the runner, including dry-runs, unless `HIGH_RISK_APPROVED=1` and `HIGH_RISK_REASON` is non-empty. This is intentional because dry-runs validate the command flow before real runs.

The guard currently detects explicit high-risk paths, commands, and Runiac domain risks, including submitted assessment paths, PRD/PDD baselines, Flutter/Firebase scaffolding, Firebase rules/config/functions, secrets/env/API key/project ID wording, private GPS data, XP/streak/rank/leaderboard ownership violations, `subscriptionStatus`/`userRole` bypasses, AI/LLM scoring misuse, destructive file operations, build/test/deploy commands, and approval/review bypass language.

`REVIEW_ENABLED=0`, `REVIEW_MODE=lite`, and `CONTEXT_PACKET_ENABLED=1` are not high-risk approval. Keep these responsibilities separate.

Batch sequencing:

- Done: schema validation note.
- Done: `REVIEW_ENABLED` on/off policy documentation.
- Done: `REVIEW_ENABLED` runner integration.
- Done: context packet builder design.
- Done: standalone context packet builder implementation.
- This batch: opt-in context packet builder runner integration.
- Done: first deterministic high-risk auto-routing guard.
- Each batch must remain independently committable.

## Generic Context Selection Protocol

The generic agent-review workflow should use progressive context selection:

1. Cheap inventory first.
2. User-declared context class when available.
3. Conservative context class decision when not declared.
4. `Plan Scope`.
5. Codex inspect-only plan.
6. Codex-generated `Review Scope`.
7. Claude scope-limited review.
8. Codex final decision based on plan and review.

Context classes:

- `workflow`: runner scripts, agent prompts, review workflow docs, `.claude/settings.json`, and repo process automation.
- `docs`: documentation-only changes that do not affect implementation behavior.
- `implementation_prep`: requirements maps, setup gates, scaffolding decisions, architecture mapping, and implementation planning.
- `feature`: product feature planning or implementation work.
- `security`: security rules, sensitive data, auth, permissions, entitlement, secrets, or privacy work.
- `architecture`: system architecture, data ownership, module boundaries, deployment shape, or cross-component design.
- `unknown`: insufficient information to choose safely.

Prefer a user-declared context class when the user provides one. If none is provided, Codex may classify conservatively from the task text and must explain the classification in 1-2 sentences. `unknown` must not fall back to a broader class automatically; Codex must stop with a clarification/escalation note instead of doing a broad scan.

Codex plans must include a `Context Class Decision`, `Plan Scope`, and `Review Scope`. Review Scope files must stay within Plan Scope allowed paths or explicit Allow paths. If Review Scope needs a file outside Plan Scope, the plan must flag that as an error and stop instead of silently expanding scope.

Codex plans must also include `Planning Evidence Read`, listing files actually read, files intentionally skipped, and the reason for skipping large/reference/irrelevant files.

Token/Context Discipline:

- Avoid reading long files unless directly required.
- Avoid dumping large file contents into the plan.
- Summarize findings instead of reproducing file content.
- Keep inspect-only workflow plans concise.
- For workflow smoke tests, use compact plan output with concise bullets and no long explanatory sections.

Review Scope is not an inventory list. `Files Claude may need to read for review` must be the minimum review set, not every possibly relevant file. For `workflow` context, include at most 6 review files unless the user explicitly allows expanded review. For inspect-only workflow smoke tests, choose representative files only. If more than 6 review files seem necessary, return `DEFER` instead of silently expanding Review Scope.

Compact workflow smoke-test plan:

- Use concise bullets.
- Avoid repeating the same excluded paths in multiple sections.
- Avoid listing more than 3 representative files under `Files actually read` unless necessary.
- Avoid listing more than 3 representative files under `Files Claude may need to read for review` for lite review.
- If more files are needed, recommend standard review or `DEFER`.

For `workflow` context, do not read product requirements, submitted assessment docs, PDFs, images, diagrams, generated assets, Flutter/Firebase source, tests, or test evidence unless explicitly allowed by the user. If a workflow task explicitly asks for product-requirement alignment, require explicit Allow paths rather than auto-expanding.

For `docs` context, read only directly relevant docs and local instructions. Avoid PDFs/images/generated assets unless explicitly allowed.

For `implementation_prep` context, selectively read PRD/PDD markdown if needed, but avoid submitted PDFs/images/generated assets unless explicitly allowed.

For `feature`, `security`, and `architecture` contexts, consult requirement and architecture references as needed while avoiding broad repo scans and large binary/generated assets. Include high-risk review mode guidance.

DEFER recovery:

- If the class is too restrictive, the user adds explicit Allow paths.
- If the class is wrong, the user re-runs with the correct context class.
- If the plan is too large, split it into smaller plans.
- If additional sensitive/reference docs are needed, the user approves exact paths.

`REVIEW_MODE` controls which Claude review prompt is selected when `REVIEW_PROMPT` is not explicitly set:

```bash
REVIEW_MODE=standard # default; uses 02_claude_review_plan.md
REVIEW_MODE=lite     # uses 05_claude_review_plan_lite.md
```

`REVIEW_PROMPT` remains an override. If it is set in the environment or a config file, the runner uses that prompt regardless of `REVIEW_MODE`.

Use standard mode instead of lite mode for changes touching XP, streak, level, rank, leaderboard, roles, entitlements, premium fairness, Firebase ownership, Cloud Functions ownership, security rules, or submitted PDD / PRD consistency.

Lite review should read the Codex plan first, prefer judging from plan content only, and read project files only when needed to identify a `MUST_FIX` issue. For workflow smoke tests, lite review should read at most 2-3 representative files besides the plan. It must not perform broad validation; if broad validation is needed, return `DEFER` and recommend standard mode.

Claude review has two safety caps that apply only to the Claude review step:

```bash
CLAUDE_MAX_TURNS=12
CLAUDE_MAX_BUDGET_USD=0.50
```

`CLAUDE_MAX_TURNS` limits the number of Claude turns available during plan review. `CLAUDE_MAX_BUDGET_USD` limits review spend in US dollars. Lower values can stop a review early; if that happens, rerun with caps appropriate to the requested review scope.

Do not rely only on `claude --help` output to verify these cost-cap flags; some local Claude CLI versions accept flags that are not listed there. Check local compatibility with a minimal print-mode command before enabling actual runs.

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
  --max-turns "$CLAUDE_MAX_TURNS" \
  --max-budget-usd "$CLAUDE_MAX_BUDGET_USD" \
  --append-system-prompt "$(cat CLAUDE.md)"
```

Do not allow Claude review mode to use Bash, Edit, Write, filesystem-modifying tools, `dangerously-skip-permissions`, `bypassPermissions`, `auto`, or `acceptEdits` modes.

Do not use Claude `--bare` or `--append-system-prompt-file` for this runner.

## Future

After 3-5 real planning tasks, review whether the runner logic is stable enough to externalize. Do not create a separate repo, Git submodule, package, or GitHub Actions workflow yet.

Future generic distribution should add broader fixture repo smoke tests and evaluate whether context packet or high-risk guard traceability artifacts are useful.
