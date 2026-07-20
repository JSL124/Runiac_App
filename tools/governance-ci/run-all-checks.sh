#!/usr/bin/env bash
set -uo pipefail

initial_logical_pwd="${PWD:-$(pwd)}"
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

checks=(
  "tools/governance-ci/check-canonical-root.sh"
  "tools/governance-ci/check-agent-governance.sh"
  "tools/governance-ci/check-diff-hygiene.sh"
  "tools/governance-ci/check-pre-scaffold-scope.sh"
  "tools/governance-ci/check-roadmap-routing.sh"
  "tools/governance-ci/check-historical-isolation.sh"
  "tools/governance-ci/check-sensitive-paths.sh"
  "tools/governance-ci/check-workflow-memory-drift.sh"
  "tools/governance-ci/measure-context-overhead.sh"
  "tests/governance/backend_functions_scope_test.sh"
  "tests/governance/config_contract_drift_test.sh"
)

failures=0

for check in "${checks[@]}"; do
  if [ ! -x "$check" ]; then
    printf 'FAIL %s exit=127 message=check is missing or not executable\n' "$check"
    failures=$((failures + 1))
    continue
  fi

  RUNIAC_INITIAL_LOGICAL_PWD="$initial_logical_pwd" "$check"
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
