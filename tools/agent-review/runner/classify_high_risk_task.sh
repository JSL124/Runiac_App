#!/usr/bin/env bash

set -u
set -o pipefail

error() {
  printf 'ERROR: %s\n' "$*" >&2
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

contains() {
  case "$normalized_input" in
    *"$1"*) return 0 ;;
    *) return 1 ;;
  esac
}

positive_contains() {
  case "$positive_input" in
    *"$1"*) return 0 ;;
    *) return 1 ;;
  esac
}

add_signal() {
  local signal="$1"
  case ",$signals," in
    *",$signal,"*) ;;
    *) signals="${signals:+$signals,}$signal" ;;
  esac
}

guard_enabled="${HIGH_RISK_GUARD_ENABLED:-1}"
high_risk_approved="${HIGH_RISK_APPROVED:-0}"
high_risk_reason="$(trim "${HIGH_RISK_REASON:-}")"
dry_run="${DRY_RUN:-1}"
review_enabled="${REVIEW_ENABLED:-1}"
review_mode="${REVIEW_MODE:-standard}"
context_packet_enabled="${CONTEXT_PACKET_ENABLED:-0}"
context_class="${CONTEXT_CLASS:-}"
allow_paths="${ALLOW_PATHS:-}"
subcommand="${AGENT_REVIEW_SUBCOMMAND:-}"

case "$guard_enabled" in
  1|0) ;;
  *)
    error "HIGH_RISK_GUARD_ENABLED must be 1 or 0. Got: \"$guard_enabled\""
    exit 3
    ;;
esac

case "$high_risk_approved" in
  1|0) ;;
  *)
    error "HIGH_RISK_APPROVED must be 1 or 0. Got: \"$high_risk_approved\""
    exit 3
    ;;
esac

if [ "$high_risk_approved" = "1" ] && [ -z "$high_risk_reason" ]; then
  error "HIGH_RISK_APPROVED=1 requires HIGH_RISK_REASON to be non-empty."
  exit 3
fi

if [ "$guard_enabled" = "0" ]; then
  warn "High-risk guard disabled by HIGH_RISK_GUARD_ENABLED=0."
  printf 'HIGH_RISK_LEVEL=none\n'
  printf 'HIGH_RISK_SIGNALS=guard_disabled\n'
  printf 'HIGH_RISK_APPROVAL_REQUIRED=no\n'
  printf 'HIGH_RISK_MESSAGE=High-risk guard disabled by environment.\n'
  exit 0
fi

if [ "${TASK_PROMPT+x}" = x ]; then
  task_prompt="$TASK_PROMPT"
elif [ "${TASK_PROMPT_FILE+x}" = x ]; then
  if [ ! -f "$TASK_PROMPT_FILE" ]; then
    error "TASK_PROMPT_FILE not found: $TASK_PROMPT_FILE"
    exit 3
  fi
  task_prompt="$(<"$TASK_PROMPT_FILE")"
else
  task_prompt=""
fi

raw_input="$task_prompt
$allow_paths
$subcommand
$context_class
DRY_RUN=$dry_run
REVIEW_ENABLED=$review_enabled
REVIEW_MODE=$review_mode
CONTEXT_PACKET_ENABLED=$context_packet_enabled"
normalized_input="$(printf '%s' "$raw_input" | tr '[:upper:]' '[:lower:]' | tr '\n' ' ')"
positive_input="$normalized_input"

for negated_phrase in \
  "do not run firebase init" \
  "do not create firebase config" \
  "do not create firebase.json" \
  "do not create .firebaserc" \
  "do not create firestore.rules" \
  "do not create storage.rules" \
  "do not modify prd.md" \
  "do not edit prd.md" \
  "do not modify docs/pdd" \
  "do not edit docs/pdd" \
  "do not edit submitted pdd" \
  "do not modify submitted pdd" \
  "do not add api key" \
  "do not add an api key" \
  "do not add secret" \
  "do not add token" \
  "do not create .env" \
  "do not modify .env" \
  "do not run flutter create" \
  "do not run flutter build" \
  "do not run npm install" \
  "do not run firebase deploy" \
  "must not run firebase init" \
  "must not create firebase config" \
  "must not modify prd.md" \
  "without running firebase init" \
  "without creating firebase config" \
  "without modifying prd.md"
do
  positive_input="${positive_input//$negated_phrase/ }"
done

signals=""
level="none"
message="No high-risk guard signals detected."

design_only=0
case "$normalized_input" in
  *"design only"*|*"design-only"*|*"plan only"*|*"plan-only"*|*"inspect only"*|*"inspect-only"*|*"report only"*|*"report-only"*) design_only=1 ;;
esac

negated_risky_action=0
case "$normalized_input" in
  *"do not run"*|*"do not create"*|*"do not modify"*|*"do not init"*|*"do not initialize"*|*"must not run"*|*"must not create"*|*"must not modify"*|*"must not init"*|*"without running"*|*"without creating"*|*"without modifying"*) negated_risky_action=1 ;;
esac

positive_risky_action=0
if positive_contains "run firebase init" || positive_contains "create firebase.json" || positive_contains "create .firebaserc" || positive_contains "create firestore.rules" || positive_contains "create storage.rules" || positive_contains "modify prd.md" || positive_contains "edit prd.md" || positive_contains "modify docs/pdd" || positive_contains "edit docs/pdd" || positive_contains "edit submitted pdd" || positive_contains "modify submitted pdd" || positive_contains "add api key" || positive_contains "add an api key" || positive_contains "add secret" || positive_contains "add token" || positive_contains "create .env" || positive_contains "modify .env" || positive_contains "implement client-side xp" || positive_contains "client writes xp" || positive_contains "write rank from flutter" || positive_contains "llm awards xp" || positive_contains "ai awards xp" || positive_contains "firebase deploy" || positive_contains "flutter create" || positive_contains "flutter build" || positive_contains "npm install" || positive_contains "rm -rf"; then
  positive_risky_action=1
fi

if contains "docs/submissions" || contains "submitted pdd" || contains "official frozen snapshot"; then
  add_signal "frozen_assessment_paths"
fi

if contains "prd.md" || contains "docs/pdd" || contains "pdd baseline"; then
  add_signal "prd_pdd_baseline_paths"
fi

if contains "flutter create" || contains "firebase init" || contains "firebase.json" || contains ".firebaserc" || contains "pubspec.yaml" || contains "package.json for functions" || contains "tsconfig.json for functions" || contains "firestore.rules" || contains "storage.rules" || contains "implementation/mobile/runiac_app" || contains "firebase/functions" || contains "firebase/firestore" || contains "firebase/storage"; then
  add_signal "flutter_firebase_scaffolding"
fi

if contains "firebase rules" || contains "firestore rules" || contains "storage rules" || contains "cloud functions" || contains "firebase config" || contains "firebase deploy" || contains "firebase emulators"; then
  add_signal "firebase_rules_config_functions"
fi

if contains ".env" || contains "api key" || contains "apikey" || contains "secret" || contains "token" || contains "private key" || contains "service account" || contains "google-services.json" || contains "googleservice-info.plist" || contains "production project id"; then
  add_signal "secrets_env_api_keys_project_ids"
fi

if contains "precise gps" || contains "private gps" || contains "raw route coordinates" || contains "exact location history"; then
  add_signal "precise_gps_private_data"
fi

if contains "client-side xp" || contains "client writes xp" || contains "write rank from flutter" || contains "leaderboard score from client" || contains "streak update from client" || contains "level update from client" || contains "weekly xp write" || contains "monthly xp write" || contains "leaderboard writes"; then
  add_signal "xp_streak_rank_leaderboard_ownership"
fi

if contains "bypass subscriptionstatus" || contains "bypass userrole" || contains "client writes subscriptionstatus" || contains "client writes userrole" || contains "premium access bypass"; then
  add_signal "subscription_userrole_access_control"
fi

if contains "llm awards xp" || contains "ai awards xp" || contains "llm ranks users" || contains "ai leaderboard scoring" || contains "llm official score"; then
  add_signal "ai_llm_scoring_ranking_misuse"
fi

if contains "delete many files" || contains "remove docs/pdd" || contains "rename wireframe_assets" || contains "move submitted docs" || contains "mass delete" || contains "rm -rf"; then
  add_signal "destructive_file_operations"
fi

if contains "npm install" || contains "npm test" || contains "npm run build" || contains "flutter test" || contains "flutter build" || contains "firebase deploy" || contains "firebase emulators" || contains "firebase init"; then
  add_signal "build_test_deploy_tool_commands"
fi

if contains "skip approval" || contains "bypass review" || contains "ignore guard" || contains "force implement" || contains "implement without approval"; then
  add_signal "review_approval_bypass_language"
fi

if [ "$review_enabled" = "0" ] && [ -n "$signals" ]; then
  add_signal "review_disabled_with_high_risk"
fi

if [ -n "$signals" ]; then
  level="block"
  message="High-risk guard signals detected: $signals"
fi

if [ "$level" = "block" ] && { [ "$design_only" = "1" ] || [ "$negated_risky_action" = "1" ]; } && [ "$positive_risky_action" = "0" ]; then
  level="warning"
  message="Risk keywords appear in design-only, inspect-only, or negated context."
fi

if [ "$level" = "block" ] && [ "$high_risk_approved" = "1" ]; then
  printf 'HIGH_RISK_LEVEL=block\n'
  printf 'HIGH_RISK_SIGNALS=%s\n' "$signals"
  printf 'HIGH_RISK_APPROVAL_REQUIRED=yes\n'
  printf 'HIGH_RISK_MESSAGE=High-risk task explicitly approved: %s\n' "$high_risk_reason"
  exit 0
fi

case "$level" in
  none)
    printf 'HIGH_RISK_LEVEL=none\n'
    printf 'HIGH_RISK_SIGNALS=none\n'
    printf 'HIGH_RISK_APPROVAL_REQUIRED=no\n'
    printf 'HIGH_RISK_MESSAGE=%s\n' "$message"
    exit 0
    ;;
  warning)
    printf 'HIGH_RISK_LEVEL=warning\n'
    printf 'HIGH_RISK_SIGNALS=%s\n' "$signals"
    printf 'HIGH_RISK_APPROVAL_REQUIRED=no\n'
    printf 'HIGH_RISK_MESSAGE=%s\n' "$message"
    exit 0
    ;;
  block)
    error "High-risk task blocked."
    printf 'HIGH_RISK_LEVEL=block\n'
    printf 'HIGH_RISK_SIGNALS=%s\n' "$signals"
    printf 'HIGH_RISK_APPROVAL_REQUIRED=yes\n'
    printf 'HIGH_RISK_MESSAGE=%s\n' "$message"
    exit 2
    ;;
esac
