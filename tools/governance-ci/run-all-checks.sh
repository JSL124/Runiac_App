#!/usr/bin/env bash
set -uo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

checks=(
  "tools/governance-ci/check-agent-governance.sh"
  "tools/governance-ci/check-diff-hygiene.sh"
  "tools/governance-ci/check-pre-scaffold-scope.sh"
  "tools/governance-ci/check-roadmap-routing.sh"
  "tools/governance-ci/check-sensitive-paths.sh"
)

failures=0

for check in "${checks[@]}"; do
  if [ ! -x "$check" ]; then
    printf 'FAIL %s exit=127 message=check is missing or not executable\n' "$check"
    failures=$((failures + 1))
    continue
  fi

  "$check"
  status=$?

  if [ "$status" -eq 0 ]; then
    printf 'PASS %s\n' "$check"
  else
    printf 'FAIL %s exit=%s\n' "$check" "$status"
    failures=$((failures + 1))
  fi
done

if [ "$failures" -eq 0 ]; then
  printf 'All Governance CI checks passed.\n'
  exit 0
fi

printf 'Governance CI checks failed: %s\n' "$failures"
exit 1
