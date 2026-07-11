#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

tmp_dir="$(mktemp -d)"
current_backup="$tmp_dir/CURRENT.md"
alternate_index="$tmp_dir/index"
actual_baseline_path="functions/test/homeGuideLoggerCapture.ts"
actual_baseline_backup=""
cp implementation/roadmap/CURRENT.md "$current_backup"
cp "$(git rev-parse --git-path index)" "$alternate_index"

set_inactive_feed_capsule() {
  perl -0pi -e 's{- Current active capsule in this isolated worktree: `implementation/roadmap/capsules/feed-friends-emulator-backend\.md`\.[^\n]*}{- Current active capsule: none. Historical reference: Feed/Friends emulator backend is not active.}' implementation/roadmap/CURRENT.md
}

set_adaptive_character_guidance_capsule() {
  perl -0pi -e 's{^- Current active capsule(?: in this isolated worktree)?: .*?$}{- Current active capsule in this isolated worktree: `implementation/roadmap/capsules/adaptive-character-guidance.md`.}m' implementation/roadmap/CURRENT.md
}

cleanup_probes() {
  rm -f \
    functions/.runiac-governance-probe.js \
    functions/src/.runiac-governance-probe.ts \
    functions/src/.runiac-governance-staged-probe.ts \
    functions/src/agent/.runiac-governance-adaptive-probe.ts \
    tests/firebase-rules/.runiac-nonprefix-feed-probe.mjs \
    functions/test/.runiac-governance-nested/feedScope.test.ts \
    tests/firebase-rules/.runiac-governance-nested/feed-scope.mjs
  rmdir functions/test/.runiac-governance-nested tests/firebase-rules/.runiac-governance-nested 2>/dev/null || true
}

cleanup() {
  if [ -n "$actual_baseline_backup" ] && [ -f "$actual_baseline_backup" ]; then
    cp "$actual_baseline_backup" "$actual_baseline_path"
  fi
  cleanup_probes
  cp "$current_backup" implementation/roadmap/CURRENT.md
  rm -rf "$tmp_dir"
}

trap cleanup EXIT
cleanup_probes

expect_rejection() {
  local checker="$1"
  local expected_path="$2"
  local label="$3"
  local output

  if output="$("$checker" 2>&1)"; then
    printf '%s\n' "$output"
    printf '%s\n' "Expected $label to fail"
    exit 1
  fi

  if ! grep -Fq "$expected_path" <<<"$output"; then
    printf '%s\n' "$output"
    printf '%s\n' "Expected $label to reject $expected_path"
    exit 1
  fi
}

expect_no_rejection() {
  local checker="$1"
  local unexpected_path="$2"
  local label="$3"
  local output

  output="$("$checker" 2>&1 || true)"
  if grep -Fq "$unexpected_path" <<<"$output"; then
    printf '%s\n' "$output"
    printf '%s\n' "Expected $label not to reject $unexpected_path"
    exit 1
  fi
}

if ! ./tools/governance-ci/check-diff-hygiene.sh >"$tmp_dir/diff-hygiene-active-pass.txt"; then
  cat "$tmp_dir/diff-hygiene-active-pass.txt"
  exit 1
fi

if ! ./tools/governance-ci/check-pre-scaffold-scope.sh >"$tmp_dir/pre-scaffold-active-pass.txt"; then
  cat "$tmp_dir/pre-scaffold-active-pass.txt"
  exit 1
fi

if ! grep -Fq 'git rev-parse ":$path"' tools/governance-ci/check-pre-scaffold-scope.sh || ! grep -Fq 'git hash-object -- "$path"' tools/governance-ci/check-pre-scaffold-scope.sh || ! grep -Fq '[ "$index_blob" != "$expected_blob" ] || [ "$worktree_blob" != "$expected_blob" ]' tools/governance-ci/check-pre-scaffold-scope.sh; then
  printf '%s\n' 'Expected immutable Adaptive baseline checks to compare both index and worktree blobs for clean committed-content enforcement'
  exit 1
fi

if ! grep -Eq '^- Current active capsule in this isolated worktree: `implementation/roadmap/capsules/feed-friends-emulator-backend\.md`\.' implementation/roadmap/CURRENT.md; then
  printf '%s\n' 'Expected this regression to start with the Feed capsule active'
  exit 1
fi

actual_baseline_backup="$tmp_dir/homeGuideLoggerCapture.ts"
cp "$actual_baseline_path" "$actual_baseline_backup"
baseline_mutation_blob="$(git rev-parse HEAD:AGENTS.md)"
approved_home_guide_logger_blob="b5e8340a755b33bb4fb1d8f425649bd4172e3af7"

if [ "$baseline_mutation_blob" = "$approved_home_guide_logger_blob" ]; then
  printf '%s\n' 'Expected the alternate-index mutation fixture to differ from the approved Home Guide logger baseline'
  exit 1
fi

cp "$(git rev-parse --git-path index)" "$alternate_index"
GIT_INDEX_FILE="$alternate_index" git update-index --cacheinfo "100644,$baseline_mutation_blob,$actual_baseline_path"

if actual_staged_output="$(GIT_INDEX_FILE="$alternate_index" ./tools/governance-ci/check-pre-scaffold-scope.sh 2>&1)"; then
  printf '%s\n' "$actual_staged_output"
  printf '%s\n' 'Expected check-pre-scaffold-scope to reject an alternate-index mutation of the actual Adaptive baseline path'
  exit 1
fi

if ! grep -Fq "$actual_baseline_path" <<<"$actual_staged_output"; then
  printf '%s\n' "$actual_staged_output"
  printf '%s\n' 'Expected the alternate-index baseline mutation rejection to name the actual Adaptive path'
  exit 1
fi

cp "$(git rev-parse --git-path index)" "$alternate_index"
printf '%s\n' 'unstaged immutable baseline mutation probe' >> "$actual_baseline_path"
expect_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh "$actual_baseline_path" 'check-pre-scaffold-scope unstaged actual Adaptive baseline mutation'
cp "$actual_baseline_backup" "$actual_baseline_path"

if ! cmp -s "$actual_baseline_backup" "$actual_baseline_path"; then
  printf '%s\n' 'Expected the unstaged actual Adaptive baseline path to be restored from its temporary backup'
  exit 1
fi

if ! ./tools/governance-ci/check-pre-scaffold-scope.sh >"$tmp_dir/pre-scaffold-inactive-baseline-pass.txt"; then
  cat "$tmp_dir/pre-scaffold-inactive-baseline-pass.txt"
  printf '%s\n' 'Expected unchanged immutable Adaptive baselines to coexist with the active Feed capsule'
  exit 1
fi

set_adaptive_character_guidance_capsule
expect_no_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh "$actual_baseline_path" 'check-pre-scaffold-scope active Adaptive actual baseline path'
cp "$current_backup" implementation/roadmap/CURRENT.md

if ! cmp -s "$current_backup" implementation/roadmap/CURRENT.md; then
  printf '%s\n' 'Expected disposable CURRENT state to be restored before subsequent probes'
  exit 1
fi

if ! test -f functions/src/feed/engagement/engagement.ts; then
  printf '%s\n' 'Expected a nested Feed Functions source fixture for recursive allowlist coverage'
  exit 1
fi

printf '%s\n' 'allowed Feed rules probe' > tests/firebase-rules/.runiac-nonprefix-feed-probe.mjs

if ! ./tools/governance-ci/check-diff-hygiene.sh >"$tmp_dir/nonprefix-rules-pass.txt"; then
  cat "$tmp_dir/nonprefix-rules-pass.txt"
  printf '%s\n' 'Expected a root non-prefix *feed*.mjs rules test to be allowed while Feed is active'
  exit 1
fi

if ! ./tools/governance-ci/check-pre-scaffold-scope.sh >"$tmp_dir/nonprefix-rules-pre-scaffold-pass.txt"; then
  cat "$tmp_dir/nonprefix-rules-pre-scaffold-pass.txt"
  printf '%s\n' 'Expected a root non-prefix *feed*.mjs rules test to be allowed while Feed is active'
  exit 1
fi

rm -f tests/firebase-rules/.runiac-nonprefix-feed-probe.mjs

mkdir -p functions/test/.runiac-governance-nested tests/firebase-rules/.runiac-governance-nested
printf '%s\n' 'nested Feed Functions test probe' > functions/test/.runiac-governance-nested/feedScope.test.ts
printf '%s\n' 'nested Feed rules test probe' > tests/firebase-rules/.runiac-governance-nested/feed-scope.mjs

expect_rejection ./tools/governance-ci/check-diff-hygiene.sh functions/test/.runiac-governance-nested/feedScope.test.ts 'check-diff-hygiene nested Feed Functions test probe'
expect_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh functions/test/.runiac-governance-nested/feedScope.test.ts 'check-pre-scaffold-scope nested Feed Functions test probe'
expect_rejection ./tools/governance-ci/check-diff-hygiene.sh tests/firebase-rules/.runiac-governance-nested/feed-scope.mjs 'check-diff-hygiene nested Feed rules test probe'
expect_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh tests/firebase-rules/.runiac-governance-nested/feed-scope.mjs 'check-pre-scaffold-scope nested Feed rules test probe'
cleanup_probes

mkdir -p functions/src
printf '%s\n' 'generated artifact probe' > functions/.runiac-governance-probe.js
printf '%s\n' 'source artifact probe' > functions/src/.runiac-governance-probe.ts

expect_rejection ./tools/governance-ci/check-diff-hygiene.sh functions/.runiac-governance-probe.js 'check-diff-hygiene generated artifact probe'
expect_rejection ./tools/governance-ci/check-diff-hygiene.sh functions/src/.runiac-governance-probe.ts 'check-diff-hygiene source artifact probe'
expect_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh functions/.runiac-governance-probe.js 'check-pre-scaffold-scope generated artifact probe'
expect_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh functions/src/.runiac-governance-probe.ts 'check-pre-scaffold-scope source artifact probe'

staged_probe_blob="$(git rev-parse HEAD:AGENTS.md)"
GIT_INDEX_FILE="$alternate_index" git update-index --add --cacheinfo "100644,$staged_probe_blob,functions/src/.runiac-governance-staged-probe.ts"

if staged_pre_scaffold_output="$(GIT_INDEX_FILE="$alternate_index" ./tools/governance-ci/check-pre-scaffold-scope.sh 2>&1)"; then
  printf '%s\n' "$staged_pre_scaffold_output"
  printf '%s\n' 'Expected check-pre-scaffold-scope to reject a staged-only forbidden Functions probe'
  exit 1
fi

if ! grep -Fq 'functions/src/.runiac-governance-staged-probe.ts' <<<"$staged_pre_scaffold_output"; then
  printf '%s\n' "$staged_pre_scaffold_output"
  printf '%s\n' 'Expected check-pre-scaffold-scope to scan the staged-only forbidden Functions probe'
  exit 1
fi

cp "$current_backup" implementation/roadmap/CURRENT.md
set_inactive_feed_capsule
printf '%s\n' 'adaptive inactive probe' > functions/src/agent/.runiac-governance-adaptive-probe.ts

expect_rejection ./tools/governance-ci/check-diff-hygiene.sh functions/src/feed/cleanup.ts 'check-diff-hygiene inactive Feed Functions probe'
expect_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh functions/src/feed/cleanup.ts 'check-pre-scaffold-scope inactive Feed Functions probe'
expect_rejection ./tools/governance-ci/check-diff-hygiene.sh storage.rules 'check-diff-hygiene inactive Feed Storage probe'
expect_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh storage.rules 'check-pre-scaffold-scope inactive Feed Storage probe'
expect_rejection ./tools/governance-ci/check-diff-hygiene.sh functions/src/agent/.runiac-governance-adaptive-probe.ts 'check-diff-hygiene inactive adaptive probe'
expect_rejection ./tools/governance-ci/check-pre-scaffold-scope.sh functions/src/agent/.runiac-governance-adaptive-probe.ts 'check-pre-scaffold-scope inactive adaptive probe'

printf '%s\n' 'backend functions scope governance probe PASS'
