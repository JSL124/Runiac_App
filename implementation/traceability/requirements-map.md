# Runiac Phase 1 Requirements Map

## 1. Purpose and Scope

This document is a Phase 1 implementation-preparation traceability matrix. It maps approved PRD/PDD requirement areas to future implementation owner areas, backend-owned logic, security concerns, and minimally viable test expectations.

This is not an implementation specification. It does not approve Flutter scaffolding, Firebase setup, production source creation, tests, builds, deployment, or environment configuration.

A0_ORCH owns the workflow. A6_REVIEW checks consistency and high-risk boundaries. A8_OUTPUT_CHECKER checks completeness and deliverable readiness. These workflow roles do not replace explicit human/project approval.

## 2. Source Baseline

Read-only sources used for this mapping:

- `PRD.md`: sections 3.2, 3.3, 3.4, 4.2, 9, 11.2-11.5, and 12.2.
- `docs/pdd/01-application-architecture.md`: architecture responsibilities, data flow, MVP/future split, AI boundary, expert-plan governance.
- `docs/pdd/02-physical-architecture.md`: Firebase deployment responsibilities, security considerations, GPS/privacy, external services.
- `docs/pdd/03-component-diagram.md`: frontend/backend component ownership and dependency flow.
- `docs/pdd/04-class-diagram.md`: model/service ownership for users, activities, progression, leaderboards, expert plans, notifications, and summaries.
- `docs/pdd/06-consistency-review.md`: role, entitlement, governance, and server-side responsibility consistency checks.
- Approved planning artifacts:
  - `implementation/traceability/plans/2026-05-24T10-10-36_codex_plan.md`
  - `implementation/traceability/reviews/2026-05-24T10-10-36_codex_review.md`
  - `implementation/traceability/decisions/2026-05-24T10-10-36_codex_decision.md`

Files skipped during the earlier inspect-only planning pass were skipped only for that planning pass. They are not declared unnecessary for future mapping. Submitted assessment artifacts, diagrams, wireframes, and generated assets remain protected and require explicit approval before read or modification if they become necessary later.

These sources are the baseline used for this draft and the minimum expected read-only sources for future review; they are not a hard maximum if additional approved references are needed.

## 3. Traceability ID Model

Traceability IDs provide stable links between PRD requirements, PDD design references, setup gates, implementation tasks, tests, and demo evidence.

Traceability IDs are planning and verification labels only; they do not approve Flutter scaffolding, Firebase setup, production source creation, tests, builds, deployment, or environment configuration.

| Prefix | Meaning | Example |
| --- | --- | --- |
| `REQ-F*` | PRD-numbered functional requirements only. Preserve PRD numbering without zero-padding. | `REQ-F1`, `REQ-F2`, `REQ-F10` |
| `REQ-NF*` | PRD non-functional, privacy, safety, security, reliability, performance, or quality requirements. | `REQ-NF-PRIV`, `REQ-NF-SEC` |
| `PDD-APP-*` | Application architecture references. | `PDD-APP-AUTH`, `PDD-APP-XP` |
| `PDD-PHYS-*` | Physical architecture, Firebase, deployment, external service, or privacy references. | `PDD-PHYS-FIREBASE`, `PDD-PHYS-GPS` |
| `PDD-COMP-*` | Component diagram references. | `PDD-COMP-ACTIVITY`, `PDD-COMP-NOTIFY` |
| `PDD-CLASS-*` | Class diagram or data model references. | `PDD-CLASS-USER`, `PDD-CLASS-STATS` |
| `GATE-FLUTTER-*` | Flutter setup gate references from `setup-gates.md`. | `GATE-FLUTTER-SCAFFOLD` |
| `GATE-FIREBASE-*` | Firebase setup, config, Firestore, or Cloud Functions gate references from `setup-gates.md`. | `GATE-FIREBASE-CONFIG`, `GATE-FIREBASE-FUNC` |
| `GATE-SEC-*` | Security, privacy, secrets, rules, role, entitlement, auth/authorization, or GPS gate references from `setup-gates.md`. | `GATE-SEC-SECRETS`, `GATE-SEC-GPS` |
| `TASK-MVP-*` | Future MVP implementation task references. | `TASK-MVP-AUTH`, `TASK-MVP-XP` |
| `TEST-UNIT-*` | Unit test target references. | `TEST-UNIT-VALIDATION` |
| `TEST-WIDGET-*` | Flutter widget test target references. | `TEST-WIDGET-RUN` |
| `TEST-RULES-*` | Firestore rules test target references. | `TEST-RULES-OWNER`, `TEST-RULES-XP-DENY` |
| `TEST-FUNC-*` | Cloud Functions test target references. | `TEST-FUNC-XP-AWARD` |
| `EVID-DEMO-*` | Demo, screenshot, walkthrough, or manual evidence references. | `EVID-DEMO-RUN`, `EVID-DEMO-PRIVACY` |

Naming rules:

- Keep IDs short and flat. Avoid deeply nested IDs.
- Use `REQ-F*` only for PRD-numbered functional requirements.
- Use `REQ-NF*` for non-functional, privacy, safety, security, reliability, performance, quality, and cross-cutting requirement constraints.
- Use `GATE-SEC-*` for setup/security gate conditions, including authentication, authorization, roles, entitlements, secrets, rules, and GPS/privacy approval boundaries.
- Backend-owned business rules such as XP, streak, level, leaderboard, roles, and entitlements should reference `REQ-NF-*` or `GATE-SEC-*` as appropriate, with wording that points back to `setup-gates.md` invariants.
- Do not create new ID prefixes beyond `REQ-F*`, `REQ-NF*`, `PDD-*`, `GATE-*`, `TASK-*`, `TEST-*`, and `EVID-DEMO-*`.
- Use semicolon-separated IDs when one row maps to multiple sources, tasks, gates, tests, or evidence items.
- IDs are stable once assigned; rename only with an explicit traceability migration note.
- Gate IDs reference `setup-gates.md`; they do not grant scaffold permission.
- Future implementation plans, test descriptions, demo evidence, and commit bodies should reference relevant IDs when practical.

<!-- Example mapping rows will be added after the first implementation task is created. -->

## 4. Phase 1 Scope Summary

Phase 1 preparation covers traceability and setup readiness only. It records the design baseline for future implementation of the MVP foundation:

- Authentication and onboarding/profile foundation.
- Running activity capture and privacy-sensitive GPS data handling.
- Basic analysis, beginner training plan, reminders, streaks, XP, and level progression.
- Backend ownership for trusted progression, streak, rank, weekly XP, monthly XP, and leaderboard score logic.
- Access-control boundaries for `subscriptionStatus` and `userRole`.
- Expert-plan governance boundaries, including Platform Administrator authority and Medical Trainer/Expert draft/content-provider limits.
- Future or Phase 2 boundaries for route sharing, territorial leaderboard, and AI/LLM summaries.

## 5. Requirements Traceability Matrix

| Feature / Requirement Area | Source Reference | Phase 1 Priority | Implementation Owner Area | Backend-Owned Fields or Logic | Security / Access-Control Concern | Minimally Viable Test Criterion | Test Layer | Test Assertions | Scaffold Dependency | Status / Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Authentication and user profile | PRD 3.2, PRD 5.2, PDD app architecture 3.2-4, component diagram Auth/User Profile | MVP foundation | Flutter auth/profile UI; Firebase Authentication; Firestore user profile storage | Authentication identity is owned by Firebase Authentication; profile persistence is stored in Firestore | Users can access only their own private profile, onboarding, and health/safety readiness data | Authenticated user can create/read own profile and cannot read another user's private profile | Firestore Emulator Rules Test | Rules allow owner read/write for profile fields and deny cross-user profile access | Flutter and Firebase scaffolds required | To verify from approved PRD/PDD source before implementation |
| `subscriptionStatus` access control | PRD 4.2, PDD app architecture 3.1, component diagram 3.4, class diagram notes | MVP foundation | Flutter entitlement display; backend entitlement service; Firestore subscription state | Premium-only access decisions are enforced by backend checks, not UI hiding only | Premium gating must not create XP, rank, leaderboard score, or competitive advantage | Basic user is denied premium-only data generation/access while Premium user is allowed for the same protected feature | Firestore Emulator Rules Test; Cloud Functions Integration Test | Rules/functions deny Basic access to premium-only records or generation paths and allow Premium access without changing XP/rank fields | Firebase scaffold and rules required | `subscriptionStatus` is the tier field; Basic/Premium are not separate subclasses. `firestore-schema-rules-draft` adds emulator-only rules-test coverage for Premium expert-plan read/enrollment and Basic denial; Cloud Functions enforcement remains future work. |
| `userRole` governance control | PRD 3.2, PDD app architecture 3.1, component diagram 3.5, consistency review 4-7 | MVP/foundation for admin paths | Backend role checks; future admin workflow; Flutter/admin UI only after approval | Operational and governance access uses `userRole` | User role must not be client-writeable by normal users; admin operations must not be client-only | Normal user cannot grant self admin/expert role; restricted governance action requires Platform Administrator role | Firestore Emulator Rules Test; Cloud Functions Integration Test | User attempts to write `userRole` are denied; restricted function path rejects non-admin role | Firebase scaffold, rules, and functions gates required | Platform Administrator authority is human/project role authority, not provider approval |
| Running activity tracking | PRD F1, PRD 5.2, PDD app architecture 3.2 and 4, physical architecture 2.5 | MVP | Flutter run tracking UI/service; Firestore activity submission; backend activity processing | Activity validation and canonical processed metrics are backend-owned after upload | GPS route data and activity history are sensitive user data | App can submit a completed activity draft; backend validation path decides whether it becomes a canonical activity | Flutter Widget Test; Cloud Functions Integration Test | Widget can complete a run flow without writing trusted progression fields; function accepts plausible sample and rejects implausible sample | Flutter scaffold and Firebase functions required | No precise private GPS data should be committed as fixture/static data |
| XP, streak, level progression | PRD F6/F9, PRD 9.2-9.3, PRD 11.4-11.5, PDD app architecture 1 and 4, class diagram `UserStats`/`XPAndStreakFunction` | MVP | Cloud Functions; Firestore trusted progression records; Flutter read-only display | XP, streak, level, weekly XP, monthly XP are backend-owned | Client must not calculate or directly write official progression values | Client write to trusted progression fields is denied; backend function updates them after valid activity | Firestore Emulator Rules Test; Cloud Functions Integration Test | Rules reject client writes to `totalXP`, `level`, `streakCount`, `weeklyXP`, `monthlyXP`; function produces expected progression update for a controlled valid activity | Firebase functions and rules required | XP formulas remain implementation decisions; do not invent weights here |
| Leaderboard/ranking | PRD F8/F9 and Phase 2 allocation, PRD 9.2-9.3, PRD 11.4-11.5, PDD component/class diagrams | Phase 2 data model readiness; not full MVP leaderboard | Cloud Functions aggregation; Firestore leaderboard read models; Flutter read-only display | Leaderboard score, rank, league division, weekly/monthly ranking aggregation are backend-owned | Client must not write rank/score; Premium must not receive ranking advantage | Client cannot write leaderboard rank/score; backend aggregation reads trusted XP inputs only | Firestore Emulator Rules Test; Cloud Functions Integration Test | Rules deny client leaderboard writes; aggregation test fixture uses backend trusted weekly/monthly XP and not client-submitted score | Firebase functions and rules required | Full territorial leaderboard is Phase 2; Phase 1 may prepare data boundary only |
| Training plan generation and schedule | PRD F3/F4, PRD 4.2, PDD app architecture 4-5, component diagram Plan/Notification | MVP | Flutter plan UI; Firestore plan data; backend-supported initial plan and reminders | Backend may support first beginner plan initialization and schedule/reminder checks | Health/safety onboarding data is private; plan progression should be conservative for beginners | Onboarding input results in a stored beginner plan; reminder eligibility can be evaluated without exposing private profile to other users | Cloud Functions Integration Test; Flutter Widget Test | Function creates/initializes plan from allowed user inputs; widget displays plan without exposing restricted fields | Flutter, Firestore, Cloud Functions, FCM gates required | Detailed plan algorithm to verify from approved PRD/PDD source |
| Expert plan submission/approval/publishing | PRD 3.2, PDD app architecture 3.1 and 4, physical architecture 2.1/2.4/2.5, consistency review 4 | Foundation for future premium expert plans | Restricted backend/admin workflow; future expert dashboard only after approval | Cloud Functions may enforce trusted transitions; Platform Administrator remains only authority for approve/publish/update/archive/reject/suspend/manage actions | Medical Trainer/Expert can submit draft content only; Premium users can access only published/approved plans | Non-admin cannot publish expert plan; expert draft cannot become published without Platform Administrator action evidence | Cloud Functions Integration Test; A8_OUTPUT_CHECKER Evidence Review | Function rejects non-admin publish request; evidence confirms status transitions preserve admin authority | Firebase functions, rules, and admin workflow gates required | Cloud Functions are backend enforcement, not governance authority |
| Basic/Premium route and explore features | PRD F7/F8 and Phase 2 allocation, PRD 4.2, PDD component diagram Route Service, physical architecture external map services | Phase 2; map foundation may support run tracking | Flutter map/explore UI; backend route storage; optional map/geocoding services | Route moderation state and privacy masking should be backend-enforced | Route data may expose location routines; Premium route tools must not create competition advantage | Shared route output masks sensitive start/end areas before public visibility | Manual Evidence / Screenshot; Firestore Emulator Rules Test | Manual evidence shows privacy-masked route display; rules deny unauthorized route visibility/moderation changes | Flutter map, Firebase, and privacy gates required | Phase 2 unless explicitly approved earlier. `firestore-schema-rules-draft` adds emulator-only shared-route metadata/privacy rule tests with synthetic masked data only; real map/GPS route fixtures remain unapproved. |
| Notifications | PRD F4, PRD 4.2, PDD app architecture 4-5, component diagram Notification Service, physical architecture FCM | MVP | Flutter notification permission/handler; Cloud Functions scheduler; Firebase Cloud Messaging | Reminder scheduling/checks are backend-owned where based on plan/streak state | Notification tokens and preferences are user-private | User can opt in/out of reminders; backend sends reminder only when preference and plan/streak condition allow it | Flutter Widget Test; Cloud Functions Integration Test | Widget records preference state; function does not send when disabled and creates/send-intent when enabled and eligible | Flutter, FCM, functions gates required | Actual push delivery may need manual/device evidence later |
| Post-run summary / future AI/LLM boundary | PRD F10 and Phase 2 allocation, PRD 4.2, PRD risks R18/R19, PDD app architecture 3.4 and 5, physical architecture 2.4 | Basic rule-based summary may be future/MVP-adjacent; LLM is Phase 2/Premium | Backend summary generation; Flutter display only | AI/LLM calls are backend-controlled; official scoring/ranking logic must not depend on AI/LLM output | LLM must not provide medical diagnosis, injury prediction, or official XP/rank/leaderboard decisions | Summary output is stored/displayed as explanatory feedback only and cannot alter XP, rank, leaderboard score, or plan authority | Cloud Functions Integration Test; A8_OUTPUT_CHECKER Evidence Review | Function test confirms summary path does not write trusted progression/ranking fields; review evidence confirms wording avoids medical claims | Functions and AI boundary gate required | LLM support is future/Premium summary support only |
| GPS/privacy-sensitive data handling | PRD F1/F7/F8, PRD risks R1/R2/R5/R8, PDD physical architecture security considerations, component Route/Activity services | MVP privacy baseline | Flutter GPS collection; Firestore activity/route storage; backend validation/privacy masking | Backend validates activity plausibility and applies privacy controls before public sharing/ranking use | Precise GPS and route history are sensitive; no private route coordinates should be committed | Private GPS data is owner-only by default; public/shared route data is masked or approved before exposure | Firestore Emulator Rules Test; Manual Evidence / Screenshot | Rules deny non-owner access to raw route coordinates; manual evidence shows no precise private coordinates in committed fixtures/screenshots | Firebase rules, privacy, and map gates required | Use synthetic/coarse test data only. `firestore-schema-rules-draft` denies client-submitted precise route trace fields in shared-route metadata tests; real GPS/private route fixtures remain forbidden. |

## 6. Backend-Owned Field and Logic Map

| Field or Logic | Trusted Owner | Client Role | Notes |
| --- | --- | --- | --- |
| XP, total XP, weekly XP, monthly XP | Cloud Functions / backend enforcement | Display trusted values only | No direct Flutter write path. |
| Streak count and streak-risk state | Cloud Functions / backend enforcement | Display status and receive reminders | Reminder UI may display backend-derived state. |
| Level and league division | Cloud Functions / backend enforcement | Display trusted values only | Used by future leaderboard grouping. |
| Leaderboard score and rank | Cloud Functions aggregation / Firestore trusted read model | Read/display only | Client must not sort, rank, or write official values. |
| Activity validation and anti-abuse checks | Activity Processing Function | Submit activity draft and raw run data | Backend decides validity before progression/ranking effects. |
| `subscriptionStatus` entitlement | Backend entitlement checks using Firestore state | Display tier and request premium features | Premium UI hiding is insufficient by itself. |
| `userRole` governance | Backend role checks using Firestore/Auth context | Display role-appropriate UI only | Normal users must not self-assign admin/expert role. |
| Expert-plan approve/publish/update/archive/reject/suspend/manage actions | Platform Administrator authority, enforced by restricted backend/admin workflow | Premium users read published plans only; experts submit drafts/content only | Cloud Functions enforce transitions but are not the governance authority. |
| AI/LLM summary generation | Backend-controlled summary path | Display stored summary | AI/LLM must not write official scoring/ranking/progression logic. |

## 7. Security and Access-Control Notes

- Firebase Authentication is the identity source.
- Firestore rules must protect private user profile, health/safety readiness, activity history, GPS route, training plan, notification preference, and subscription/role data.
- `subscriptionStatus` controls Basic/Premium access.
- `userRole` controls operational/governance access.
- Premium features must be backend-enforced where they affect data generation or access.
- Premium users must not receive XP, rank, leaderboard score, weekly XP, monthly XP, level, streak, or competitive advantages.
- Platform Administrator remains the authority for expert-plan approval, publishing, update, archive, rejection, suspension, and management.
- No secrets, API keys, production project IDs, service accounts, `.env*`, `google-services.json`, `GoogleService-Info.plist`, or precise private GPS data should be committed.

## 8. Test Assertions / Minimally Viable Test Criteria

| Area | Minimally Viable Test Criterion | Test Layer | Required Assertion |
| --- | --- | --- | --- |
| Authentication/profile | Owner-only profile access is enforced. | Firestore Emulator Rules Test | User A can read/write own profile; User B cannot read/write User A profile. |
| Subscription entitlement | Premium-only access is backend-enforced. | Firestore Emulator Rules Test; Cloud Functions Integration Test | Basic access is denied and Premium access is allowed without changing competitive fields. |
| Role governance | Admin/expert roles cannot be self-granted. | Firestore Emulator Rules Test | Normal user write to `userRole` is denied. |
| Activity tracking | Run submission does not write trusted progression directly. | Flutter Widget Test; Firestore Emulator Rules Test | Run completion UI submits activity draft only; direct progression writes are denied. |
| Activity validation | Implausible activity is rejected before XP/leaderboard impact. | Cloud Functions Integration Test | Function rejects impossible pace/location jump or below-threshold activity. |
| XP/streak/level | Trusted progression updates happen only through backend processing. | Cloud Functions Integration Test | Valid activity fixture updates XP/streak/level through backend function path. |
| Leaderboard/rank | Client cannot write official leaderboard output. | Firestore Emulator Rules Test | Direct client write to rank/score/leaderboard record is denied. |
| Training plan | Beginner plan can be initialized from approved onboarding inputs. | Cloud Functions Integration Test; Flutter Widget Test | Backend creates plan; Flutter displays plan without exposing private readiness fields. |
| Expert plans | Publication requires Platform Administrator authority. | Cloud Functions Integration Test; A8_OUTPUT_CHECKER Evidence Review | Expert draft cannot become published without admin-authorized transition and recorded evidence. |
| Route/privacy | Raw route coordinates are private by default. | Firestore Emulator Rules Test; Manual Evidence / Screenshot | Non-owner cannot read raw route; public route evidence uses masked/synthetic location data. |
| Notifications | Reminder honors preference and eligibility. | Cloud Functions Integration Test; Flutter Widget Test | Disabled reminders produce no send-intent; enabled eligible reminder produces expected send-intent or local preview. |
| AI/LLM boundary | Summary generation cannot alter official progression/ranking. | Cloud Functions Integration Test; A8_OUTPUT_CHECKER Evidence Review | Summary path writes only summary output and does not write XP/rank/leaderboard fields or medical claims. |

## 9. Scaffold Dependency Notes

Future implementation needs approved gates before creating or changing production scaffolding:

- Flutter scaffold gate before `flutter create`, `pubspec.yaml`, production Dart files, or app package structure.
- Firebase project/config gate before `firebase init`, `.firebaserc`, Firestore rules/indexes, production Firebase project references, mobile config, or non-emulator Firebase setup. Approved exception: root `firebase.json` for the Firestore emulator shell is allowed under the limited `firebase-emulator-shell` approval.
- Firestore and Cloud Functions gates before rules, data collections, functions source, `package.json`, or `tsconfig.json`.
- Secret/environment gate before any `.env*`, service account, API key, mobile platform config, or production project ID handling.

## 10. Out of Scope for Phase 1

- Full territorial leaderboard implementation unless explicitly re-approved.
- Community route sharing beyond privacy and data-boundary preparation unless explicitly re-approved.
- Premium LLM post-run summaries beyond boundary design and test criteria.
- Production Flutter/Firebase scaffolding until setup gates are approved.
- Submitted assessment artifact edits.
- PRD/PDD rewrites.
- Diagrams, wireframes, generated assets, production tests, deployment, or build automation.

## 11. Open Questions / Approval Needed

- Confirm whether Phase 1 implementation starts with Flutter scaffold, Firebase scaffold, or an additional design review batch.
- Confirm whether submitted assessment artifacts are needed as read-only verification before implementation starts.
- Confirm exact MVP cut for F2 derived metrics and F3 plan generation depth.
- Confirm whether expert-plan governance remains setup-gate only during Phase 1 or gets an admin workflow prototype later.
- Confirm whether notification delivery is tested through emulator/send-intent evidence first or delayed until device testing.
- Confirm map provider and geocoding provider choices before any API key or project configuration is created.
