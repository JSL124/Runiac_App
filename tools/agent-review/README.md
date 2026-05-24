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

Profile `context-policy.yml` files are schema-only in this batch. No runner reads them yet, `run_plan_review.sh` does not parse YAML, and this change does not add a context packet builder.

The intended future integration is a context packet builder that reads profile policy, applies the selected context class, and emits bounded planning/review context. Until that integration exists, prompts and human review remain authoritative. If runner integration is delayed, re-review the schema before treating any `context-policy.yml` as authoritative.

The schema separates:

- Layer A: `non_negotiable_invariants`, always-on domain rules.
- Layer B: `allowed_paths` and `excluded_paths`, class-specific context scope.

Within `context_classes`, `allowed_path_keys` may refer to either named groups under `allowed_paths` or the top-level `always_read` list. Future integration must resolve both reference types explicitly.

Review mode controls review depth, not context breadth. Context breadth is controlled by context class, allowed paths, excluded paths, and explicit `Allow: <path>` entries. `unknown_context_behavior: "reject"` means unknown context must not auto-expand into feature, security, or architecture scope.

Before any runner integration treats `context-policy.yml` as authoritative, add schema validation for required top-level keys, `schema_version`, context class keys, `allowed_path_keys` references, `allowed_paths` groups, `excluded_paths` groups, `review_file_budgets`, `unknown_context_behavior`, and `explicit_allow_behavior`.

The generic profile must not contain project-specific invariants. Project profiles may add domain-specific invariants and forbidden content patterns.

## External Review On/Off Design

This is design intent only. The runner does not implement `REVIEW_ENABLED` yet, there is no `REVIEW_PROVIDER=none`, there is no `REVIEW_MODE=off`, and implementation must not be auto-run from this policy.

`REVIEW_ENABLED` should control whether an external review step runs. `REVIEW_MODE` should control review depth only when external review is enabled. `REVIEW_MODE` remains `lite|standard`; do not use `REVIEW_MODE=off`.

Recommended future defaults:

- For `pipeline`, `REVIEW_ENABLED=1` by default.
- `REVIEW_MODE=standard` remains the default depth when review is enabled.
- Low-risk workflow/documentation tasks may use `REVIEW_ENABLED=0`.
- High-risk tasks should keep review enabled.

Proposed future behavior:

- `REVIEW_ENABLED=1` runs the existing Claude review step.
- `REVIEW_ENABLED=0` explicitly skips the external Claude review step.
- Skipping review must never be silent.
- Skipping review must never be treated as approval.
- Skipping review must never auto-run implementation.

Skip review justification:

- `REVIEW_ENABLED=0` must require a non-empty `SKIP_REASON` environment variable or equivalent future flag.
- Missing `SKIP_REASON` should be a hard stop.
- `SKIP_REASON` should be stored verbatim in the skipped-review artifact.
- This prevents accidental skipping when `REVIEW_ENABLED=0` remains in the shell environment.

Skipped-review artifact specification:

- Location: `implementation/traceability/reviews/`
- Filename: `<timestamp>_external_review_skipped.md`
- The artifact must be created before Codex final decision so the decision phase can reference it.
- Required sections:
  - `External Review Status`
  - `Status: SKIPPED`
  - `Reason`
  - `Context Class at Time of Skip`
  - `Risk Tags at Time of Skip`
  - `Skip Justification`
  - `Implications`
  - `Codex decision proceeds without external validation.`
  - `Implementation still requires explicit user approval.`

Codex final decision behavior when review is skipped:

- Decision phase still runs.
- Input is Codex plan plus the skipped-review artifact.
- Decision prompt must explicitly state: "External review was explicitly skipped. You are the sole reviewer."
- Decision must apply elevated self-critique.
- Decision artifact must include `External Review Status: SKIPPED`.
- Decision artifact must include `Self-critique applied: yes/no`.

Implementation gating when review is skipped:

- Runner must not chain implementation after skipped review.
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

Future high-risk auto-routing guard specification:

- Trigger: plan `risk_tags` contains high-risk `yes`, the plan touches feature/security paths, or forbidden content patterns are implicated.
- If `REVIEW_ENABLED=0` and the guard triggers, hard stop.
- Do not silently override to `REVIEW_ENABLED=1`.
- User must either keep review enabled or use a future explicit override with justification.
- This is design intent only. Do not implement it in this batch.

Batch sequencing:

- Done: schema validation note.
- This batch: `REVIEW_ENABLED` on/off policy documentation.
- Next: `REVIEW_ENABLED` runner integration.
- Later: context packet builder design.
- Later: context packet builder implementation.
- Later: high-risk auto-routing guard.
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

Future generic distribution should integrate `context-policy.yml` through a context packet builder, cheap inventory size limits, and a generic fixture repo smoke test. These integrations are future work only and are not implemented in this batch.
