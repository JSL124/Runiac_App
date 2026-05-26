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

allowed_docs_meta_reference() {
  line="$1"
  normalized="$(printf '%s\n' "$line" | tr '[:upper:]' '[:lower:]')"

  # Legitimate boundary references are allowed when they state that docs/meta is
  # non-operational archive context, or when they merely record archive paths.
  case "$normalized" in
    *non-operational*|*archive*|*historical*|*reflective*|*schema-only*)
      return 0
      ;;
    *"do not treat"*|*"do not use"*|*"must not override"*|*"cannot override"*|*"does not authorize"*|*"does not modify"*|*"may be modified"*|*"must not be used"*|*"no operational"*)
      return 0
      ;;
    *"not authority"*|*"not operational truth"*|*"not routing"*|*"not approval"*|*"not setup-gate"*|*"not implementation guidance"*|*"not override"*)
      return 0
      ;;
    *"created document"*|*"created record"*|*"created at"*|*"persisted at"*|*"pushed in"*|*"added to docs/meta"*|*"added to \`docs/meta"*|*"under \`docs/meta"*|*"meta/archive work"*)
      return 0
      ;;
    *":docs/meta/"*|*":- \`docs/meta/"*|*":- docs/meta/"*)
      return 0
      ;;
  esac

  return 1
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
    unsafe_matches=""
    while IFS= read -r line; do
      if ! allowed_docs_meta_reference "$line"; then
        if [ -z "$unsafe_matches" ]; then
          unsafe_matches="$line"
        else
          unsafe_matches="$unsafe_matches
$line"
        fi
      fi
    done <<EOF
$matches
EOF

    if [ -n "$unsafe_matches" ]; then
      fail "ERROR: docs/meta operational authority/dependency detected in operational routing/governance chain: $target"
      printf '%s\n' "$unsafe_matches"
    fi
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
printf 'message=Historical archive contamination detected. docs/meta must not be used as operational authority/dependency.\n'
printf 'next_step=Remove operational authority/dependency usage of docs/meta from operational-chain targets and rerun this check.\n'
exit 1
