# Project Design Document

# Runiac

Runiac is a beginner-focused running application that helps new runners build a safe and consistent running habit through onboarding-driven plan setup, guided run tracking, progress feedback, reminders, route exploration, and fair progression displays. This Project Design Document covers the application architecture, physical architecture, component design, class design, and wireframe design for the prepared Runiac PDD package.

## Table Of Contents

- [1. Introduction / Project Overview](#1-introduction--project-overview)
- [2. Application Architecture](#2-application-architecture)
- [3. Physical Architecture](#3-physical-architecture)
- [4. Component Diagram](#4-component-diagram)
- [5. Class Diagram](#5-class-diagram)
- [6. Wireframe Design](#6-wireframe-design)
- [7. Appendix / Supporting Notes](#7-appendix--supporting-notes)

## 1. Introduction / Project Overview

Runiac is designed as a mobile-first running app for beginner users. The app supports setup through a one-question-per-page onboarding flow, uses the onboarding answers to initialise the user's first beginner running plan, and provides daily plan guidance, GPS-based run tracking, post-run summaries, reminders, route features, leaderboard displays, and profile progress views.

The design separates subscription access from operational governance. Basic and Premium access is controlled through `subscriptionStatus`; Platform Administrator and Medical Trainer/Expert responsibilities are controlled through `userRole`. Premium adds value through richer analytics, approved expert plan access, route convenience, and presentation/sharing features, but it must not create XP, rank, weekly XP, monthly XP, leaderboard score, or other competitive advantages.

Trusted progression values are backend-owned. The Flutter client displays XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP after backend processing, but it must not directly calculate, edit, or write those values. Health/safety onboarding inputs are readiness and cautiousness signals only; they are not used for medical diagnosis, treatment, medical advice, exercise clearance, or clinical compliance. Location permission is not requested during onboarding and is requested later only when run tracking or route features require it.

## 2. Application Architecture

Runiac uses a mobile client with Firebase Backend-as-a-Service architecture. The Flutter mobile application handles the user-facing experience, including onboarding, run tracking screens, map views, training plan displays, post-run summaries, reminders, XP display, and leaderboard views. Firebase provides authentication, persistent data storage, server-side processing, and push notification delivery.

This architecture is suitable for a university MVP because it keeps the system small enough to implement within the project timeline while still supporting synchronized user data, server-side validation, reminders, XP progression, and future leaderboard features. Security-sensitive and fairness-sensitive logic is handled in Firebase Cloud Functions rather than inside the Flutter client.

![Figure 1: Application Architecture](diagrams/application-architecture.png)

**Caption:** Figure 1 shows how the Flutter mobile app, Firebase services, and external services work together so Runiac can provide mobile running features while keeping trusted progression and governance logic on the backend.

### 2.1 Main Architectural Layers

| Layer | Main Elements | Purpose |
| --- | --- | --- |
| User Layer | Basic User, Premium User, Platform Administrator, Medical Trainer/Expert | Represents the people who use, manage, review, or provide expert plan content for the system. |
| Flutter Mobile App Layer | Flutter screens, navigation, state management, GPS tracking, local run buffer, map UI, notification handler | Provides the mobile experience and collects user input and run data. |
| Firebase Service Layer | Firebase Authentication, Cloud Firestore, Cloud Functions, Firebase Cloud Messaging, optional Firebase Cloud Storage | Provides identity, database storage, backend processing, push notifications, and optional media/file storage. |
| External Service Layer | Google Maps / Mapbox APIs, optional AI / LLM summary service | Provides map rendering, route display, geocoding support, and future AI-assisted summary generation. |

### 2.2 Layer Responsibilities

Basic and Premium users interact with Runiac through the same mobile application. Basic and Premium access is distinguished by `subscriptionStatus`, while operational or content-governance responsibility is distinguished by `userRole`. Premium users receive advanced analytics, published expert goal plans, saved route collections, advanced route filters, route comparison, AI-assisted summaries, and enhanced sharing presentation, but they earn XP, level, rank, and leaderboard score under exactly the same server-owned rules as Basic users, so Premium gives no ranking advantage.

Platform Administrator is the operational `userRole` responsible for moderation and expert plan governance. Medical Trainer/Expert is a content provider rather than a direct plan publisher. Expert plan content is prepared through an off-system or controlled submission process, reviewed by the Platform Administrator, and made visible to Premium Users only after approval and publication.

The Flutter app may write user-owned input such as profile information, preferences, plan schedule changes, and raw completed activity submissions. It must not directly calculate or write XP, level, rank, streak, weekly XP, monthly XP, or leaderboard score fields. Cloud Functions handle activity validation, backend-supported first beginner plan generation, XP and streak updates, leaderboard aggregation, notification checks, entitlement checks, expert plan governance, and AI-assisted summary orchestration where applicable.

### 2.3 Data Flow

1. The user signs in through the Flutter app and Firebase Authentication returns an authenticated session.
2. During onboarding, Flutter submits and stores profile, goal, running level, availability, preference, health/safety readiness, and cautiousness inputs in Cloud Firestore.
3. The Plan Data Service and Cloud Functions create or initialise the first beginner running plan and store it in Firestore for plan screens and reminders.
4. During a run, Flutter records GPS samples and live metrics locally while rendering the active run screen and map view.
5. When the run ends, Flutter submits the completed activity data to a backend-controlled activity path.
6. Backend processing validates the activity before XP, streak, level, weekly XP, monthly XP, summaries, or leaderboard records can be updated.
7. Flutter reads the processed values and displays them to the user.

### 2.4 MVP Scope And Future Extensions

The MVP focuses on Firebase Authentication, onboarding, beginner-friendly training plans, Flutter GPS tracking, local run buffering, activity upload, basic activity history, reminder checks, and backend-owned progression values. Future or Phase 2 extensions may include richer route sharing, territorial leaderboard aggregation, AI-assisted summaries, expert dashboards for draft submission, and additional Premium presentation features. These extensions must preserve backend ownership of trusted values and Platform Administrator ownership of expert plan publication.

## 3. Physical Architecture

Runiac is deployed as a mobile-first system using a Flutter application and Firebase Backend-as-a-Service. The main runtime environment is the user's iOS or Android mobile device. The device runs the Runiac Flutter app, collects GPS-based activity data, displays maps and progress information, and communicates with managed Firebase services through the Internet using HTTPS.

The backend is not deployed as a custom server, Kubernetes cluster, or microservice platform. Instead, backend responsibilities are handled by managed Firebase cloud components. Firebase Authentication manages user identity, Cloud Firestore stores application data, Cloud Functions runs server-side validation and aggregation logic, Firebase Cloud Messaging delivers reminders, and Cloud Storage for Firebase stores files or generated media if required.

![Figure 2: Physical Architecture](diagrams/physical-architecture.png)

**Caption:** Figure 2 shows the deployment boundary between the mobile device, Firebase managed cloud services, and external services so Runiac can support GPS-based running features without operating a custom backend server.

### 3.1 Client Device Responsibilities

| Client-side component | Physical responsibility |
| --- | --- |
| iOS / Android mobile device | Runs the Flutter application and provides access to platform capabilities such as GPS, notifications, local storage, and OS sharing. |
| Runiac Flutter app | Renders the user interface, handles navigation, displays activity history, shows plans, maps, XP, streaks, and leaderboard views. |
| GPS / location sensor | Captures route points, location accuracy, pace-related data, and distance-related inputs during a running session. |
| Optional wearable integration | Provides supported metrics such as heart rate through platform mechanisms such as HealthKit or Health Connect, where available. |
| Local cache / active run buffer | Temporarily stores in-progress activity data so that a run is not lost when connectivity is weak or unstable. |
| Push notification receiver | Receives reminder and engagement notifications delivered through Firebase Cloud Messaging. |
| OS share sheet | Allows the user to share selected run summaries, achievement cards, or leaderboard cards to external platforms after explicit confirmation. |

The mobile client may calculate display-only values needed for immediate feedback during a run, such as elapsed time or temporary pace display. However, the client must not be trusted as the authority for XP, level, streak, leaderboard score, or rank. Those values are calculated or validated through Firebase Cloud Functions before being stored.

### 3.2 Firebase And External Services

| Service | Responsibility in Runiac |
| --- | --- |
| Firebase Authentication | Handles sign-in, identity, session tokens, and access-control integration. |
| Cloud Firestore | Stores user profiles, onboarding information, subscription or entitlement state, activities, GPS trace records, routes, route reports, training plans, approved/published expert plans, progression records, leaderboard aggregates, reminder settings, and post-run summaries. |
| Cloud Functions | Performs trusted server-side logic, including activity validation, backend-supported onboarding-driven first beginner plan initialisation, XP/streak/level updates, leaderboard aggregation, reminder checks, entitlement checks, expert plan governance, route region mapping, and summary orchestration. |
| Firebase Cloud Messaging | Sends push notifications for planned runs, rest reminders, missed sessions, streak-risk reminders, and engagement prompts. |
| Cloud Storage for Firebase | Stores optional binary assets where needed, such as profile images, generated share cards, route-related media, or exported files. |
| Google Maps / Mapbox APIs | Provides map tiles, map rendering support, route display, and map-based interaction for run tracking, community routes, and territorial leaderboard views. |
| OS share sheet / social media platforms | Supports user-confirmed sharing while avoiding unnecessary exposure of sensitive route or health/safety readiness information. |

### 3.3 Network And Security Notes

During onboarding, Flutter submits profile, goal, running level, availability, health/safety readiness, and cautiousness inputs. The Plan Data Service and Cloud Functions create or initialise the first beginner running plan in Cloud Firestore for plan screens and reminders.

After a run, activity data is uploaded over HTTPS and validated before it can affect XP, streaks, levels, or leaderboards. Cloud Functions write validated activity results, GPS trace records, progression updates, entitlement-checked outputs, route report states, leaderboard aggregates, and summaries to Cloud Firestore. Location privacy must be protected through privacy-aware sharing, route masking where appropriate, and explicit user confirmation before public sharing.

## 4. Component Diagram

The component diagram describes the main software components that make up Runiac and the dependencies between them. It is a design-level view, so screens are grouped by feature area instead of being shown one by one. This keeps the diagram focused on responsibility boundaries rather than navigation detail.

Runiac is organised into a Flutter mobile application and a Firebase backend. The Flutter application handles user interaction, screen rendering, GPS-based run tracking, map display, and local session behaviour. Firebase provides authentication, persistent data access, backend processing, aggregation, and notification delivery. External services such as map providers, geocoding, device sensors, the operating system share sheet, and optional AI summary generation sit outside the Runiac ownership boundary.

![Figure 3: Component Diagram](diagrams/component-diagram.png)

**Caption:** Figure 3 shows the main frontend, backend, and external service components and highlights that trusted processing such as XP, streak, and leaderboard updates belongs to backend services.

**Formatting note:** The component diagram is intentionally detailed and may need full-width or landscape placement in the final Word/PDF version.

### 4.1 Component Names

| Area | Canonical name used in this PDD |
| --- | --- |
| Authentication | Auth Component, Authentication Service |
| Onboarding and profile | Onboarding Component, Profile Component, User/Profile Data Service |
| Plans | Plan Component, Plan Data Service |
| Expert plan governance | Admin Expert Plan Management |
| Running | Run Tracking Component, Activity Data Service, Activity Processing Function |
| Analysis | Activity Analysis Component, Summary Generation Function |
| Progression | XP and Streak Function |
| Routes | Explore / Route Component, Route Data Service |
| Competition | Leaderboard Component, Leaderboard Aggregation Function |
| Notifications | Notification Service |
| Premium access | Premium / Entitlement Component, Entitlement Service |
| Maps | Google Maps / Mapbox APIs |

### 4.2 Component Responsibilities

The frontend components depend on backend interfaces rather than directly owning backend logic. The Onboarding Component captures running experience, goals, fitness level, health/safety readiness, cautiousness inputs, and initial preferences. The Plan Component presents current plans and approved/published Premium expert plan flows where entitlement allows. The Run Tracking Component captures GPS and optional wearable metrics during a run, maintains local run state, and uploads completed activity data.

Backend components provide the trusted system boundary. Activity Processing Function owns completed activity validation, anti-abuse checks, GPS trace quality checks, metric derivation, and processing events for XP and summary generation. XP and Streak Function calculates XP, streak, level, league division, weekly XP, and monthly XP after a valid activity or scheduled streak check. Leaderboard Aggregation Function aggregates validated XP data by region and level division, then stores precomputed weekly/monthly leaderboard records.

Expert plan governance is handled separately from the Premium plan UI. Medical Trainer/Expert prepares expert plan content but does not publish it into the app or database in the MVP. Platform Administrator uses Admin Expert Plan Management to review the content for safety, completeness, beginner suitability, and Runiac standards before creating, approving, publishing, updating, or archiving the plan. Premium Users can only read and select published expert plan records.

## 5. Class Diagram

The class diagram represents the design-level logical structure of Runiac. It identifies the main model classes used to describe users, running activities, GPS traces, plans, routes, route reports, progression, leaderboards, post-run feedback, and notification preferences. It also includes the main service and controller classes that coordinate authentication, plan handling, run tracking, activity processing, XP calculation, leaderboard aggregation, route management, entitlement checks, summary generation, and notifications.

![Figure 4: Class Diagram](diagrams/class-diagram.png)

**Caption:** Figure 4 shows the design-level entities and services used by Runiac, including backend-owned progression records, subscription-based access, and administrator-controlled expert plan governance.

**Formatting note:** The class diagram is large and may need full-width or landscape placement in the final Word/PDF version.

### 5.1 Class Model Rules

Basic User and Premium User are not modelled as separate subclasses. Instead, Basic/Premium access is represented through `User.subscriptionStatus`. Operational and governance responsibility is represented through `User.userRole`, such as Platform Administrator and Medical Trainer/Expert. This avoids duplicating user classes when tiers share the same identity, profile, activity, XP, and leaderboard model.

Expert plan governance is modelled explicitly. `MedicalTrainerExpert` represents the content provider who prepares expert goal plan content. The expert does not directly publish plans into the mobile app or database in the MVP. `AdminExpertPlanManagementService` represents the Platform Administrator's restricted workflow for creating, reviewing, approving, publishing, updating, and archiving expert plans. Premium Users can select only `ExpertPlan` records with a published status.

Server-side responsibilities are separated from client-side controllers. The Flutter client may display XP, level, streak, rank, and leaderboard data, but it must not directly calculate or write those values. `ActivityProcessingFunction`, `XPAndStreakFunction`, and `LeaderboardAggregationFunction` represent backend processing that validates activity data and updates trusted progression and ranking records.

### 5.2 Main Entity Classes

| Class | Purpose | Key attributes |
| --- | --- | --- |
| `User` | Represents the authenticated Runiac account and role/tier state. | `userId`, `email`, `userRole`, `subscriptionStatus`, `createdAt` |
| `UserProfile` | Stores onboarding and personal running profile information, including readiness and cautiousness signals. | `profileId`, `userId`, `displayName`, `fitnessLevel`, `goals`, `healthSafetyReadiness`, `planCautiousness` |
| `TrainingPlan` | Represents a user's active or historical running plan. | `planId`, `userId`, `goalType`, `planType`, `startDate`, `endDate`, `status` |
| `PlanDay` | Represents one scheduled workout or rest day inside a training plan. | `planDayId`, `scheduledDate`, `workoutType`, `targetDistance`, `targetDuration`, `completionStatus`, `xpReward` |
| `Activity` | Stores a completed or submitted run activity after run tracking. | `activityId`, `userId`, `planDayId`, `routeId`, `startedAt`, `endedAt`, `distance`, `duration`, `avgPace`, `validationStatus` |
| `ActivityTrackPoint` | Represents a lightweight GPS trace point captured during a run. | `trackPointId`, `activityId`, `latitude`, `longitude`, `timestamp`, `accuracy`, `sequenceNo` |
| `RouteReport` | Represents a user-submitted report for unsafe or inappropriate shared route content. | `reportId`, `routeId`, `reporterUserId`, `reason`, `description`, `status`, `createdAt` |
| `UserStats` | Stores trusted progression values calculated by backend logic. | `userId`, `totalXP`, `level`, `streakCount`, `weeklyXP`, `monthlyXP`, `leagueDivision`, `updatedAt` |
| `LeaderboardEntry` | Represents a user's ranking record for a region, period, and league division. | `entryId`, `userId`, `region`, `leagueDivision`, `rankingPeriod`, `scoreXP`, `rank`, `updatedAt` |
| `MedicalTrainerExpert` | Represents the expert plan content provider. | `expertId`, `name`, `specialty`, `credentialSummary`, `providerStatus` |
| `ExpertPlan` | Represents Premium expert or goal-based plan templates governed by admin review. | `expertPlanId`, `expertId`, `title`, `goalType`, `difficulty`, `durationWeeks`, `status`, `reviewComment`, `publishedAt`, `version` |
| `PlanReview` | Records Platform Administrator review decisions for expert plan content. | `reviewId`, `expertPlanId`, `reviewerAdminId`, `decision`, `comment`, `reviewedAt` |

### 5.3 Main Service Classes

| Class | Layer | Design responsibility |
| --- | --- | --- |
| `PlanService` | Client/backend coordination service | Loads training plans, requests backend-supported first beginner plan initialisation from onboarding inputs, reschedules plan days, checks premium access for published expert plans, and saves plan updates. |
| `RunTrackingService` | Flutter client controller | Starts, pauses, resumes, and ends active GPS run tracking. It creates an activity draft but does not award XP or update leaderboard data. |
| `ActivityProcessingFunction` | Cloud Function / backend service | Owns activity validation, anti-abuse checks, GPS trace quality checks, derived metric creation, and downstream processing events. |
| `XPAndStreakFunction` | Cloud Function / backend service | Calculates XP, updates user stats, updates streak and level values, and triggers downstream leaderboard refresh after valid activity processing. |
| `LeaderboardAggregationFunction` | Backend aggregation function | Aggregates trusted user stats into regional and league-based leaderboard records. |
| `EntitlementService` | Backend service | Checks `subscriptionStatus` before allowing premium expert plans, AI-assisted summaries, advanced analytics, saved route collections, route comparison, or premium sharing templates. |
| `AdminExpertPlanManagementService` | Restricted admin service | Allows Platform Administrator to create, review, approve, publish, update, version, and archive expert plans. |

## 6. Wireframe Design

This section presents the Runiac wireframes prepared for the Project Design Document. The wireframes are divided into mobile user wireframes and controlled governance wireframes. The mobile wireframes cover Basic and Premium user experiences, while the governance wireframes cover Platform Administrator and Medical Trainer/Expert workflows.

The mobile figures are grouped by user journey rather than inserted as every individual Basic/Premium screen. Shared mobile screens are treated as common Basic/Premium user experiences unless a screen explicitly shows a locked Premium state or Premium-only enhancement. Basic/Premium feature access is represented through `subscriptionStatus`, while operational and governance access is represented through `userRole`.

### 6.1 Mobile User Wireframes

#### Figure 5: Home Dashboard

![Figure 5a: Basic Home Dashboard](wireframe-images/mobile-user/basic/basic-home-page.png)

![Figure 5b: Premium Home Dashboard](wireframe-images/mobile-user/premium/premium-home-page.png)

**Caption:** Figure 5 shows the Home Dashboard for Basic and Premium users, including daily plan guidance, XP progress display, weekly plan preview, last-run information, and Premium dashboard extensions.

Premium dashboard content adds richer guidance and presentation value, but it must not create XP, rank, weekly XP, monthly XP, or leaderboard scoring advantages.

#### Figure 6: Onboarding / Profile Setup

![Figure 6a: Onboarding Welcome](wireframe-images/mobile-user/shared/onboarding/01-onboarding-welcome-page.png)

![Figure 6b: Onboarding Main Goal](wireframe-images/mobile-user/shared/onboarding/02-onboarding-main-goal-page.png)

![Figure 6c: Onboarding Current Level](wireframe-images/mobile-user/shared/onboarding/03-onboarding-current-level-page.png)

![Figure 6d: Onboarding Weekly Availability](wireframe-images/mobile-user/shared/onboarding/04-onboarding-weekly-availability-page.png)

![Figure 6e: Onboarding Preferred Days](wireframe-images/mobile-user/shared/onboarding/05-onboarding-preferred-days-page.png)

![Figure 6f: Onboarding Preferred Time](wireframe-images/mobile-user/shared/onboarding/06-onboarding-preferred-time-page.png)

![Figure 6g: Onboarding Session Length](wireframe-images/mobile-user/shared/onboarding/07-onboarding-session-length-page.png)

![Figure 6h: Onboarding Running Place](wireframe-images/mobile-user/shared/onboarding/08-onboarding-running-place-page.png)

![Figure 6i: Onboarding Motivation Style](wireframe-images/mobile-user/shared/onboarding/09-onboarding-motivation-style-page.png)

![Figure 6j: Onboarding Health Condition](wireframe-images/mobile-user/shared/onboarding/10-onboarding-health-condition-page.png)

![Figure 6k: Onboarding Activity Symptoms](wireframe-images/mobile-user/shared/onboarding/11-onboarding-activity-symptoms-page.png)

![Figure 6l: Onboarding Plan Cautiousness](wireframe-images/mobile-user/shared/onboarding/12-onboarding-plan-cautiousness-page.png)

![Figure 6m: Onboarding Plan Preview](wireframe-images/mobile-user/shared/onboarding/13-onboarding-plan-preview-page.png)

**Caption:** Figure 6 shows the canonical 13-page onboarding sequence used to collect beginner plan inputs and initialise the user's first running plan.

Onboarding collects the user's running goal, current level, weekly availability, preferred days, preferred time, session length, running place/context, motivation style, health/safety readiness, cautiousness inputs, and final plan preview. Health/safety inputs are readiness and cautiousness signals only. Location permission is not requested during onboarding and is requested later when starting a run or using route features.

#### Figure 7: Plan Home and Today's Plan Detail

![Figure 7a: Basic Plan Home](wireframe-images/mobile-user/basic/basic-you-plan-page.png)

![Figure 7b: Basic Today's Plan](wireframe-images/mobile-user/basic/basic-todays-plan-page.png)

![Figure 7c: Premium Plan Home](wireframe-images/mobile-user/premium/premium-you-plan-page.png)

![Figure 7d: Premium Today's Plan Detail](wireframe-images/mobile-user/premium/premium-todays-plan-detail-page.png)

**Caption:** Figure 7 shows weekly plan progress, daily plan detail, session guidance, XP reward display, and start-run entry points.

#### Figure 8: Edit Schedule

![Figure 8a: Basic Edit Schedule](wireframe-images/mobile-user/shared/basic-source-edit-plan-schedule-page.png)

![Figure 8b: Premium Edit Schedule](wireframe-images/mobile-user/shared/premium-source-edit-plan-schedule-page.png)

**Caption:** Figure 8 shows how users adjust plan timing while preserving backend-supported plan ownership and schedule consistency.

#### Figure 9: Run Start and Live Run

![Figure 9a: Run Landing](wireframe-images/mobile-user/shared/basic-source-run-landing-page.png)

![Figure 9b: Run Guide](wireframe-images/mobile-user/shared/run-guide-page.png)

![Figure 9c: Live Run Tracking](wireframe-images/mobile-user/shared/basic-source-run-tracking-page.png)

![Figure 9d: Paused Run Tracking](wireframe-images/mobile-user/shared/basic-source-paused-run-tracking-page.png)

**Caption:** Figure 9 shows route/plan confirmation, pre-run guidance, active GPS tracking, pause, resume, and end-run controls.

#### Figure 10: Cool Down and Run Summary

![Figure 10a: Cool Down Landing](wireframe-images/mobile-user/shared/cool-down-landing-page.png)

![Figure 10b: Cool Down Intro](wireframe-images/mobile-user/shared/cool-down-intro-page.png)

![Figure 10c: Basic Run Summary](wireframe-images/mobile-user/basic/basic-run-summary-page.png)

![Figure 10d: Premium Run Summary](wireframe-images/mobile-user/premium/premium-run-summary-page.png)

![Figure 10e: XP And Streak Update](wireframe-images/mobile-user/shared/basic-source-xp-streak-update-page.png)

**Caption:** Figure 10 shows the post-run flow, including recovery guidance, run summary, XP/streak display after backend processing, and Premium run analysis.

### 6.2 Route, Leaderboard, and Profile Wireframes

#### Figure 11: Explore Map and Route List

![Figure 11a: Basic Maps Landing](wireframe-images/mobile-user/shared/basic-source-maps-landing-page.png)

![Figure 11b: Shared Route List](wireframe-images/mobile-user/shared/basic-source-shared-route-list-page.png)

**Caption:** Figure 11 shows route discovery through map preview, search, nearby shared routes, filters, and route cards.

#### Figure 12: Route Detail and My Route

![Figure 12a: Basic Map Detail](wireframe-images/mobile-user/basic/basic-map-detail-page.png)

![Figure 12b: Route Selected](wireframe-images/mobile-user/shared/route-selected-page.png)

![Figure 12c: Basic My Route](wireframe-images/mobile-user/basic/basic-my-route-page.png)

![Figure 12d: Route Report](wireframe-images/mobile-user/shared/basic-source-route-report-page.png)

**Caption:** Figure 12 shows route details, route selection confirmation, saved-route management, and route reporting for administrator moderation.

Route and GPS data are sensitive. Route sharing should require confirmation and use privacy-aware wording such as masking or avoiding unnecessary precise exposure where appropriate.

#### Figure 13: Leaderboard

![Figure 13a: Leaderboard Landing](wireframe-images/mobile-user/shared/basic-source-leaderboard-landing-page.png)

![Figure 13b: Leaderboard Region](wireframe-images/mobile-user/shared/basic-source-leaderboard-region-page.png)

![Figure 13c: Leaderboard League](wireframe-images/mobile-user/shared/basic-source-leaderboard-league-page.png)

![Figure 13d: Premium Leaderboard Sharing](wireframe-images/mobile-user/premium/premium-leaderboard-sharing-page.png)

**Caption:** Figure 13 shows territorial ranking, regional detail, league views, expanded rankings, and sharing templates.

Leaderboard values are precomputed by backend aggregation. Premium sharing templates provide presentation/status value only and must not affect ranking, XP, or leaderboard fairness.

#### Figure 14: Profile / You

![Figure 14a: Basic Profile](wireframe-images/mobile-user/basic/basic-you-page.png)

![Figure 14b: Premium Profile](wireframe-images/mobile-user/premium/premium-you-page.png)

**Caption:** Figure 14 shows personal progress, calendar, recent runs, runner level display, and plan entry points.

#### Figure 15: Premium Expert Plan Access

![Figure 15a: Explore Expert Goal Plan](wireframe-images/mobile-user/premium/explore-expert-goal-plan-page.png)

![Figure 15b: View Expert Plan Detail](wireframe-images/mobile-user/premium/view-expert-plan-detail-page.png)

![Figure 15c: View Goal Plan Journey](wireframe-images/mobile-user/premium/view-goal-plan-journey-page.png)

**Caption:** Figure 15 shows expert plan discovery, published plan details, goal-plan journey, and Premium plan progress.

Premium Users can view and select only expert plans that have been approved and published by the Platform Administrator.

### 6.3 Admin/Expert Governance Flow Overview

![Figure 16: Admin/Expert Governance Flow Overview](wireframe-images/shared-governance/admin-expert-governance-flow-overview.png)

**Caption:** Figure 16 shows how expert plan content moves from Medical Trainer/Expert submission to Platform Administrator review and controlled publication.

The governance flow separates content preparation from system publication. Medical Trainer/Expert submits and revises content only. Platform Administrator reviews, approves, publishes, rejects, and archives expert plans. Premium Users can view/select only approved and published expert plans.

### 6.4 Platform Administrator Wireframes

#### Figure 17: Admin Dashboard

![Figure 17: Admin Dashboard](wireframe-images/platform-admin/admin-dashboard.png)

**Caption:** Figure 17 shows governance workload, pending expert plans, reported routes, active notifications, quick actions, and recent activity.

#### Figure 18: User Management

![Figure 18: User Management](wireframe-images/platform-admin/user-management.png)

**Caption:** Figure 18 shows account search, filters, user table, and View/Edit/Suspend actions while keeping Basic/Premium as `subscriptionStatus`.

#### Figure 19: User Detail / Role Control

![Figure 19: User Detail / Role Control](wireframe-images/platform-admin/user-detail-role-control.png)

**Caption:** Figure 19 shows profile, access information, read-only running summary, moderation notes, and administrator actions.

Administrator screens may display trusted progression values, but they must not directly modify XP, level, streak, rank, or leaderboard score.

#### Figure 20: Expert Plan Review

![Figure 20: Expert Plan Review](wireframe-images/platform-admin/expert-plan-review.png)

**Caption:** Figure 20 shows submitted expert plan details, provider information, weekly schedule, safety notes, review checklist, administrator comments, and decision buttons.

#### Figure 21: Expert Plan Review Queue

![Figure 21: Expert Plan Review Queue](wireframe-images/platform-admin/expert-plan-review-queue.png)

**Caption:** Figure 21 shows pending expert plan submissions, review status, provider information, and administrator review actions.

#### Figure 22: Plan Management

![Figure 22: Plan Management](wireframe-images/platform-admin/plan-management.png)

**Caption:** Figure 22 shows system and expert plan records, lifecycle statuses, search filters, and View/Edit/Archive actions.

#### Figure 23: Expert Plan Publish Confirmation

![Figure 23: Expert Plan Publish Confirmation](wireframe-images/platform-admin/expert-plan-publish-confirmation.png)

**Caption:** Figure 23 shows administrator pre-publication checks before making an approved expert plan visible to Premium Users.

#### Figure 24: Route Management

![Figure 24: Route Management](wireframe-images/platform-admin/route-management.png)

**Caption:** Figure 24 shows shared route search, route table, map preview, report detail preview, and soft moderation actions.

Reported routes are handled by Platform Administrator moderation and should be reviewed for safety, privacy, and content quality.

#### Figure 25: Notification / Report Management

![Figure 25: Notification / Report Management](wireframe-images/platform-admin/notification-report-management.png)

**Caption:** Figure 25 shows notification creation, notification history, report table, and moderation actions.

### 6.5 Medical Trainer/Expert Wireframes

#### Figure 26: Expert Plan Submission Form

![Figure 26: Expert Plan Submission Form](wireframe-images/medical-trainer-expert/expert-plan-submission-form.png)

**Caption:** Figure 26 shows expert credentials, plan details, weekly plan builder, safety guidance, and submission controls for administrator review.

The form must not include direct publication into the live Premium plan catalogue.

#### Figure 27: Submitted Plan Status Page

![Figure 27: Submitted Plan Status Page](wireframe-images/medical-trainer-expert/submitted-plan-status-page.png)

**Caption:** Figure 27 shows submitted expert plans, review statuses, administrator comments, and revision-response actions.

#### Figure 28: Expert Plan Revision Response

![Figure 28: Expert Plan Revision Response](wireframe-images/medical-trainer-expert/expert-plan-revision-response.png)

**Caption:** Figure 28 shows how Medical Trainer/Expert responds to revision requests while approval and publication remain Platform Administrator responsibilities.

## 7. Appendix / Supporting Notes

### 7.1 Figure Numbering Note

This assembled draft uses document-wide figure numbering. Final Word/PDF formatting may require automatic numbering updates, especially if the report template inserts earlier figures before the PDD section.

### 7.2 Final Formatting Notes

- The component and class diagrams may need full-width or landscape placement in the final Word/PDF version.
- The table of contents and list of figures should be refreshed in Word/PDF before submission.
- A final spell/grammar pass should be completed before submission.
- Final assembly should preserve canonical paths under `diagrams/` and `wireframe-images/`.
- A final `git status --short` check should be clean after any later assembly edits are committed.
