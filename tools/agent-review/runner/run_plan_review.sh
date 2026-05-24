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

REVIEW_ENABLED="${REVIEW_ENABLED:-1}"
case "$REVIEW_ENABLED" in
  1|0) ;;
  *)
    printf 'ERROR: REVIEW_ENABLED must be 1 or 0. Got: "%s"\n' "$REVIEW_ENABLED" >&2
    exit 1
    ;;
esac

REVIEW_PROVIDER="${REVIEW_PROVIDER:-gemini}"
if [ "$REVIEW_ENABLED" = "1" ]; then
  case "$REVIEW_PROVIDER" in
    gemini|claude|codex) ;;
    *)
      printf 'ERROR: REVIEW_PROVIDER must be gemini, claude, or codex when REVIEW_ENABLED=1. Got: "%s"\n' "$REVIEW_PROVIDER" >&2
      exit 1
      ;;
  esac
fi

CONTEXT_PACKET_ENABLED="${CONTEXT_PACKET_ENABLED:-0}"
case "$CONTEXT_PACKET_ENABLED" in
  1|0) ;;
  *)
    printf 'ERROR: CONTEXT_PACKET_ENABLED must be 1 or 0. Got: "%s"\n' "$CONTEXT_PACKET_ENABLED" >&2
    exit 1
    ;;
esac

HIGH_RISK_GUARD_ENABLED="${HIGH_RISK_GUARD_ENABLED:-1}"
case "$HIGH_RISK_GUARD_ENABLED" in
  1|0) ;;
  *)
    printf 'ERROR: HIGH_RISK_GUARD_ENABLED must be 1 or 0. Got: "%s"\n' "$HIGH_RISK_GUARD_ENABLED" >&2
    exit 1
    ;;
esac

HIGH_RISK_APPROVED="${HIGH_RISK_APPROVED:-0}"
case "$HIGH_RISK_APPROVED" in
  1|0) ;;
  *)
    printf 'ERROR: HIGH_RISK_APPROVED must be 1 or 0. Got: "%s"\n' "$HIGH_RISK_APPROVED" >&2
    exit 1
    ;;
esac

if [ "${REVIEW_PROMPT+x}" = "x" ]; then
  REVIEW_PROMPT_EXPLICIT=1
else
  REVIEW_PROMPT_EXPLICIT=0
fi

PLAN_PROMPT="${PLAN_PROMPT:-$AGENT_REVIEW_PROFILE_DIR/prompts/01_codex_create_plan.md}"
CLAUDE_REVIEW_PROMPT_STANDARD="${REVIEW_PROMPT_STANDARD:-$AGENT_REVIEW_PROFILE_DIR/prompts/02_claude_review_plan.md}"
CLAUDE_REVIEW_PROMPT_LITE="${REVIEW_PROMPT_LITE:-$AGENT_REVIEW_PROFILE_DIR/prompts/05_claude_review_plan_lite.md}"
if [ "$REVIEW_PROMPT_EXPLICIT" = "0" ]; then
  case "$REVIEW_MODE" in
    standard) CLAUDE_REVIEW_PROMPT="$CLAUDE_REVIEW_PROMPT_STANDARD" ;;
    lite) CLAUDE_REVIEW_PROMPT="$CLAUDE_REVIEW_PROMPT_LITE" ;;
  esac
else
  CLAUDE_REVIEW_PROMPT="$REVIEW_PROMPT"
fi
GEMINI_REVIEW_PROMPT="${GEMINI_REVIEW_PROMPT:-$AGENT_REVIEW_PROFILE_DIR/prompts/06_gemini_review_plan.md}"
CODEX_REVIEW_PROMPT="${CODEX_REVIEW_PROMPT:-$AGENT_REVIEW_PROFILE_DIR/prompts/07_codex_review_plan.md}"
DECISION_PROMPT="${DECISION_PROMPT:-$AGENT_REVIEW_PROFILE_DIR/prompts/03_codex_final_review_decision.md}"
IMPLEMENT_PROMPT="${IMPLEMENT_PROMPT:-$AGENT_REVIEW_PROFILE_DIR/prompts/04_codex_implement_approved_plan.md}"

PLAN_PROMPT="$(resolve_profile_prompt "$PLAN_PROMPT" "01_codex_create_plan.md")"
CLAUDE_REVIEW_PROMPT="$(resolve_profile_prompt "$CLAUDE_REVIEW_PROMPT" "${CLAUDE_REVIEW_PROMPT##*/}")"
GEMINI_REVIEW_PROMPT="$(resolve_profile_prompt "$GEMINI_REVIEW_PROMPT" "06_gemini_review_plan.md")"
CODEX_REVIEW_PROMPT="$(resolve_profile_prompt "$CODEX_REVIEW_PROMPT" "07_codex_review_plan.md")"
DECISION_PROMPT="$(resolve_profile_prompt "$DECISION_PROMPT" "03_codex_final_review_decision.md")"
IMPLEMENT_PROMPT="$(resolve_profile_prompt "$IMPLEMENT_PROMPT" "04_codex_implement_approved_plan.md")"

PLAN_DIR="${PLAN_DIR:-implementation/traceability/plans}"
REVIEW_DIR="${REVIEW_DIR:-implementation/traceability/reviews}"
DECISION_DIR="${DECISION_DIR:-implementation/traceability/decisions}"
CLAUDE_MAX_TURNS="${CLAUDE_MAX_TURNS:-12}"
CLAUDE_MAX_BUDGET_USD="${CLAUDE_MAX_BUDGET_USD:-0.50}"
GEMINI_APPROVAL_MODE="${GEMINI_APPROVAL_MODE:-plan}"
GEMINI_OUTPUT_FORMAT="${GEMINI_OUTPUT_FORMAT:-text}"
GEMINI_TIMEOUT_SECONDS="${GEMINI_TIMEOUT_SECONDS:-120}"
CONTEXT_PACKET_MAX_BYTES=8000
CONTEXT_PACKET_BUILDER="tools/agent-review/runner/build_context_packet.sh"
HIGH_RISK_CLASSIFIER="tools/agent-review/runner/classify_high_risk_task.sh"

usage() {
  cat <<'USAGE'
Usage: run_plan_review.sh <plan|review|decision|implement|pipeline>

Environment:
  DRY_RUN=1                 Default. Write the command that would run.
  DRY_RUN=0                 Actually invoke Codex, Gemini, or Claude.
  AGENT_REVIEW_PROFILE=NAME Default: runiac.
  AGENT_REVIEW_PROFILE_DIR=PATH
                            Default: tools/agent-review/profiles/$AGENT_REVIEW_PROFILE.
  AGENT_REVIEW_CONFIG=PATH  Optional shell env file.
  REVIEW_ENABLED=1|0       Default: 1. When 0, skip provider review
                            and create a skipped-review artifact instead.
  REVIEW_PROVIDER=gemini|claude|codex
                            Default: gemini when REVIEW_ENABLED=1. Ignored
                            when REVIEW_ENABLED=0.
  SKIP_REASON=TEXT          Required when REVIEW_ENABLED=0.
  CONTEXT_PACKET_ENABLED=1|0
                            Default: 0. When 1, generate a context packet
                            before Codex inspect-only planning.
  HIGH_RISK_GUARD_ENABLED=1|0
                            Default: 1. When 1, block high-risk tasks unless
                            approved with HIGH_RISK_APPROVED and reason.
  HIGH_RISK_APPROVED=1|0    Default: 0. Explicit high-risk approval flag.
  HIGH_RISK_REASON=TEXT     Required when HIGH_RISK_APPROVED=1.
  REVIEW_MODE=standard|lite Default: standard. Selects Claude review depth and
                            is passed as context to Gemini/Codex provider prompts.
                            REVIEW_MODE remains lite|standard and does not
                            disable review.
  CLAUDE_MAX_TURNS=N       Default: 12. Claude review step turn cap.
  CLAUDE_MAX_BUDGET_USD=N  Default: 0.50. Claude review step budget cap.
  GEMINI_APPROVAL_MODE=N   Default: plan. Gemini review approval mode.
  GEMINI_OUTPUT_FORMAT=N   Default: text. Gemini review output format.
  GEMINI_TIMEOUT_SECONDS=N Default: 120. Positive integer timeout for actual
                            Gemini review runs.
  TASK_PROMPT=TEXT          Task prompt for plan/implement/pipeline subcommands.
  TASK_PROMPT_FILE=PATH     Task prompt file for plan/implement/pipeline when TASK_PROMPT is unset.
  PLAN_FILE=PATH            Existing plan file for review/decision/implement.
  REVIEW_FILE=PATH          Existing review artifact file for decision.

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

selected_review_prompt() {
  case "$REVIEW_PROVIDER" in
    gemini) printf '%s' "$GEMINI_REVIEW_PROMPT" ;;
    claude) printf '%s' "$CLAUDE_REVIEW_PROMPT" ;;
    codex) printf '%s' "$CODEX_REVIEW_PROMPT" ;;
    *) die "unsupported REVIEW_PROVIDER: $REVIEW_PROVIDER" ;;
  esac
}

validate_gemini_timeout_seconds() {
  case "$GEMINI_TIMEOUT_SECONDS" in
    ''|0|0*|*[!0-9]*)
      die "GEMINI_TIMEOUT_SECONDS must be a positive non-zero integer. Got: \"$GEMINI_TIMEOUT_SECONDS\""
      ;;
  esac
}

find_timeout_command() {
  if command -v timeout >/dev/null 2>&1; then
    printf 'timeout'
    return 0
  fi

  if command -v gtimeout >/dev/null 2>&1; then
    printf 'gtimeout'
    return 0
  fi

  return 1
}

require_common_paths() {
  require_file "$(repo_path "$PLAN_PROMPT")"
  if [ "$REVIEW_ENABLED" = "1" ]; then
    require_file "$(repo_path "$(selected_review_prompt)")"
  fi
  require_file "$(repo_path "$DECISION_PROMPT")"
  require_file "$(repo_path "$IMPLEMENT_PROMPT")"

  if [ "$DRY_RUN" = "0" ]; then
    mkdir -p "$(repo_path "$PLAN_DIR")" "$(repo_path "$REVIEW_DIR")" "$(repo_path "$DECISION_DIR")"
  fi
}

require_agent_commands_for_actual_run() {
  local codex_needed="$1"
  local claude_needed="$2"
  local gemini_needed="${3:-0}"

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

  if [ "$DRY_RUN" = "0" ] && [ "$gemini_needed" = "1" ]; then
    if ! command -v gemini >/dev/null 2>&1; then
      die "REVIEW_PROVIDER=gemini requires Gemini CLI. Install/authenticate Gemini CLI or use REVIEW_PROVIDER=claude, REVIEW_PROVIDER=codex, or REVIEW_ENABLED=0."
    fi
    validate_gemini_timeout_seconds
    if ! find_timeout_command >/dev/null; then
      die "REVIEW_PROVIDER=gemini requires timeout or gtimeout to avoid hung review runs. Install coreutils or use REVIEW_PROVIDER=claude, REVIEW_PROVIDER=codex, or REVIEW_ENABLED=0."
    fi
  fi
}

review_provider_command_needs() {
  local provider="$1"
  case "$provider" in
    gemini) printf '0 0 1' ;;
    claude) printf '0 1 0' ;;
    codex) printf '1 0 0' ;;
    *) die "unsupported REVIEW_PROVIDER: $provider" ;;
  esac
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

run_high_risk_guard() {
  local subcommand="$1"
  local task_prompt="${2:-}"
  local classifier_output
  local env_args
  local exit_code

  require_file "$(repo_path "$HIGH_RISK_CLASSIFIER")"

  env_args=(
    "AGENT_REVIEW_SUBCOMMAND=$subcommand"
    "TASK_PROMPT=$task_prompt"
    "DRY_RUN=$DRY_RUN"
    "REVIEW_ENABLED=$REVIEW_ENABLED"
    "REVIEW_MODE=$REVIEW_MODE"
    "CONTEXT_PACKET_ENABLED=$CONTEXT_PACKET_ENABLED"
    "HIGH_RISK_GUARD_ENABLED=$HIGH_RISK_GUARD_ENABLED"
    "HIGH_RISK_APPROVED=$HIGH_RISK_APPROVED"
    "HIGH_RISK_REASON=${HIGH_RISK_REASON:-}"
  )
  if [ "${CONTEXT_CLASS+x}" = "x" ]; then
    env_args+=("CONTEXT_CLASS=$CONTEXT_CLASS")
  fi
  if [ "${ALLOW_PATHS+x}" = "x" ]; then
    env_args+=("ALLOW_PATHS=$ALLOW_PATHS")
  fi

  if classifier_output="$(env "${env_args[@]}" "$HIGH_RISK_CLASSIFIER")"; then
    printf '%s\n' "$classifier_output" >&2
    return 0
  else
    exit_code=$?
  fi

  printf '%s\n' "$classifier_output" >&2
  if [ "$exit_code" = "2" ]; then
    printf 'ERROR: High-risk guard blocked %s. Set HIGH_RISK_APPROVED=1 and HIGH_RISK_REASON only after explicit user approval.\n' "$subcommand" >&2
  elif [ "$exit_code" = "3" ]; then
    printf 'ERROR: High-risk guard configuration is invalid.\n' >&2
  else
    printf 'ERROR: High-risk guard failed unexpectedly with exit code %s.\n' "$exit_code" >&2
  fi
  return "$exit_code"
}

build_context_packet_for_prompt() {
  local task_prompt="$1"
  local packet
  local env_args

  require_file "$(repo_path "$CONTEXT_PACKET_BUILDER")"

  env_args=(
    "PROFILE=$AGENT_REVIEW_PROFILE"
    "TASK_PROMPT=$task_prompt"
    "REVIEW_ENABLED=$REVIEW_ENABLED"
    "REVIEW_MODE=$REVIEW_MODE"
  )
  if [ "${CONTEXT_CLASS+x}" = "x" ]; then
    env_args+=("CONTEXT_CLASS=$CONTEXT_CLASS")
  fi
  if [ "${ALLOW_PATHS+x}" = "x" ]; then
    env_args+=("ALLOW_PATHS=$ALLOW_PATHS")
  fi
  if [ "${SKIP_REASON+x}" = "x" ]; then
    env_args+=("SKIP_REASON=$SKIP_REASON")
  fi

  if ! packet="$(env "${env_args[@]}" "$CONTEXT_PACKET_BUILDER")"; then
    printf 'ERROR: Context packet generation failed. Pipeline stopped; no broad repo scanning fallback.\n' >&2
    return 1
  fi

  packet="${packet/Standalone only — not integrated into run_plan_review.sh yet./Standalone context packet — generated by build_context_packet.sh and optionally provided to run_plan_review.sh when CONTEXT_PACKET_ENABLED=1.}"

  printf '%s' "$packet"
}

task_prompt_for_plan() {
  local task_prompt="$1"
  local packet
  local packet_size

  if [ "$CONTEXT_PACKET_ENABLED" = "0" ]; then
    printf '%s' "$task_prompt"
    return
  fi

  packet="$(build_context_packet_for_prompt "$task_prompt")" || return 1
  packet_size="$(printf '%s' "$packet" | wc -c | tr -d ' ')"

  if [ "$packet_size" -gt "$CONTEXT_PACKET_MAX_BYTES" ]; then
    printf 'ERROR: Context packet too large (%s bytes > %s limit).\n' "$packet_size" "$CONTEXT_PACKET_MAX_BYTES" >&2
    printf 'Reduce scope with narrower CONTEXT_CLASS or fewer ALLOW_PATHS.\n' >&2
    return 1
  fi

  printf '%s\n\n---\n\n%s' "$packet" "$task_prompt"
}

new_plan_output_file() {
  repo_path "$PLAN_DIR/$(timestamp_utc)_codex_plan.md"
}

new_review_output_file() {
  case "$REVIEW_PROVIDER" in
    gemini) repo_path "$REVIEW_DIR/$(timestamp_utc)_gemini_review.md" ;;
    claude) repo_path "$REVIEW_DIR/$(timestamp_utc)_claude_review.md" ;;
    codex) repo_path "$REVIEW_DIR/$(timestamp_utc)_codex_review.md" ;;
    *) die "unsupported REVIEW_PROVIDER: $REVIEW_PROVIDER" ;;
  esac
}

new_skipped_review_output_file() {
  repo_path "$REVIEW_DIR/$(timestamp_utc)_external_review_skipped.md"
}

new_decision_output_file() {
  repo_path "$DECISION_DIR/$(timestamp_utc)_codex_decision.md"
}

warn_review_disabled() {
  printf 'WARNING: External review is disabled. If this plan touches XP, streak, leaderboard, Firebase, security rules, production source, or PRD/PDD consistency, consider enabling review.\n' >&2
}

require_skip_reason() {
  if [ "$REVIEW_ENABLED" = "0" ] && [ -z "${SKIP_REASON:-}" ]; then
    printf 'ERROR: REVIEW_ENABLED=0 requires SKIP_REASON to be set.\n' >&2
    printf 'Example: SKIP_REASON="documentation-only change"\n' >&2
    exit 1
  fi
}

extract_context_class_for_skip() {
  local plan_file="$1"
  local context_section

  if [ -n "${CONTEXT_CLASS:-}" ]; then
    printf '%s\n' "$CONTEXT_CLASS"
    return
  fi

  context_section="$(awk '
    /^## Context Class Decision[[:space:]]*$/ { capture = 1; next }
    /^## / && capture { exit }
    capture { print }
  ' "$plan_file")"

  if [ -n "$context_section" ]; then
    printf '%s\n' "$context_section"
  else
    printf 'Not set — context packet builder not yet integrated.\n'
  fi
}

extract_risk_tags_for_skip() {
  local plan_file="$1"
  local risk_section

  risk_section="$(awk '
    /^[[:space:]]*-?[[:space:]]*Risk tags:/ { capture = 1; print; next }
    /^## / && capture { exit }
    /^[[:space:]]*-?[[:space:]]*Recommended review mode:/ && capture { exit }
    capture { print }
  ' "$plan_file")"

  if [ -n "$risk_section" ]; then
    printf '%s\n' "$risk_section"
  else
    printf 'Not evaluated — auto-routing guard not yet implemented.\n'
  fi
}

create_skipped_review_artifact() {
  local output_file="$1"
  local plan_file="$2"
  local context_class
  local risk_tags

  ensure_new_file "$output_file"
  context_class="$(extract_context_class_for_skip "$plan_file")"
  risk_tags="$(extract_risk_tags_for_skip "$plan_file")"

  {
    printf '# External Review Skipped\n\n'
    printf '## External Review Status\n\n'
    printf '%s\n' '- Status: SKIPPED'
    printf '%s\n\n' "- Reason: $SKIP_REASON"
    printf '## Context Class at Time of Skip\n\n'
    printf '%s\n\n' "$context_class"
    printf '## Risk Tags at Time of Skip\n\n'
    printf '%s\n\n' "$risk_tags"
    printf '## Skip Justification\n\n'
    printf '%s\n\n' "$SKIP_REASON"
    printf '## Implications\n\n'
    printf '%s\n' '- Provider review was not run.'
    printf '%s\n' '- This skipped review is not approval.'
    printf '%s\n' '- Implementation still requires explicit user approval.'
    printf '%s\n' '- Codex final decision must treat this as an unreviewed plan and apply elevated self-critique.'
  } > "$output_file"

  info "skipped-review artifact written: $output_file"
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

run_gemini_review_step() {
  local output_file="$1"
  local plan_file="$2"
  local gemini_input
  local timeout_command
  local exit_code

  gemini_input="$(cat "$(repo_path "$GEMINI_REVIEW_PROMPT")"; printf '\n\nProvider metadata:\n'; printf -- '- REVIEW_PROVIDER: gemini\n'; printf -- '- REVIEW_MODE: %s\n' "$REVIEW_MODE"; printf -- '- PLAN_FILE: %s\n' "$plan_file"; printf '\n\nPlan to review:\n'; cat "$plan_file")"

  # Gemini review is read-only by prompt and plan approval mode.
  local command_text
  command_text="<timeout|gtimeout> \"$GEMINI_TIMEOUT_SECONDS\" gemini --approval-mode \"$GEMINI_APPROVAL_MODE\" --output-format \"$GEMINI_OUTPUT_FORMAT\" -p \"\$(cat $GEMINI_REVIEW_PROMPT; printf '\\n\\nProvider metadata:\\n- REVIEW_PROVIDER: gemini\\n- REVIEW_MODE: $REVIEW_MODE\\n- PLAN_FILE: $plan_file\\n\\nPlan to review:\\n'; cat '$plan_file')\""

  if [ "$DRY_RUN" != "0" ]; then
    write_dry_run "$output_file" "Gemini read-only plan review" "$command_text"
    return
  fi

  validate_gemini_timeout_seconds
  timeout_command="$(find_timeout_command)" || die "REVIEW_PROVIDER=gemini requires timeout or gtimeout to avoid hung review runs. Install coreutils or use REVIEW_PROVIDER=claude, REVIEW_PROVIDER=codex, or REVIEW_ENABLED=0."

  ensure_new_file "$output_file"
  if "$timeout_command" "$GEMINI_TIMEOUT_SECONDS" gemini --approval-mode "$GEMINI_APPROVAL_MODE" --output-format "$GEMINI_OUTPUT_FORMAT" -p "$gemini_input" > "$output_file"; then
    info "output written: $output_file"
    return
  fi

  exit_code=$?
  if [ "$exit_code" = "124" ]; then
    {
      printf '\n\n## Gemini Review Timeout\n\n'
      printf 'ERROR: Gemini review timed out after %s seconds.\n' "$GEMINI_TIMEOUT_SECONDS"
      printf 'The review is incomplete and must not be treated as successful.\n'
    } >> "$output_file"
    printf 'ERROR: Gemini review timed out after %s seconds. REVIEW_FILE is incomplete: %s\n' "$GEMINI_TIMEOUT_SECONDS" "$output_file" >&2
  else
    printf 'ERROR: Gemini review failed with exit code %s. REVIEW_FILE may be incomplete: %s\n' "$exit_code" "$output_file" >&2
  fi
  return "$exit_code"
}

run_claude_review_step() {
  local output_file="$1"
  local plan_file="$2"

  # Claude review is restricted to read-only tools and plan permission mode.
  local command_text
  command_text="claude -p \"\$(cat $CLAUDE_REVIEW_PROMPT; printf '\\n\\nProvider metadata:\\n- REVIEW_PROVIDER: claude\\n- REVIEW_MODE: $REVIEW_MODE\\n- PLAN_FILE: $plan_file\\n\\nPlan to review:\\n'; cat '$plan_file')\" --permission-mode plan --tools \"Read,Grep,Glob\" --max-turns \"$CLAUDE_MAX_TURNS\" --max-budget-usd \"$CLAUDE_MAX_BUDGET_USD\" --append-system-prompt \"\$(cat CLAUDE.md)\""

  run_or_dry "$output_file" "Claude read-only plan review" "$command_text" \
    claude \
    -p "$(cat "$(repo_path "$CLAUDE_REVIEW_PROMPT")"; printf '\n\nProvider metadata:\n'; printf -- '- REVIEW_PROVIDER: claude\n'; printf -- '- REVIEW_MODE: %s\n' "$REVIEW_MODE"; printf -- '- PLAN_FILE: %s\n' "$plan_file"; printf '\n\nPlan to review:\n'; cat "$plan_file")" \
    --permission-mode plan \
    --tools "Read,Grep,Glob" \
    --max-turns "$CLAUDE_MAX_TURNS" \
    --max-budget-usd "$CLAUDE_MAX_BUDGET_USD" \
    --append-system-prompt "$(cat "$(repo_path CLAUDE.md)")"
}

run_codex_review_step() {
  local output_file="$1"
  local plan_file="$2"

  # Codex fallback review is read-only and cannot request approvals.
  local command_text
  command_text="codex --sandbox read-only --ask-for-approval never -C . exec \"\$(cat $CODEX_REVIEW_PROMPT; printf '\\n\\nProvider metadata:\\n- REVIEW_PROVIDER: codex\\n- REVIEW_MODE: $REVIEW_MODE\\n- PLAN_FILE: $plan_file\\n\\nPlan to review:\\n'; cat '$plan_file')\""

  run_or_dry "$output_file" "Codex read-only fallback plan review" "$command_text" \
    codex --sandbox read-only --ask-for-approval never -C "." exec \
    "$(cat "$(repo_path "$CODEX_REVIEW_PROMPT")"; printf '\n\nProvider metadata:\n'; printf -- '- REVIEW_PROVIDER: codex\n'; printf -- '- REVIEW_MODE: %s\n' "$REVIEW_MODE"; printf -- '- PLAN_FILE: %s\n' "$plan_file"; printf '\n\nPlan to review:\n'; cat "$plan_file")"
}

run_review_step() {
  local output_file="$1"
  local plan_file="$2"

  case "$REVIEW_PROVIDER" in
    gemini) run_gemini_review_step "$output_file" "$plan_file" ;;
    claude) run_claude_review_step "$output_file" "$plan_file" ;;
    codex) run_codex_review_step "$output_file" "$plan_file" ;;
    *) die "unsupported REVIEW_PROVIDER: $REVIEW_PROVIDER" ;;
  esac
}

run_decision_step() {
  local output_file="$1"
  local plan_file="$2"
  local review_file="$3"

  # Codex final decision is read-only and evaluates the plan plus review artifact.
  local command_text
  command_text="codex --sandbox read-only --ask-for-approval never -C . exec \"\$(cat $DECISION_PROMPT; printf '\\n\\nOriginal plan:\\n'; cat '$plan_file'; printf '\\n\\nReview artifact (REVIEW_FILE=$review_file):\\n'; cat '$review_file')\""

  run_or_dry "$output_file" "Codex final review decision" "$command_text" \
    codex --sandbox read-only --ask-for-approval never -C "." exec \
    "$(cat "$(repo_path "$DECISION_PROMPT")"; printf '\n\nOriginal plan:\n'; cat "$plan_file"; printf '\n\nReview artifact (REVIEW_FILE=%s):\n' "$review_file"; cat "$review_file")"
}

cmd_plan() {
  require_common_paths
  require_agent_commands_for_actual_run 1 0 0

  local task_prompt
  local plan_task_prompt
  task_prompt="$(resolve_task_prompt "Create an inspect-only implementation plan for the requested Runiac task.")"
  run_high_risk_guard "plan" "$task_prompt"
  plan_task_prompt="$(task_prompt_for_plan "$task_prompt")"
  run_plan_step "$(new_plan_output_file)" "$plan_task_prompt"
}

cmd_review() {
  require_common_paths

  local plan_file="${PLAN_FILE:-}"
  [ -n "$plan_file" ] || die "PLAN_FILE is required for review"
  require_file "$plan_file"

  if [ "$REVIEW_ENABLED" = "0" ]; then
    require_skip_reason
    warn_review_disabled
    local skipped_review_file
    skipped_review_file="$(new_skipped_review_output_file)"
    if [ "$DRY_RUN" != "0" ]; then
      cat <<REVIEW_SKIP_DRY_RUN
# Review Dry Run Preview

DRY_RUN=1, so no provider will be invoked and no skipped-review artifact will be written.

REVIEW_ENABLED=0
External review is skipped.
REVIEW_PROVIDER is ignored when REVIEW_ENABLED=0.
SKIP_REASON=$SKIP_REASON

Would read PLAN_FILE:
$plan_file

Would write REVIEW_FILE as skipped-review artifact:
$skipped_review_file
REVIEW_SKIP_DRY_RUN
      return
    fi

    create_skipped_review_artifact "$skipped_review_file" "$plan_file"
    return
  fi

  local codex_needed claude_needed gemini_needed
  read -r codex_needed claude_needed gemini_needed <<<"$(review_provider_command_needs "$REVIEW_PROVIDER")"
  require_agent_commands_for_actual_run "$codex_needed" "$claude_needed" "$gemini_needed"
  run_review_step "$(new_review_output_file)" "$plan_file"
}

cmd_decision() {
  require_common_paths
  require_agent_commands_for_actual_run 1 0 0

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
  require_agent_commands_for_actual_run 1 0 0

  local plan_file="${PLAN_FILE:-}"
  [ -n "$plan_file" ] || die "PLAN_FILE is required for implement"
  require_file "$plan_file"
  run_high_risk_guard "implement" "Implement approved plan from PLAN_FILE=$plan_file"

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
  local context_packet_preview="${4:-}"
  local plan_prompt_description="<plan prompt + task>"

  if [ "$CONTEXT_PACKET_ENABLED" = "1" ]; then
    plan_prompt_description="<plan prompt + context packet + original task>"
  fi

  cat <<PIPELINE_DRY_RUN
# Pipeline Dry Run Preview

DRY_RUN=1, so Codex and review provider commands will not be invoked and no
plan/review/decision artifacts will be written.

Would run:

Review enabled:
   $REVIEW_ENABLED

Review provider:
   $([ "$REVIEW_ENABLED" = "1" ] && printf '%s' "$REVIEW_PROVIDER" || printf 'ignored because REVIEW_ENABLED=0')

Review mode:
   $REVIEW_MODE

Review prompt:
   $([ "$REVIEW_ENABLED" = "1" ] && selected_review_prompt || printf 'not used')

Context packet enabled:
   $CONTEXT_PACKET_ENABLED

PIPELINE_DRY_RUN

  if [ "$CONTEXT_PACKET_ENABLED" = "1" ]; then
    cat <<PIPELINE_DRY_RUN
0. Context packet generation

   $CONTEXT_PACKET_BUILDER

   The runner generated a context packet in memory, checked it against the
   $CONTEXT_PACKET_MAX_BYTES byte limit, and would prepend it to the original
   task prompt before Codex inspect-only planning.

   Context packet preview:

\`\`\`markdown
$context_packet_preview
\`\`\`

PIPELINE_DRY_RUN
  fi

  cat <<PIPELINE_DRY_RUN
1. Codex inspect-only plan

   codex --sandbox read-only --ask-for-approval never -C . exec "$plan_prompt_description"

   Would write PLAN_FILE:
   $plan_file

PIPELINE_DRY_RUN

  if [ "$REVIEW_ENABLED" = "1" ] && [ "$REVIEW_PROVIDER" = "gemini" ]; then
    cat <<PIPELINE_DRY_RUN
2. Gemini read-only plan review

   <timeout|gtimeout> "$GEMINI_TIMEOUT_SECONDS" gemini --approval-mode "$GEMINI_APPROVAL_MODE" --output-format "$GEMINI_OUTPUT_FORMAT" -p "<Gemini review prompt + provider metadata + PLAN_FILE content>"

   Would read PLAN_FILE:
   $plan_file

   Would write REVIEW_FILE:
   $review_file

PIPELINE_DRY_RUN
  elif [ "$REVIEW_ENABLED" = "1" ] && [ "$REVIEW_PROVIDER" = "claude" ]; then
    cat <<PIPELINE_DRY_RUN
2. Claude read-only plan review

   claude -p "<Claude review prompt + provider metadata + PLAN_FILE content>" --permission-mode plan --tools "Read,Grep,Glob" --max-turns "$CLAUDE_MAX_TURNS" --max-budget-usd "$CLAUDE_MAX_BUDGET_USD" --append-system-prompt "\$(cat CLAUDE.md)"

   Would read PLAN_FILE:
   $plan_file

   Would write REVIEW_FILE:
   $review_file

PIPELINE_DRY_RUN
  elif [ "$REVIEW_ENABLED" = "1" ] && [ "$REVIEW_PROVIDER" = "codex" ]; then
    cat <<PIPELINE_DRY_RUN
2. Codex read-only fallback plan review

   codex --sandbox read-only --ask-for-approval never -C . exec "<Codex reviewer prompt + provider metadata + PLAN_FILE content>"

   Would read PLAN_FILE:
   $plan_file

   Would write REVIEW_FILE:
   $review_file

PIPELINE_DRY_RUN
  else
    cat <<PIPELINE_DRY_RUN
2. External review skipped

   External review is skipped because REVIEW_ENABLED=0.
   REVIEW_PROVIDER is ignored.
   SKIP_REASON:
   $SKIP_REASON

   Would read PLAN_FILE:
   $plan_file

   Would write REVIEW_FILE as skipped-review artifact:
   $review_file

   Codex decision will use the skipped-review artifact as REVIEW_FILE.

PIPELINE_DRY_RUN
  fi

  cat <<PIPELINE_DRY_RUN
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
  require_skip_reason
  if [ "$REVIEW_ENABLED" = "0" ]; then
    warn_review_disabled
  fi

  local task_prompt
  local plan_task_prompt
  local context_packet_preview=""
  task_prompt="$(resolve_task_prompt)"
  run_high_risk_guard "pipeline" "$task_prompt"
  plan_task_prompt="$(task_prompt_for_plan "$task_prompt")"
  if [ "$CONTEXT_PACKET_ENABLED" = "1" ]; then
    context_packet_preview="${plan_task_prompt%%$'\n\n---\n\n'*}"
  fi

  local plan_file
  local review_file
  local decision_file
  plan_file="$(new_plan_output_file)"
  if [ "$REVIEW_ENABLED" = "1" ]; then
    review_file="$(new_review_output_file)"
  else
    review_file="$(new_skipped_review_output_file)"
  fi
  decision_file="$(new_decision_output_file)"

  if [ "$DRY_RUN" != "0" ]; then
    print_pipeline_dry_run "$plan_file" "$review_file" "$decision_file" "$context_packet_preview"
    return
  fi

  local provider_codex_needed=0
  local provider_claude_needed=0
  local provider_gemini_needed=0
  if [ "$REVIEW_ENABLED" = "1" ]; then
    read -r provider_codex_needed provider_claude_needed provider_gemini_needed <<<"$(review_provider_command_needs "$REVIEW_PROVIDER")"
  fi
  require_agent_commands_for_actual_run 1 "$provider_claude_needed" "$provider_gemini_needed"

  if ! run_plan_step "$plan_file" "$plan_task_prompt"; then
    pipeline_failed "plan" "$plan_file" || true
    return 1
  fi

  if [ "$REVIEW_ENABLED" = "1" ]; then
    if ! run_review_step "$review_file" "$plan_file"; then
      pipeline_failed "review" "$review_file" || true
      return 1
    fi
  else
    if ! create_skipped_review_artifact "$review_file" "$plan_file"; then
      pipeline_failed "skipped-review artifact" "$review_file" || true
      return 1
    fi
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
