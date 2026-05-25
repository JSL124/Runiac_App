#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-roadmap-routing"
current_file="implementation/roadmap/CURRENT.md"
snapshot_file="implementation/roadmap/snapshots/latest.md"
failures=0

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

if [ ! -f "$current_file" ]; then
  fail "Missing roadmap current file: $current_file"
  active_phase=""
else
  active_phase_count="$(grep -Ec '^[[:space:]]*-[[:space:]]*Current phase:[[:space:]]*`[^`]+`[[:space:]]*$' "$current_file" || true)"
  if [ "$active_phase_count" -ne 1 ]; then
    fail "CURRENT.md must name exactly one active phase; found $active_phase_count"
    active_phase=""
  else
    active_phase="$(sed -n 's/^[[:space:]]*-[[:space:]]*Current phase:[[:space:]]*`\([^`][^`]*\)`[[:space:]]*$/\1/p' "$current_file")"
    if [ -z "$active_phase" ]; then
      fail "CURRENT.md active phase path is empty"
    elif [ ! -f "$active_phase" ]; then
      fail "Active phase file is missing: $active_phase"
    fi
  fi
fi

if [ ! -f "$snapshot_file" ]; then
  fail "Missing roadmap snapshot file: $snapshot_file"
fi

if [ -f "$current_file" ]; then
  if ! grep -Eq '^##[[:space:]]+(Required Reading Order|Layered Reading Order|Reading Order)[[:space:]]*$' "$current_file"; then
    fail "CURRENT.md missing a required or layered reading order section"
  fi

  if ! grep -Eq '^[[:space:]]*[0-9]+[.)][[:space:]]*`?implementation/roadmap/CURRENT\.md`?[[:space:]]*$' "$current_file"; then
    fail "CURRENT.md reading order does not include CURRENT.md as a numbered entry"
  fi

  if ! grep -Eiq '^[[:space:]]*[0-9]+[.)][[:space:]]*Active phase document' "$current_file"; then
    fail "CURRENT.md reading order does not include the active phase document"
  fi

  if ! grep -Eiq '^[[:space:]]*[0-9]+[.)][[:space:]]*Relevant ADRs?' "$current_file"; then
    fail "CURRENT.md reading order does not include relevant ADRs"
  fi

  if ! grep -Eq '^[[:space:]]*[0-9]+[.)][[:space:]]*`?implementation/roadmap/snapshots/latest\.md`?[[:space:]]*$' "$current_file"; then
    fail "CURRENT.md reading order does not include the latest roadmap snapshot"
  fi

  if ! grep -Eiq '(Forbidden Work|Forbidden Scope|Do not run|not authorized|unauthorized|blocked until|explicit approval)' "$current_file"; then
    fail "CURRENT.md missing explicit forbidden or approval-boundary governance language"
  fi

  for boundary in scaffold build init deploy; do
    if ! grep -Eiq "$boundary" "$current_file"; then
      fail "CURRENT.md missing explicit forbidden boundary term: $boundary"
    fi
  done

  if ! grep -Eiq '(governance|scope|boundary|approval|forbidden)' "$current_file"; then
    fail "CURRENT.md missing equivalent governance language for forbidden boundaries"
  fi
fi

if [ -f "$snapshot_file" ]; then
  if ! grep -Eq '\b[0-9a-fA-F]{7,40}\b' "$snapshot_file"; then
    fail "Snapshot file missing commit hash: $snapshot_file"
  fi
fi

scanned_paths="$current_file,${active_phase:-<missing-active-phase>},$snapshot_file"

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Active phase path, reading order, snapshot metadata, and forbidden-boundary routing are deterministic.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Roadmap routing is incomplete or stale.\n'
printf 'next_step=Update roadmap routing artifacts, then rerun once.\n'
exit 1
