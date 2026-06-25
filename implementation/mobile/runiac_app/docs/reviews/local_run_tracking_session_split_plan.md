# M-AA-OPT-P5 — LocalRunTrackingSession Responsibility Split Plan

This is plan-only durable evidence. No production code was changed for M-AA-OPT-P5.

## Current Ownership Map

`LocalRunTrackingSession` currently owns these responsibilities in one stateful session object:

- Sample validation: coordinate, accuracy, timestamp, non-finite distance, and impossible-jump rejection.
- Movement/stationary classification: GPS movement, stationary drift, resume candidates, and motion-evidence assisted state decisions.
- Auto-pause / abnormal pause policy: pre-movement dwell, no-sample dwell, moving-to-stopped dwell, abnormal transport candidate windows, and resume handling.
- Route segmentation: accepted route segments, resume anchors, suppressed movement anchors, and route-safe current position state.
- Distance/pace accumulation: accepted-route-only distance, active moving duration, tracking duration, and average pace.
- Pace graph accumulation: active-elapsed graph point segments derived from accepted movement samples.
- Cadence accumulation: phone-motion cadence sample acceptance and cadence analysis series creation.
- Elevation accumulation: accepted route altitude sampling, cumulative distance mapping, and local elevation analysis series creation.
- Diagnostics/state reporting: accepted/rejected sample counters, latest rejection/accuracy status, movement status, map view state, and QA logs.

## Proposed Future Split

Keep `LocalRunTrackingSession` as the orchestration facade only. Future extracted collaborators should be introduced behind existing behavior-preserving tests:

- `RunSampleValidator`: validates raw `RunLocationSample` values and returns explicit rejection reasons.
- `RunMovementClassifier`: owns movement, stationary, resume, suspicious, and abnormal-transport decisions.
- `RunRouteSegmentAccumulator`: owns accepted route segments, route anchors, accepted-route-only distance, and current route position.
- `RunPaceGraphAccumulator`: owns graph-safe active elapsed sample segments and pace graph sample derivation inputs.
- `RunCadenceAccumulator`: owns phone-motion cadence acceptance and cadence analysis series assembly.
- `RunElevationAccumulator`: owns altitude sample extraction and elevation series assembly from accepted route segments.
- `RunTrackingDiagnosticsAdapter`: translates validator/classifier/accumulator outcomes into `RunTrackingDiagnostics`, movement status reporting, and QA log fields.

## Recommended Capsule Order

1. Extract validation first, because sample rejection rules are narrow and already observable through diagnostics and controller tests.
2. Extract movement classification next, keeping pause/resume state transitions behaviorally identical.
3. Extract the route segment accumulator after validation/classification outputs are stable.
4. Extract the pace graph accumulator once route segment ownership is isolated.
5. Extract cadence and elevation accumulators after route/graph behavior is locked.
6. Extract diagnostics last, so reporting follows the final collaborator boundaries instead of shaping them too early.

## Risk Notes

- Splitting the full session at once is high regression risk because route, distance, moving time, graph points, diagnostics, and pause state share timing-sensitive state.
- Stationary, tiny-distance, and low-data behavior must remain unchanged.
- Distance must continue to use accepted route samples only; rejected, stationary, suspicious, and suppressed bridge samples must not inflate distance.
- Pause, resume, auto-pause, abnormal pause, and no-sample dwell behavior must remain deterministic.
- Local analysis merge expectations must remain intact: low-data summaries may preserve route evidence but must not imply confidence in pace, cadence, or elevation analysis.

## Validation Strategy

Use the current run-tracking tests as the safety net before and after each future extraction:

- `test/run_tracking_flow_test.dart` for completion flow, route preservation, and local analysis merge behavior.
- Low-data and stationary tests for short/tiny runs, no-sample dwell, stationary drift, and unavailable analysis.
- Meaningful moving route tests for accepted-route-only distance, average pace, route segments, and current marker behavior.
- Route preservation tests for completed summary and activity history replay.
- Cadence, elevation, and pace graph regression tests for local analysis derivation and source confidence.
- Full `flutter test` before each extraction commit.
- `./tools/governance-ci/run-all-checks.sh` to confirm no forbidden backend, native, dependency, Firebase, or roadmap scope drift.
