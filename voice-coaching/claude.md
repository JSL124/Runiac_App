# claude.md — Voice Progress Coaching (`yrself/`)

This directory holds the planning artifacts for the **Runiac Voice Progress Coaching** feature.
See [`TDD.md`](./TDD.md) for the full test-driven development plan.

## What this feature is

Before starting a run, the user enables **Voice Coaching** from the gear (⚙️) on the
Running Start Page. During an active run, the app speaks Korean progress announcements
when the runner crosses a configured **distance** or **time** milestone.

The first version does **not** call an LLM at runtime. It uses a local rule engine
(`RunVoiceAnnouncementPolicy`) plus validated Korean message templates
(`RunVoiceMessageFormatter`).

## Working rules for this repo

- **Default mode is PDD_MODE.** Do not touch Flutter, Firebase, Cloud Functions, tests,
  or production source unless the user explicitly asks for implementation work. See the
  root `AGENTS.md` / `CLAUDE.md`.
- The files in this directory are **planning documents**, not active agent instructions.
- Before any implementation or validation, read `implementation/roadmap/CURRENT.md` — it
  is the operational source of truth for what is in scope, forbidden, and gated.
- Do not commit unless the user explicitly grants permission. Stop at "Ready for commit"
  and provide manual git commands.
- All shipped widget copy must be English; the **spoken announcements** are Korean by design.

## Architecture at a glance

```
Settings UI → RunVoiceSettingsRepository → RunVoiceCoachingSettings
   → (Start Run) → RunVoiceSessionConfig (frozen snapshot)
   → RunSessionController → RunVoiceSnapshotMapper
   → RunVoiceCoachingCoordinator → Policy + Selector → Formatter
   → RunSpeechOutput → FlutterTtsRunSpeechOutput
```

Key layering invariants:
- `RunSessionController` never calls TTS directly and never builds message strings.
- `RunVoiceAnnouncementPolicy` and `RunVoiceMessageFormatter` are pure Dart — no Flutter,
  no TTS, unit-testable.
- The coordinator owns dedup, priority, the single pending slot, stop cleanup, and TTS
  error isolation.
- Voice settings are copied to an immutable `RunVoiceSessionConfig` at Start; later global
  setting changes must not affect the in-progress run.

## Non-negotiable behaviors (guardrails)

- Announce only when: `config.enabled` **and** phase is `active` **and** not paused.
- Each milestone announces **exactly once** (`consumedAnnouncementIds`).
- Use **accepted (filtered) distance**, not raw GPS accumulation.
- Time milestones use the run's active elapsed time, never `DateTime.now()`; paused time
  does not count.
- A TTS failure must not change run state, stop GPS/time tracking, or block run completion
  — wrap the coordinator call and swallow/log errors (`unawaited` + try/catch).
- On End: stop current speech, clear the pending slot, and speak nothing afterward.

## TDD build order (see TDD.md for details)

0. Characterize existing run lifecycle (regression safety net)
1. Settings domain + validation
2. Local settings repository (safe fallback on malformed data)
3. Settings UI from the start-page gear
4. Session snapshot at Start
5–8. Policies: distance, lifecycle guard, time, target (halfway/completed)
9. Priority selection
10. Korean message formatter
11. Speech output port + fake
12–13. Coordinator + pending-slot queue
14. RunSessionController integration
15. Flutter TTS adapter
16. End-to-end integration tests

## First vertical slice

Switch → save → Start snapshot → active 1 km crossing → fixed Korean sentence
(`"1킬로미터를 완료했습니다."`) → fake speech test → real TTS adapter → End cleanup.
Stabilize this slice before adding elapsed time, pace, other intervals, and target
milestones.
