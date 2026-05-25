#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-diff-hygiene"
scanned_paths="git status --short,git diff --check,git diff --cached --check,git diff --name-only"
failures=0

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

diff_check_output="$(git diff --check 2>&1 || true)"
if [ -n "$diff_check_output" ]; then
  fail "Whitespace errors detected by git diff --check: $diff_check_output"
fi

cached_diff_check_output="$(git diff --cached --check 2>&1 || true)"
if [ -n "$cached_diff_check_output" ]; then
  fail "Whitespace errors detected by git diff --cached --check: $cached_diff_check_output"
fi

while IFS= read -r line; do
  [ -n "$line" ] || continue
  path="${line:3}"
  case "$path" in
    *' -> '*)
      path="${path##* -> }"
      ;;
  esac

  case "$path" in
    # Approved: non-operational historical archive (Phase A)
    docs/meta/.aiignore|docs/meta/README.md|docs/meta/RETROSPECTIVE_POLICY.md|docs/meta/RUNIAC_REPOSITORY_EVOLUTION_REPORT.md|tools/governance-ci/check-historical-isolation.sh)
      ;;
    # Approved: routed Repository Workflow Record documentation/governance patch only
    docs/meta/REPOSITORY_WORKFLOW_RECORD.md|implementation/roadmap/capsules/repository-workflow-record.md)
      ;;
    implementation/roadmap/CURRENT.md|implementation/roadmap/phases/phase-01-governance-ci.md|implementation/roadmap/snapshots/latest.md|implementation/roadmap/ci/*|tools/governance-ci/*)
      ;;
    *)
      fail "Unrelated modified path is outside Governance CI scope: $path"
      ;;
  esac

  case "$path" in
    *pubspec.yaml|*firebase.json|*.firebaserc|*google-services.json|*GoogleService-Info.plist|*firebase_options.dart|*package.json|*firestore.rules|*storage.rules)
      fail "Forbidden implementation/config artifact appears in diff status: $path"
      ;;
  esac
done < <(git status --short --untracked-files=all)

while IFS= read -r path; do
  [ -n "$path" ] || continue
  case "$path" in
    *pubspec.yaml|*firebase.json|*.firebaserc|*google-services.json|*GoogleService-Info.plist|*firebase_options.dart|*package.json|*firestore.rules|*storage.rules)
      fail "Forbidden implementation/config artifact appears in tracked diff: $path"
      ;;
  esac
done < <(git diff --name-only)

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Diff has no whitespace errors, unrelated paths, or forbidden implementation/config artifacts.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Diff hygiene failed.\n'
printf 'next_step=Remove unrelated or forbidden files, fix whitespace, then rerun once.\n'
exit 1
