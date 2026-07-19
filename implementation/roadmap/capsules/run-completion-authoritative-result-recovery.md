# Run Completion Authoritative Result Recovery

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed IMPLEMENTATION_MODE production reliability fix running concurrently with cadence capture recovery.

## Goal

Make a completed run durable before network submission, then use the authenticated `completeRun` response as the only source of XP, level, streak, validated activity identity, and Feed eligibility across Cool-down, Summary, XP Update, Activity History, and Feed.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Flutter run completion/history integration against the existing trusted Cloud Functions contract.
- Status: `In progress`.
- Current active capsule remains `cadence-capture-reliability-recovery`; this capsule is concurrent and must not rewrite or supersede its routing, code, or evidence.
- Commit boundary: no automatic staging, commit, push, deployment, or production mutation.

## Required Review Chain

`A0_ORCH -> A10_FLUTTER_IMPL -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Allowed Scope

- `run_launch_screen.dart` and `run_active_screen.dart` must submit through their injected `RunRepository`, not a static completion result.
- A local-first completion coordinator may retain the original `clientRunSessionId`, rich local analysis, and retryable pending run before calling the repository.
- Accepted backend results may reconcile the pending record with canonical `activity_*` identity and backend-owned progression values.
- Guided and skipped Cool-down paths must forward the same completion result and payload into Summary and XP Update.
- Current-session Activity History and Summary may enable Feed only for canonical, validated backend activity identity; `local-*`, `static-*`, empty, pending, and rejected results remain non-publishable.
- Focused Flutter tests, existing Functions idempotency tests, Firebase Emulator Suite QA with synthetic non-sensitive run data, and iOS Simulator user-flow QA.
- This capsule, an append-only concurrent note in `implementation/roadmap/CURRENT.md`, and the minimal diff-hygiene allowlist entry required for this capsule document.

## Backend Ownership and Safety Boundaries

- Cloud Functions remain the sole calculator/writer for XP, level, streak, rank, leaderboard, weekly XP, and monthly XP.
- The client may display only values returned by the trusted completion response; it must not infer awards from distance, duration, or local pending state.
- Retry uses the unchanged payload and stable `clientRunSessionId` so the existing backend idempotency contract remains authoritative.
- Feed publication requires canonical validated identity and must not treat a successful local save as backend acceptance.
- No raw GPS trace, new sensitive-data persistence, new dependency, Firebase initialization, rules change, production deploy, entitlement change, or unrelated cadence work is authorized.

## Target Implementation Areas

- `implementation/mobile/runiac_app/lib/features/run/presentation/run_completion_coordinator.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_launch_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/run_active_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/cool_down_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/cool_down_guide_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/presentation/view_summary_screen.dart`
- `implementation/mobile/runiac_app/lib/features/run/domain/models/run_feed_publish_source.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/current_session_activity_history.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/current_session_activity_history_persistence.dart`
- Focused tests in `run_tracking_flow_test.dart`, `run_flow_static_ui_test.dart`, and `current_session_activity_history_persistence_test.dart`.

## Exit Criteria

- [ ] Both run entry surfaces invoke the injected repository exactly once for an online completion.
- [ ] Local durability precedes remote completion, and a retryable failure remains recoverable with the same session identity and rich analysis.
- [ ] Accepted backend XP, level, streak, summary, and canonical activity ID reach Cool-down, Summary, and XP Update unchanged.
- [ ] Guided and skipped Cool-down routes preserve the same result and payload.
- [ ] Pending/local/static identities cannot publish; an accepted canonical retry becomes publishable without losing local analysis.
- [ ] Replaying the same synthetic completion through the Firebase Emulator Suite returns the same authoritative result.
- [ ] iOS Simulator QA observes the awarded flow and canonical Feed boundary, or records a specific simulator-only limitation without claiming physical-device cadence evidence.
- [ ] Focused/full validation, security review, diff hygiene, and roadmap routing checks pass.

## Evidence Policy

- Firebase emulator evidence must use synthetic run data and record project/host guards, first acceptance, identical replay, backend-owned XP/level/streak, and cleanup receipts.
- iOS evidence must identify Simulator device/build inputs and distinguish UI-flow proof from unavailable physical motion/cadence proof.
- Validation results are recorded only after execution; routing this capsule does not itself claim that emulator, Simulator, or full-suite QA has passed.
