# Cadence Capture Reliability Recovery

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed IMPLEMENTATION_MODE production reliability fix.

## Goal

Recover truthful phone cadence capture and preserve it from the native sensor boundary through Flutter completion, trusted backend validation, persistence, and Activity Summary analysis without fabricating cadence.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Native phone cadence adapters, Flutter run tracking, and trusted `completeRun` validation.
- Status: `Ready for physical-device QA`.
- Required terminal state: `Ready for physical-device QA` and `Ready for manual commit`.
- Current readiness: automated/code gates are complete; physical-device evidence and `Ready for manual commit` remain pending.
- Commit boundary: no automatic commit, push, deployment, or production mutation.

## Required Review Chain

`A0_ORCH -> A10_FLUTTER_IMPL -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER`

## Allowed Scope

- iOS and Android phone-motion cadence adapters and their native tests.
- Flutter cadence event parsing, diagnostics, lifecycle propagation, completion-series construction, and focused tests.
- One shared truthful cadence acceptance range of 40 through 240 steps per minute across native, Dart, and Cloud Functions.
- Trusted `completeRun` cadence validation and targeted Functions tests.
- Existing local/Firestore cadence persistence and rehydration regression validation.
- This capsule and `implementation/roadmap/CURRENT.md` for routing and closure.

## Forbidden Scope

- No fabricated cadence, stationary fallback values, or cadence inferred without step evidence.
- No XP, streak, level, rank, leaderboard, progression, entitlement, role, or expert-publication behavior changes.
- No raw GPS geometry or new sensitive-data persistence.
- No new dependencies, Firebase initialization, production deployment, secrets, or service-account changes.
- No unrelated Run UI, Feed, Friends, Leaderboard, You, or roadmap capsule work.

## Exit Criteria

- [x] Native adapters emit only truthful 40–240 spm samples and observable diagnostics.
- [x] Flutter rejects malformed/adversarial native events without throwing.
- [x] Accepted cadence stays chronologically ordered across pause/resume and never exceeds completion bounds.
- [x] Flutter completion and persistence retain eligible cadence analysis.
- [x] Cloud Functions accepts 40 and 240 spm and rejects values outside the shared range.
- [x] Targeted Dart, native, and Functions validation passes.
- [ ] Physical-device cadence evidence is recorded without claiming fabricated or unavailable data.

## Validation Evidence

- Flutter cadence, lifecycle, analysis, and persistence: 91 tests passed; `flutter analyze --no-pub` passed.
- Android native cadence: 5 tests passed.
- iOS native cadence: 12 tests passed with the iOS 15 deployment-target override.
- Cloud Functions cadence and completion validation: 73 tests passed under the emulator lane.
- `check-diff-hygiene.sh` and `check-roadmap-routing.sh`: passed.
- Global caveat: the repository-wide governance runner retains the pre-existing pre-scaffold baseline failure caused by already tracked routed Firebase, Functions, and Feed artifacts; it is not introduced by this capsule.
