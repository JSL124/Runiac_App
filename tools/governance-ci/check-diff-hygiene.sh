#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-diff-hygiene"
scanned_paths="git status --short,git diff --check,git diff --cached --check,git diff --name-status"
failures=0

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

is_complete_run_functions_capsule_active() {
  grep -Eq '^- Current active capsule: `implementation/roadmap/capsules/complete-run-cloud-functions-emulator-skeleton\.md`' implementation/roadmap/CURRENT.md
}

is_running_activity_history_capsule_active() {
  grep -Eq '^- Current active capsule: `implementation/roadmap/capsules/running-activity-history-user-link\.md`' implementation/roadmap/CURRENT.md
}

is_run_duration_fields_capsule_active() {
  grep -Eq '^- Current active capsule: `implementation/roadmap/capsules/run-duration-fields\.md`' implementation/roadmap/CURRENT.md
}

is_cadence_capture_reliability_capsule_active() {
  grep -Eq '^- Current active capsule: `implementation/roadmap/capsules/cadence-capture-reliability-recovery\.md`' implementation/roadmap/CURRENT.md
}

is_cadence_capture_reliability_functions_path() {
  case "$1" in
    functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/test/completeRun.test.ts)
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

is_challenge_distance_system_path() {
  case "$1" in
    implementation/roadmap/capsules/challenge-distance-system.md|\
    implementation/roadmap/snapshots/latest.md|\
    functions/src/challenge/*|\
    functions/test/challenge*.ts|\
    functions/src/notifications/*|\
    functions/src/index.ts|\
    functions/package.json|\
    tests/firebase-rules/challenge.firestore.rules.test.mjs)
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

  # implementation/roadmap/CURRENT.md is intentionally not claimed here:
  # routing updates to CURRENT.md are governed by the general roadmap
  # allowlist below so routed non-feed capsules can append routing while
  # the Feed capsule is inactive in this worktree's CURRENT.md.
  case "$1" in
    implementation/roadmap/capsules/feed-friends-emulator-backend.md|\
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
    functions/package.json|\
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

is_running_activity_history_functions_path() {
  case "$1" in
    functions/package.json|functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateRunPayload.ts|functions/test/completeRun.test.ts|functions/test/completeRunZeroMetrics.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_run_duration_fields_functions_path() {
  case "$1" in
    functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/src/run/validateRunScalarFields.ts|functions/test/completeRun.test.ts|functions/test/completeRunCallableSurface.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_allowed_path() {
  if is_challenge_distance_system_path "$1" && is_challenge_distance_system_capsule_active; then
    return 0
  fi

  if is_feed_friends_emulator_backend_path "$1"; then
    if is_feed_friends_emulator_backend_capsule_active; then
      return 0
    fi
    return 1
  fi

  case "$1" in
    implementation/roadmap/capsules/run-completion-authoritative-result-recovery.md)
      return 0
      ;;
    implementation/roadmap/capsules/cadence-capture-reliability-recovery.md)
      if is_cadence_capture_reliability_capsule_active; then
        return 0
      fi
      return 1
      ;;
    # Approved: non-operational historical archive (Phase A)
    docs/meta/.aiignore|docs/meta/README.md|docs/meta/RETROSPECTIVE_POLICY.md|docs/meta/RUNIAC_REPOSITORY_EVOLUTION_REPORT.md|tools/governance-ci/check-historical-isolation.sh)
      return 0
      ;;
    implementation/roadmap/capsules/friends-row-add-pending-icons.md)
      return 0
      ;;
    # Approved: routed capsule documentation/governance patches only
    docs/meta/REPOSITORY_WORKFLOW_RECORD.md|implementation/roadmap/capsules/repository-workflow-record.md|implementation/roadmap/capsules/flutter-app-shell-baseline.md|implementation/roadmap/capsules/android-ui-smoke-test-evidence.md|implementation/roadmap/capsules/home-dashboard-visual-polish.md|implementation/roadmap/capsules/premium-home-dashboard-static-wireframe-alignment.md|implementation/roadmap/capsules/github-actions-governance-ci-baseline.md|implementation/roadmap/capsules/github-actions-flutter-validation-baseline.md|implementation/roadmap/capsules/home-dashboard-scroll-layout-stability-fix.md|implementation/roadmap/capsules/home-dashboard-reference-layout-alignment.md|implementation/roadmap/capsules/home-dashboard-primary-action-simplification.md|implementation/roadmap/capsules/home-maps-static-read-model-snapshot-readiness.md|implementation/roadmap/capsules/complete-run-progression-contract-plan.md|implementation/roadmap/capsules/complete-run-cloud-functions-emulator-skeleton.md|implementation/roadmap/capsules/run-duration-fields.md|implementation/roadmap/capsules/running-activity-history-user-link.md|implementation/roadmap/capsules/firestore-base-bootstrap-seam.md|implementation/roadmap/capsules/profile-persistence-rules-contract.md|implementation/roadmap/capsules/goal-plan-detail-static-snapshot-shell.md|implementation/roadmap/capsules/goal-plan-detail-header-timeline-alignment.md|implementation/roadmap/capsules/maps-tab-static-placeholder.md|implementation/roadmap/capsules/maps-static-discovery-hierarchy-polish.md|implementation/roadmap/capsules/leaderboard-static-motivation-hierarchy-polish.md|implementation/roadmap/capsules/leaderboard-map-first-landing-shell.md|implementation/roadmap/capsules/leaderboard-help-modal-shell.md|implementation/roadmap/capsules/leaderboard-region-preview-sheet-shell.md|implementation/roadmap/capsules/leaderboard-leagues-popup-shell.md|implementation/roadmap/capsules/leaderboard-static-read-model-snapshot-readiness.md|implementation/roadmap/capsules/flutter-frontend-hygiene-cleanup.md|implementation/roadmap/capsules/flutter-source-structure-refactor.md|implementation/roadmap/capsules/run-tab-static-placeholder.md|implementation/roadmap/capsules/run-tab-fullscreen-map-overlay-alignment.md|implementation/roadmap/capsules/run-controls-and-plan-spacing-polish.md|implementation/roadmap/capsules/run-launch-fullscreen-static-interaction.md|implementation/roadmap/capsules/run-launch-brand-color-polish.md|implementation/roadmap/capsules/run-plan-objective-bottom-sheet.md|implementation/roadmap/capsules/run-static-read-model-snapshot-readiness.md|implementation/roadmap/capsules/weekly-workout-detail-static-snapshot-shell.md|implementation/roadmap/capsules/expert-plan-list-static-snapshot-shell.md|implementation/roadmap/capsules/expert-plan-detail-static-snapshot-shell.md|implementation/roadmap/capsules/you-tab-progress-overview-static.md|implementation/roadmap/capsules/you-plans-static-ui.md|implementation/roadmap/capsules/home-social-dropdown-friends-shell.md)
      return 0
      ;;
    # Approved: scaffold-baseline instruction/setup-gate alignment only
    implementation/AGENTS.md|implementation/mobile/AGENTS.md|implementation/traceability/setup-gates.md|implementation/traceability/requirements-map.md)
      return 0
      ;;
    # Approved: scaffold-baseline and Codex-only review instruction cleanup
    AGENTS.md|docs/pdd/AGENTS_CHANGELOG.md|.agents/skills/runiac-review-flow/SKILL.md|.claude/settings.json|tools/agent-review/README.md|tools/agent-review/profiles/runiac/context-policy.yml|tools/agent-review/runner/build_context_packet.sh|tools/agent-review/runner/classify_high_risk_task.sh|tools/agent-review/runner/run_plan_review.sh|tools/agent-review/profiles/runiac/prompts/01_codex_create_plan.md)
      return 0
      ;;
    # Approved: reusable agent-review reference templates only
    tools/agent-review/templates/*.md)
      return 0
      ;;
    implementation/roadmap/CURRENT.md|implementation/roadmap/phases/phase-01-governance-ci.md|implementation/roadmap/snapshots/latest.md|implementation/roadmap/decisions/ADR-003-governance-lite-execution-lanes.md|implementation/roadmap/ci/*|tools/governance-ci/*|.github/workflows/governance-ci.yml)
      return 0
      ;;
    .gitignore)
      return 0
      ;;
    firebase/README.md|firebase/emulators/README.md|firebase/messaging/README.md|firebase.json|firestore.rules|firestore.indexes.json|tests/firebase-rules/.gitignore|tests/firebase-rules/firestore.rules.test.mjs|tests/firebase-rules/support/firestore_rules_test_support.mjs|tests/firebase-rules/package-lock.json|tests/firebase-rules/package.json)
      return 0
      ;;
    tests/governance/backend_functions_scope_test.sh)
      return 0
      ;;
    functions/.gitignore|functions/package-lock.json|functions/package.json|functions/tsconfig.json|functions/src/index.ts|functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/src/run/validateRunScalarFields.ts|functions/src/progression/planBoundedStreakState.ts|functions/src/progression/progressionEventWriter.ts|functions/src/progression/streakCalculator.ts|functions/src/agent/homeGuideAgent.ts|functions/src/agent/homeGuideAgentHandler.ts|functions/src/agent/homeGuideContracts.ts|functions/src/agent/homeGuideEvidence.ts|functions/src/agent/homeGuideModel.ts|functions/src/agent/homeGuideModelOutput.ts|functions/src/agent/homeGuideQuotaCache.ts|functions/src/agent/homeGuideQuotaFingerprint.ts|functions/test/completeRun.test.ts|functions/test/completeRunCallableSurface.test.ts|functions/test/homeGuideAgentCallableSurface.test.ts|functions/test/homeGuideAgentSurface.test.ts|functions/test/homeGuideEvidence.test.ts|functions/test/homeGuideEvidenceFixtures.ts|functions/test/homeGuideModel.test.ts|functions/test/homeGuideModelFixtures.ts|functions/test/homeGuideQuotaCache.test.ts)
      if is_complete_run_functions_capsule_active; then
        return 0
      fi
      if is_running_activity_history_functions_path "$1" && is_running_activity_history_capsule_active; then
        return 0
      fi
      if is_run_duration_fields_functions_path "$1" && is_run_duration_fields_capsule_active; then
        return 0
      fi
      if is_cadence_capture_reliability_functions_path "$1" && is_cadence_capture_reliability_capsule_active; then
        return 0
      fi
      if is_adaptive_character_guidance_functions_path "$1" && is_adaptive_character_guidance_capsule_active; then
        return 0
      fi
      return 1
      ;;
    functions/test/completeRunZeroMetrics.test.ts)
      if is_running_activity_history_capsule_active; then
        return 0
      fi
      return 1
      ;;
    implementation/mobile/runiac_app/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_unrelated_mobile_native_artifact() {
  case "$1" in
    implementation/mobile/runiac_app/ios/Podfile.lock|\
    implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.pbxproj|\
    implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/*|\
    implementation/mobile/runiac_app/ios/Runner.xcworkspace/xcshareddata/swiftpm/*|\
    implementation/mobile/runiac_app/ios/**/Package.resolved)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_forbidden_path() {
  if is_challenge_distance_system_path "$1" && is_challenge_distance_system_capsule_active; then
    return 1
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
    functions/.gitignore|functions/package-lock.json|functions/package.json|functions/tsconfig.json|functions/src/index.ts|functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/src/run/validateRunScalarFields.ts|functions/src/progression/planBoundedStreakState.ts|functions/src/progression/progressionEventWriter.ts|functions/src/progression/streakCalculator.ts|functions/src/agent/homeGuideAgent.ts|functions/src/agent/homeGuideAgentHandler.ts|functions/src/agent/homeGuideContracts.ts|functions/src/agent/homeGuideEvidence.ts|functions/src/agent/homeGuideModel.ts|functions/src/agent/homeGuideModelOutput.ts|functions/src/agent/homeGuideQuotaCache.ts|functions/src/agent/homeGuideQuotaFingerprint.ts|functions/test/completeRun.test.ts|functions/test/completeRunCallableSurface.test.ts|functions/test/homeGuideAgentCallableSurface.test.ts|functions/test/homeGuideAgentSurface.test.ts|functions/test/homeGuideEvidence.test.ts|functions/test/homeGuideEvidenceFixtures.ts|functions/test/homeGuideModel.test.ts|functions/test/homeGuideModelFixtures.ts|functions/test/homeGuideQuotaCache.test.ts)
      if is_complete_run_functions_capsule_active; then
        return 1
      fi
      if is_running_activity_history_functions_path "$1" && is_running_activity_history_capsule_active; then
        return 1
      fi
      if is_run_duration_fields_functions_path "$1" && is_run_duration_fields_capsule_active; then
        return 1
      fi
      if is_cadence_capture_reliability_functions_path "$1" && is_cadence_capture_reliability_capsule_active; then
        return 1
      fi
      if is_adaptive_character_guidance_functions_path "$1" && is_adaptive_character_guidance_capsule_active; then
        return 1
      fi
      return 0
      ;;
    functions/test/completeRunZeroMetrics.test.ts)
      if is_running_activity_history_capsule_active; then
        return 1
      fi
      return 0
      ;;
    functions/*)
      return 0
      ;;
    *package.json)
      case "$1" in
        functions/package.json)
          if is_complete_run_functions_capsule_active || is_running_activity_history_capsule_active; then
            return 1
          fi
          return 0
          ;;
        implementation/*|firebase/*|functions/*)
          return 0
          ;;
      esac
      ;;
  esac

  return 1
}

is_deletion_status() {
  case "$1" in
    " D"|"D "|D)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
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
  status_code="${line:0:2}"
  path="${line:3}"
  case "$path" in
    *' -> '*)
      path="${path##* -> }"
      ;;
  esac

  if ! is_allowed_path "$path"; then
    fail "Unrelated modified path is outside Governance CI scope: $path"
  fi

  if is_unrelated_mobile_native_artifact "$path"; then
    fail "Unrelated iOS/SwiftPM native artifact appears in diff status: $path"
  fi

  if is_forbidden_path "$path" && ! is_deletion_status "$status_code"; then
    fail "Forbidden implementation/config artifact appears in diff status: $path"
  fi

  if is_pubspec_outside_approved_scaffold "$path"; then
    fail "Flutter pubspec artifact appears outside approved scaffold path: $path"
  fi
done < <(git status --short --untracked-files=all)

while IFS=$'\t' read -r status path rest; do
  [ -n "$path" ] || continue
  if [ -n "${rest:-}" ]; then
    path="$rest"
  fi

  if is_unrelated_mobile_native_artifact "$path"; then
    fail "Unrelated iOS/SwiftPM native artifact appears in tracked diff: $path"
  fi

  if is_forbidden_path "$path" && ! is_deletion_status "$status"; then
    fail "Forbidden implementation/config artifact appears in tracked diff: $path"
  fi

  if is_pubspec_outside_approved_scaffold "$path"; then
    fail "Flutter pubspec artifact appears outside approved scaffold path: $path"
  fi
done < <(git diff --name-status)

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Diff has no whitespace errors, unrelated paths, or forbidden implementation/config artifacts; approved Flutter scaffold, Auth config, Functions skeleton, and routed capsule exceptions are allowed only on their explicit paths.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Diff hygiene failed.\n'
printf 'next_step=Remove unrelated or forbidden files, fix whitespace, then rerun once.\n'
exit 1
