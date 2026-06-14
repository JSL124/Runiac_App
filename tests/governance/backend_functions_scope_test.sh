#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"
tmp_dir="$(mktemp -d)"
current_backup="$tmp_dir/CURRENT.md"
cp implementation/roadmap/CURRENT.md "$current_backup"

cleanup_probes() {
  rm -f functions/.runiac-governance-probe.js functions/src/.runiac-governance-probe.ts
}

cleanup() {
  cleanup_probes
  cp "$current_backup" implementation/roadmap/CURRENT.md
  rm -rf "$tmp_dir"
}

trap cleanup EXIT

cleanup_probes

if ! ./tools/governance-ci/check-diff-hygiene.sh >"$tmp_dir/diff-hygiene-pass.txt"; then
  cat "$tmp_dir/diff-hygiene-pass.txt"
  exit 1
fi

if ! ./tools/governance-ci/check-pre-scaffold-scope.sh >"$tmp_dir/pre-scaffold-pass.txt"; then
  cat "$tmp_dir/pre-scaffold-pass.txt"
  exit 1
fi

mkdir -p functions/src
printf '%s\n' 'generated artifact probe' > functions/.runiac-governance-probe.js
printf '%s\n' 'source artifact probe' > functions/src/.runiac-governance-probe.ts

diff_hygiene_output="$(./tools/governance-ci/check-diff-hygiene.sh 2>&1 || true)"
pre_scaffold_output="$(./tools/governance-ci/check-pre-scaffold-scope.sh 2>&1 || true)"

if ! grep -q 'functions/.runiac-governance-probe.js' <<<"$diff_hygiene_output"; then
  printf '%s\n' "$diff_hygiene_output"
  printf '%s\n' 'Expected check-diff-hygiene to reject functions/.runiac-governance-probe.js'
  exit 1
fi

if ! grep -q 'functions/src/.runiac-governance-probe.ts' <<<"$diff_hygiene_output"; then
  printf '%s\n' "$diff_hygiene_output"
  printf '%s\n' 'Expected check-diff-hygiene to reject functions/src/.runiac-governance-probe.ts'
  exit 1
fi

if ! grep -q 'functions/.runiac-governance-probe.js' <<<"$pre_scaffold_output"; then
  printf '%s\n' "$pre_scaffold_output"
  printf '%s\n' 'Expected check-pre-scaffold-scope to reject functions/.runiac-governance-probe.js'
  exit 1
fi

if ! grep -q 'functions/src/.runiac-governance-probe.ts' <<<"$pre_scaffold_output"; then
  printf '%s\n' "$pre_scaffold_output"
  printf '%s\n' 'Expected check-pre-scaffold-scope to reject functions/src/.runiac-governance-probe.ts'
  exit 1
fi

cp "$current_backup" implementation/roadmap/CURRENT.md
perl -0pi -e 's/- Current active capsule: `implementation\/roadmap\/capsules\/complete-run-cloud-functions-emulator-skeleton\.md`\.[^\n]*/- Current active capsule: none. Historical reference: `complete-run-cloud-functions-emulator-skeleton` is not active./' implementation/roadmap/CURRENT.md

inactive_diff_hygiene_output="$(./tools/governance-ci/check-diff-hygiene.sh 2>&1 || true)"
inactive_pre_scaffold_output="$(./tools/governance-ci/check-pre-scaffold-scope.sh 2>&1 || true)"

if ! grep -q 'functions/.runiac-governance-probe.js' <<<"$inactive_diff_hygiene_output"; then
  printf '%s\n' "$inactive_diff_hygiene_output"
  printf '%s\n' 'Expected check-diff-hygiene to reject Functions files when the capsule is not active'
  exit 1
fi

if ! grep -q 'functions/package.json' <<<"$inactive_pre_scaffold_output"; then
  printf '%s\n' "$inactive_pre_scaffold_output"
  printf '%s\n' 'Expected check-pre-scaffold-scope to reject Functions files when the capsule is not active'
  exit 1
fi

cp "$current_backup" implementation/roadmap/CURRENT.md

printf '%s\n' 'backend functions scope governance probe PASS'
