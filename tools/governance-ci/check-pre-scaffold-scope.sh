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

is_historical_backend_functions_path() {
  case "$1" in
    functions/.gitignore|\
    functions/package-lock.json|\
    functions/package.json|\
    functions/tsconfig.json|\
    functions/src/index.ts|\
    functions/src/notifications/deviceRegistry.ts|\
    functions/src/notifications/dispatchPlanner.ts|\
    functions/src/notifications/scheduledPushDispatch.ts|\
    functions/src/notifications/scheduledPushFirestore.ts|\
    functions/src/notifications/scheduledPushMessagingAdapter.ts|\
    functions/src/notifications/scheduledPushReaders.ts|\
    functions/src/notifications/types.ts|\
    functions/src/leaderboard/leaderboardMockDataset.ts|\
    functions/src/leaderboard/leaderboardMockProfiles.ts|\
    functions/src/leaderboard/leaderboardSeedArguments.ts|\
    functions/src/leaderboard/leaderboardSeedCleanupAuthorization.ts|\
    functions/src/leaderboard/leaderboardSeedCleanupLease.ts|\
    functions/src/leaderboard/leaderboardSeedCommandTypes.ts|\
    functions/src/leaderboard/leaderboardSeedDataset.ts|\
    functions/src/leaderboard/leaderboardSeedFirestore.ts|\
    functions/src/leaderboard/leaderboardSeedInventory.ts|\
    functions/src/leaderboard/leaderboardSeedInventoryFingerprint.ts|\
    functions/src/leaderboard/leaderboardSeedMutation.ts|\
    functions/src/leaderboard/leaderboardSeedOwnership.ts|\
    functions/src/leaderboard/leaderboardSeedVerification.ts|\
    functions/src/leaderboard/leaderboardSeedWriteRecovery.ts|\
    functions/src/leaderboard/leaderboardTypes.ts|\
    functions/src/leaderboard/monthlyLeaderboard.ts|\
    functions/src/leaderboard/monthlyLeaderboardPlanner.ts|\
    functions/src/leaderboard/monthlyLeaderboardWriter.ts|\
    functions/src/leaderboard/seedLeaderboardMockData.ts|\
    functions/src/leaderboard/singaporePlanningAreas.ts|\
    functions/src/plan/adaptiveEstimate.ts|\
    functions/src/plan/planProgress.ts|\
    functions/src/plan/planProgressParsing.ts|\
    functions/src/plan/planProgressSnapshot.ts|\
    functions/src/progression/planBoundedStreakState.ts|\
    functions/src/progression/progressionAudit.ts|\
    functions/src/progression/progressionAuditHelpers.ts|\
    functions/src/progression/progressionCalculator.ts|\
    functions/src/progression/progressionDisplayReader.ts|\
    functions/src/progression/progressionEventWriter.ts|\
    functions/src/progression/streakCalculator.ts|\
    functions/src/progression/leaderboardLeagues.ts|\
    functions/src/run/completeRun.ts|\
    functions/src/run/runCompletionArtifacts.ts|\
    functions/src/run/runCompletionTypes.ts|\
    functions/src/run/validateCadenceAnalysisSeries.ts|\
    functions/src/run/validateRunPayload.ts|\
    functions/src/run/validateRunScalarFields.ts|\
    functions/test/completeRun.test.ts|\
    functions/test/completeRunCallableSurface.test.ts|\
    functions/test/notificationDevices.test.ts|\
    functions/test/notificationDispatch.test.ts|\
    functions/test/notificationScheduledDispatch.test.ts|\
    functions/test/leaderboardMockDataset.test.ts|\
    functions/test/leaderboardSeedAuthorization.test.ts|\
    functions/test/leaderboardSeedFirestore.test.ts|\
    functions/test/leaderboardSeedVerification.test.ts|\
    functions/test/monthlyLeaderboard.test.ts|\
    functions/test/monthlyLeaderboardWriter.test.ts|\
    functions/test/seedLeaderboardCleanup.test.ts|\
    functions/test/seedLeaderboardInventory.test.ts|\
    functions/test/seedLeaderboardMockData.test.ts|\
    functions/test/seedLeaderboardSafety.test.ts|\
    functions/test/progressionCalculator.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_adaptive_character_guidance_capsule_active() {
  grep -Eq '^- Current active capsule( in this isolated worktree)?: `implementation/roadmap/capsules/adaptive-character-guidance\.md`' implementation/roadmap/CURRENT.md
}

is_adaptive_character_guidance_functions_path() {
  case "$1" in
    functions/src/agent/homeGuideAgent.ts|\
    functions/src/agent/homeGuideAgentHandler.ts|\
    functions/src/agent/homeGuideContracts.ts|\
    functions/src/agent/homeGuideEvidence.ts|\
    functions/src/agent/homeGuideModel.ts|\
    functions/src/agent/homeGuideModelOutput.ts|\
    functions/src/agent/homeGuideQuotaCache.ts|\
    functions/src/agent/homeGuideQuotaFingerprint.ts|\
    functions/test/homeGuideAgentCallableSurface.test.ts|\
    functions/test/homeGuideAgentSurface.test.ts|\
    functions/test/homeGuideEvidence.test.ts|\
    functions/test/homeGuideEvidenceFixtures.ts|\
    functions/test/homeGuideModel.test.ts|\
    functions/test/homeGuideModelFixtures.ts|\
    functions/test/homeGuideQuotaCache.test.ts)
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
    functions/*)
      if is_historical_backend_functions_path "$1"; then
        return 1
      fi
      if is_adaptive_character_guidance_functions_path "$1" && is_adaptive_character_guidance_capsule_active; then
        return 1
      fi
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
          if is_historical_backend_functions_path "$path"; then
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
