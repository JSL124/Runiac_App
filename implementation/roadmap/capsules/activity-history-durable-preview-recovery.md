# activity-history-durable-preview-recovery

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed IMPLEMENTATION_MODE production bug fix.

## Goal

Keep a user's meaningful running analysis and privacy-safe route thumbnail available in Activity History and Activity Summary after deleting/reinstalling the app and signing back into the same account.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Flutter run completion/history plus trusted Cloud Functions persistence.
- Status: `In progress`.
- Required terminal state: `Ready for user screen QA` and `Ready for manual commit`.
- Commit boundary: no commit from the debugging workflow; prepare atomic manual commit groups only.

## Required Agent / Review Chain

`A0_ORCH -> A9_TRACE -> A10_FLUTTER_IMPL -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Allowed Scope

- Persist bounded derived pace, cadence, and elevation series in owner-scoped `runSummaries` through authenticated `completeRun`.
- Persist a bounded privacy-masked route preview only: at most 64 segments / 256 points, coordinates quantized to 3 decimal places, without timestamps, altitude, accuracy, speed, or raw route samples.
- Restore those fields from Firestore when no local completion state exists after reinstall.
- Regenerate Activity History thumbnails only from an explicitly trusted owner-scoped persisted preview.
- Preserve local full-fidelity route data for the current session and pending retry; never send that precise route through the backend contract.
- Add failing-first Functions, Flutter mapper, retry, privacy, auth-switch, downsampling, and widget tests.
- Emulator-first backend QA and physical-device UI QA using non-sensitive test data.

## Forbidden Scope

- No precise GPS coordinates, timestamps, altitude, accuracy, speed, or raw route trace persistence.
- No raw route data in OpenAI requests, prompts, logs, or generated feedback.
- No client writes to `runSummaries` or any trusted progression field.
- No XP, streak, level, rank, leaderboard, entitlement, role, or publication behavior changes.
- No Feed, Running map, or Leaderboard redesign or persistence changes.
- No production deployment, Firebase init, FlutterFire configure, new secrets, service accounts, or dependencies.
- No attempt to fabricate rich data for legacy summaries that never stored it.

## Exact Target Areas

- `functions/src/run/**`
- `functions/test/completeRun.test.ts`
- `implementation/mobile/runiac_app/lib/features/run/domain/models/**`
- `implementation/mobile/runiac_app/lib/features/run/presentation/controllers/run_tracking_controller.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_active_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart`
- `implementation/mobile/runiac_app/lib/features/you/data/**`
- `implementation/mobile/runiac_app/lib/features/you/domain/models/activity_history_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/activity_history_display_controller.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_*`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/compact_run_activity_card.dart`
- Focused tests for those paths.
- This capsule, `implementation/roadmap/CURRENT.md`, and `implementation/roadmap/snapshots/latest.md` for routing/closure only.

## Exit Criteria

- [ ] A new run persists derived analysis and a masked preview through authenticated `completeRun`.
- [ ] App deletion/reinstall plus same-account login restores Activity History/Summary analysis with an empty local store.
- [ ] Activity History regenerates its thumbnail from trusted masked preview data.
- [ ] Precise route fields are rejected by backend and absent from persisted summaries.
- [ ] Owner switching during Firestore reads fails closed.
- [ ] Pending retry after restart preserves the same masked preview/fingerprint.
- [ ] Legacy scalar-only summaries remain readable with safe placeholders.
- [ ] Focused/full validation, security review, and manual QA pass.
