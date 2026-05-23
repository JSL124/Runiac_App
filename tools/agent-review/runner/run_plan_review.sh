#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$REPO_ROOT"

# Generic helpers only. Project rules belong in prompt/config files.
source "$SCRIPT_DIR/lib/common.sh"

DRY_RUN="${DRY_RUN:-1}"
CONFIG_FILE="${AGENT_REVIEW_CONFIG:-}"

if [ -n "$CONFIG_FILE" ]; then
  require_file "$CONFIG_FILE"
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

PLAN_PROMPT="${PLAN_PROMPT:-tools/agent-review/prompts/runiac/01_codex_create_plan.md}"
REVIEW_PROMPT="${REVIEW_PROMPT:-tools/agent-review/prompts/runiac/02_claude_review_plan.md}"
DECISION_PROMPT="${DECISION_PROMPT:-tools/agent-review/prompts/runiac/03_codex_final_review_decision.md}"
IMPLEMENT_PROMPT="${IMPLEMENT_PROMPT:-tools/agent-review/prompts/runiac/04_codex_implement_approved_plan.md}"

PLAN_DIR="${PLAN_DIR:-implementation/traceability/plans}"
REVIEW_DIR="${REVIEW_DIR:-implementation/traceability/reviews}"
DECISION_DIR="${DECISION_DIR:-implementation/traceability/decisions}"

usage() {
  cat <<'USAGE'
Usage: run_plan_review.sh <plan|review|decision|implement>

Environment:
  DRY_RUN=1                 Default. Write the command that would run.
  DRY_RUN=0                 Actually invoke Codex or Claude.
  AGENT_REVIEW_CONFIG=PATH  Optional shell env file.
  TASK_PROMPT=TEXT          Task prompt for plan/implement subcommands.
  PLAN_FILE=PATH            Existing plan file for review/decision/implement.
  REVIEW_FILE=PATH          Existing Claude review file for decision.
USAGE
}

repo_path() {
  printf '%s/%s' "$REPO_ROOT" "$1"
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
    check_help_flag_if_possible claude "--bare"
    check_help_flag_if_possible claude "--permission-mode"
    check_help_flag_if_possible claude "--tools"
    check_help_flag_if_possible claude "--append-system-prompt-file"
    check_help_flag_if_possible claude "--max-turns"
  fi
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
  "$@" > "$output_file"
  info "output written: $output_file"
}

cmd_plan() {
  require_common_paths
  require_agent_commands_for_actual_run 1 0

  local task_prompt="${TASK_PROMPT:-Create an inspect-only implementation plan for the requested Runiac task.}"
  local output_file
  output_file="$(repo_path "$PLAN_DIR/$(timestamp_utc)_codex_plan.md")"

  # Codex plan creation is read-only and cannot request approvals.
  local command_text
  command_text="codex --sandbox read-only --ask-for-approval never -C . exec \"\$(cat $PLAN_PROMPT; printf '\\n\\nTask:\\n%s\\n' '$task_prompt')\""

  run_or_dry "$output_file" "Codex inspect-only plan" "$command_text" \
    codex --sandbox read-only --ask-for-approval never -C "." exec \
    "$(cat "$(repo_path "$PLAN_PROMPT")"; printf '\n\nTask:\n%s\n' "$task_prompt")"
}

cmd_review() {
  require_common_paths
  require_agent_commands_for_actual_run 0 1

  local plan_file="${PLAN_FILE:-}"
  [ -n "$plan_file" ] || die "PLAN_FILE is required for review"
  require_file "$plan_file"

  local output_file
  output_file="$(repo_path "$REVIEW_DIR/$(timestamp_utc)_claude_review.md")"

  # Claude review is restricted to read-only tools and plan permission mode.
  local command_text
  command_text="claude --bare -p \"\$(cat $REVIEW_PROMPT; printf '\\n\\nPlan to review:\\n'; cat '$plan_file')\" --permission-mode plan --tools \"Read,Grep,Glob\" --append-system-prompt-file CLAUDE.md --max-turns 10"

  run_or_dry "$output_file" "Claude read-only plan review" "$command_text" \
    claude --bare \
    -p "$(cat "$(repo_path "$REVIEW_PROMPT")"; printf '\n\nPlan to review:\n'; cat "$plan_file")" \
    --permission-mode plan \
    --tools "Read,Grep,Glob" \
    --append-system-prompt-file "CLAUDE.md" \
    --max-turns 10
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

  local output_file
  output_file="$(repo_path "$DECISION_DIR/$(timestamp_utc)_codex_decision.md")"

  # Codex final decision is read-only and evaluates the plan plus review.
  local command_text
  command_text="codex --sandbox read-only --ask-for-approval never -C . exec \"\$(cat $DECISION_PROMPT; printf '\\n\\nOriginal plan:\\n'; cat '$plan_file'; printf '\\n\\nClaude review:\\n'; cat '$review_file')\""

  run_or_dry "$output_file" "Codex final review decision" "$command_text" \
    codex --sandbox read-only --ask-for-approval never -C "." exec \
    "$(cat "$(repo_path "$DECISION_PROMPT")"; printf '\n\nOriginal plan:\n'; cat "$plan_file"; printf '\n\nClaude review:\n'; cat "$review_file")"
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

main() {
  local subcommand="${1:-}"
  case "$subcommand" in
    plan) cmd_plan ;;
    review) cmd_review ;;
    decision) cmd_decision ;;
    implement) cmd_implement ;;
    -h|--help|help|"") usage ;;
    *) usage; die "unknown subcommand: $subcommand" ;;
  esac
}

main "$@"
