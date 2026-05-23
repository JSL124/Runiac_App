#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$REPO_ROOT"

# Generic helpers only. Project rules belong in prompt/config files.
source "$SCRIPT_DIR/lib/common.sh"

DRY_RUN="${DRY_RUN:-1}"
AGENT_REVIEW_PROFILE="${AGENT_REVIEW_PROFILE:-runiac}"
AGENT_REVIEW_PROFILE_DIR="${AGENT_REVIEW_PROFILE_DIR:-tools/agent-review/profiles/$AGENT_REVIEW_PROFILE}"
CONFIG_FILE="${AGENT_REVIEW_CONFIG:-}"
DEFAULT_CONFIG_FILE="$AGENT_REVIEW_PROFILE_DIR/agent-review.env.example"
LEGACY_CONFIG_FILE="tools/agent-review/config/$AGENT_REVIEW_PROFILE.agent-review.env.example"

resolve_config_file() {
  local config_file="$1"

  if [ -f "$config_file" ]; then
    printf '%s' "$config_file"
    return
  fi

  if [ "$config_file" = "$LEGACY_CONFIG_FILE" ] && [ -f "$DEFAULT_CONFIG_FILE" ]; then
    info "legacy config path moved; using: $DEFAULT_CONFIG_FILE"
    printf '%s' "$DEFAULT_CONFIG_FILE"
    return
  fi

  require_file "$config_file"
}

if [ -n "$CONFIG_FILE" ]; then
  CONFIG_FILE="$(resolve_config_file "$CONFIG_FILE")"
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

resolve_profile_prompt() {
  local prompt_path="$1"
  local prompt_file="$2"
  local legacy_prompt_path="tools/agent-review/prompts/$AGENT_REVIEW_PROFILE/$prompt_file"
  local profile_prompt_path="$AGENT_REVIEW_PROFILE_DIR/prompts/$prompt_file"

  if [ -f "$prompt_path" ]; then
    printf '%s' "$prompt_path"
    return
  fi

  if [ "$prompt_path" = "$legacy_prompt_path" ] && [ -f "$profile_prompt_path" ]; then
    info "legacy prompt path moved; using: $profile_prompt_path"
    printf '%s' "$profile_prompt_path"
    return
  fi

  printf '%s' "$prompt_path"
}

REVIEW_MODE="${REVIEW_MODE:-standard}"
case "$REVIEW_MODE" in
  standard|lite) ;;
  *) die "unsupported REVIEW_MODE: $REVIEW_MODE (expected: standard or lite)" ;;
esac

if [ "${REVIEW_PROMPT+x}" = "x" ]; then
  REVIEW_PROMPT_EXPLICIT=1
else
  REVIEW_PROMPT_EXPLICIT=0
fi

PLAN_PROMPT="${PLAN_PROMPT:-$AGENT_REVIEW_PROFILE_DIR/prompts/01_codex_create_plan.md}"
REVIEW_PROMPT_STANDARD="${REVIEW_PROMPT_STANDARD:-$AGENT_REVIEW_PROFILE_DIR/prompts/02_claude_review_plan.md}"
REVIEW_PROMPT_LITE="${REVIEW_PROMPT_LITE:-$AGENT_REVIEW_PROFILE_DIR/prompts/05_claude_review_plan_lite.md}"
if [ "$REVIEW_PROMPT_EXPLICIT" = "0" ]; then
  case "$REVIEW_MODE" in
    standard) REVIEW_PROMPT="$REVIEW_PROMPT_STANDARD" ;;
    lite) REVIEW_PROMPT="$REVIEW_PROMPT_LITE" ;;
  esac
fi
DECISION_PROMPT="${DECISION_PROMPT:-$AGENT_REVIEW_PROFILE_DIR/prompts/03_codex_final_review_decision.md}"
IMPLEMENT_PROMPT="${IMPLEMENT_PROMPT:-$AGENT_REVIEW_PROFILE_DIR/prompts/04_codex_implement_approved_plan.md}"

PLAN_PROMPT="$(resolve_profile_prompt "$PLAN_PROMPT" "01_codex_create_plan.md")"
REVIEW_PROMPT="$(resolve_profile_prompt "$REVIEW_PROMPT" "${REVIEW_PROMPT##*/}")"
DECISION_PROMPT="$(resolve_profile_prompt "$DECISION_PROMPT" "03_codex_final_review_decision.md")"
IMPLEMENT_PROMPT="$(resolve_profile_prompt "$IMPLEMENT_PROMPT" "04_codex_implement_approved_plan.md")"

PLAN_DIR="${PLAN_DIR:-implementation/traceability/plans}"
REVIEW_DIR="${REVIEW_DIR:-implementation/traceability/reviews}"
DECISION_DIR="${DECISION_DIR:-implementation/traceability/decisions}"
CLAUDE_MAX_TURNS="${CLAUDE_MAX_TURNS:-12}"
CLAUDE_MAX_BUDGET_USD="${CLAUDE_MAX_BUDGET_USD:-0.50}"

usage() {
  cat <<'USAGE'
Usage: run_plan_review.sh <plan|review|decision|implement|pipeline>

Environment:
  DRY_RUN=1                 Default. Write the command that would run.
  DRY_RUN=0                 Actually invoke Codex or Claude.
  AGENT_REVIEW_PROFILE=NAME Default: runiac.
  AGENT_REVIEW_PROFILE_DIR=PATH
                            Default: tools/agent-review/profiles/$AGENT_REVIEW_PROFILE.
  AGENT_REVIEW_CONFIG=PATH  Optional shell env file.
  REVIEW_MODE=standard|lite Default: standard. Selects the Claude review prompt
                            unless REVIEW_PROMPT is explicitly set.
  CLAUDE_MAX_TURNS=N       Default: 12. Claude review step turn cap.
  CLAUDE_MAX_BUDGET_USD=N  Default: 0.50. Claude review step budget cap.
  TASK_PROMPT=TEXT          Task prompt for plan/implement/pipeline subcommands.
  TASK_PROMPT_FILE=PATH     Task prompt file for plan/implement/pipeline when TASK_PROMPT is unset.
  PLAN_FILE=PATH            Existing plan file for review/decision/implement.
  REVIEW_FILE=PATH          Existing Claude review file for decision.

For pipeline, TASK_PROMPT is required unless TASK_PROMPT_FILE is set. If both are
set, TASK_PROMPT is used and TASK_PROMPT_FILE is ignored.
USAGE
}

repo_path() {
  case "$1" in
    /*) printf '%s' "$1" ;;
    *) printf '%s/%s' "$REPO_ROOT" "$1" ;;
  esac
}

require_common_paths() {
  require_file "$(repo_path "$PLAN_PROMPT")"
  require_file "$(repo_path "$REVIEW_PROMPT")"
  require_file "$(repo_path "$DECISION_PROMPT")"
  require_file "$(repo_path "$IMPLEMENT_PROMPT")"

  if [ "$DRY_RUN" = "0" ]; then
    mkdir -p "$(repo_path "$PLAN_DIR")" "$(repo_path "$REVIEW_DIR")" "$(repo_path "$DECISION_DIR")"
  fi
}

require_agent_commands_for_actual_run() {
  local codex_needed="$1"
  local claude_needed="$2"

  if [ "$DRY_RUN" = "0" ] && [ "$codex_needed" = "1" ]; then
    require_command codex
    check_help_flag_if_possible codex "--sandbox"
    check_help_flag_if_possible codex "--ask-for-approval"
    check_help_flag_if_possible codex "-C"
  fi

  if [ "$DRY_RUN" = "0" ] && [ "$claude_needed" = "1" ]; then
    require_command claude
    check_help_flag_if_possible claude "--permission-mode"
    check_help_flag_if_possible claude "--tools"
    check_help_flag_if_possible claude "--append-system-prompt "
  fi
}

resolve_task_prompt() {
  local default_prompt="${1:-}"

  if [ -n "${TASK_PROMPT:-}" ]; then
    printf '%s' "$TASK_PROMPT"
    return
  fi

  if [ -n "${TASK_PROMPT_FILE:-}" ]; then
    require_file "$TASK_PROMPT_FILE"
    cat "$TASK_PROMPT_FILE"
    return
  fi

  if [ -n "$default_prompt" ]; then
    printf '%s' "$default_prompt"
    return
  fi

  die "TASK_PROMPT or TASK_PROMPT_FILE is required"
}

new_plan_output_file() {
  repo_path "$PLAN_DIR/$(timestamp_utc)_codex_plan.md"
}

new_review_output_file() {
  repo_path "$REVIEW_DIR/$(timestamp_utc)_claude_review.md"
}

new_decision_output_file() {
  repo_path "$DECISION_DIR/$(timestamp_utc)_codex_decision.md"
}

run_or_dry() {
  local output_file="$1"
  local description="$2"
  local command_text="$3"
  shift 3

  if [ "$DRY_RUN" != "0" ]; then
    write_dry_run "$output_file" "$description" "$command_text"
    return
  fi

  # Output redirection is owned by the runner; agent commands must not overwrite files.
  ensure_new_file "$output_file"
  if ! "$@" > "$output_file"; then
    return 1
  fi
  info "output written: $output_file"
}

run_plan_step() {
  local output_file="$1"
  local task_prompt="$2"

  # Codex plan creation is read-only and cannot request approvals.
  local command_text
  command_text="codex --sandbox read-only --ask-for-approval never -C . exec \"\$(cat $PLAN_PROMPT; printf '\\n\\nTask:\\n%s\\n' '$task_prompt')\""

  run_or_dry "$output_file" "Codex inspect-only plan" "$command_text" \
    codex --sandbox read-only --ask-for-approval never -C "." exec \
    "$(cat "$(repo_path "$PLAN_PROMPT")"; printf '\n\nTask:\n%s\n' "$task_prompt")"
}

run_review_step() {
  local output_file="$1"
  local plan_file="$2"

  # Claude review is restricted to read-only tools and plan permission mode.
  local command_text
  command_text="claude -p \"\$(cat $REVIEW_PROMPT; printf '\\n\\nPlan to review:\\n'; cat '$plan_file')\" --permission-mode plan --tools \"Read,Grep,Glob\" --max-turns \"$CLAUDE_MAX_TURNS\" --max-budget-usd \"$CLAUDE_MAX_BUDGET_USD\" --append-system-prompt \"\$(cat CLAUDE.md)\""

  run_or_dry "$output_file" "Claude read-only plan review" "$command_text" \
    claude \
    -p "$(cat "$(repo_path "$REVIEW_PROMPT")"; printf '\n\nPlan to review:\n'; cat "$plan_file")" \
    --permission-mode plan \
    --tools "Read,Grep,Glob" \
    --max-turns "$CLAUDE_MAX_TURNS" \
    --max-budget-usd "$CLAUDE_MAX_BUDGET_USD" \
    --append-system-prompt "$(cat "$(repo_path CLAUDE.md)")"
}

run_decision_step() {
  local output_file="$1"
  local plan_file="$2"
  local review_file="$3"

  # Codex final decision is read-only and evaluates the plan plus review.
  local command_text
  command_text="codex --sandbox read-only --ask-for-approval never -C . exec \"\$(cat $DECISION_PROMPT; printf '\\n\\nOriginal plan:\\n'; cat '$plan_file'; printf '\\n\\nClaude review:\\n'; cat '$review_file')\""

  run_or_dry "$output_file" "Codex final review decision" "$command_text" \
    codex --sandbox read-only --ask-for-approval never -C "." exec \
    "$(cat "$(repo_path "$DECISION_PROMPT")"; printf '\n\nOriginal plan:\n'; cat "$plan_file"; printf '\n\nClaude review:\n'; cat "$review_file")"
}

cmd_plan() {
  require_common_paths
  require_agent_commands_for_actual_run 1 0

  local task_prompt
  task_prompt="$(resolve_task_prompt "Create an inspect-only implementation plan for the requested Runiac task.")"
  run_plan_step "$(new_plan_output_file)" "$task_prompt"
}

cmd_review() {
  require_common_paths
  require_agent_commands_for_actual_run 0 1

  local plan_file="${PLAN_FILE:-}"
  [ -n "$plan_file" ] || die "PLAN_FILE is required for review"
  require_file "$plan_file"

  run_review_step "$(new_review_output_file)" "$plan_file"
}

cmd_decision() {
  require_common_paths
  require_agent_commands_for_actual_run 1 0

  local plan_file="${PLAN_FILE:-}"
  local review_file="${REVIEW_FILE:-}"
  [ -n "$plan_file" ] || die "PLAN_FILE is required for decision"
  [ -n "$review_file" ] || die "REVIEW_FILE is required for decision"
  require_file "$plan_file"
  require_file "$review_file"

  run_decision_step "$(new_decision_output_file)" "$plan_file" "$review_file"
}

cmd_implement() {
  require_common_paths
  require_agent_commands_for_actual_run 1 0

  local plan_file="${PLAN_FILE:-}"
  [ -n "$plan_file" ] || die "PLAN_FILE is required for implement"
  require_file "$plan_file"

  local output_file
  output_file="$(repo_path "$DECISION_DIR/$(timestamp_utc)_codex_implementation_command.md")"

  # First implementation runs must be interactive Codex after explicit user approval.
  local command_text
  command_text="codex --sandbox workspace-write --ask-for-approval on-request -C ."

  if [ "$DRY_RUN" != "0" ]; then
    write_dry_run "$output_file" "Interactive Codex implementation after user approval" "$command_text"
    return
  fi

  cat <<'MESSAGE'
Open interactive Codex manually after explicit user approval:

  codex --sandbox workspace-write --ask-for-approval on-request -C .

Use this prompt with the approved plan file and do not run git add, commit, or push.
MESSAGE
}

print_pipeline_dry_run() {
  local plan_file="$1"
  local review_file="$2"
  local decision_file="$3"

  cat <<PIPELINE_DRY_RUN
# Pipeline Dry Run Preview

DRY_RUN=1, so Codex and Claude will not be invoked and no plan/review/decision
artifacts will be written.

Would run:

Review mode:
   $REVIEW_MODE

Review prompt:
   $REVIEW_PROMPT

1. Codex inspect-only plan

   codex --sandbox read-only --ask-for-approval never -C . exec "<plan prompt + task>"

   Would write PLAN_FILE:
   $plan_file

2. Claude read-only plan review

   claude -p "<review prompt + PLAN_FILE>" --permission-mode plan --tools "Read,Grep,Glob" --max-turns "$CLAUDE_MAX_TURNS" --max-budget-usd "$CLAUDE_MAX_BUDGET_USD" --append-system-prompt "\$(cat CLAUDE.md)"

   Would read PLAN_FILE:
   $plan_file

   Would write REVIEW_FILE:
   $review_file

3. Codex final review decision

   codex --sandbox read-only --ask-for-approval never -C . exec "<decision prompt + PLAN_FILE + REVIEW_FILE>"

   Would read PLAN_FILE:
   $plan_file

   Would read REVIEW_FILE:
   $review_file

   Would write DECISION_FILE:
   $decision_file

Implementation, git staging, commit, push, tests, builds, deployment, Flutter,
Firebase, and npm commands would not run.
PIPELINE_DRY_RUN
}

pipeline_failed() {
  local step="$1"
  local output_file="${2:-}"

  info "pipeline failed at step: $step"
  if [ -n "$output_file" ] && [ -e "$output_file" ]; then
    info "output path created before failure: $output_file"
  elif [ -n "$output_file" ]; then
    info "intended output path: $output_file"
  fi
  return 1
}

print_pipeline_summary() {
  local plan_file="$1"
  local review_file="$2"
  local decision_file="$3"

  cat <<PIPELINE_SUMMARY
Pipeline complete.

PLAN_FILE=$plan_file
REVIEW_FILE=$review_file
DECISION_FILE=$decision_file

git status --short:
PIPELINE_SUMMARY
  git status --short
  cat <<'PIPELINE_SUMMARY'

Implementation was not run.
Inspect DECISION_FILE before starting any implementation.
PIPELINE_SUMMARY
}

cmd_pipeline() {
  require_common_paths

  local task_prompt
  task_prompt="$(resolve_task_prompt)"

  local plan_file
  local review_file
  local decision_file
  plan_file="$(new_plan_output_file)"
  review_file="$(new_review_output_file)"
  decision_file="$(new_decision_output_file)"

  if [ "$DRY_RUN" != "0" ]; then
    print_pipeline_dry_run "$plan_file" "$review_file" "$decision_file"
    return
  fi

  require_agent_commands_for_actual_run 1 1

  if ! run_plan_step "$plan_file" "$task_prompt"; then
    pipeline_failed "plan" "$plan_file" || true
    return 1
  fi

  if ! run_review_step "$review_file" "$plan_file"; then
    pipeline_failed "review" "$review_file" || true
    return 1
  fi

  if ! run_decision_step "$decision_file" "$plan_file" "$review_file"; then
    pipeline_failed "decision" "$decision_file" || true
    return 1
  fi

  print_pipeline_summary "$plan_file" "$review_file" "$decision_file"
}

main() {
  local subcommand="${1:-}"
  case "$subcommand" in
    plan) cmd_plan ;;
    review) cmd_review ;;
    decision) cmd_decision ;;
    implement) cmd_implement ;;
    pipeline) cmd_pipeline ;;
    -h|--help|help|"") usage ;;
    *) usage; die "unknown subcommand: $subcommand" ;;
  esac
}

main "$@"
