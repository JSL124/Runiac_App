# ADR-003 - Governance Lite Execution Lanes

## Status

Accepted.

This decision records the Governance Lite execution lanes only. It does not activate or enforce a new workflow, change CI, change AGENTS instructions, route a capsule, authorize Flutter implementation, authorize Firebase/backend work, or select Phase 02.

## Context

Runiac needs faster execution for low-risk Flutter UI-only work while preserving strict backend-owned safety boundaries for Firebase, Authentication, Firestore, Cloud Functions, trusted progression, subscription, expert-plan governance, and activity validation.

Existing governance prevents architecture drift, but applying the full review path to every static UI polish task slows visible Flutter progress. This ADR defines execution lanes that classify work by ownership boundary, file scope, validation depth, and approval requirements.

This ADR extends ADR-001 Tier Gate System and ADR-002 Emulator First. It does not replace either ADR.

## Decision

Runiac work must be routed through one of three execution lanes:

1. UI Fast Lane
2. Backend Guarded Lane
3. Governance/Architecture Lane

If lane classification is ambiguous, use the stricter lane.

## Protected Backend-Owned State

The Flutter client must not directly calculate, mutate, write, spoof, or submit trusted replacements for:

- XP
- streak
- level
- rank
- leaderboard score
- weekly XP
- monthly XP
- subscription privilege state
- expert plan publication state
- validated activity contribution state

Validated activity contribution state means any trusted backend decision that a submitted activity is valid, eligible, counted, rejected, adjusted, fraud-checked, GPS-quality-checked, or allowed to contribute to progression, streaks, summaries, rankings, leaderboards, rewards, entitlement-sensitive outputs, or official activity history.

Flutter may display trusted backend results after backend processing. Flutter may submit user-owned/raw activity inputs only through approved backend-owned validation paths. Flutter must not decide whether an activity contributes to official progression or leaderboard outcomes.

## Lane 1 - UI Fast Lane

### Purpose

Speed up Flutter UI-only implementation without weakening backend-owned safety boundaries.

### Allowed Scope

UI Fast Lane may be used only for routed Flutter UI-only work that affects presentation, layout, visual hierarchy, static local interaction, copy, widget composition, or related widget tests.

Allowed files are limited to:

- `implementation/mobile/runiac_app/lib/features/*/presentation/`
- `implementation/mobile/runiac_app/lib/features/*/presentation/widgets/`
- `implementation/mobile/runiac_app/test/` for related widget tests only

The following paths are allowed only when explicitly named by the routed task:

- `implementation/mobile/runiac_app/lib/core/theme/`
- `implementation/mobile/runiac_app/lib/core/widgets/`

`implementation/mobile/runiac_app/lib/app.dart` is allowed only for approved shell/navigation presentation changes. It must not be used for app bootstrapping, Firebase initialization, auth routing, dependency setup, environment setup, trusted state logic, or backend-owned behavior.

### Forbidden Scope

UI Fast Lane must not touch:

- `pubspec.yaml` or dependency configuration unless separate approval exists
- Android or iOS native files
- Firebase config, Firebase initialization, Authentication, Firestore, Cloud Functions, FCM, Storage, or security rules
- backend-owned validation, entitlement, leaderboard, XP, streak, level, rank, subscription, or expert-publication logic
- generated files, build output, secrets, environment files, deployment config, or setup gates
- roadmap, ADR, CI, or workflow policy files except for minimal routed capsule/closure updates when separately approved

UI Fast Lane must not introduce new dependencies, real map SDKs, GPS/native permissions, backend integration, fake leaderboard users, fake XP/rank/score values, or client-owned trusted state.

### Validation

During fast iteration, run:

```bash
cd implementation/mobile/runiac_app
flutter analyze --no-pub
flutter test
```

`flutter analyze --no-pub` is fast iteration validation only. It is not final commit validation.

Before Ready for commit, commit, or push, run canonical local full governance CI from the repository root:

```bash
./tools/governance-ci/run-all-checks.sh
```

Also run:

```bash
git diff --check
```

Android emulator smoke evidence is optional for minor static UI changes. It is required when the UI change affects navigation, launch flow, run flow, map-like layout, animation-critical interaction, or screen transition behavior.

## Lane 2 - Backend Guarded Lane

### Purpose

Protect trusted backend boundaries and prevent client-owned mutation of safety-critical or fairness-critical state.

### Scope

Backend Guarded Lane applies to:

- Firebase Authentication
- Firestore data model or rules
- Cloud Functions
- Firebase Emulator workflows
- backend-owned activity validation
- XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, and leaderboard aggregation
- subscription privilege enforcement
- expert plan approval, publication, archive, rejection, suspension, or governance state
- security rules, roles, entitlements, privacy-sensitive data paths, and trusted writes
- Flutter client integration that depends on backend-owned behavior

### Required Controls

Backend Guarded Lane requires:

- full review and governance path
- A11_FIREBASE_IMPL for Firebase/backend work
- A13_SECURITY_RULES for authentication, roles, entitlements, rules, trusted writes, privacy, and fairness boundaries
- A6_REVIEW when architecture, security, data model, roles, entitlements, XP, streaks, levels, ranks, leaderboards, subscription state, or expert publication behavior is affected
- A12_QA_TEST for relevant test planning and evidence
- A8_OUTPUT_CHECKER before Ready for commit

Production Firebase setup, `firebase init`, `flutterfire configure`, production connections, deploys, secrets, service accounts, native GPS permission requests, cost-affecting changes, and irreversible external operations remain Tier 1 under ADR-001 and require explicit human approval.

Firebase work must follow ADR-002 Emulator First unless a separate Tier 1 production approval exists.

### Validation

Backend Guarded Lane must run canonical local full governance CI:

```bash
./tools/governance-ci/run-all-checks.sh
```

It must also run the relevant Flutter, Firebase emulator, security rules, Cloud Functions, or integration tests for the touched boundary. If a relevant test cannot be run, the blocker must be recorded explicitly before any readiness claim.

## Lane 3 - Governance/Architecture Lane

### Purpose

Protect project-level rules, routing, architecture, CI, roadmap memory, and workflow behavior.

### Scope

Governance/Architecture Lane applies to:

- ADRs
- roadmap policy
- `CURRENT.md`
- snapshots
- setup gates
- CI workflows
- AGENTS instructions
- validation/checker scripts
- repo structure
- workflow memory policy
- tool-permission policy
- lane definitions
- architecture decisions

### Required Controls

Governance/Architecture Lane requires explicit human approval before changing files or workflow behavior.

Planning, interview, and inspect-only review are allowed without file modification.

Governance/Architecture changes must preserve ADR-001 and ADR-002 unless the task explicitly routes a replacement decision. Any project behavior change must update the relevant changelog or decision record.

Before Ready for commit, run:

```bash
git diff --check
./tools/governance-ci/run-all-checks.sh
```

## Context Loading Rules

### ADR Loading

Load relevant ADRs when work touches:

- Tier classification
- lane classification
- Firebase or emulator policy
- setup gates
- CI or governance workflow
- backend-owned values
- authentication, roles, entitlements, subscription, security, privacy, or expert-plan governance
- leaderboard, XP, streak, level, rank, weekly XP, monthly XP, validated activity contribution state, or activity validation
- dependency, native, GPS, real map, Firebase, backend, or production setup boundaries

For UI Fast Lane tasks, do not load ADRs beyond the hot path unless the routed task touches one of these boundaries or lane classification is ambiguous.

### Snapshot Loading

Load `implementation/roadmap/snapshots/latest.md` when:

- starting lane classification from the hot path
- claiming latest verified implementation or governance state
- checking closure/readiness state
- updating roadmap, ADR, capsule, CURRENT, or snapshot files
- resolving drift between routing, implementation state, and governance memory

### Full Roadmap Loading

Full roadmap loading is forbidden during normal UI Fast Lane work unless explicitly requested or required by routing, phase selection, capsule selection, closure audit, governance rewrite, historical reconstruction, or ambiguity that cannot be resolved from the hot path.

Do not load `roadmap-stretch.md`, archived snapshots, future phase documents, `docs/meta/*`, retrospectives, workflow records, or broad historical planning files during ordinary lane classification.

## Tool Policy

### Superpowers

Superpowers may be used only when they are inspect-only, planning-only, review-only, or validation-supporting and do not mutate repository state, install tools, scaffold, build, init, deploy, commit, push, route capsules, broaden scope, or bypass lane gates.

### LazyCodex / ooo / OMX

LazyCodex, `ooo`, and OMX remain forbidden when they would automate implementation, start autonomous execution loops, mutate workflow state, install tools, scaffold, build, init, deploy, create commits, push, route work, broaden context beyond the lane, or bypass AGENTS/ADR gates.

Explicit user-invoked plan-only or interview-only use is allowed when it is inspect-only and does not modify files or start implementation.

### Flutter/Firebase Official Skills

Flutter official skills may be used as documentation/reference support for approved Flutter UI work, analyzer/test behavior, widgets, layout, Dart syntax, or validation planning.

Firebase official skills may be used as documentation/reference support for approved Backend Guarded Lane planning or implementation.

Official skills are not approval to add dependencies, initialize Firebase, configure secrets, deploy, connect production services, or move backend-owned behavior into Flutter.

## Consequences

- Flutter UI-only work has a documented fast lane for future routed tasks.
- Backend-owned safety boundaries remain protected and use the stricter Backend Guarded Lane.
- Governance and architecture changes remain explicit-approval work.
- ADR-003 adoption records a policy decision only; enforcement changes require a separately approved workflow task.
