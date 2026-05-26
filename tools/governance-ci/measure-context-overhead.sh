#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="measure-context-overhead"
current_file="implementation/roadmap/CURRENT.md"
snapshot_file="implementation/roadmap/snapshots/latest.md"
hot_list="$(mktemp)"
warm_list="$(mktemp)"
cold_list="$(mktemp)"
failures=0

cleanup() {
  rm -f "$hot_list" "$warm_list" "$cold_list"
}
trap cleanup EXIT

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

add_file() {
  list_file="$1"
  path="$2"
  required="${3:-optional}"

  if [ -f "$path" ]; then
    printf '%s\n' "$path" >> "$list_file"
    return
  fi

  if [ "$required" = "required" ]; then
    fail "Required context file missing: $path"
  fi
}

add_glob() {
  list_file="$1"
  shift

  for path in "$@"; do
    [ -f "$path" ] || continue
    printf '%s\n' "$path" >> "$list_file"
  done
}

dedupe_list() {
  list_file="$1"
  tmp_file="$(mktemp)"
  sort -u "$list_file" > "$tmp_file"
  mv "$tmp_file" "$list_file"
}

count_list() {
  list_file="$1"
  files=0
  lines=0

  while IFS= read -r path; do
    [ -n "$path" ] || continue
    files=$((files + 1))
    file_lines="$(wc -l < "$path" | awk '{print $1}')"
    lines=$((lines + file_lines))
  done < "$list_file"

  printf '%s %s\n' "$files" "$lines"
}

add_file "$hot_list" "$current_file" required

active_capsule=""
if [ -f "$current_file" ]; then
  active_capsule="$(sed -n 's/^- Current active capsule: `\([^`][^`]*\)`.*/\1/p' "$current_file")"
fi

if [ -n "$active_capsule" ]; then
  add_file "$hot_list" "$active_capsule" required
fi

add_file "$hot_list" "$snapshot_file" required

add_file "$warm_list" "AGENTS.md" optional
add_file "$warm_list" "implementation/AGENTS.md" optional
add_file "$warm_list" "implementation/mobile/AGENTS.md" optional
add_file "$warm_list" "implementation/traceability/setup-gates.md" optional
add_file "$warm_list" "docs/pdd/AGENTS_CHANGELOG.md" optional
add_glob "$warm_list" implementation/roadmap/phases/*.md
add_glob "$warm_list" implementation/roadmap/decisions/*.md
add_glob "$warm_list" implementation/roadmap/ci/*.md
add_glob "$warm_list" tools/governance-ci/*.sh
add_glob "$warm_list" tools/agent-review/templates/*.md

add_glob "$cold_list" docs/meta/*.md
add_glob "$cold_list" implementation/roadmap/capsules/*.md
add_glob "$cold_list" implementation/roadmap/snapshots/archive/*.md
add_glob "$cold_list" implementation/traceability/plans/*.md
add_glob "$cold_list" implementation/traceability/reviews/*.md
add_glob "$cold_list" implementation/traceability/decisions/*.md
add_file "$cold_list" "implementation/roadmap/roadmap-stretch.md" optional
add_file "$cold_list" "implementation/roadmap/roadmap-summary.md" optional

dedupe_list "$hot_list"
dedupe_list "$warm_list"
dedupe_list "$cold_list"

read hot_files hot_lines <<EOF
$(count_list "$hot_list")
EOF

read warm_files warm_lines <<EOF
$(count_list "$warm_list")
EOF

read cold_files cold_lines <<EOF
$(count_list "$cold_list")
EOF

total_lines=$((hot_lines + warm_lines + cold_lines))
if [ "$total_lines" -gt 0 ]; then
  hot_path_ratio="$(awk -v hot="$hot_lines" -v total="$total_lines" 'BEGIN { printf "%.1f", (hot / total) * 100 }')"
else
  hot_path_ratio="0.0"
fi

printf 'CONTEXT_OVERHEAD hot_files=%s hot_lines=%s\n' "$hot_files" "$hot_lines"
printf 'CONTEXT_OVERHEAD warm_files=%s warm_lines=%s\n' "$warm_files" "$warm_lines"
printf 'CONTEXT_OVERHEAD cold_files=%s cold_lines=%s\n' "$cold_files" "$cold_lines"
printf 'CONTEXT_OVERHEAD total_governance_lines=%s\n' "$total_lines"
printf 'CONTEXT_OVERHEAD hot_path_ratio=%s%%\n' "$hot_path_ratio"

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'message=Context overhead measurement completed without enforcing advisory line-count thresholds.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'message=Context overhead measurement could not classify required files.\n'
exit 1
