#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-sensitive-paths"
setup_gates="implementation/traceability/setup-gates.md"
scanned_paths=".gitignore,.claude/settings.json,tools/agent-review/profiles/runiac/context-policy.yml,$setup_gates,tracked files,unignored untracked files,ignored .env files"
failures=0

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

gate_status() {
  local gate_name="$1"
  awk -F'|' -v gate="$gate_name" '
    index($2, gate) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3)
      print $3
      exit
    }
  ' "$setup_gates"
}

require_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    fail "Missing scanned policy file: $path"
  fi
}

require_any_regex() {
  local regex="$1"
  local label="$2"
  shift 2
  local matched=1
  local path

  for path in "$@"; do
    if [ -f "$path" ] && grep -Eq -- "$regex" "$path"; then
      matched=0
      break
    fi
  done

  if [ "$matched" -ne 0 ]; then
    fail "Missing required deny/ignore coverage: $label"
  fi
}

require_file "$setup_gates"
require_file ".gitignore"
require_file ".claude/settings.json"
require_file "tools/agent-review/profiles/runiac/context-policy.yml"

is_approved_auth_mobile_config_path() {
  case "$1" in
    implementation/mobile/runiac_app/firebase.json|\
    implementation/mobile/runiac_app/lib/firebase_options.dart|\
    implementation/mobile/runiac_app/android/app/google-services.json|\
    implementation/mobile/runiac_app/ios/Runner/GoogleService-Info.plist)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

secret_gate_status="$(gate_status 'Secret / API Key / Environment Handling Gate')"
gps_gate_status="$(gate_status 'GPS and Location Privacy Gate')"

if [ -z "$secret_gate_status" ]; then
  fail "Could not determine Secret / API Key / Environment Handling Gate status"
fi

if [ -z "$gps_gate_status" ]; then
  fail "Could not determine GPS and Location Privacy Gate status"
fi

if [ -f ".claude/settings.json" ] && command -v python3 >/dev/null 2>&1; then
  if ! python3 -m json.tool ".claude/settings.json" >/dev/null 2>&1; then
    fail "Malformed JSON policy file: .claude/settings.json"
  fi
fi

if [ -f "tools/agent-review/profiles/runiac/context-policy.yml" ] && grep -n $'\t' "tools/agent-review/profiles/runiac/context-policy.yml" >/dev/null 2>&1; then
  fail "Malformed YAML policy file: tools/agent-review/profiles/runiac/context-policy.yml contains tab indentation"
fi

policy_files=(
  ".gitignore"
  ".claude/settings.json"
  "tools/agent-review/profiles/runiac/context-policy.yml"
)

require_any_regex '(^|[[:space:]/])\.env(\*|\.\*)?($|[[:space:]])' ".env deny pattern" "${policy_files[@]}"
require_any_regex '(\*\*/\.env|Read\(\./\*\*/\.env)' "nested .env deny pattern" "${policy_files[@]}"
require_any_regex '(google-services\.json|GoogleService-Info\.plist|firebase_options\.dart|firebase\.json|\.firebaserc)' "Firebase config deny pattern" "${policy_files[@]}"
require_any_regex '(service[-_ ]?account|serviceAccount|credentials?\.json)' "service account or credential deny pattern" "${policy_files[@]}"
require_any_regex '(key\.properties|local\.properties|\.jks|\.keystore|\.p12|\.cer|\.mobileprovision|\.p8)' "signing material deny pattern" "${policy_files[@]}"
require_any_regex '(gps-private|private-gps|route-private|private-route|location-private|private-location)' "private GPS/location/route deny pattern" "${policy_files[@]}"
require_any_regex '(private[-_ ]?evidence|evidence[-_ ]?private|private[-_ ]?screenshot|screenshot[-_ ]?private|test[-_]?evidence|test evidence|test/evidence|Manual Evidence|Screenshot)' "private test evidence deny pattern" "${policy_files[@]}"

check_mapbox_token_leaks() {
  local path
  while IFS= read -r path; do
    if [ ! -f "$path" ]; then
      continue
    fi

    case "$path" in
      tools/governance-ci/check-sensitive-paths.sh)
        continue
        ;;
    esac

    if ! grep -Iq . "$path"; then
      continue
    fi

    if grep -Eq '(^|[^A-Za-z0-9_])sk\.[A-Za-z0-9._-]+' "$path"; then
      fail "Mapbox secret token-looking content present: $path"
    fi

    if grep -Eq 'MAPBOX_PUBLIC_ACCESS_TOKEN[[:space:]]*=[[:space:]]*pk\.[A-Za-z0-9._-]+' "$path"; then
      fail "Committed Mapbox public token assignment present: $path"
    fi

    if grep -Eq 'MBXAccessToken[^A-Za-z0-9]*(pk|sk)\.[A-Za-z0-9._-]+' "$path"; then
      fail "Native Mapbox token-looking content present: $path"
    fi

    if grep -Eq 'mapbox_access_token[^A-Za-z0-9]*(pk|sk)\.[A-Za-z0-9._-]+' "$path"; then
      fail "Android Mapbox resource token-looking content present: $path"
    fi

    if grep -Eq '(^|[^A-Za-z0-9_])(MAPBOX_DOWNLOADS_TOKEN|DOWNLOADS_TOKEN)([^A-Za-z0-9_]|$)' "$path"; then
      fail "Mapbox download token reference present: $path"
    fi
  done < <(
    {
      git ls-files --cached --others --exclude-standard
      find . -type f \( -name '.env' -o -name '.env.*' \) -print \
        | sed 's#^\./##'
    } | sort -u
  )
}

check_mapbox_token_leaks

if [ "$secret_gate_status" = "Not Started" ] || [ "$secret_gate_status" = "Blocked" ]; then
  while IFS= read -r path; do
    if is_approved_auth_mobile_config_path "$path"; then
      continue
    fi
    fail "Secret/config artifact present while Secret gate is $secret_gate_status: $path"
  done < <(
    git ls-files --others --cached --exclude-standard \
      | grep -E '(^|/)(\.env[^/]*|google-services\.json|GoogleService-Info\.plist|firebase_options\.dart|service[-_]?account.*\.json|.*credentials.*\.json|key\.properties|local\.properties|.*\.(jks|keystore|p12|cer|mobileprovision|p8))$' \
      || true
  )
fi

if [ "$gps_gate_status" = "Not Started" ] || [ "$gps_gate_status" = "Blocked" ]; then
  while IFS= read -r path; do
    fail "Private GPS/location/route artifact present while GPS gate is $gps_gate_status: $path"
  done < <(
    git ls-files --others --cached --exclude-standard \
      | grep -E '(^|/)(gps-private|private-gps|route-private|private-route|location-private|private-location)(/|$)' \
      || true
  )
fi

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'gate_secret_status=%s\n' "$secret_gate_status"
  printf 'gate_gps_status=%s\n' "$gps_gate_status"
  printf 'message=Sensitive/config/private artifact deny and ignore coverage is present for current gate states.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'gate_secret_status=%s\n' "${secret_gate_status:-unknown}"
printf 'gate_gps_status=%s\n' "${gps_gate_status:-unknown}"
printf 'message=Sensitive path governance coverage is incomplete or current gate state forbids detected artifacts.\n'
printf 'next_step=Update governance policy or route the finding to A6_REVIEW and A8_OUTPUT_CHECKER.\n'
exit 1
