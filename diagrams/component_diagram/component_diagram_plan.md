# Runiac Component Diagram Plan

> Diagram category: PDD / Section 3 / Component Diagram
> Main references: `Topic 4.pdf` pages 29-31, existing Runiac PDD sample-style notes in `PDD_diagram_plan.md`, and the current application architecture in `diagrams/application_architecture/application_architecture.mmd`.

## 1. Topic 4 Component Diagram Rules To Preserve

The lecture places component diagrams in the `Development View`. For Runiac, this means the diagram should show the major software pieces that make up the system and how they depend on each other.

Key rules from `Topic 4.pdf`:

| Rule | How Runiac should apply it |
| --- | --- |
| Component diagrams illustrate pieces of software, embedded controllers, and subsystems. | Show Runiac's mobile app components, Firebase backend components, device-service adapters, and external services. |
| Component diagrams show relationships between different parts and help organize the system into subsystems. | Use clear boundaries such as `<<subsystem>> Runiac Application` and `Firebase Backend / BaaS`. |
| A component is a module of classes that represents an independent system or subsystem. | Use functional modules such as `Run Tracking`, `Training Plan`, `Route Sharing`, and `Territorial Leaderboard`, not individual screens. |
| A component is usually implemented by one or more classes or objects at runtime. | Do not treat every class as a component; group related classes into design-level components. |
| Components are shown as rectangles. | Use UML component rectangles with `<<component>>` labels and component icons where possible. |
| Provided interfaces use a complete circle. | Use lollipop symbols for services a component provides, such as activity processing or map display. |
| Required interfaces use a half circle. | Use socket symbols for services a component requires, such as authentication, storage, maps, AI summary generation, or push notifications. |
| The interface name should be placed near the interface symbol. | Label interfaces directly beside the lollipop/socket, e.g. `IActivityProcessing`, `IMapDisplay`, `IPushNotification`. |
| Package means physical code location; component means functionality. | The Runiac component diagram must focus on functionality and responsibility boundaries, not folder/package structure. |

## 2. Sample PDD Style To Match

The supervisor-provided sample PDD uses a clean UML-style component diagram rather than a colorful architecture map. Runiac's component diagram should follow that style:

- Use thin black or grey outlines.
- Use a large application boundary around app-owned components.
- Use UML component boxes and component icons.
- Keep external actors and services outside the application boundary.
- Use the same component rectangle notation for Firestore, Firebase services, and third-party systems; do not switch to database cylinders or server icons.
- Label connectors with short verbs such as `uses`, `stores`, `updates`, `triggers`, `generates`, `notifies`, and `shares`.
- Keep the diagram readable on one A4 page.
- Avoid showing every UI screen or every Firestore collection in this diagram.

## 3. Diagram Purpose

The component diagram should explain how Runiac's main software components collaborate at design level:

- what belongs inside the Runiac mobile application;
- what backend services support those features;
- which external services are required;
- which components provide or require key interfaces;
- which components are Basic-only, Premium-only, or shared by both user tiers.

This diagram should complement the Physical Architecture Diagram and Application Architecture Diagram, not repeat them exactly.

## 4. Planned High-Level Layout

Recommended layout:

```text
External Actors / Devices     Runiac Application Subsystem       Firebase / External Services
-------------------------     -----------------------------      ----------------------------
Basic User                    Account & Profile                  Firebase Authentication
Premium User                  Run Tracking                       Cloud Firestore
Platform Administrator        Training Plan                      Cloud Functions
Smartphone GPS                Activity Analysis                  Firebase Cloud Messaging
Optional Wearable             XP / Streak / Level                Maps / Geocoding
                              Route Sharing                      AI / LLM Service
                              Territorial Leaderboard            OS Share Sheet
                              Reminder & Notification
                              Subscription Entitlement
```

The final visual should place actors and device services on the left, Runiac app-owned components in the center, Firebase/backend components to the right or bottom-right, and external APIs on the far right.

## 5. Runiac Components To Include

### 5.1 Actors And External Inputs

| Element | Diagram Role |
| --- | --- |
| Basic User | Uses standard app features: onboarding, tracking, plan, XP, leaderboard, route viewing, reminders. |
| Premium User | Uses all Basic features plus expert plans and richer post-run analysis. |
| Platform Administrator | Reviews route reports and moderation-related data. |
| Smartphone GPS | Provides route points, pace, and distance inputs. |
| Optional Wearable | Provides supported metrics such as heart-rate data. |

### 5.2 Runiac Application Components

| Component | Responsibility |
| --- | --- |
| `Account & Profile` | Authentication flow, onboarding, goals, fitness level, health declarations, profile preferences. |
| `Subscription Entitlement` | Basic/Premium feature access and premium feature gating. |
| `Run Tracking` | Live run session, pause/resume/end run, GPS route capture, local activity buffering. |
| `Training Plan` | Today's plan, schedule editing, weekly plan, premium expert goal plan access. |
| `Activity Analysis` | Pace, distance, calorie, heart-rate, run summary display, premium analysis view. |
| `XP / Streak / Level` | User progression display, XP records, streaks, level and league indicators. |
| `Route Sharing` | Shared route list, route detail, route upload, favorite routes, route reporting. |
| `Territorial Leaderboard` | Regional ranking, level-based league ranking, rank details, rank sharing. |
| `Reminder & Notification` | Reminder preferences, notification inbox, foreground push handling. |
| `Share Card Generator` | Creates run summary cards and leaderboard sharing cards. |

### 5.3 Firebase Backend Components

| Component | Responsibility |
| --- | --- |
| `Firebase Authentication` | Identity, login, session management. |
| `Cloud Firestore` | Persistent app data: users, activities, routes, plans, XP, leaderboard, summaries, notifications, subscriptions. |
| `Cloud Functions Processing` | Validates activities, derives metrics/progression, aggregates leaderboards, schedules reminders, handles route moderation, and orchestrates premium AI summaries. |
| `Firebase Cloud Messaging` | Sends reminders and engagement push notifications. |

### 5.4 External Services

| Component | Responsibility |
| --- | --- |
| `Maps API` | Provides map rendering and route visualization. |
| `Geocoding / Region Mapping` | Maps GPS route coordinates to administrative regions. |
| `AI / LLM Service` | Generates premium post-run summary text from processed run data. |
| `OS Share Sheet / Social Media` | Receives generated run or rank share cards. |

## 6. Interfaces To Show

Use lollipop/socket notation for the important interfaces. If the drawing tool becomes too dense, show only the bold interfaces and keep the rest as labelled connectors.

| Interface | Provided By | Required By | Purpose |
| --- | --- | --- | --- |
| `IAuthentication` | Firebase Authentication | Account & Profile | Login/session service. |
| `IAppDataAccess` | Cloud Firestore | Most Runiac app components | Read/write persistent app data. |
| `IActivityProcessing` | Cloud Functions Processing | Run Tracking | Submit completed activity for validation and processing. |
| `IMetricProgressUpdate` | Cloud Functions Processing | Activity Analysis, XP / Streak / Level, Training Plan | Update metrics, XP, streak, level, and plan progress. |
| `ILeaderboardAggregation` | Cloud Functions Processing | Territorial Leaderboard | Retrieve regional ranking and rank updates. |
| `IRouteManagement` | Cloud Functions Processing / Cloud Firestore | Route Sharing | Store, retrieve, report, and moderate shared routes. |
| `IMapDisplay` | Maps API | Route Sharing, Territorial Leaderboard, Run Tracking | Display maps and routes. |
| `IRegionMapping` | Geocoding / Region Mapping | Cloud Functions Processing, Territorial Leaderboard, Route Sharing | Convert routes to regions. |
| `ISummaryGeneration` | AI / LLM Service | Cloud Functions Processing | Generate premium post-run summary text. |
| `IPushNotification` | Firebase Cloud Messaging | Reminder & Notification | Deliver reminders and engagement notifications. |
| `IShareTarget` | OS Share Sheet / Social Media | Share Card Generator | Share run/rank cards outside the app. |
| `IEntitlementCheck` | Subscription Entitlement | Training Plan, Activity Analysis, Cloud Functions Processing | Gate premium-only functions. |

## 7. Main Connector Story

The final diagram should communicate this flow without becoming a sequence diagram:

1. Basic and Premium users interact only with the Runiac application components.
2. `Account & Profile` uses Firebase Authentication and Firestore.
3. `Run Tracking` collects GPS/wearable data and submits completed activity through `IActivityProcessing`.
4. Backend processing validates activities, derives metrics, updates XP/streak/level, adjusts plans, and stores results in Firestore.
5. `Territorial Leaderboard` depends on aggregated leaderboard data and region mapping.
6. `Route Sharing` depends on maps, route storage, and route moderation.
7. `Reminder & Notification` depends on scheduled backend checks and Firebase Cloud Messaging.
8. Premium-only analysis depends on entitlement checks and the AI summary service.
9. Share cards are generated inside the app and passed to the OS share sheet/social platforms.

## 8. Complexity Control

To keep the diagram readable:

- Keep the app-owned component count around 9-10.
- Keep backend processing components around 6-8.
- Use one `Cloud Firestore` storage component instead of drawing every collection.
- Use one `Cloud Functions Processing` boundary if individual backend components become too crowded.
- Show only major interfaces with lollipop/socket notation.
- Use labelled straight connectors for secondary relationships.
- Avoid drawing every UI screen, every data entity, or every internal manager class.

## 9. Drawing Steps

1. Create a `<<subsystem>> Runiac Application` boundary in the center.
2. Add the app-owned UML component boxes inside the boundary.
3. Add Basic User, Premium User, Platform Administrator, Smartphone GPS, and Optional Wearable outside the left side.
4. Add Firebase Authentication, Cloud Firestore, Cloud Functions Processing, and Firebase Cloud Messaging outside the right or bottom-right side.
5. Add Maps API, Geocoding / Region Mapping, AI / LLM Service, and OS Share Sheet as external service boxes.
6. Draw the major lollipop/socket interfaces from Section 6.
7. Add short relationship labels only where they clarify the dependency.
8. Compare final names against the Physical Architecture and Application Architecture diagrams for consistency.
9. Export the final diagram as PNG/SVG and add one explanatory paragraph under it in the PDD.

## 10. Open Decisions Before Final Drawing

| Decision | Current Assumption |
| --- | --- |
| Maps provider | Label as `Google Maps / Mapbox API` unless the final stack chooses one provider. |
| Wearable support | Keep as optional external input because the PRD treats it as supported/optional. |
| Admin interface | Show `Platform Administrator` connected to backend route moderation; do not create a full admin UI unless the PDD needs it. |
| Premium features | Mark premium-only dependencies through `Subscription Entitlement` rather than separate Premium-only subsystem. |
| Drawing tool | Use draw.io/diagrams.net for the final version because UML lollipop/socket notation is easier to draw cleanly than in Mermaid. |

## 11. Draft PDD Explanation Paragraph

The component diagram shows the main functional components that make up the Runiac system. The Runiac application subsystem contains the user-facing mobile components for account setup, run tracking, training plans, activity analysis, progression, route sharing, leaderboard participation, reminders, and sharing. Firebase services provide authentication, persistent storage, backend processing, and push notifications, while external services support map rendering, region mapping, AI-generated premium summaries, and social sharing. The diagram uses provided and required interfaces to show which services each component offers or depends on.
