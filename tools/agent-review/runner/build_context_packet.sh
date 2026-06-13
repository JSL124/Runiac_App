#!/usr/bin/env bash

set -u
set -o pipefail

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

require_ruby() {
  if ! command -v ruby >/dev/null 2>&1; then
    die "Ruby is required to parse context-policy.yml. Install Ruby or run this tool in an environment with Ruby stdlib YAML available."
  fi
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
agent_review_dir="$(cd "$script_dir/.." && pwd)"
repo_root="$(cd "$agent_review_dir/../.." && pwd)"

profile="${PROFILE:-runiac}"
policy_file="$repo_root/tools/agent-review/profiles/$profile/context-policy.yml"

require_ruby

if [ ! -f "$policy_file" ]; then
  die "Policy file not found: tools/agent-review/profiles/$profile/context-policy.yml"
fi

ruby -e 'require "yaml"; YAML.load_file(ARGV.fetch(0))' "$policy_file" \
  || die "Invalid YAML syntax in tools/agent-review/profiles/$profile/context-policy.yml"

ruby -e '
  require "yaml"
  data = YAML.load_file(ARGV.fetch(0))
  required = %w[
    schema_version
    context_classes
    always_read
    allowed_paths
    excluded_paths
    review_file_budgets
    inventory_limits
    unknown_context_behavior
    explicit_allow_behavior
    non_negotiable_invariants
    forbidden_content_patterns
  ]
  missing = required.reject { |key| data.is_a?(Hash) && data.key?(key) }
  abort("Missing required context-policy.yml keys: #{missing.join(", ")}") unless missing.empty?
' "$policy_file" || exit 1

if [ "${TASK_PROMPT+x}" = x ]; then
  task_prompt="$TASK_PROMPT"
elif [ "${TASK_PROMPT_FILE+x}" = x ]; then
  [ -f "$TASK_PROMPT_FILE" ] || die "TASK_PROMPT_FILE not found: $TASK_PROMPT_FILE"
  task_prompt="$(<"$TASK_PROMPT_FILE")"
else
  task_prompt=""
fi

allow_justification="$(trim "${ALLOW_JUSTIFICATION:-}")"
if [ "${ALLOW_PATHS+x}" = x ] && [ -n "$ALLOW_PATHS" ]; then
  allow_path_count=0
  IFS=',' read -r -a allow_path_items_for_policy <<<"$ALLOW_PATHS"
  for raw_path in "${allow_path_items_for_policy[@]}"; do
    path="$(trim "$raw_path")"
    [ -n "$path" ] || continue
    allow_path_count=$((allow_path_count + 1))
  done
  if [ "$allow_path_count" -gt 5 ]; then
    die "ALLOW_PATHS has $allow_path_count non-empty entries; maximum is 5."
  fi
  if [ "$allow_path_count" -gt 0 ] && [ -z "$allow_justification" ]; then
    die "ALLOW_JUSTIFICATION is required when ALLOW_PATHS is non-empty."
  fi
fi

selected_class=""
class_source="unknown"

if [ "${CONTEXT_CLASS+x}" = x ] && [ -n "$CONTEXT_CLASS" ]; then
  selected_class="$CONTEXT_CLASS"
  class_source="user-declared"
elif [[ "$task_prompt" =~ Context[[:space:]]+Class:[[:space:]]*([A-Za-z0-9_-]+) ]]; then
  selected_class="${BASH_REMATCH[1]}"
  class_source="task-prompt"
else
  selected_class="unknown"
  class_source="unknown"
fi

unknown_behavior="$(ruby -e 'require "yaml"; puts YAML.load_file(ARGV.fetch(0)).fetch("unknown_context_behavior")' "$policy_file")" \
  || die "Could not read unknown_context_behavior from context-policy.yml"

class_exists="$(SELECTED_CLASS="$selected_class" ruby -e '
  require "yaml"
  data = YAML.load_file(ARGV.fetch(0))
  puts data.fetch("context_classes").key?(ENV.fetch("SELECTED_CLASS")) ? "yes" : "no"
' "$policy_file")" || die "Could not validate selected context class"

if [ "$class_exists" != "yes" ]; then
  die "Unknown context class '$selected_class'. Valid classes are defined in context-policy.yml."
fi

if [ "$selected_class" = "unknown" ] && [ "$unknown_behavior" = "reject" ]; then
  die "Context class could not be determined and unknown_context_behavior is reject. Set CONTEXT_CLASS or include 'Context Class: <class>' in TASK_PROMPT."
fi

if [ "$class_source" = "user-declared" ]; then
  reason="User explicitly declared context class '$selected_class'."
  excluded_classes="N/A — user explicitly declared class"
elif [ "$class_source" = "task-prompt" ]; then
  reason="Task prompt declared context class '$selected_class'."
  excluded_classes="docs: only if the task is documentation-only; feature: only if application behavior changes are requested."
else
  reason="No context class declaration was found."
  excluded_classes="N/A — classification failed"
fi

default_review_mode="$(SELECTED_CLASS="$selected_class" ruby -e '
  require "yaml"
  classes = YAML.load_file(ARGV.fetch(0)).fetch("context_classes")
  puts classes.fetch(ENV.fetch("SELECTED_CLASS"), {}).fetch("default_review_mode", "standard")
' "$policy_file")" || default_review_mode="standard"

review_enabled="${REVIEW_ENABLED:-1}"
review_mode="${REVIEW_MODE:-$default_review_mode}"
case "$review_enabled" in
  0|1) ;;
  *) die "REVIEW_ENABLED must be 1 or 0." ;;
esac
case "$review_mode" in
  lite|standard) ;;
  *) die "REVIEW_MODE must be lite or standard." ;;
esac

file_budget="$(REVIEW_MODE_VALUE="$review_mode" ruby -e '
  require "yaml"
  budgets = YAML.load_file(ARGV.fetch(0)).fetch("review_file_budgets")
  puts budgets[ENV.fetch("REVIEW_MODE_VALUE")] || budgets["default"] || 0
' "$policy_file")" || die "Could not read review_file_budgets from context-policy.yml"

if [ "$review_enabled" = "0" ]; then
  skip_reason_required="yes"
else
  skip_reason_required="no"
fi

max_listed_files="$(ruby -e 'require "yaml"; puts YAML.load_file(ARGV.fetch(0)).fetch("inventory_limits").fetch("max_listed_files")' "$policy_file")" \
  || die "Could not read inventory_limits.max_listed_files"
max_directory_depth="$(ruby -e 'require "yaml"; puts YAML.load_file(ARGV.fetch(0)).fetch("inventory_limits").fetch("max_directory_depth")' "$policy_file")" \
  || die "Could not read inventory_limits.max_directory_depth"
max_inventory_bytes="$(ruby -e 'require "yaml"; puts YAML.load_file(ARGV.fetch(0)).fetch("inventory_limits").fetch("max_inventory_bytes")' "$policy_file")" \
  || die "Could not read inventory_limits.max_inventory_bytes"

allowed_from_policy() {
  SELECTED_CLASS="$selected_class" ruby -e '
    require "yaml"
    data = YAML.load_file(ARGV.fetch(0))
    keys = data.fetch("context_classes").fetch(ENV.fetch("SELECTED_CLASS")).fetch("allowed_path_keys", [])
    keys.each do |key|
      paths = key == "always_read" ? data.fetch("always_read") : data.fetch("allowed_paths").fetch(key, [])
      puts "- #{key}: #{paths.empty? ? "(no paths)" : paths.join(", ")}"
    end
  ' "$policy_file"
}

excluded_from_policy() {
  ruby -e '
    require "yaml"
    data = YAML.load_file(ARGV.fetch(0))
    data.fetch("excluded_paths").each do |category, paths|
      if category.to_s == "sensitive"
        puts "- #{category}: configured sensitive/generated config exclusions (see context-policy.yml)"
      else
        puts "- #{category}: #{Array(paths).join(", ")}"
      end
    end
  ' "$policy_file"
}

invariants_from_policy() {
  ruby -e '
    require "yaml"
    invariants = YAML.load_file(ARGV.fetch(0)).fetch("non_negotiable_invariants")
    if invariants.empty?
      puts "- None configured."
    else
      invariants.each { |item| puts "- #{item}" }
    end
  ' "$policy_file"
}

forbidden_summary_from_policy() {
  ruby -e '
    require "yaml"
    patterns = YAML.load_file(ARGV.fetch(0)).fetch("forbidden_content_patterns")
    if patterns.empty?
      puts "- None configured."
    else
      patterns.each do |entry|
        description = entry.is_a?(Hash) ? entry.fetch("description", "Unnamed category") : entry.to_s
        count = entry.is_a?(Hash) ? Array(entry["patterns"]).length : 0
        if count > 5
          puts "- #{description} (#{count} patterns, see context-policy.yml)"
        else
          puts "- #{description}"
        end
      end
    end
  ' "$policy_file"
}

appears_excluded() {
  local path
  path="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$path" in
    .env|.env.*|*.env|*/.env|*/.env.*) return 0 ;;
    secrets/*|*/secrets/*|docs/submissions/*|*/docs/submissions/*) return 0 ;;
    test-evidence/*|*/test-evidence/*) return 0 ;;
    firebase_options.dart|*/firebase_options.dart) return 0 ;;
    google-services.json|*/google-services.json) return 0 ;;
    googleservice-info.plist|*/googleservice-info.plist) return 0 ;;
    *service-account*.json|*serviceaccount*.json|*-service-account.json|*.credentials.json) return 0 ;;
    .firebase/*|*/.firebase/*|.firebaserc|*/.firebaserc|.runtimeconfig.json|*/.runtimeconfig.json) return 0 ;;
    firebase-export-*/*|*/firebase-export-*/*) return 0 ;;
    android/local.properties|*/android/local.properties|android/key.properties|*/android/key.properties) return 0 ;;
    *.jks|*.keystore|*.p12|*.cer|*.mobileprovision|*.p8) return 0 ;;
    *gps-private*|*private-gps*|*route-private*|*private-route*|*location-private*|*private-location*) return 0 ;;
    *node_modules/*|*/build/*|build/*|*.dart_tool/*|*/.dart_tool/*|.git/*|*/.git/*) return 0 ;;
    *.pdf|*.png|*.jpg|*.jpeg|*.svg) return 0 ;;
  esac
  return 1
}

allowed_paths_output=""
if [ "${ALLOW_PATHS+x}" = x ] && [ -n "$ALLOW_PATHS" ]; then
  IFS=',' read -r -a allow_path_items <<<"$ALLOW_PATHS"
  for raw_path in "${allow_path_items[@]}"; do
    path="$(trim "$raw_path")"
    [ -n "$path" ] || continue
    if appears_excluded "$path"; then
      warn "Allow path appears to match excluded_paths and is marked as override: $path"
      allowed_paths_output+="- [OVERRIDE] $path"$'\n'
    else
      allowed_paths_output+="- $path"$'\n'
    fi
  done
else
  allowed_paths_output="$(allowed_from_policy)"$'\n'
fi

excluded_paths_output="$(excluded_from_policy)"
applied_invariants_output="$(invariants_from_policy)"
forbidden_summary_output="$(forbidden_summary_from_policy)"

inventory_status="$(cd "$repo_root" && git status --short 2>/dev/null)"
if [ -z "$inventory_status" ]; then
  inventory_status="(clean)"
fi

broad_exclusions="node_modules, build, .dart_tool, .git, docs/submissions, test-evidence, secrets, .env files, Firebase/mobile generated config, PDFs, images, SVGs"

if cd "$repo_root" && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  file_list="$(cd "$repo_root" && git ls-files \
    | grep -Eiv '(^|/)(node_modules|build|\.dart_tool|\.git|secrets|test-evidence|\.firebase)(/|$)|^docs/submissions/|(^|/)\.env(\.|$)|(^|/)[^/]+\.env$|(^|/)firebase_options\.dart$|(^|/)google-services\.json$|(^|/)googleservice-info\.plist$|(^|/).*service-?account.*\.json$|(^|/)serviceaccount.*\.json$|(^|/).*\.credentials\.json$|(^|/)\.firebaserc$|(^|/)\.runtimeconfig\.json$|(^|/)firebase-export-[^/]+/|(^|/)android/(local|key)\.properties$|\.(jks|keystore|p12|cer|mobileprovision|p8)$|gps-private|private-gps|route-private|private-route|location-private|private-location|\.(pdf|png|jpg|jpeg|svg)$' \
    | head -n "$max_listed_files")"
  inventory_source="git ls-files"
else
  file_list="$(cd "$repo_root" && find . -maxdepth "$max_directory_depth" -type f \
    | grep -Eiv '(^|/)(node_modules|build|\.dart_tool|\.git|secrets|test-evidence|\.firebase)(/|$)|^\./docs/submissions/|(^|/)\.env(\.|$)|(^|/)[^/]+\.env$|(^|/)firebase_options\.dart$|(^|/)google-services\.json$|(^|/)googleservice-info\.plist$|(^|/).*service-?account.*\.json$|(^|/)serviceaccount.*\.json$|(^|/).*\.credentials\.json$|(^|/)\.firebaserc$|(^|/)\.runtimeconfig\.json$|(^|/)firebase-export-[^/]+/|(^|/)android/(local|key)\.properties$|\.(jks|keystore|p12|cer|mobileprovision|p8)$|gps-private|private-gps|route-private|private-route|location-private|private-location|\.(pdf|png|jpg|jpeg|svg)$' \
    | head -n "$max_listed_files")"
  inventory_source="find -maxdepth $max_directory_depth"
fi

if [ -z "$file_list" ]; then
  file_list="(no files listed)"
fi

inventory_summary="- Source: $inventory_source
- Listed files limit: $max_listed_files
- Directory depth limit: $max_directory_depth
- Inventory byte limit: $max_inventory_bytes"

inventory_body="### Git Status Summary
\`\`\`text
$inventory_status
\`\`\`

### Compact File List
\`\`\`text
$file_list
\`\`\`

### Applied Broad Exclusions
$broad_exclusions"

inventory_bytes="$(printf '%s' "$inventory_body" | wc -c | tr -d ' ')"
if [ "$inventory_bytes" -gt "$max_inventory_bytes" ]; then
  inventory_body="$(printf '%s' "$inventory_body" | head -c "$max_inventory_bytes")

[TRUNCATED — exceeded max_inventory_bytes limit]"
fi

cat <<EOF
Standalone only — not integrated into run_plan_review.sh yet.

## Context Class Decision

- selected_class: $selected_class
- reason: $reason
- source: $class_source
- excluded_classes_considered: $excluded_classes

## Plan Scope

### allowed_planning_paths
$allowed_paths_output
### excluded_planning_paths
$excluded_paths_output

### inventory_summary
$inventory_summary

### applied_invariants
$applied_invariants_output

## Review Budget Hint

- review_enabled: $review_enabled
- review_mode: $review_mode
- file_budget: $file_budget
- skip_reason_required: $skip_reason_required

## Forbidden Content Pattern Summary

$forbidden_summary_output

## Inventory

$inventory_body
EOF
