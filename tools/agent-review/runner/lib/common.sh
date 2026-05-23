#!/usr/bin/env bash

set -euo pipefail

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '%s\n' "$*" >&2
}

require_file() {
  local path="$1"
  [ -f "$path" ] || die "required file not found: $path"
}

require_dir() {
  local path="$1"
  [ -d "$path" ] || die "required directory not found: $path"
}

require_command() {
  local command_name="$1"
  command -v "$command_name" >/dev/null 2>&1 || die "required command not found on PATH: $command_name"
}

timestamp_utc() {
  date -u '+%Y-%m-%dT%H-%M-%S'
}

ensure_new_file() {
  local path="$1"
  [ ! -e "$path" ] || die "refusing to overwrite existing output: $path"
}

help_has_flag() {
  local command_name="$1"
  local flag="$2"
  "$command_name" --help 2>/dev/null | grep -F -- "$flag" >/dev/null 2>&1
}

check_help_flag_if_possible() {
  local command_name="$1"
  local flag="$2"
  if "$command_name" --help >/dev/null 2>&1; then
    help_has_flag "$command_name" "$flag" || die "$command_name --help did not show expected flag: $flag"
  else
    info "warning: could not inspect $command_name --help for $flag"
  fi
}

write_dry_run() {
  local path="$1"
  local description="$2"
  local command_text="$3"
  ensure_new_file "$path"
  {
    printf '# Dry Run: %s\n\n' "$description"
    printf 'DRY_RUN=1, so no external agent command was invoked.\n\n'
    printf 'Command that would run:\n\n'
    printf '```bash\n%s\n```\n' "$command_text"
  } > "$path"
}
