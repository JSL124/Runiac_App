# activity-summary-agent-feedback

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly routed IMPLEMENTATION_MODE follow-up for Run Activity Summary AI feedback.

## Goal

Add an Activity Summary-only AI feedback button that opens the selected Runiac character in a blocking overlay and returns beginner-friendly, derived-metrics-only running feedback through a server-side Firebase callable/OpenAI pipeline.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Flutter Run UI plus trusted Cloud Functions callable.
- Status: `In progress`.
- Required terminal state: `Ready for user screen QA` and `Ready for manual commit`.
- Real-screen boundary: agent may run simulator/manual QA for this explicitly routed feature and must record evidence.
- Commit boundary: user explicitly authorized committing the existing worktree baseline on 2026-07-12 Asia/Singapore; subsequent feature commits must remain atomic and task-scoped.

## Required Agent / Review Chain

`A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Allowed Scope

- Activity Summary header AI/sparkle button immediately left of the existing Share button.
- Transparent sparkle icon asset derived from the user-provided source image.
- Activity Summary-only character feedback overlay with dark modal barrier, selected character run-in/idle/run-out or reduced-motion equivalent, close control, and four styled feedback sections: Summary, Went well, Improve, Next focus.
- Derived-metrics-only Flutter payload built from `RunSummarySnapshot` and `AdvancedAnalysisSnapshotBuilder`.
- Flutter callable adapter, strict parsing, local deterministic fallback, and UI loading/fallback states.
- Authenticated Cloud Functions callable, request/response contracts, server-side OpenAI provider, safe output validation, privacy-safe logging, and per-user 5 attempts per Asia/Singapore day quota metadata.
- Focused Flutter, Functions, privacy, and visual/manual QA evidence under `.omo/evidence/activity-feedback/`.
- Roadmap routing files for this capsule only.

## Forbidden Scope

- No raw GPS coordinates, route geometry, raw polyline, route names, persistent activity IDs, or demo-only values in OpenAI prompts or logs.
- No Flutter-side OpenAI calls, OpenAI keys, or prompt/response persistence.
- No mutation of stored run summaries, XP, streak, level, rank, leaderboard score, weekly/monthly XP, subscription privilege state, or expert-plan publication state.
- No AI button on Advanced Analysis in this capsule.
- No production deploy, Firebase init, FlutterFire configure, secrets, service accounts, or production project mutation.
- No edits, formatting, staging, or committing of unrelated Activity History Feed upload, Feed/Friends, Leaderboard, You, design, or debug artifacts.

## Exact Target Files

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/activity-summary-agent-feedback.md`
- `implementation/mobile/runiac_app/lib/core/assets/runiac_assets.dart`
- `implementation/mobile/runiac_app/pubspec.yaml`
- `implementation/mobile/runiac_app/assets/**`
- `implementation/mobile/runiac_app/lib/features/run/domain/models/**`
- `implementation/mobile/runiac_app/lib/features/run/domain/services/**`
- `implementation/mobile/runiac_app/lib/features/run/data/**`
- `implementation/mobile/runiac_app/lib/features/run/presentation/view_summary_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/widgets/**`
- `implementation/mobile/runiac_app/test/activity_feedback_payload_builder_test.dart`
- `implementation/mobile/runiac_app/test/cloud_function_activity_feedback_agent_test.dart`
- `implementation/mobile/runiac_app/test/run_flow_static_ui_test.dart`
- `functions/src/agent/activityFeedback*.ts`
- `functions/src/index.ts`
- `functions/test/activityFeedback*.test.ts`

## Required Tests

- `cd implementation/mobile/runiac_app && flutter test test/activity_feedback_payload_builder_test.dart`
- `cd implementation/mobile/runiac_app && flutter test test/cloud_function_activity_feedback_agent_test.dart`
- `cd implementation/mobile/runiac_app && flutter test test/run_flow_static_ui_test.dart --plain-name "Activity feedback"`
- `cd functions && npm test -- activityFeedback`
- Existing Home guide callable/model tests if shared agent infrastructure is touched.
- `dart analyze` on changed Dart files.
- `git diff --check -- <changed files>`

## Required Evidence

- `.omo/evidence/activity-feedback/c1-c2-flutter-overlay.txt`
- `.omo/evidence/activity-feedback/c3-c4-privacy-callable.txt`
- `.omo/evidence/activity-feedback/final-verification.txt`
- `.omo/evidence/activity-feedback/visual/01-summary-closed.png` through `09-reduced-motion.png`, or a documented simulator/tooling blocker with the strongest available surface evidence.

## Exit Criteria

- [ ] Activity Summary shows the transparent sparkle AI button immediately left of Share.
- [ ] Advanced Analysis does not show the AI button.
- [ ] AI button opens a blocking selected-character overlay with loading and four styled feedback sections.
- [ ] Close restores underlying interaction and Share still works.
- [ ] Flutter sends only whitelisted derived metrics and Advanced Analysis-derived summaries.
- [ ] Estimated metrics are explicitly labelled as estimated.
- [ ] Cloud Function requires auth, validates input/output, enforces daily quota, keeps OpenAI server-side, and does not persist prompts or generated feedback.
- [ ] Focused Flutter and Functions tests pass.
- [ ] Manual/visual QA evidence proves the Activity Summary interaction.
