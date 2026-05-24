# Generic Agent Review Profile

This profile is a reusable template for generic agent-review context selection. It is not tied to Runiac or any other project domain.

## Context Policy

`context-policy.yml` is schema-only in this batch. It documents the intended shape of future context-selection policy, but no runner reads it yet and no YAML parsing is wired into `run_plan_review.sh`.

The schema fields are:

- `schema_version`: policy schema version.
- `context_classes`: supported context classes, their default review mode, and which path groups they may use.
- `always_read`: small files that may be loaded regardless of context class.
- `allowed_paths`: Layer B path groups for class-specific context scope.
- `excluded_paths`: large, generated, or sensitive paths to avoid unless explicitly allowed by a future integration.
- `review_file_budgets`: target file-count budgets for lite, standard, and default review.
- `unknown_context_behavior`: rejection behavior for unknown context so it cannot broaden automatically.
- `explicit_allow_behavior`: syntax and limits for user-approved extra paths.
- `non_negotiable_invariants`: Layer A always-on domain rules.
- `forbidden_content_patterns`: content patterns that should trigger caution or rejection.

Within each context class, `allowed_path_keys` may reference named `allowed_paths` groups or the top-level `always_read` list. Future schema validation must reject unknown references instead of silently broadening context.

Review mode controls review depth, not context breadth. Context breadth is controlled by context class, allowed paths, excluded paths, and explicit Allow paths.

Before runner integration, validate required top-level keys, `schema_version`, context class keys, `allowed_path_keys` references, `allowed_paths` groups, `excluded_paths` groups, `review_file_budgets`, `unknown_context_behavior`, and `explicit_allow_behavior`.

`non_negotiable_invariants` and `forbidden_content_patterns` are intentionally empty by default because the generic profile must not contain project-specific rules.

`context-policy.yml` remains schema-only until a parser or context packet builder is explicitly added.

External review on/off behavior is documented in the top-level README. The generic profile inherits `REVIEW_ENABLED` behavior and does not define project-specific skip policy.
