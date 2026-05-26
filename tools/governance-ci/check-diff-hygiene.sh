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

is_allowed_path() {
  case "$1" in
    # Approved: non-operational historical archive (Phase A)
    docs/meta/.aiignore|docs/meta/README.md|docs/meta/RETROSPECTIVE_POLICY.md|docs/meta/RUNIAC_REPOSITORY_EVOLUTION_REPORT.md|tools/governance-ci/check-historical-isolation.sh)
      return 0
      ;;
    # Approved: routed capsule documentation/governance patches only
    docs/meta/REPOSITORY_WORKFLOW_RECORD.md|implementation/roadmap/capsules/repository-workflow-record.md|implementation/roadmap/capsules/flutter-app-shell-baseline.md|implementation/roadmap/capsules/android-ui-smoke-test-evidence.md|implementation/roadmap/capsules/home-dashboard-visual-polish.md|implementation/roadmap/capsules/premium-home-dashboard-static-wireframe-alignment.md)
      return 0
      ;;
    # Approved: scaffold-baseline instruction/setup-gate alignment only
    implementation/AGENTS.md|implementation/mobile/AGENTS.md|implementation/traceability/setup-gates.md)
      return 0
      ;;
    # Approved: scaffold-baseline and Codex-only review instruction cleanup
    AGENTS.md|.agents/skills/runiac-review-flow/SKILL.md|tools/agent-review/profiles/runiac/context-policy.yml|tools/agent-review/profiles/runiac/prompts/01_codex_create_plan.md)
      return 0
      ;;
    # Approved: reusable agent-review reference templates only
    tools/agent-review/templates/*.md)
      return 0
      ;;
    implementation/roadmap/CURRENT.md|implementation/roadmap/phases/phase-01-governance-ci.md|implementation/roadmap/snapshots/latest.md|implementation/roadmap/ci/*|tools/governance-ci/*)
      return 0
      ;;
    .gitignore)
      return 0
      ;;
    implementation/mobile/runiac_app/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_forbidden_path() {
  case "$1" in
    *.env.example|*.env.*.example)
      return 1
      ;;
    *firebase.json|*.firebaserc|*firebase_options.dart|*google-services.json|*GoogleService-Info.plist|*firestore.rules|*storage.rules)
      return 0
      ;;
    *.env|*.env.*|*service-account*|*credentials*|*ServiceAccount*|*Credentials*)
      return 0
      ;;
    *android/local.properties|*android/key.properties|*.jks|*.keystore|*.p12|*.cer|*.mobileprovision|*.p8)
      return 0
      ;;
    */build/*|build/*|*/.dart_tool/*|*.apk|*.aab|*.ipa|*.xcarchive)
      return 0
      ;;
    firebase/functions/*|firebase/functions/src/*|functions/*|functions/src/*)
      return 0
      ;;
    *package.json)
      case "$1" in
        implementation/*|firebase/*|functions/*)
          return 0
          ;;
      esac
      ;;
  esac

  return 1
}

is_pubspec_outside_approved_scaffold() {
  case "$1" in
    implementation/mobile/runiac_app/pubspec.yaml|implementation/mobile/runiac_app/pubspec.lock)
      return 1
      ;;
    *pubspec.yaml|*pubspec.lock)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
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

  if ! is_allowed_path "$path"; then
    fail "Unrelated modified path is outside Governance CI scope: $path"
  fi

  if is_forbidden_path "$path"; then
    fail "Forbidden implementation/config artifact appears in diff status: $path"
  fi

  if is_pubspec_outside_approved_scaffold "$path"; then
    fail "Flutter pubspec artifact appears outside approved scaffold path: $path"
  fi
done < <(git status --short --untracked-files=all)

while IFS= read -r path; do
  [ -n "$path" ] || continue
  if is_forbidden_path "$path"; then
    fail "Forbidden implementation/config artifact appears in tracked diff: $path"
  fi

  if is_pubspec_outside_approved_scaffold "$path"; then
    fail "Flutter pubspec artifact appears outside approved scaffold path: $path"
  fi
done < <(git diff --name-only)

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Diff has no whitespace errors, unrelated paths, or forbidden implementation/config artifacts; approved Flutter scaffold baseline is allowed under implementation/mobile/runiac_app.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Diff hygiene failed.\n'
printf 'next_step=Remove unrelated or forbidden files, fix whitespace, then rerun once.\n'
exit 1
