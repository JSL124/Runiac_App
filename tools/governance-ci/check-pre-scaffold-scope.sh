#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-pre-scaffold-scope"
scanned_paths="git ls-files --cached --others --exclude-standard"
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
    functions/src/agent/homeGuideAgent.ts|\
    functions/src/agent/homeGuideAgentHandler.ts|\
    functions/src/agent/homeGuideConsent.ts|\
    functions/src/agent/homeGuideContracts.ts|\
    functions/src/agent/homeGuideEvidence.ts|\
    functions/src/agent/homeGuideModel.ts|\
    functions/src/agent/homeGuideModelOutput.ts|\
    functions/src/agent/homeGuideQuotaCache.ts|\
    functions/src/agent/homeGuideQuotaFingerprint.ts|\
    functions/src/agent/activityFeedbackAgent.ts|\
    functions/src/agent/activityFeedbackAgentHandler.ts|\
    functions/src/agent/activityFeedbackContractFields.ts|\
    functions/src/agent/activityFeedbackContracts.ts|\
    functions/src/agent/activityFeedbackModel.ts|\
    functions/src/agent/activityFeedbackModelOutput.ts|\
    functions/src/agent/activityFeedbackQuota.ts|\
    functions/src/agent/activityFeedbackTypes.ts|\
    functions/src/config/configLoader.ts|\
    functions/src/security/appCheck.ts|\
    functions/src/feed/cleanup.ts|\
    functions/src/feed/contracts.ts|\
    functions/src/feed/engagement/engagement.ts|\
    functions/src/feed/fixtures/cli.ts|\
    functions/src/feed/fixtures/emulatorFixtures.ts|\
    functions/src/feed/fixtures/fixtureDefinitions.ts|\
    functions/src/feed/fixtures/fixtureLibrary.ts|\
    functions/src/feed/lifecycle/core.ts|\
    functions/src/feed/lifecycle/firebasePort.ts|\
    functions/src/feed/lifecycle/functions.ts|\
    functions/src/feed/lifecycle/types.ts|\
    functions/src/feed/png.ts|\
    functions/src/feed/publish/callable.ts|\
    functions/src/feed/publish/core.ts|\
    functions/src/feed/publish/entitlement.ts|\
    functions/src/feed/relationship.ts|\
    functions/src/feed/thumbnail/callable.ts|\
    functions/src/feed/thumbnail/core.ts|\
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
    functions/src/leaderboard/monthlyLeaderboardOwnerFacts.ts|\
    functions/src/leaderboard/monthlyLeaderboardPeriod.ts|\
    functions/src/leaderboard/monthlyLeaderboardPlanner.ts|\
    functions/src/leaderboard/monthlyLeaderboardWriter.ts|\
    functions/src/leaderboard/monthlyLeaderboardWrites.ts|\
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
    functions/src/run/rejectUnsupportedFields.ts|\
    functions/src/run/validateRoutePreview.ts|\
    functions/src/run/validateRunSummaryDetails.ts|\
    functions/test/activityFeedbackAgentCallableSurface.test.ts|\
    functions/test/activityFeedbackContracts.test.ts|\
    functions/test/activityFeedbackModel.test.ts|\
    functions/test/completeRun.test.ts|\
    functions/test/planProgressCompletion.test.ts|\
    functions/test/completeRunCallableSurface.test.ts|\
    functions/test/completeRunRichSummaryCases.ts|\
    functions/test/completeRunRichSummaryFixtures.ts|\
    functions/test/completeRunRichSummaryScenarios.ts|\
    functions/test/configLoader.test.ts|\
    functions/test/feedCallableSurface.test.ts|\
    functions/test/feedContracts.test.ts|\
    functions/test/feedEmulatorIntegration.test.ts|\
    functions/test/feedEngagement.test.ts|\
    functions/test/feedFixtureGuard.test.ts|\
    functions/test/feedLifecycle.test.ts|\
    functions/test/feedPublishCore.test.ts|\
    functions/test/feedPublishEntitlement.test.ts|\
    functions/test/feedThumbnailCore.test.ts|\
    functions/test/homeGuideAgentCallableSurface.test.ts|\
    functions/test/homeGuideConsent.test.ts|\
    functions/test/homeGuideAgentSurface.test.ts|\
    functions/test/homeGuideEvidence.test.ts|\
    functions/test/homeGuideEvidenceFixtures.ts|\
    functions/test/homeGuideGeneratedCopyPolicy.test.ts|\
    functions/test/homeGuideModel.test.ts|\
    functions/test/homeGuideModelFixtures.ts|\
    functions/test/homeGuideQuotaCache.test.ts|\
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

is_historical_backend_config_path() {
  case "$1" in
    firebase.json|firestore.indexes.json|firestore.rules|storage.rules|\
    implementation/roadmap/CURRENT.md|\
    implementation/roadmap/capsules/feed-friends-emulator-backend.md|\
    implementation/roadmap/snapshots/latest.md|\
    tests/firebase-rules/feed.emulator.guard.mjs|\
    tests/firebase-rules/feed.firestore.rules.test.mjs|\
    tests/firebase-rules/feed.storage.rules.test.mjs|\
    tests/firebase-rules/package.json|\
    tests/firebase-rules/package-lock.json)
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

is_feed_friends_emulator_backend_capsule_active() {
  grep -Eq '^- Current active capsule in this isolated worktree: `implementation/roadmap/capsules/feed-friends-emulator-backend\.md`\.' implementation/roadmap/CURRENT.md
}

is_challenge_distance_system_capsule_active() {
  grep -Eq '^- Newly routed Challenge distance system on 2026-07-13 Asia/Singapore: `implementation/roadmap/capsules/challenge-distance-system\.md`' implementation/roadmap/CURRENT.md
}

is_friends_backend_mvp_capsule_active() {
  grep -Eq '^- Newly routed backed Friends MVP on 2026-07-13 Asia/Singapore: `implementation/roadmap/capsules/friends-backend-mvp\.md`' implementation/roadmap/CURRENT.md
}

is_friends_backend_mvp_functions_path() {
  case "$1" in
    functions/src/friends/*|\
    functions/test/friendsCore.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_challenge_distance_system_functions_path() {
  case "$1" in
    functions/src/challenge/*|\
    functions/test/challenge*.ts|\
    functions/test/levelUpLeaderboard.integration.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_cool_down_stretch_xp_bonus_capsule_active() {
  grep -Eq '^- Newly routed cool-down stretch completion XP bonus on 2026-07-14 Asia/Singapore: `implementation/roadmap/capsules/cool-down-stretch-completion-xp-bonus\.md`' implementation/roadmap/CURRENT.md
}

is_cool_down_stretch_xp_bonus_functions_path() {
  case "$1" in
    functions/src/run/completeCoolDown.ts|\
    functions/src/run/validateCoolDownPayload.ts|\
    functions/src/run/runCompletionTypes.ts|\
    functions/src/run/runCompletionArtifacts.ts|\
    functions/src/progression/progressionCalculator.ts|\
    functions/src/progression/progressionAudit.ts|\
    functions/src/progression/progressionDisplayReader.ts|\
    functions/src/index.ts|\
    functions/test/completeCoolDown.test.ts|\
    functions/test/progressionCalculator.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_admin_console_leaderboard_oversight_capsule_active() {
  grep -Eq '^- Newly routed admin console Leaderboard Oversight alignment on 2026-07-20 Asia/Singapore: `implementation/roadmap/capsules/admin-console-leaderboard-oversight\.md`' implementation/roadmap/CURRENT.md
}

is_admin_console_leaderboard_oversight_functions_path() {
  case "$1" in
    functions/src/leaderboard/leaderboardTypes.ts|\
    functions/src/leaderboard/monthlyLeaderboard.ts|\
    functions/src/leaderboard/monthlyLeaderboardPlanner.ts|\
    functions/src/leaderboard/monthlyLeaderboardWriter.ts|\
    functions/src/leaderboard/leaderboardAdminCommand.ts|\
    functions/src/run/completeRun.ts|\
    functions/src/run/completeCoolDown.ts|\
    functions/src/index.ts|\
    functions/test/monthlyLeaderboard.test.ts|\
    functions/test/monthlyLeaderboardWriter.test.ts|\
    functions/test/leaderboardAdminCommand.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_friends_emulator_backend_rules_test_path() {
  local path="$1"
  local relative_path
  local basename

  case "$path" in
    tests/firebase-rules/*) relative_path="${path#tests/firebase-rules/}" ;;
    *) return 1 ;;
  esac
  case "$relative_path" in
    */*) return 1 ;;
  esac

  basename="${relative_path##*/}"
  case "$basename" in
    *feed*.mjs) return 0 ;;
    *) return 1 ;;
  esac
}

is_feed_friends_emulator_backend_rules_test_candidate_path() {
  local path="$1"
  local basename

  case "$path" in
    tests/firebase-rules/*) basename="${path##*/}" ;;
    *) return 1 ;;
  esac

  case "$basename" in
    *feed*.mjs) return 0 ;;
    *) return 1 ;;
  esac
}

is_feed_friends_emulator_backend_functions_test_path() {
  local path="$1"
  local relative_path
  local basename

  case "$path" in
    functions/test/*) relative_path="${path#functions/test/}" ;;
    *) return 1 ;;
  esac
  case "$relative_path" in
    */*) return 1 ;;
  esac

  basename="${relative_path##*/}"
  case "$basename" in
    feed*.ts) return 0 ;;
    *) return 1 ;;
  esac
}

is_feed_friends_emulator_backend_path() {
  if is_feed_friends_emulator_backend_rules_test_path "$1" || is_feed_friends_emulator_backend_functions_test_path "$1"; then
    return 0
  fi

  case "$1" in
    implementation/roadmap/capsules/feed-friends-emulator-backend.md|\
    implementation/roadmap/CURRENT.md|\
    implementation/roadmap/snapshots/latest.md|\
    firebase.json|firestore.rules|firestore.indexes.json|storage.rules|\
    tests/firebase-rules/package.json|tests/firebase-rules/package-lock.json|\
    functions/src/feed/*|\
    functions/src/index.ts|functions/package.json|functions/package-lock.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac

}

is_adaptive_character_guidance_functions_path() {
  case "$1" in
    functions/src/index.ts|\
    functions/src/security/appCheck.ts|\
    functions/src/agent/activityFeedbackAgent.ts|\
    functions/src/agent/homeGuideConsent.ts|\
    functions/src/agent/homeGuideAgent.ts|\
    functions/src/agent/homeGuideAgentHandler.ts|\
    functions/src/agent/homeGuideContracts.ts|\
    functions/src/agent/homeGuideEvidence.ts|\
    functions/src/agent/homeGuideModel.ts|\
    functions/src/agent/homeGuideModelOutput.ts|\
    functions/src/agent/homeGuideQuotaCache.ts|\
    functions/src/agent/homeGuideQuotaFingerprint.ts|\
    functions/src/progression/refreshStreakStatus.ts|\
    functions/test/homeGuideAgentCallableSurface.test.ts|\
    functions/test/homeGuideConsent.test.ts|\
    functions/test/homeGuideAgentSurface.test.ts|\
    functions/test/homeGuideEvidence.test.ts|\
    functions/test/homeGuideEvidenceFixtures.ts|\
    functions/test/homeGuideLoggerCapture.ts|\
    functions/test/homeGuideModel.test.ts|\
    functions/test/homeGuideModelFixtures.ts|\
    functions/test/homeGuideQuotaCache.test.ts|\
    functions/test/streakExpiry.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

approved_adaptive_inactive_baseline_blob() {
  case "$1" in
    functions/src/progression/refreshStreakStatus.ts)
      printf '%s\n' '26ec88d24e4f28415cbef6b473fa9d98d0e9f842'
      ;;
    functions/test/streakExpiry.test.ts)
      printf '%s\n' 'ca432a704997422ba9e8e3f96abad33ffc1c1e1e'
      ;;
    functions/test/homeGuideLoggerCapture.ts)
      printf '%s\n' 'b5e8340a755b33bb4fb1d8f425649bd4172e3af7'
      ;;
    *)
      return 1
      ;;
  esac
}

check_approved_adaptive_inactive_baselines() {
  local path
  local expected_blob
  local index_blob
  local worktree_blob

  if is_adaptive_character_guidance_capsule_active; then
    return 0
  fi

  while IFS= read -r path; do
    expected_blob="$(approved_adaptive_inactive_baseline_blob "$path")"
    index_blob="$(git rev-parse ":$path" 2>/dev/null || true)"
    worktree_blob="$(git hash-object -- "$path" 2>/dev/null || true)"

    if [ "$index_blob" != "$expected_blob" ] || [ "$worktree_blob" != "$expected_blob" ]; then
      fail "Adaptive inactive immutable baseline mismatch: $path (expected_blob=$expected_blob index_blob=${index_blob:-missing} worktree_blob=${worktree_blob:-missing})"
    fi
  done <<'PATHS'
functions/src/progression/refreshStreakStatus.ts
functions/test/streakExpiry.test.ts
functions/test/homeGuideLoggerCapture.ts
PATHS
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

is_user_feedback_pipeline_capsule_active() {
  grep -Eq '^- Newly routed user feedback pipeline on 2026-07-19 Asia/Singapore: `implementation/roadmap/capsules/user-feedback-pipeline\.md`' implementation/roadmap/CURRENT.md
}

is_error_reporting_pipeline_capsule_active() {
  grep -Eq '^- Newly routed error reporting pipeline on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/error-reporting-pipeline\.md`' implementation/roadmap/CURRENT.md
}

# New source files introduced by the routed error reporting pipeline capsule.
# Only the genuinely new paths need listing here; already-tracked files this
# capsule modifies are handled by the diff-hygiene allowlist.
is_error_reporting_pipeline_path() {
  case "$1" in
    functions/src/errors/errorGroupStore.ts|\
    functions/src/errors/reportAppError.ts|\
    functions/src/errors/reportBackendError.ts|\
    functions/src/errors/sanitize.ts|\
    functions/src/errors/withErrorReporting.ts|\
    functions/test/reportAppError.test.ts|\
    functions/test/backendErrorReporting.test.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    firestore.rules)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_live_author_level_capsule_active() {
  grep -Eq '^- Newly routed feed live author level on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/feed-live-author-level\.md`' implementation/roadmap/CURRENT.md
}

# New source files introduced by the routed feed live author level capsule.
# Only the genuinely new paths need listing here; already-tracked files this
# capsule modifies are handled by the diff-hygiene allowlist.
is_friends_live_level_capsule_active() {
  grep -Eq '^- Newly routed friends live level on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/friends-live-level\.md`' implementation/roadmap/CURRENT.md
}

is_friends_live_level_path() {
  case "$1" in
    implementation/roadmap/capsules/friends-live-level.md|\
    functions/src/progression/profileLevelDisplay.ts|\
    functions/src/friends/friendLevels/core.ts|\
    functions/src/friends/friendLevels/callable.ts|\
    functions/src/friends/friendsDiscovery.ts|\
    functions/test/friendLevels.test.ts|\
    functions/test/friendsCore.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_live_author_level_path() {
  case "$1" in
    functions/src/feed/authorLevels/core.ts|\
    functions/src/feed/authorLevels/callable.ts|\
    functions/test/feedAuthorLevels.test.ts|\
    functions/src/index.ts|\
    functions/package.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_exception_queue_moderation_capsule_active() {
  grep -Eq '^- Newly routed Exception Queue moderation adjudication on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/exception-queue-moderation-adjudication\.md`' implementation/roadmap/CURRENT.md
}

# New source files introduced by the routed Exception Queue moderation capsule.
# Only the genuinely new paths need listing here; already-tracked files this
# capsule modifies are handled by the diff-hygiene allowlist.
is_exception_queue_moderation_path() {
  case "$1" in
    functions/src/moderation/moderationCommand.ts|\
    functions/src/security/accountStatus.ts|\
    functions/test/moderationCommand.test.ts|\
    functions/test/accountStatus.test.ts|\
    functions/src/index.ts|\
    functions/package.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_admin_role_subscription_expiry_capsule_active() {
  grep -Eq '^- Newly routed admin role and subscription expiry on 2026-07-20 Asia/Singapore: `implementation/roadmap/capsules/admin-role-subscription-expiry\.md`' implementation/roadmap/CURRENT.md
}

# New source files introduced by the routed admin role / premium expiry capsule.
# Only the genuinely new paths need listing here; already-tracked files this
# capsule modifies are handled by the diff-hygiene allowlist.
is_admin_role_subscription_expiry_path() {
  case "$1" in
    functions/src/security/roles.ts|\
    functions/src/progression/subscriptionExpiryCore.ts|\
    functions/src/progression/subscriptionExpirySchedule.ts|\
    functions/test/roles.test.ts|\
    functions/test/progressionAuditHelpers.test.ts|\
    functions/test/subscriptionExpiry.test.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    firestore.indexes.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Note: the rules test basename contains "feed", so this must be consulted
# before the feed-friends-emulator-backend basename patterns claim it.
is_user_feedback_pipeline_path() {
  case "$1" in
    firestore.rules|\
    firestore.indexes.json|\
    functions/src/feedback/*|\
    functions/test/submitFeedback.test.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    tests/firebase-rules/feedback.firestore.rules.test.mjs|\
    tests/firebase-rules/package.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_admin_automation_policy_capsule_active() {
  grep -Eq '^- Newly routed admin automation & policy control plane on 2026-07-22 Asia/Singapore: `implementation/roadmap/capsules/admin-automation-policy-control-plane\.md`' implementation/roadmap/CURRENT.md
}

# New source files introduced by the routed admin automation & policy control
# plane capsule. Only the genuinely new paths need listing here; already-tracked
# files this capsule modifies are handled by the diff-hygiene allowlist.
is_admin_automation_policy_path() {
  case "$1" in
    functions/src/config/automationGate.ts|\
    functions/src/moderation/reportAutomation.ts|\
    functions/src/moderation/staleReportSweep.ts|\
    functions/src/errors/errorGroupNotifications.ts|\
    functions/test/automationGate.test.ts|\
    functions/test/reportAutomation.test.ts|\
    functions/test/staleReportSweep.test.ts|\
    functions/test/errorGroupNotifications.test.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    tools/governance-ci/check-pre-scaffold-scope.sh)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_forbidden_config_or_secret() {
  if is_error_reporting_pipeline_path "$1" && is_error_reporting_pipeline_capsule_active; then
    return 1
  fi

  if is_user_feedback_pipeline_path "$1" && is_user_feedback_pipeline_capsule_active; then
    return 1
  fi

  if is_exception_queue_moderation_path "$1" && is_exception_queue_moderation_capsule_active; then
    return 1
  fi

  if is_feed_live_author_level_path "$1" && is_feed_live_author_level_capsule_active; then
    return 1
  fi

  if is_friends_live_level_path "$1" && is_friends_live_level_capsule_active; then
    return 1
  fi

  if is_admin_automation_policy_path "$1" && is_admin_automation_policy_capsule_active; then
    return 1
  fi

  if is_admin_role_subscription_expiry_path "$1" && is_admin_role_subscription_expiry_capsule_active; then
    return 1
  fi

  if is_historical_backend_config_path "$1"; then
    return 1
  fi

  if is_historical_backend_functions_path "$1"; then
    return 1
  fi

  if is_feed_friends_emulator_backend_rules_test_candidate_path "$1"; then
    if is_feed_friends_emulator_backend_path "$1" && is_feed_friends_emulator_backend_capsule_active; then
      return 1
    fi
    return 0
  fi

  if is_feed_friends_emulator_backend_path "$1"; then
    if is_feed_friends_emulator_backend_capsule_active; then
      return 1
    fi
    return 0
  fi

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
      if is_friends_backend_mvp_functions_path "$1" && is_friends_backend_mvp_capsule_active; then
        return 1
      fi
      if is_challenge_distance_system_functions_path "$1" && is_challenge_distance_system_capsule_active; then
        return 1
      fi
      if is_cool_down_stretch_xp_bonus_functions_path "$1" && is_cool_down_stretch_xp_bonus_capsule_active; then
        return 1
      fi
      if is_adaptive_character_guidance_functions_path "$1" && is_adaptive_character_guidance_capsule_active; then
        return 1
      fi
      if is_admin_console_leaderboard_oversight_functions_path "$1" && is_admin_console_leaderboard_oversight_capsule_active; then
        return 1
      fi
      if is_exception_queue_moderation_path "$1" && is_exception_queue_moderation_capsule_active; then
        return 1
      fi
      if is_feed_live_author_level_path "$1" && is_feed_live_author_level_capsule_active; then
        return 1
      fi
      if is_friends_live_level_path "$1" && is_friends_live_level_capsule_active; then
        return 1
      fi
      if is_admin_automation_policy_path "$1" && is_admin_automation_policy_capsule_active; then
        return 1
      fi
      if approved_adaptive_inactive_baseline_blob "$1" >/dev/null; then
        return 1
      fi
      return 0
      ;;
  esac

  return 1
}

check_approved_adaptive_inactive_baselines

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
