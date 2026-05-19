# Runiac PDD Diagram Plan

> Purpose: plan the diagrams needed for the Runiac Project Design Document (PDD) and define the diagram style based on the supervisor-provided sample PDD.
> Sample reviewed: `/Users/leejinseo/Desktop/FYP/Week 1/Sub 2 - Project Design Doc Sample.pdf`
> UML class diagram reference reviewed: `/Users/leejinseo/Desktop/CSCI314 Software Development Methodologies/Slides/Topic 3.pdf`, especially pp.15-23.
> Runiac references: `PRD.md`, `wireframe.md`, `PRD_assets/`, `wireframe_assets/basic/`, `wireframe_assets/premium/`

## 1. What The Sample PDD Uses

The sample PDD is structured around design-level diagrams, not requirement-level UML. Its main visual sections are:

| Sample PDD Section | Diagram Type | Sample Page | Observed Style |
| --- | --- | --- | --- |
| 2.1 Physical Architecture Diagram | Physical/system deployment architecture | p.9 | Large bordered canvas, split into Frontend and Backend zones, labelled modules, service icons, directional arrows, short arrow labels. |
| 2.2 Application Architecture Diagram | Application architecture / module interaction diagram | p.11 | Nested boxes, feature modules inside Frontend, backend services below, solid and dotted arrows showing data/control flow, service icons used sparingly. |
| 3. Component Diagram | UML-style component diagram | p.16 | Thin black UML component boxes, component icons, application boundary, database/server boxes, actor boxes, connectors labelled with access/permission relationships. |
| 4. User Interface | Wireframe/screen catalogue | pp.18-75 | One numbered function per page, bold screen title, large screenshot/wireframe, short explanatory paragraph below with screen name in bold. |
| 5. Semantic Data Diagram | ERD / semantic data model | pp.76-78 | Entity tables with PK/FK rows, attributes and data types, crow's-foot style relationships, short explanation paragraph after diagram. |

Important conclusion: the PDD sample does not emphasize use case, sequence, or activity diagrams. Those already exist in the PRD and should not be the main PDD diagram set unless the supervisor specifically asks for them again.

## 2. Required Runiac PDD Diagrams

Recommended PDD diagram set for Runiac:

| Priority | Diagram | Include In PDD? | Reason |
| --- | --- | --- | --- |
| P1 | Physical Architecture Diagram | Yes | Required to show Flutter client, Firebase backend, GPS/wearable/mobile services, mapping services, notification services, and AI summary service at a deployment/system level. |
| P1 | Application Architecture Diagram | Yes | Required to show how Runiac app modules interact with Firebase, Cloud Functions, Firestore, maps, leaderboard aggregation, XP, reminders, and AI summary processing. |
| P1 | Class Diagram | Yes | Required by the PDD preparation schedule. Use Topic 3 UML class notation to show the static logical model: domain classes, attributes, operations, and relationships. |
| P1 | Component Diagram | Yes | Required to show major software components and responsibility boundaries: account, run tracking, plan, analytics, route sharing, leaderboard, XP, reminders, notifications, data layer. |
| P1 | Semantic Data Diagram | Yes | Required to describe Firestore collections, key fields, references, and relationships between users, activities, plans, routes, leaderboard entries, XP, summaries, notifications, and subscriptions. |
| P1 | User Interface Wireframe Catalogue | Yes | Required because the sample PDD has a large UI section. Use saved Basic and Premium wireframes. |
| P2 | Basic User Screen Flow Diagram | Recommended | Useful because Basic flow image already exists and helps explain navigation between screens. Add as a supporting UI-flow diagram before or after Basic UI screens. |
| P2 | Premium User Screen Flow Diagram | Recommended | Useful because Premium has many unlocked branches. Add as a supporting UI-flow diagram once a local exported PNG is available. |
| P3 | Feature-Specific Processing Flow Diagrams | Optional | Only add if the PDD becomes unclear. Candidate flows: Run Completion Processing, Leaderboard Aggregation, AI Post-Run Summary. These are not present as separate diagram types in the sample PDD, so keep them optional. |

## 3. Proposed PDD Diagram Section Order

Mirror the sample PDD structure:

```text
2. System Architecture Design
  2.1 Physical Architecture Diagram
  2.2 Application Architecture Diagram

3. Class Diagram

4. Component Diagram

5. User Interface
  5.1 Basic User Screen Flow
  5.2 Basic User Interface Screens
  5.3 Premium User Screen Flow
  5.4 Premium User Interface Screens

6. Semantic Data Diagram
```

This order keeps the sample PDD structure recognizable while adding the Topic 3 logical class model required for Runiac's PDD preparation.

## 4. Diagram-by-Diagram Plan

### 4.1 Physical Architecture Diagram

Purpose:

- Show the high-level runtime environment and external services.
- Explain where the mobile app, Firebase services, third-party APIs, and user devices sit.

Current saved draft:

- Source folder: `diagrams/physical_architecture/`
- Current screenshot: `diagrams/physical_architecture/physical_architecture_current.png`
- Mermaid source: `diagrams/physical_architecture/physical_architecture.mmd`
- Explanation notes: `diagrams/physical_architecture/physical_architecture.md`

Runiac content to include:

| Layer | Elements |
| --- | --- |
| Users / Devices | Basic User, Premium User, iOS/Android mobile device, smartphone GPS sensor, optional wearable device |
| Frontend | Flutter Mobile Application |
| Backend / BaaS | Firebase Authentication, Cloud Firestore, Cloud Functions, Firebase Cloud Messaging |
| External Services | Google Maps or Mapbox, geocoding/location service, OS Share Sheet/social media platforms, AI/LLM service for premium post-run summary |
| Data / Storage | Firestore collections for users, activities, routes, plans, leaderboards, XP, summaries, notifications |

Sample style to match:

- Use a large outer rectangle.
- Split visually into `Frontend` and `Backend` bands, with labels on the left side.
- Use simple rectangular modules with thin borders.
- Use small platform/service icons only where helpful: Flutter, Firebase, maps, mobile device, GPS/wearable, AI.
- Use mostly black/grey lines; avoid decorative color except service icons.
- Add short arrow labels such as `records GPS data`, `authenticates`, `stores activity`, `sends reminder`, `requests map tiles`, `generates summary`.

Recommended diagram shape:

```text
Basic/Premium User
        |
Mobile Device: Flutter App + GPS + optional Wearable
        |
Firebase Auth / Firestore / Cloud Functions / FCM
        |
Maps Service, Geocoding, Social Share, AI Summary Service
```

Key point to communicate:

- The mobile app handles user interaction and live tracking.
- Firebase handles authentication, persistence, backend processing, leaderboard aggregation, reminders, and synchronization.
- External services support map rendering, sharing, and AI-assisted summaries.

### 4.2 Application Architecture Diagram

Purpose:

- Show Runiac's internal application modules and how they communicate with backend services.
- This is more detailed than the physical architecture diagram.

Runiac frontend modules:

| Module | Responsibilities |
| --- | --- |
| Authentication and Onboarding | Login, profile setup, user goals, fitness level, health declarations |
| Run Tracking | GPS tracking, live metrics, pause/resume/end run, local run buffer |
| Training Plan | weekly plan, today's plan, schedule edit, expert goal plan for Premium |
| Analysis and Summary | pace/distance/calorie metrics, premium analysis, post-run summary |
| Reminder and Notification UI | run reminders, rest reminders, streak-risk reminders |
| XP and Streak | XP update, level display, streak/consistency progress |
| Route Sharing | explore map, route detail, selected route, favorite routes, route upload, route report |
| Territorial Leaderboard | map ranking, region ranking, league division, share rank |
| Subscription / Entitlement | Basic vs Premium feature gating |

Runiac backend modules:

| Backend Service | Responsibilities |
| --- | --- |
| Firebase Authentication | account identity and session handling |
| Cloud Firestore | persistent records and real-time synchronization |
| Cloud Functions | activity validation, metric derivation, XP calculation, leaderboard aggregation, reminder checks, AI-summary preparation |
| Firebase Cloud Messaging | push notifications |
| Map / Geocoding API | route rendering, coordinate-to-region mapping |
| AI/LLM Service | premium post-run summary and richer analysis text |

Sample style to match:

- Use nested rectangles.
- Put Frontend modules in the top half and Backend services in the bottom half.
- Show feature modules as medium-sized boxes connected to backend processing modules.
- Use solid arrows for direct runtime calls and dotted arrows for background/scheduled processing.
- Keep labels short; detailed explanation should be in paragraph text after the diagram.

Main flows to show:

- Run Tracking -> local buffer -> Firestore -> Cloud Functions -> Activities / XP / Summary / Leaderboard.
- Training Plan -> Firestore -> Reminder Checks -> FCM.
- Route Sharing -> Map API / Firestore routes / Report processing.
- Leaderboard -> region aggregation -> Firestore leaderboard entries -> mobile UI.
- Premium Summary -> Cloud Functions -> AI/LLM -> summary stored in Firestore -> displayed in app.

### 4.3 Class Diagram

Purpose:

- Show the static logical structure of the Runiac system.
- Identify the main domain classes, their key attributes, important operations, and relationships.
- Bridge the PRD requirements, semantic data model, and implementation design without showing UI screens or Firebase document internals too early.

Current saved draft:

- Source folder: `diagrams/class_diagram/`
- Planning notes: `diagrams/class_diagram/class_diagram_plan.md`

Topic 3 UML class notation to follow:

| Notation | Use In Runiac Class Diagram |
| --- | --- |
| Class box | Use a rectangle with the class name at the top. Add attributes and operations only when they clarify the design. |
| Attribute format | Use `visibility name: Type`, for example `- email: String`. |
| Operation format | Use `visibility methodName(): ReturnType`, for example `+ calculateXP(): int`. |
| Visibility | `+` public, `-` private, `#` protected. |
| Read-only value | Use `{read only}` for constants or immutable values. |
| Static member | Underline static attributes or operations if the drawing tool supports it. |
| Association | Default relationship for "uses", "communicates with", "has-a", or "makes requests of". |
| Aggregation | Use only when one object is part of another but can exist independently. |
| Composition | Use only when the part cannot exist independently from the whole. |
| Inheritance | Use only for a true `is-a` specialization where subclass objects inherit superclass attributes, operations, and associations. |

Recommended Runiac class groups:

| Group | Candidate Classes |
| --- | --- |
| Account and entitlement | `UserAccount`, `UserProfile`, `Subscription`, `EntitlementPolicy` |
| Running activity | `Activity`, `RoutePoint`, `RunMetric`, `RunSummary`, `PremiumRunSummary` |
| Training plan | `TrainingPlan`, `PlanSession`, `Reminder` |
| Motivation | `XPRecord`, `UserProgression`, `Streak` |
| Route sharing | `SharedRoute`, `RouteFavorite`, `RouteReport` |
| Competition | `LeaderboardRegion`, `LeaderboardEntry`, `LeagueDivision` |
| Notification | `Notification`, `NotificationPreference` |
| External adapters | `MapServiceAdapter`, `AIServiceAdapter`, `WearableDataAdapter`, `PushNotificationAdapter` |

Recommended relationship rules:

- Use composition for strong lifecycle ownership, such as `Activity` composed of `RoutePoint`, `TrainingPlan` composed of `PlanSession`, and `Activity` composed of `RunSummary`.
- Use aggregation for weaker part-of relationships where the part may remain meaningful independently.
- Use association for most service/data interactions, such as `UserAccount` records `Activity`, `SharedRoute` is saved by `RouteFavorite`, or `LeaderboardEntry` references `LeaderboardRegion`.
- Use inheritance sparingly. `PremiumRunSummary` may specialize `RunSummary`; do not model `BasicUser` and `PremiumUser` as subclasses unless the implementation truly treats them as different user types. Prefer `Subscription` or `EntitlementPolicy` for tier behavior.

Recommended drawing shape:

```text
Account classes
  -> Activity / Training / Route / Leaderboard classes
  -> Summary / XP / Notification classes
  -> External service adapter classes
```

Key point to communicate:

- The class diagram should model Runiac's logical domain objects and relationships, not screens, pages, Firebase collections, or physical services. Firestore structure belongs in the Semantic Data Diagram; modules and deployable pieces belong in the Component and Architecture diagrams.

### 4.4 Component Diagram

Purpose:

- Show software components, access relationships, and responsibility boundaries.
- This should look like the sample's UML component diagram.

Recommended components:

| Component Group | Components |
| --- | --- |
| User / Account | User, Account Management, Profile and Onboarding, Subscription Entitlement |
| Running | Run Tracking, Activity Validation, GPS Route Recorder, Wearable Data Adapter |
| Planning | Training Plan Generator, Schedule Editor, Expert Goal Plan, Reminder Scheduler |
| Analysis | Metric Calculator, Premium Run Analysis, AI Post-Run Summary |
| Motivation | XP Calculator, Streak Tracker, Level Manager |
| Social / Route | Route Sharing, Route Repository, Favorite Routes, Route Report |
| Competition | Territorial Leaderboard, Region Mapper, League Division Manager, Rank Sharing |
| Notification | Notification Inbox, Push Notification Dispatcher |
| Data / External | Firestore Database, Firebase Auth, Cloud Functions, FCM, Maps API, AI/LLM Service, OS Share Sheet |

Sample style to match:

- Use UML component notation where possible.
- Large `Application` boundary around app-owned components.
- Separate `<< Database >> Firestore` and `<< External Service >>` boxes.
- Label connector lines with relationship verbs: `creates`, `stores`, `has access`, `triggers`, `updates`, `generates`, `notifies`, `shares`.
- Use thin black lines and minimal color.

Suggested component layout:

- Left: User actors and external systems.
- Center: Runiac Application boundary.
- Right: major feature components.
- Bottom/side: Firestore, Cloud Functions, Maps API, AI service, FCM.

### 4.5 User Interface Wireframe Catalogue

Purpose:

- Document the UI screens and explain each screen's role.
- This should closely follow the sample PDD's UI section.

Basic User assets:

- Stored in `wireframe_assets/basic/`
- 31 PNG files currently saved.
- Include Basic flow image first, then screen-by-screen catalogue.

Premium User assets:

- Stored in `wireframe_assets/premium/`
- 36 PNG files currently saved.
- Include Premium flow image when exported locally, then screen-by-screen catalogue.

Sample style to match:

- One screen or small related group per page.
- Numbered title, e.g. `1. Basic Home Page`.
- Place the phone wireframe large enough to read.
- Put a short paragraph below:
  - first phrase bold: `Basic Home Page:`
  - then explain purpose, core interactions, and where it navigates.
- Keep the writing functional and direct, not marketing-style.

Recommended grouping:

```text
5.1 Basic User Screen Flow
5.2 Basic User Interface Screens
  1. Basic Home Page
  2. Today's Plan Page
  3. Edit Plan Schedule Page
  ...

5.3 Premium User Screen Flow
5.4 Premium User Interface Screens
  1. Premium Home Page
  2. Today's Plan Detail Page
  3. Explore Expert Goal Plan Page
  ...
```

Do not include every tiny duplicate state if page count becomes too high. However, because the sample PDD includes many UI pages, it is acceptable to include all saved wireframe screens if the final document length allows it.

### 4.6 Semantic Data Diagram

Purpose:

- Show Firestore data collections and relationships.
- Equivalent to the sample PDD's ERD-style semantic data diagram.

Recommended Runiac entities / collections:

| Entity / Collection | Key Fields |
| --- | --- |
| UserAccount | userID, email, passwordHash/authProvider, role, subscriptionTier, createdAt |
| UserProfile | userID, displayName, fitnessLevel, runningExperience, goals, injuryHistory, healthDeclarations |
| Subscription | subscriptionID, userID, tier, status, startDate, renewalDate |
| Activity | activityID, userID, routeID, startTime, endTime, distance, duration, avgPace, calories, heartRateAvg, status, validationStatus |
| RoutePoint | pointID, activityID, latitude, longitude, timestamp, elevation, speed |
| SharedRoute | routeID, ownerUserID, title, distance, estimatedTime, difficulty, routePolyline, savedCount, visibilityStatus |
| RouteFavorite | favoriteID, userID, routeID, createdAt |
| RouteReport | reportID, routeID, reporterUserID, reason, description, status, createdAt |
| TrainingPlan | planID, userID, goalType, startDate, endDate, currentWeek, status, premiumPlanID |
| PlanSession | sessionID, planID, scheduledDateTime, targetDistance, targetDuration, intensity, completionStatus |
| Reminder | reminderID, userID, sessionID, reminderType, scheduledAt, sentStatus |
| XPRecord | xpRecordID, userID, activityID, xpAmount, reason, createdAt |
| UserProgression | userID, totalXP, level, leagueDivision, streakCount, weeklyXP, monthlyXP |
| LeaderboardRegion | regionID, name, type, parentRegionID, boundaryReference |
| LeaderboardEntry | entryID, regionID, userID, leagueDivision, weeklyXP, monthlyXP, rank, updatedAt |
| RunSummary | summaryID, activityID, userID, summaryType, text, recommendation, generatedAt |
| Notification | notificationID, userID, title, body, notificationType, readStatus, createdAt |

Sample style to match:

- Use table boxes with a title row.
- Use `PK` and `FK` markers even though Firestore is NoSQL; explain that document IDs and reference fields are represented in ERD form for clarity.
- Use crow's-foot relationships where possible.
- Use black/grey lines, no heavy color.
- Add a short explanatory paragraph after the diagram, like the sample.

Important relationships:

- UserAccount 1:1 UserProfile.
- UserAccount 1:N Activity.
- UserAccount 1:N TrainingPlan.
- TrainingPlan 1:N PlanSession.
- UserAccount 1:1 UserProgression.
- Activity 1:N RoutePoint.
- Activity 1:1 RunSummary.
- Activity 1:N XPRecord.
- SharedRoute 1:N RouteFavorite.
- SharedRoute 1:N RouteReport.
- LeaderboardRegion 1:N LeaderboardEntry.
- UserAccount 1:N LeaderboardEntry.
- UserAccount 1:N Notification.

## 5. Diagram Style Rules To Follow

General PDD visual style:

- Use a clean academic report style, not an app-marketing style.
- Prefer white background, black/grey outlines, and simple typography.
- Use color only for recognizable platform icons or tiny visual anchors.
- Keep diagrams readable on an A4 page.
- Use clear section titles above diagrams, matching the sample's numbering style.
- Add one explanatory paragraph after each major diagram.

Architecture diagrams:

- Use large grouped zones with labels such as `Frontend`, `Backend`, `External Services`, `Database`.
- Keep arrows directional and labelled.
- Avoid too many crossing lines; if a diagram becomes dense, split it into physical architecture and application architecture rather than forcing everything into one diagram.

Class diagram:

- Use UML class boxes with up to three compartments: class name, attributes, and operations.
- Keep class names singular and implementation-neutral.
- Use `+`, `-`, and `#` visibility prefixes consistently when attributes or operations are shown.
- Use association as the default relationship, and use aggregation, composition, or inheritance only when the meaning matches Topic 3.
- Avoid turning Basic/Premium subscription tiers, UI screens, Firebase services, or Firestore collections into classes unless they are actual logical domain objects.
- Split into packages or multiple diagrams if the class model becomes too dense for one A4 page.

Component diagram:

- Use UML component boxes and component icons where possible.
- Use actor boxes outside the application boundary.
- Label relationships with short verbs.

Semantic data diagram:

- Use entity boxes with PK/FK and type columns.
- Keep table field names consistent with the text explanation.
- For Firestore, use `documentID` and reference fields to represent relationships.

UI diagrams:

- Use actual wireframe PNGs from `wireframe_assets/`.
- Follow the sample format: title, screenshot, short paragraph.
- Basic and Premium sections should be separated clearly.

## 6. Diagrams Not To Prioritize

Do not make these the main PDD diagrams unless requested:

| Diagram Type | Reason |
| --- | --- |
| Use Case Diagrams | Already included in PRD functional requirements; sample PDD does not use them as the design-document core. |
| Sequence Diagrams | Already included in PRD; can be referenced but not repeated unless needed for a complex backend flow. |
| Activity Diagrams | Already included in PRD; PDD should focus on architecture, components, UI, and data design. |
| Detailed algorithm flowcharts | Optional only for complex functions such as leaderboard aggregation or AI summary generation. |

## 7. Recommended Work Order

1. Draw Physical Architecture Diagram first.
2. Draw Application Architecture Diagram using the same modules but with more internal detail.
3. Draw Class Diagram from the PRD domain concepts and Topic 3 UML class notation.
4. Draw Component Diagram from the application architecture modules.
5. Draw Semantic Data Diagram from Firestore collections and relationships.
6. Prepare UI section using saved Basic and Premium wireframes.
7. Add Basic and Premium screen-flow diagrams if final PDD page budget allows.
8. Review every diagram for consistency: same component names, same Firebase service names, same user role names, same feature names as PRD.

## 8. Naming Standards For Runiac Diagrams

Use these exact titles in the PDD:

```text
2.1 Physical Architecture Diagram
2.2 Application Architecture Diagram
3. Class Diagram
4. Component Diagram
5.1 Basic User Screen Flow
5.2 Basic User Interface Screens
5.3 Premium User Screen Flow
5.4 Premium User Interface Screens
6. Semantic Data Diagram
```

If optional processing diagrams are added, place them after the Application Architecture Diagram or in an appendix:

```text
Appendix A. Run Completion Processing Flow
Appendix B. Leaderboard Aggregation Flow
Appendix C. AI-Assisted Post-Run Summary Flow
```
