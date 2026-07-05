#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-pre-scaffold-scope"
scanned_paths="."
failures=0
approved_scaffold_prefix="implementation/mobile/runiac_app/"

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

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

is_historical_complete_run_functions_path() {
  case "$1" in
    functions/.gitignore|\
    functions/package-lock.json|\
    functions/package.json|\
    functions/tsconfig.json|\
    functions/src/index.ts|\
    functions/src/run/completeRun.ts|\
    functions/src/run/runCompletionTypes.ts|\
    functions/src/run/validateCadenceAnalysisSeries.ts|\
    functions/src/run/validateRunPayload.ts|\
    functions/src/run/validateRunScalarFields.ts|\
    functions/src/progression/progressionEventWriter.ts|\
    functions/test/completeRun.test.ts|\
    functions/test/completeRunZeroMetrics.test.ts|\
    functions/test/completeRunCallableSurface.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_approved_scaffold_path() {
  case "$1" in
    "$approved_scaffold_prefix"*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_forbidden_config_or_secret() {
  case "$1" in
    firebase.json|firestore.rules)
      return 1
      ;;
    *.env.example|*.env.*.example)
      return 1
      ;;
    *firebase.json|*.firebaserc|*firebase_options.dart|*google-services.json|*GoogleService-Info.plist|*firestore.rules|*storage.rules)
      if is_approved_auth_mobile_config_path "$1"; then
        return 1
      fi
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
    firebase/functions/*|firebase/functions/src/*)
      return 0
      ;;
    functions/.gitignore|functions/package-lock.json|functions/package.json|functions/tsconfig.json|functions/src/index.ts|functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/src/run/validateRunScalarFields.ts|functions/src/progression/progressionEventWriter.ts|functions/test/completeRun.test.ts|functions/test/completeRunZeroMetrics.test.ts|functions/test/completeRunCallableSurface.test.ts)
      if is_historical_complete_run_functions_path "$1"; then
        return 1
      fi
      return 0
      ;;
    functions/*)
      return 0
      ;;
  esac

  return 1
}

while IFS= read -r path; do
  [ -n "$path" ] || continue

  if is_forbidden_config_or_secret "$path"; then
    fail "Forbidden config/secret/backend marker found: $path"
    continue
  fi

  case "$path" in
    *pubspec.yaml|*pubspec.lock)
      if ! is_approved_scaffold_path "$path"; then
        fail "Flutter scaffold marker appears outside approved scaffold path: $path"
      fi
      ;;
    *package.json)
      case "$path" in
        functions/package.json)
          if is_historical_complete_run_functions_path "$path"; then
            continue
          fi
          fail "Forbidden app package marker found: $path"
          ;;
        implementation/*|firebase/*|functions/*)
          fail "Forbidden app package marker found: $path"
          ;;
      esac
      ;;
    implementation/mobile/*/lib/*.dart|implementation/mobile/*/android/*|implementation/mobile/*/ios/*)
      if ! is_approved_scaffold_path "$path"; then
        fail "Flutter production source marker appears outside approved scaffold path: $path"
      fi
      ;;
  esac
done < <(git ls-files --cached --others --exclude-standard)

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Approved Flutter scaffold, Auth config, and Functions skeleton exceptions are limited to their explicit paths; no secrets or unauthorized scaffold markers were found.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Approved scaffold baseline boundary check failed.\n'
printf 'next_step=Remove unauthorized scaffold/config/source files or route the finding to A6_REVIEW and A8_OUTPUT_CHECKER.\n'
exit 1
