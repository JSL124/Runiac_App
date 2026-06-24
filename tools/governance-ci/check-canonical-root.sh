#!/usr/bin/env bash
set -euo pipefail

check_name="check-canonical-root"
canonical_root="/Users/leejinseo/Desktop/FYP_Runiac"
forbidden_root="/Users/leejinseo/Documents/FYP_Runiac"
logical_pwd="${RUNIAC_INITIAL_LOGICAL_PWD:-${PWD:-$(pwd)}}"
invocation_path="${RUNIAC_INVOCATION_PATH:-}"
git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
physical_pwd="$(pwd -P)"
is_github_actions="${GITHUB_ACTIONS:-}"

fail_wrong_logical_root() {
  printf 'CHECK %s FAIL\n' "$check_name"
  printf 'marker=BLOCKED_WRONG_LOGICAL_ROOT\n'
  printf 'logical_pwd=%s\n' "$logical_pwd"
  if [ -n "$invocation_path" ]; then
    printf 'invocation_path=%s\n' "$invocation_path"
  fi
  printf 'physical_pwd=%s\n' "$physical_pwd"
  printf 'git_root=%s\n' "${git_root:-<none>}"
  printf 'message=BLOCKED_WRONG_LOGICAL_ROOT: Launch from %s, not the Documents symlink path.\n' "$canonical_root"
  printf 'next_step=cd %s && ./tools/governance-ci/run-all-checks.sh\n' "$canonical_root"
  exit 1
}

fail_canonical_root() {
  printf 'CHECK %s FAIL\n' "$check_name"
  printf 'logical_pwd=%s\n' "$logical_pwd"
  printf 'physical_pwd=%s\n' "$physical_pwd"
  printf 'git_root=%s\n' "${git_root:-<none>}"
  printf 'message=%s\n' "$1"
  exit 1
}

case "$logical_pwd" in
  "$forbidden_root"|"$forbidden_root"/*)
    fail_wrong_logical_root
    ;;
esac

case "$invocation_path" in
  "$forbidden_root"|"$forbidden_root"/*|*/Documents/FYP_Runiac|*/Documents/FYP_Runiac/*)
    fail_wrong_logical_root
    ;;
esac

if [ "$is_github_actions" = "true" ]; then
  if [ -z "$git_root" ]; then
    fail_canonical_root "GitHub Actions checkout must run inside a Git repository."
  fi

  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=logical PWD,runner invocation path\n'
  printf 'canonical_root=%s\n' "$canonical_root"
  printf 'logical_pwd=%s\n' "$logical_pwd"
  if [ -n "$invocation_path" ]; then
    printf 'invocation_path=%s\n' "$invocation_path"
  fi
  printf 'physical_pwd=%s\n' "$physical_pwd"
  printf 'git_root=%s\n' "$git_root"
  printf 'message=Hosted GitHub Actions checkout is allowed; local Desktop root enforcement remains active outside CI.\n'
  exit 0
fi

case "$logical_pwd" in
  /Users/leejinseo/*)
    case "$logical_pwd" in
      "$canonical_root"|"$canonical_root"/*) ;;
      *) fail_wrong_logical_root ;;
    esac
    ;;
esac

if [ "$git_root" != "$canonical_root" ]; then
  fail_canonical_root "Git repository root must resolve to $canonical_root."
fi

case "$physical_pwd" in
  "$canonical_root"|"$canonical_root"/*) ;;
  *) fail_canonical_root "Physical working directory must be inside $canonical_root." ;;
esac

printf 'CHECK %s PASS\n' "$check_name"
printf 'scanned_paths=logical PWD,runner invocation path\n'
printf 'canonical_root=%s\n' "$canonical_root"
printf 'logical_pwd=%s\n' "$logical_pwd"
if [ -n "$invocation_path" ]; then
  printf 'invocation_path=%s\n' "$invocation_path"
fi
printf 'physical_pwd=%s\n' "$physical_pwd"
printf 'git_root=%s\n' "$git_root"
printf 'message=Canonical logical repository root is in use.\n'
