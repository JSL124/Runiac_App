#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-historical-isolation"
needle="docs/meta"
failures=0
scanned_paths=""

scan_targets=(
  "implementation/roadmap/CURRENT.md"
  "implementation/roadmap/phases/"
  "implementation/roadmap/capsules/"
  "implementation/roadmap/snapshots/"
  "AGENTS.md"
)

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

for target in "${scan_targets[@]}"; do
  if [ ! -e "$target" ]; then
    continue
  fi

  if [ -z "$scanned_paths" ]; then
    scanned_paths="$target"
  else
    scanned_paths="$scanned_paths,$target"
  fi

  matches="$(grep -rsn -- "$needle" "$target" || true)"
  if [ -n "$matches" ]; then
    fail "ERROR: historical archive contamination detected in operational routing/governance chain: $target"
    printf '%s\n' "$matches"
  fi
done

if [ -z "$scanned_paths" ]; then
  scanned_paths="<none>"
fi

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Historical archive is isolated from operational routing and governance targets.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Historical archive contamination detected. docs/meta must not be referenced by operational routing, governance, planning, approval, or execution inputs.\n'
printf 'next_step=Remove docs/meta references from operational-chain targets and rerun this check.\n'
exit 1
