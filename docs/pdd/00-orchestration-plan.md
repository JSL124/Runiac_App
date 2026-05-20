# 00. PDD Orchestration Plan

## 1. PDD Goal

The Project Design Document (PDD) should prove that Runiac has a coherent and realistic system design for a university Final Year Project. It should show how the completed PRD and wireframes translate into an implementable mobile application architecture without adding unnecessary enterprise complexity.

The PDD must demonstrate:

- The Flutter mobile app, Firebase backend services, and external services have clear responsibilities.
- Security-sensitive and fairness-sensitive logic is placed on the backend, especially XP, streaks, levels, ranks, and leaderboard scores.
- The Basic User and Premium User experiences are consistent with the same core product model.
- Platform Administrator and Medical Trainer/Expert governance workflows are separated from Basic/Premium subscription tiers.
- The diagrams and wireframe descriptions use the same terminology, feature boundaries, and data concepts.
- MVP features are separated from future or premium extensions.

## 2. Deliverable Scope

The PDD will produce exactly these deliverables:

| No. | Deliverable | Output file |
| --- | --- | --- |
| 1 | Application Architecture | `docs/pdd/01-application-architecture.md` |
| 2 | Physical Architecture | `docs/pdd/02-physical-architecture.md` |
| 3 | Component Diagram | `docs/pdd/03-component-diagram.md` |
| 4 | Class Diagram | `docs/pdd/04-class-diagram.md` |
| 5 | Wireframe Descriptions | `docs/pdd/05-wireframe-description.md` |

Out of scope:

- Implementation code for Flutter, Firebase, Cloud Functions, or Firestore rules.
- Final production-ready diagrams during orchestration.
- Additional PRD sections, business model rewrites, market survey rewrites, use case diagrams, sequence diagrams, or activity diagrams.
- A full database ERD unless separately requested.
- Detailed algorithm design for XP weighting, route fraud detection, AI prompt design, or leaderboard ranking formulas.
- Implementation of admin dashboard screens or Medical Trainer/Expert submission screens.
- Deployment automation, CI/CD, testing strategy, or release planning.

## 3. Shared Architecture Assumptions

All agents must use the same architecture assumptions:

| Area | Assumption |
| --- | --- |
| Mobile application | Runiac is a Flutter mobile app for iOS and Android. |
| Authentication | Firebase Authentication manages identity, sign-in, and authenticated sessions. |
| Database | Cloud Firestore stores user profiles, training plans, activities, routes, XP/progression records, leaderboard records, notification preferences, and post-run summaries. |
| Server-side logic | Cloud Functions handles activity validation, XP calculation, streak updates, level updates, leaderboard aggregation, reminder checks, report handling, and premium entitlement-sensitive processing. |
| Notifications | Firebase Cloud Messaging sends planned-run reminders, rest reminders, missed-session reminders, streak-risk reminders, and engagement notifications. |
| Storage | Firebase Cloud Storage is optional and only used when binary assets are needed, such as profile images, generated share cards, or route-related media. Structured data remains in Firestore. |
| Map provider | Google Maps / Mapbox APIs provide map rendering, route visualization, and map interaction. Region mapping for leaderboard processing may use a geocoding or map provider service. |
| Optional future AI summary service | AI-assisted post-run summaries are treated as a future or premium extension. If included in design, Cloud Functions calls the AI service and stores the generated result; Flutter does not call the AI service directly. |
| Admin support | A Platform Administrator may have an optional admin dashboard or restricted admin workflow, but this is not part of the core MVP mobile user flow. The Platform Administrator is the main governance and CRUDS role for users, roles, plans, expert plan review, routes, notifications, reports, moderation, and system analytics. For expert plans, the Platform Administrator reviews, enters, approves, publishes, updates, and archives plan records. |
| Medical Trainer/Expert support | Medical Trainer/Expert (expert plan content provider) prepares and submits expert goal plan content only. This role must not directly publish plans or directly write published expert plan records into the Runiac mobile app or Firebase database in the MVP. |

Source input note:

- Requested PRD path: `docs/prd/Runiac_PRD.pdf`.
- Requested wireframe path: `docs/wireframes/`.
- Current checkout also contains readable source equivalents at `PRD.md`, `wireframe.md`, `PRD_assets/`, and `wireframe_assets/`. If the requested paths are unavailable, agents should use these local equivalents and flag the source substitution in their output assumptions.

## 4. Naming Rules

Agents must use the exact role names below:

- `Basic User`
- `Premium User`
- `Platform Administrator`
- `Medical Trainer/Expert`

Agents must use the exact service names below:

- `Flutter Mobile App`
- `Firebase Authentication`
- `Cloud Firestore`
- `Cloud Functions`
- `Firebase Cloud Messaging`
- `Firebase Cloud Storage`
- `Google Maps / Mapbox APIs`
- `External AI/LLM Service`
- `OS Share Sheet`

Agents must use the exact major component names below unless the target diagram requires shorter labels:

- `Authentication and Onboarding`
- `Profile Management`
- `Training Plan`
- `Run Tracking`
- `Activity Validation`
- `Activity Analysis`
- `XP and Streak`
- `Leaderboard`
- `Route Sharing`
- `Reminder and Notification`
- `Subscription Entitlement`
- `Post-Run Summary`
- `Report Moderation`
- `Map Integration`
- `Admin Expert Plan Management`

Agents must use the exact entity names below for class and data references:

- `User`
- `UserProfile`
- `Subscription`
- `TrainingPlan`
- `PlanSession`
- `Activity`
- `RoutePoint`
- `RunMetric`
- `PostRunSummary`
- `UserProgression`
- `XPRecord`
- `Streak`
- `SharedRoute`
- `SavedRoute`
- `RouteReport`
- `LeaderboardRegion`
- `LeaderboardEntry`
- `LeagueDivision`
- `NotificationPreference`
- `Notification`

Naming consistency rules:

- Use singular names for entities and classes.
- Use title case for diagram component labels.
- Use `Basic User` and `Premium User` as roles, not as separate domain subclasses unless explicitly justified.
- Use `subscriptionStatus` for Basic/Premium feature access and `userRole` for operational or governance access.
- Treat Platform Administrator CRUDS as Create, Read, Update, Delete/Archive/Suspend, and Search.
- Prefer Archive, Hide, Suspend, Deactivate, Reject, or Dismiss over hard delete for user, route, plan, report, and moderation records.
- Use `Cloud Functions`, not `Firebase Functions`.
- Use `Cloud Firestore`, not `Firebase Database`.
- Use `Firebase Cloud Messaging`, not only `push notification service`, when referring to the selected technology.
- Use `Post-Run Summary`, not mixed alternatives such as `AI feedback`, `run diary`, or `reflection`, unless describing a specific future enhancement.

## 5. Agent Breakdown

### 5.1 PDD Orchestrator Agent

| Field | Definition |
| --- | --- |
| Agent name | `PDD Orchestrator Agent` |
| Purpose | Maintain the orchestration plan, assign design work, enforce shared terminology, and perform final consistency review. |
| Input files | `AGENTS.md`, `docs/prd/Runiac_PRD.pdf`, `docs/wireframes/`, `PRD.md`, `wireframe.md`, `wireframe_assets/`, all `docs/pdd/*.md` files. |
| Output file | `docs/pdd/00-orchestration-plan.md` |
| Allowed modifications | May modify only the orchestration plan and final review notes unless explicitly asked to edit a deliverable. |
| Completion criteria | The plan defines scope, assumptions, naming rules, agent assignments, dependency order, consistency rules, Runiac-specific rules, and final integration checklist. |

### 5.2 Application Architecture Agent

| Field | Definition |
| --- | --- |
| Agent name | `Application Architecture Agent` |
| Purpose | Explain the logical architecture of Runiac and how app modules interact with Firebase and external services. |
| Input files | `AGENTS.md`, `docs/prd/Runiac_PRD.pdf`, `PRD.md`, `wireframe.md`, `docs/pdd/00-orchestration-plan.md`. |
| Output file | `docs/pdd/01-application-architecture.md` |
| Allowed modifications | May modify only `docs/pdd/01-application-architecture.md`. |
| Completion criteria | Describes user layer, Flutter app layer, Firebase service layer, external service layer, MVP/future split, and backend-only trusted operations. Does not create implementation code. |

### 5.3 Physical Architecture Agent

| Field | Definition |
| --- | --- |
| Agent name | `Physical Architecture Agent` |
| Purpose | Describe the runtime/deployment view of user devices, mobile app, Firebase cloud services, and third-party services. |
| Input files | `AGENTS.md`, `docs/prd/Runiac_PRD.pdf`, `PRD.md`, `docs/pdd/00-orchestration-plan.md`, `docs/pdd/01-application-architecture.md`. |
| Output file | `docs/pdd/02-physical-architecture.md` |
| Allowed modifications | May modify only `docs/pdd/02-physical-architecture.md`. |
| Completion criteria | Shows where Flutter, Firebase Authentication, Cloud Firestore, Cloud Functions, FCM, optional Storage, maps, geocoding, OS sharing, and optional AI service sit in the system. Distinguishes mobile device responsibilities from cloud responsibilities. |

### 5.4 Component Diagram Agent

| Field | Definition |
| --- | --- |
| Agent name | `Component Diagram Agent` |
| Purpose | Define the major software components and responsibility boundaries that support Runiac features. |
| Input files | `AGENTS.md`, `docs/prd/Runiac_PRD.pdf`, `PRD.md`, `wireframe.md`, `docs/pdd/00-orchestration-plan.md`, `docs/pdd/01-application-architecture.md`, `docs/pdd/02-physical-architecture.md`. |
| Output file | `docs/pdd/03-component-diagram.md` |
| Allowed modifications | May modify only `docs/pdd/03-component-diagram.md`. |
| Completion criteria | Uses shared component names, separates Flutter-facing components from backend processing components, includes Firebase and external service dependencies, and labels trusted server-side operations clearly. |

### 5.5 Class Diagram Agent

| Field | Definition |
| --- | --- |
| Agent name | `Class Diagram Agent` |
| Purpose | Define the static logical domain model for users, activities, plans, progression, routes, leaderboard, notifications, and summaries. |
| Input files | `AGENTS.md`, `docs/prd/Runiac_PRD.pdf`, `PRD.md`, `wireframe.md`, `docs/pdd/00-orchestration-plan.md`, `docs/pdd/01-application-architecture.md`, `docs/pdd/03-component-diagram.md`. |
| Output file | `docs/pdd/04-class-diagram.md` |
| Allowed modifications | May modify only `docs/pdd/04-class-diagram.md`. |
| Completion criteria | Uses singular entity names, avoids modelling screens as classes, avoids treating Basic/Premium as duplicate user subclasses, and shows backend-owned classes or services for XP, streak, and leaderboard processing. |

### 5.6 Wireframe Description Agent

| Field | Definition |
| --- | --- |
| Agent name | `Wireframe Description Agent` |
| Purpose | Describe the completed Basic and Premium wireframes, plus the planned Platform Administrator and Medical Trainer/Expert governance wireframes, in PDD-ready language and link each screen group to user goals and system components. |
| Input files | `AGENTS.md`, `docs/wireframes/`, `wireframe.md`, `wireframe_assets/basic/`, `wireframe_assets/premium/`, the Platform Administrator and Medical Trainer/Expert wireframe plan supplied during PDD review, `docs/pdd/00-orchestration-plan.md`, `docs/pdd/01-application-architecture.md`, `docs/pdd/03-component-diagram.md`. |
| Output file | `docs/pdd/05-wireframe-description.md` |
| Allowed modifications | May modify only `docs/pdd/05-wireframe-description.md`. |
| Completion criteria | Covers Basic, Premium, Platform Administrator, and Medical Trainer/Expert screen groups, explains purpose, main UI elements, user action flow, related PRD feature/component, and Basic/Premium or governance-role differences. Does not redesign screens. |

## 6. Dependency Order

Agents must work in this order:

1. `PDD Orchestrator Agent` creates `docs/pdd/00-orchestration-plan.md`.
2. `Application Architecture Agent` creates or revises `docs/pdd/01-application-architecture.md`.
3. `Physical Architecture Agent` creates or revises `docs/pdd/02-physical-architecture.md` using the application architecture assumptions.
4. `Component Diagram Agent` creates or revises `docs/pdd/03-component-diagram.md` using both architecture outputs.
5. `Class Diagram Agent` creates or revises `docs/pdd/04-class-diagram.md` using the application architecture and component boundaries.
6. `Wireframe Description Agent` creates or revises `docs/pdd/05-wireframe-description.md` using the final shared component and role names.
7. `PDD Orchestrator Agent` performs the final integration review across all five deliverables.

Dependency rules:

- The Component Diagram must not introduce components that contradict the Application Architecture.
- The Class Diagram must not introduce domain entities that are not supported by the PRD, wireframes, or architecture.
- Wireframe descriptions must use the same role, component, and feature names as the architecture and component deliverables.
- If a later agent identifies a naming or responsibility conflict, it must flag the conflict instead of silently changing shared assumptions.

## 7. Consistency Rules

### 7.1 Application Architecture Checks

- Confirms Flutter handles UI, navigation, GPS tracking UI, local interaction, map display, and display of backend-calculated values.
- Confirms Firebase Authentication handles identity.
- Confirms Cloud Firestore stores persistent structured records.
- Confirms Cloud Functions handles trusted processing.
- Confirms Firebase Cloud Messaging handles push notifications.
- Separates MVP capabilities from premium or future extensions.
- Does not imply that the Flutter client directly calculates or writes trusted progression and ranking values.

### 7.2 Physical Architecture Checks

- Shows user devices, Flutter app, Firebase managed cloud services, map provider, OS sharing, and optional AI service at runtime level.
- Keeps Firebase services named consistently with the naming rules.
- Shows all client-to-cloud communication as authenticated and protected where relevant.
- Shows optional Firebase Cloud Storage only for binary/media assets, not as the primary structured database.
- Does not introduce custom servers unless explicitly marked as out of scope or future.

### 7.3 Component Diagram Checks

- Uses the shared major component names.
- Separates user-facing components from backend processing components.
- Shows `Activity Validation`, `XP and Streak`, and `Leaderboard` as backend-trusted processing areas.
- Includes `Subscription Entitlement` for premium access checks.
- Does not treat premium features as only hidden UI.
- Does not overload the diagram with every individual screen.

### 7.4 Class Diagram Checks

- Uses singular entity/class names from the naming rules.
- Models `Basic User` and `Premium User` through user role, subscription, or entitlement state rather than duplicate user subclasses.
- Shows that `Activity`, `RoutePoint`, `RunMetric`, `PostRunSummary`, `UserProgression`, `XPRecord`, and `LeaderboardEntry` are related coherently.
- Keeps UI screens, Firebase SDK internals, and Firestore collection mechanics out of the logical class model unless needed for explanation.
- Clearly places XP, streak, level, rank, and leaderboard score updates under backend-owned services or processing classes.

### 7.5 Wireframe Description Checks

- Uses the completed Basic and Premium wireframes and the supplied Platform Administrator / Medical Trainer/Expert wireframe plan as the source of screen descriptions.
- Groups screens by user workflow rather than listing disconnected images only.
- Connects screen groups to PRD features and PDD components.
- Explains Basic/Premium differences consistently.
- Explains Platform Administrator and Medical Trainer/Expert differences through `userRole`, not `subscriptionStatus`.
- Makes clear that premium unlocks richer guidance, analysis, route management, or sharing presentation, not unfair XP or leaderboard advantage.
- Does not add new screens that are not in the wireframes or explicitly supplied wireframe plan.

## 8. Runiac-Specific Rules

All agents must follow these project-specific rules:

- XP calculation must be server-side.
- Leaderboard aggregation must be server-side.
- Streak updates, level updates, rank updates, weekly XP, monthly XP, and leaderboard score updates must be backend-owned.
- Flutter must not directly write XP, rank, streak, level, weekly XP, monthly XP, or leaderboard score.
- Flutter may display trusted values after reading them from Cloud Firestore.
- Flutter may collect raw run data, show temporary live metrics, and submit completed activity data for validation.
- Cloud Functions must validate activity data before it affects XP, streak, level, or leaderboard ranking.
- Basic/Premium behaviour must be consistent across all deliverables.
- Premium users must not receive extra XP, rank boosts, hidden leaderboard advantages, or unfair competitive information.
- Premium features must not rely only on hiding UI; entitlement checks must exist in backend-sensitive flows.
- Route reports and moderation must involve Platform Administrator responsibilities where relevant.
- Platform Administrator is the main governance and CRUDS role. CRUDS means Create, Read, Update, Delete/Archive/Suspend, and Search.
- Platform Administrator workflows should normally use Archive, Hide, Suspend, Deactivate, Reject, or Dismiss rather than hard delete.
- Platform Administrator screens may view XP, level, streak, rank, and leaderboard data, but those fields must remain read-only system-calculated values.
- Medical Trainer/Expert (expert plan content provider) should be described as a content provider only. The role does not directly publish expert plans in the MVP.
- Medical Trainer/Expert may prepare and submit expert plan content, but must not directly write published expert plans into Firebase.
- Expert plans must be reviewed and published by the Platform Administrator before Premium Users can view or select them.
- Expert plan governance flow must be: Medical Trainer/Expert submits plan content, plan enters admin review queue, Platform Administrator reviews, decision is Approve / Request Revision / Reject, Platform Administrator publishes approved plans, and Premium Users can then view or select the published plan.
- Do not overcomplicate the MVP with unnecessary microservices, Kubernetes, custom API gateways, complex ML pipelines, or enterprise infrastructure.
- Keep the design realistic for a small student team using Flutter and Firebase.

## 9. Final Integration Checklist

Use this checklist before declaring the PDD design ready:

- [ ] All five required deliverables exist in `docs/pdd/`.
- [ ] Each deliverable uses the exact role names: `Basic User`, `Premium User`, `Platform Administrator`, and `Medical Trainer/Expert`.
- [ ] Application Architecture and Physical Architecture describe the same system boundary.
- [ ] Component Diagram components match the architecture layer responsibilities.
- [ ] Class Diagram entities match the domain concepts used by the component and wireframe descriptions.
- [ ] Wireframe descriptions map Basic and Premium screens to the same feature and component names used elsewhere.
- [ ] Wireframe descriptions cover Platform Administrator screens for dashboard, user management, role control, expert plan review, plan management, route management, notification/report management, and system analytics.
- [ ] Wireframe descriptions cover Medical Trainer/Expert screens for expert plan submission and submitted plan status without direct publication authority.
- [ ] Firebase Authentication, Cloud Firestore, Cloud Functions, Firebase Cloud Messaging, optional Firebase Cloud Storage, map provider, and optional AI service are named consistently.
- [ ] XP, level, streak, rank, weekly XP, monthly XP, and leaderboard score are never described as directly calculated or written by Flutter.
- [ ] Admin screens treat XP, level, streak, rank, and leaderboard data as read-only system-calculated fields.
- [ ] Leaderboard aggregation is described as server-side and based on validated activity/progression records.
- [ ] Premium access is described through entitlement checks, not UI hiding alone.
- [ ] Basic and Premium differences are fair and consistent with the PRD.
- [ ] MVP scope remains practical for a university FYP.
- [ ] Future extensions are clearly labelled and do not appear as required MVP implementation.
- [ ] No implementation code has been added.
- [ ] No final diagrams have been generated by the orchestration step.
- [ ] Any unavailable requested source path, such as `docs/prd/Runiac_PRD.pdf` or `docs/wireframes/`, is flagged with the local source file actually used.
