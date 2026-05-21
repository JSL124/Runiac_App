# 05. Wireframe Descriptions

## 1. Source Basis And Assumptions

This section documents the existing Runiac wireframes for the Project Design Document. It is based on `wireframe.md`, the exported assets in `docs/pdd/wireframe-images/`, `PRD.md`, the component explanation in `docs/pdd/03-component-diagram.md`, and the supplied Platform Administrator and Medical Trainer/Expert wireframe plan.

The repository stores the wireframe source as `wireframe.md` and `docs/pdd/wireframe-images/` rather than `docs/wireframes/`, and the available PRD source is `PRD.md` rather than `docs/prd/Runiac_PRD.pdf`. The PRD defines use cases rather than separately numbered user stories, so this document treats the PRD use cases `UC-F1` to `UC-F10` as the related user-story references.

No redesign is proposed in this section. The descriptions explain the intent, visible elements, user flow, and system relationship of the existing wireframes. No separate image assets were found for the Platform Administrator or Medical Trainer/Expert screens, so those sections document the supplied wireframe plan at design level.

Basic and Premium access differences are treated as subscription differences controlled by `subscriptionStatus`. Operational or governance access, such as Platform Administrator moderation and expert plan publication, is treated as `userRole` behaviour rather than as a separate Basic/Premium tier. Medical Trainer/Expert is treated as an expert plan content provider, not as a direct mobile-app publisher in the MVP.

## 2. User Story Reference Key

| Reference | User-facing need represented in the PRD |
| --- | --- |
| `UC-F1` | Basic User or Premium User records running activity through GPS tracking. |
| `UC-F2` | Basic User or Premium User reviews running effects, metrics, and analysis. |
| `UC-F3` | Basic User or Premium User receives running advice and follows a scheduled plan. |
| `UC-F4` | Basic User or Premium User receives reminders for planned runs, rest, missed sessions, or streak risk. |
| `UC-F5` | Basic User or Premium User shares run achievements, leaderboard rank, or achievement cards. |
| `UC-F6` | Basic User or Premium User monitors streak and weekly consistency progress. |
| `UC-F7` | Basic User or Premium User explores, selects, saves, reports, or shares community routes. |
| `UC-F8` | Basic User or Premium User views and participates in the level-based territorial leaderboard. |
| `UC-F9` | Basic User or Premium User earns XP and progresses through runner levels. |
| `UC-F10` | Basic User or Premium User reads a beginner-friendly post-run summary, with richer AI support for Premium. |

## 2.1 Governance Wireframe Reference Key

| Reference | Governance need represented in the PDD |
| --- | --- |
| `ADM-WF1` | Platform Administrator reviews system health, pending reports, expert plan queue, and analytics from Admin Dashboard. |
| `ADM-WF2` | Platform Administrator searches, reads, updates, suspends, deactivates, or restores users through User Management. |
| `ADM-WF3` | Platform Administrator controls operational roles through User Detail / Role Control using `userRole`. |
| `ADM-WF4` | Platform Administrator reviews submitted expert plan content and decides Approve, Request Revision, or Reject. |
| `ADM-WF5` | Platform Administrator creates, reads, updates, archives, searches, and versions managed plan records. |
| `ADM-WF6` | Platform Administrator searches, hides, archives, restores, or moderates submitted and shared routes. |
| `ADM-WF7` | Platform Administrator manages notifications, reports, moderation queues, and dismissal/resolution states. |
| `EXP-WF1` | Medical Trainer/Expert (expert plan content provider) prepares and submits expert plan content for review. |
| `EXP-WF2` | Medical Trainer/Expert tracks submitted plan status and responds to requested revisions. |

## 3. Home Dashboard

**Screen name:** Basic Home Page, View Updated Home Page, Premium Home Page, Premium Updated Home Page.

**Purpose:** The Home Dashboard is the main landing screen after the user enters the application. It gives the user an immediate view of today's plan, current progress, XP, recent run feedback, and the next available action.

**Main UI elements:** The Basic Home Page contains today's plan, quick run entry, XP progress, weekly plan preview, last run summary, and a premium upgrade card. The updated home state shows completion feedback after a run. The Premium Home Page adds goal preparation progress, last-run advice, and recommended community routes while keeping the same overall dashboard role.

**User action flow:** The user opens the app and lands on Home. From here, the user can open today's plan, start a run, inspect weekly plan progress, view the last run, respond to progress updates, or follow premium route and goal-plan entries where available. After a completed run, XP and streak processing leads back to the updated home state.

**Related user stories:** `UC-F2`, `UC-F3`, `UC-F4`, `UC-F6`, `UC-F9`; Premium also relates to `UC-F7` and `UC-F10`.

**Related component:** Home Dashboard Component, Plan Component, Activity Analysis Component, XP and Streak Function, Notification Service, Explore / Route Component, Premium / Entitlement Component.

**Basic/Premium difference:** Basic shows the core plan, XP, and last-run information with a premium promotion card. Premium shows richer goal preparation, last-run advice, and recommended community route content. XP and leaderboard scoring remain the same for both Basic and Premium users.

## 4. Onboarding

**Screen name:** Onboarding and profile setup.

**Purpose:** Onboarding collects the user information required to generate safe beginner running guidance, including running experience, fitness level, personal goals, injury history, relevant health conditions, and permission choices.

**Main UI elements:** No dedicated onboarding wireframe asset was found in the provided `docs/pdd/wireframe-images/` folders. Therefore, this PDD section records onboarding only as a required PRD flow. The PRD states that onboarding must support account/profile setup and collect the health-aware information needed for training plan generation.

**User action flow:** The user creates or accesses an account, completes the profile and running background information, grants required permissions such as location and notifications, and then proceeds to the generated running plan or Home Dashboard.

**Related user stories:** `UC-F1`, `UC-F3`, `UC-F4`.

**Related component:** Auth Component, Onboarding Component, User/Profile Data Service, Plan Component, Notification Service.

**Basic/Premium difference:** No separate Basic or Premium onboarding wireframe is provided. The same profile data supports both roles. Premium status is handled by the Premium / Entitlement Component and Entitlement Service after identity and profile setup.

## 5. Plan Home

**Screen name:** Basic You Plan Page, Premium You Plan Page, View Goal Plan Journey Page.

**Purpose:** The Plan Home screens show the user's weekly training plan and plan progress. They help the user understand which sessions are planned, completed, or remaining.

**Main UI elements:** The Basic You Plan Page includes weekly preparation plan information, planned/completed/remaining counters, and day-based plan entries. It also shows the premium-only goal plan area. The Premium You Plan Page expands the plan area with goal preparation context. The View Goal Plan Journey Page shows progress through a longer milestone-oriented plan.

**User action flow:** The user opens the You or Plan area, reviews weekly progress, selects a planned day such as Tuesday, opens the plan detail, and may start a run or edit the schedule. Premium users can continue into the goal-plan journey and expert plan exploration.

**Related user stories:** `UC-F3`, `UC-F4`, `UC-F6`, `UC-F9`.

**Related component:** Plan Component, Notification Service, XP and Streak Function, Premium / Entitlement Component.

**Basic/Premium difference:** Basic supports the standard beginner weekly plan. Premium unlocks goal preparation plans and deeper journey tracking, but the plan display still supports beginner-safe progression rather than advanced athlete-only training.

## 6. Today's Plan Detail

**Screen name:** Today's Plan Page, Tuesday's Plan Detail Page, Premium Today's Plan Detail Page, View Detail of Today's Plan (Workout wise), Premium Tuesday's Plan Page.

**Purpose:** These screens provide the detailed view for a specific planned running session. They explain what the user should complete and why the session matters.

**Main UI elements:** The screens include run target, planned schedule, focus items, coach note, XP reward, guide entry, edit schedule action, and start run action. The Premium workout-wise detail view gives a more granular breakdown of the session.

**User action flow:** The user selects today's plan or a weekly plan item. The user reviews the target, reads the guidance, optionally opens a guide or workout-wise detail, edits the schedule if needed, or starts the run.

**Related user stories:** `UC-F1`, `UC-F3`, `UC-F4`, `UC-F9`.

**Related component:** Plan Component, Run Tracking Component, XP and Streak Function, Notification Service.

**Basic/Premium difference:** Basic shows the session-level plan information needed to complete the run. Premium adds richer workout guidance and more detailed goal-plan context.

## 7. Edit Schedule

**Screen name:** Edit Plan Schedule Page.

**Purpose:** Edit Schedule lets the user adjust a planned run when the original date or time is no longer suitable.

**Main UI elements:** The wireframe includes day selection, recommended or new time slots, schedule details, change reason, save action, and cancel action.

**User action flow:** The user opens a planned session, taps edit schedule, chooses a new day or time, optionally records the reason, and saves the update. The user then returns to the plan detail or plan home with the adjusted schedule.

**Related user stories:** `UC-F3`, `UC-F4`.

**Related component:** Plan Component, Notification Service.

**Basic/Premium difference:** Both Basic and Premium include schedule editing. Premium may show richer plan context, but schedule changes should still update reminders and plan adherence consistently for both user types.

## 8. Run Start

**Screen name:** Run Landing Page, Run Guide Page.

**Purpose:** Run Start prepares the user before active GPS tracking begins. It confirms the selected route or plan context and gives the user a clear start point.

**Main UI elements:** The Run Landing Page includes a selected route map, today's plan metrics, run settings, start action, and switch route action. The Run Guide Page contains pre-run and after-run guidance such as warm-up or stretching items and a confirmation action.

**User action flow:** The user enters Run from the Home Dashboard, Today's Plan Detail, or a selected route. The user checks route and plan information, opens guidance if needed, and taps start to begin live run tracking.

**Related user stories:** `UC-F1`, `UC-F3`, `UC-F7`.

**Related component:** Run Tracking Component, Plan Component, Explore / Route Component, Google Maps / Mapbox APIs.

**Basic/Premium difference:** The run start structure is similar for Basic and Premium. Premium can carry more route and goal-plan context into the start screen, but the core tracking start action remains available to both.

## 9. Live Run

**Screen name:** Run Tracking Page, Paused Run Tracking Page, Run Paused Page.

**Purpose:** Live Run supports the active running session by showing location, route progress, elapsed time, pace, distance, and run controls.

**Main UI elements:** The active tracking screens include map or route progress, elapsed time, pace, distance, and pause control. The paused state shows frozen metrics with resume and end run actions.

**User action flow:** After tapping start, the user enters active tracking. The user may pause the run, resume it, or end it. Ending the run leads into the cool-down and post-run summary flow.

**Related user stories:** `UC-F1`, `UC-F2`.

**Related component:** Run Tracking Component, Activity Analysis Component, Activity Data Service, Activity Processing Function, Google Maps / Mapbox APIs.

**Basic/Premium difference:** Both Basic and Premium require the same reliable GPS tracking experience. Premium does not change raw tracking access, but the completed activity can feed richer analysis after the run.

## 10. Run Summary And Cool Down

**Screen name:** Cool Down Landing Page, Cool Down Intro Page, Cool Down Slow Walking Tracking Page, Cool Down Stretching Tracking Page, Cool Down Completed Page, Basic Run Summary Page, Premium Run Summary Page, Premium Run Analysis Page, Share Page, View Updated XP and Streak Page.

**Purpose:** This group closes the running session, supports recovery, presents the completed activity, and shows progression updates.

**Main UI elements:** Cool-down screens include slow-walk and stretching guidance, timers, progress dots, skip or next controls, and completion confirmation. The Basic Run Summary Page includes route, distance, pace, duration, heart rate, calories, pace chart, beginner summary, premium AI lock, sharing prompt, and XP update. The Premium Run Summary Page adds advanced analysis entry and AI coaching summary. The Premium Run Analysis Page expands performance, pace, heart rate, stamina, recovery, comparison, and recommendations. The XP and streak update screen shows progression results after backend processing.

**User action flow:** The user ends a run, enters the cool-down introduction, completes slow walking and stretching steps or skips to summary, reviews the run summary, optionally shares the result, views XP and streak updates, and returns to the updated Home Dashboard.

**Related user stories:** `UC-F2`, `UC-F5`, `UC-F6`, `UC-F9`, `UC-F10`.

**Related component:** Activity Analysis Component, Run Tracking Component, XP and Streak Function, Summary Generation Function, Premium / Entitlement Component, OS Share Sheet / Social Media.

**Basic/Premium difference:** Basic receives the essential post-run metrics and beginner-friendly summary, with premium analysis visibly locked. Basic users may still use basic route sharing/upload when F7 is implemented. Premium unlocks detailed run analysis, richer AI-assisted feedback, advanced route presentation, and enhanced sharing templates.

## 11. Explore Map

**Screen name:** Maps Landing Page.

**Purpose:** Explore Map lets users discover routes and access map-based route exploration from the main navigation.

**Main UI elements:** The landing screen includes search, map preview, nearby shared routes, route cards, and entry points to the full route list or My Route area.

**User action flow:** The user opens Maps or Explore, searches or browses nearby route suggestions, selects a route card, opens the shared route detail, or navigates to the full route list or My Route screen.

**Related user stories:** `UC-F7`.

**Related component:** Explore / Route Component, Google Maps / Mapbox APIs, Geocoding / Region Mapping.

**Basic/Premium difference:** Basic can explore and select routes, and may use basic route sharing/upload when F7 is implemented. Premium has richer route management, saved-route collections, advanced filters, route comparison, and enhanced route presentation through the premium route screens.

## 12. Route List

**Screen name:** View List of Shared Route Page.

**Purpose:** Route List presents community-shared routes in a scannable list format.

**Main UI elements:** The screen includes search, filters, and route cards showing route information. It supports browsing beyond the limited nearby route preview on the map landing screen.

**User action flow:** The user opens the route list from the map landing screen, searches or filters route cards, selects a route, and moves to route detail.

**Related user stories:** `UC-F7`.

**Related component:** Explore / Route Component, Route Data Service, Google Maps / Mapbox APIs.

**Basic/Premium difference:** Basic receives the core shared route list. Premium may access richer route filtering and saved-route behavior, consistent with the PRD's premium route feature allocation.

## 13. Route Detail

**Screen name:** Basic Map Detail Page, Premium Shared Map Detail Page, Route Selected Page, Success Selecting Route Page, View Report Page, Report Shared Route Page, Premium Route Sharing Page.

**Purpose:** Route Detail helps the user inspect a selected shared route, decide whether to use it for a run, report unsafe or inappropriate content, and share a completed route when the Phase 2 route-sharing feature is implemented.

**Main UI elements:** The route detail screens show route map, distance, estimated time, difficulty, runner saves, advice, select route action, and report action. Basic route detail also includes a premium lock card for advanced route features such as saved collections and richer route tools. Route selected screens confirm that the route has been chosen and offer actions to go to run or return to explore. Report screens include selected route information, reason options, explanation text area, and report action. Route-sharing screens support publishing a completed route, with Premium receiving enhanced presentation and management options.

**User action flow:** The user selects a route from the map or route list, reviews route details, selects the route, receives confirmation, and can proceed to Run Landing. If there is a route issue, the user opens the report flow, selects a reason, and submits the report for Platform Administrator moderation. After completing a run, Basic users may submit a basic shared route when F7 is implemented, while Premium users receive richer route-sharing controls and presentation.

**Related user stories:** `UC-F1`, `UC-F5`, `UC-F7`.

**Related component:** Explore / Route Component, Run Tracking Component, Route Data Service, Google Maps / Mapbox APIs, Premium / Entitlement Component, OS Share Sheet / Social Media.

**Basic/Premium difference:** Basic can inspect, select, report, and use basic sharing for routes when F7 is implemented. Premium unlocks saved route collections, advanced filters, route comparison, enhanced route-sharing presentation, and fuller selected-route management.

## 14. My Route / Saved Route

**Screen name:** Basic My Route Page, Premium My Route Page, Premium My Route Page After Remove Route.

**Purpose:** My Route lets the user manage the currently selected route and, for Premium users, maintain saved or favorite routes.

**Main UI elements:** The Basic My Route Page shows selected route management with change or remove route actions and a premium-gated favorite route collection. The Premium My Route Page shows selected route and favorite route management. The after-remove screen shows the empty state after the selected route has been removed.

**User action flow:** The user opens My Route, reviews the selected route, changes or removes it, or starts a run using that route. Premium users can also manage saved route collections. If a route is removed, the user is shown the updated state and can return to Explore.

**Related user stories:** `UC-F1`, `UC-F7`.

**Related component:** Explore / Route Component, Run Tracking Component, Premium / Entitlement Component.

**Basic/Premium difference:** Basic supports selected-route management and shows saved collections as premium-gated. Premium supports saved or favorite routes directly and includes the route removal state.

## 15. Leaderboard

**Screen name:** Leaderboard Landing Page, Click Regional Page, Click Region Leaderboard Page, View More Leaderboard Page, View More Ranking Page, View League Page, View Tips for Leaderboard Page, Basic Share Leaderboard Page, Premium Leaderboard Ranking Sharing Page.

**Purpose:** The Leaderboard screens present level-based territorial competition, allowing users to see rankings in relevant regions and league divisions.

**Main UI elements:** The landing page includes a territorial leaderboard map, weekly/monthly XP tabs, and ranked area preview. Regional pages show the current region, top runners, user rank preview, and sharing actions. More ranking pages show expanded ranking lists and nearby user rank. League pages show available divisions. Tips explain leaderboard mechanics. Share pages generate a rank card for external sharing.

**User action flow:** The user opens Leaderboard, selects or zooms into a region, views regional rankings, expands the ranking list, checks league divisions, reads leaderboard tips, and optionally shares their rank.

**Related user stories:** `UC-F5`, `UC-F8`, `UC-F9`.

**Related component:** Leaderboard Component, Leaderboard Aggregation Function, XP and Streak Function, Google Maps / Mapbox APIs, Premium / Entitlement Component, OS Share Sheet / Social Media.

**Basic/Premium difference:** Ranking access must remain fair for both Basic and Premium users. Basic can participate in leaderboard views and basic sharing. Premium unlocks richer visual sharing templates and presentation, but does not receive extra XP, ranking boost, or competitive information advantage.

## 16. Profile

**Screen name:** Basic You Page, Premium You Landing Page.

**Purpose:** Profile gives the user a personal progress view, including habit, history, level, and plan-related entry points.

**Main UI elements:** The Basic You Page includes streak, consistency streak, running calendar, recent running history, and runner level. The Premium You Landing Page keeps the progress landing role while adding richer Premium entry points.

**User action flow:** The user opens You, checks streak and calendar progress, reviews recent runs, opens a recent run summary, enters the plan page, or follows level and league-related links.

**Related user stories:** `UC-F2`, `UC-F3`, `UC-F6`, `UC-F8`, `UC-F9`.

**Related component:** Profile Component, Activity Analysis Component, Plan Component, XP and Streak Function, Leaderboard Component.

**Basic/Premium difference:** Basic focuses on core progress visibility and recent activity history. Premium adds deeper plan and goal journey access while preserving the same personal progress function.

## 17. Premium Expert Plan Screens

**Screen name:** Explore Expert Goal Plan Page, View Expert Plan Detail Page, View Goal Plan Journey Page, Premium You Plan Page.

**Purpose:** These Premium screens support milestone-oriented preparation plans for users who want more structured guidance beyond the basic weekly plan. They show only expert plans that have been reviewed, approved, and published by the Platform Administrator.

**Main UI elements:** The expert plan screens include expert plan discovery, selected published plan detail, goal preparation journey, and premium plan progress context. Draft, under-review, revision-required, or archived expert plans must not appear in these Premium User screens. The exact visual layout should remain as shown in the provided premium wireframes.

**User action flow:** The Premium User opens the premium plan area, explores available published expert goal plans, views details for a selected published plan, and follows the goal-plan journey from the plan home. The flow returns to the Premium You Plan Page or Home after the user reviews progress. Premium Users consume approved and published expert plan content only; they do not see the expert submission or admin review workflow.

**Related user stories:** `UC-F2`, `UC-F3`, `UC-F4`.

**Related component:** Plan Component, Activity Analysis Component, Premium / Entitlement Component, Notification Service, Admin Expert Plan Management. The Medical Trainer/Expert is a content provider for expert plan material. The Platform Administrator reviews and publishes expert plans before they become visible to Premium Users.

**Basic/Premium difference:** These screens are Premium-only and show published expert plans only. Basic users see the standard weekly plan and upgrade prompts rather than the expert goal plan flow.

**Admin and expert workflow note:** Premium expert plan content depends on a governed review flow. Medical Trainer/Expert prepares expert plan content for review, while Platform Administrator reviews, approves, publishes, updates, and archives expert plans. Premium Users can view or select only expert plans that are both approved and published.

## 18. Subscription And Upgrade

**Screen name:** Upgrade To Premium Page.

**Purpose:** The upgrade screen explains the Premium value proposition when a Basic User attempts to access premium-only plan, analysis, route-management, or enhanced sharing-presentation features.

**Main UI elements:** The screen presents premium benefits such as coach-verified plans, advanced analytics, AI coaching, advanced route filters, saved route collections, route comparison, enhanced route-sharing presentation, and enhanced rank sharing.

**User action flow:** The Basic User taps a premium-gated card or action, reviews the upgrade screen, and decides whether to upgrade or return to the previous Basic flow.

**Related user stories:** `UC-F2`, `UC-F3`, `UC-F5`, `UC-F7`, `UC-F10`.

**Related component:** Premium / Entitlement Component.

**Basic/Premium difference:** Basic users see this screen when attempting to access premium-only features. Premium users should pass entitlement checks and proceed directly to the unlocked feature.

## 19. Platform Administrator Wireframes

The Platform Administrator wireframes describe the restricted governance area of Runiac. Platform Administrator is the main system governance role and has CRUDS responsibilities: Create, Read, Update, Delete/Archive/Suspend, and Search. Delete-style actions should normally be represented as soft governance actions such as Archive, Hide, Suspend, Deactivate, Reject, or Dismiss.

Operational access is controlled by `userRole`. Basic/Premium feature access is controlled separately by `subscriptionStatus`. Basic User and Premium User must not be represented as separate account classes in the admin wireframes.

### 19.1 Admin Dashboard

**Screen name:** Admin Dashboard.

**Purpose:** Provides an overview of system status and pending administrative tasks.

**Main UI elements:** Total users, Premium users, active basic users, pending expert plans, published expert plans, reported routes, pending reports, active notifications, recent activity, quick actions, and sidebar navigation. Quick actions include Manage Users, Review Expert Plans, Manage Plans, Manage Shared Routes, Send Notification, and View Reports.

**User action flow:** The Platform Administrator opens the restricted dashboard, reviews operational counts and pending queues, then uses quick actions or sidebar navigation to enter the relevant management area. The dashboard acts as the entry point for user governance, expert plan review, route moderation, notifications, and reports.

**Related governance references:** `ADM-WF1`.

**Related component:** Auth Component, User/Profile Data Service, Plan Data Service, Admin Expert Plan Management, Route Data Service, Notification Service, Report Moderation.

**Access and calculation rules:** Dashboard access is based on `userRole = Platform Administrator`. Any displayed XP, leaderboard, or activity statistics are read-only summaries produced by backend processing or stored system records.

### 19.2 User Management

**Screen name:** User Management.

**Purpose:** Allows the administrator to search, view, and manage user accounts.

**Main UI elements:** Search by name, email, or user ID; filters for `subscriptionStatus`, `userRole`, `accountStatus`, joined date, and last active; user table with name, email, `subscriptionStatus`, `userRole`, account status, and last active; actions for View, Edit, and Suspend.

**User action flow:** The Platform Administrator searches or filters the account list, selects a user row, opens the user detail view, edits allowed governance fields, or suspends an account if moderation or safety action is required.

**Related governance references:** `ADM-WF2`.

**Related component:** Auth Component, User/Profile Data Service, Premium / Entitlement Component.

**Basic/Premium difference:** Basic and Premium are shown through `subscriptionStatus`, not through separate user account classes. Role-based access is shown through `userRole`, with values such as User, Platform Administrator, and Medical Trainer/Expert.

### 19.3 User Detail / Role Control

**Screen name:** User Detail / Role Control.

**Purpose:** Allows the administrator to inspect one user and manage access or moderation status.

**Main UI elements:** User profile, `subscriptionStatus`, `userRole`, `accountStatus`, joined date, last active, running summary, total activities, total distance, level, total XP, streak, registered leaderboard area, report count, admin notes, and actions to update role, update account status, suspend/reactivate account, and add admin note.

**User action flow:** The Platform Administrator opens a user profile from User Management, reviews account and activity context, updates allowed governance fields such as `userRole` or `accountStatus`, adds an admin note, or suspends/reactivates the account. The administrator can inspect progression information for support or moderation context but cannot edit it.

**Related governance references:** `ADM-WF3`.

**Related component:** User/Profile Data Service, Premium / Entitlement Component, Activity Analysis Component, XP and Streak Function, Leaderboard Aggregation Function, Report Moderation.

**Access and calculation rules:** XP, level, streak, rank, leaderboard area, leaderboard score, weekly XP, and monthly XP must be read-only system-calculated fields. The admin wireframe must not include controls for directly editing XP, level, streak, rank, or leaderboard score.

### 19.4 Expert Plan Review

**Screen name:** Expert Plan Review.

**Purpose:** Allows the Platform Administrator to review expert-submitted plans before publication.

**Main UI elements:** Plan title, goal distance, duration, difficulty, runs per week, provider information, qualification summary, target beginner profile, weekly schedule, warm-up/cool-down notes, safety notes, beginner suitability checklist, admin review checklist, admin comment field, and actions for Approve, Request Revision, Reject, Publish Approved Plan, and Archive.

**User action flow:** The Platform Administrator opens a submitted expert plan, checks the provider information and plan structure, reviews beginner suitability and safety notes, records review comments, then approves, requests revision, or rejects the submission. After approval, the administrator may publish the approved plan so it becomes visible to Premium Users.

**Related governance references:** `ADM-WF4`, `EXP-WF1`, `EXP-WF2`.

**Related component:** Admin Expert Plan Management, Plan Data Service, Premium / Entitlement Component, User/Profile Data Service.

**Access and publication rules:** Medical Trainer/Expert does not publish expert plans. Platform Administrator publishes only after review and approval. Premium Users can view/select only approved and published expert plans.

### 19.5 Plan Management

**Screen name:** Plan Management.

**Purpose:** Allows the administrator to manage Runiac system goal plans and approved expert plans.

**Main UI elements:** Search and filter plans; plan list with title, goal, duration, difficulty, status, and last updated; Create New System Plan action; View Plan action; Edit Plan action; Archive Plan action. System plans and expert plans should be visually distinguishable.

**User action flow:** The Platform Administrator searches or filters the plan list, opens a plan, creates or edits a system plan, updates eligible approved expert-plan metadata, or archives a plan that should no longer be available. Expert plan status should support lifecycle values such as Submitted, Pending Review, Revision Requested, Approved, Published, Archived, and Rejected.

**Related governance references:** `ADM-WF5`.

**Related component:** Plan Component, Plan Data Service, Admin Expert Plan Management, Premium / Entitlement Component.

**Basic/Premium difference:** Standard system plans support the core running-plan experience. Premium expert plans are available only when `subscriptionStatus` permits access and the plan is approved and published. Premium plans must not create XP or leaderboard advantages.

### 19.6 Route Management

**Screen name:** Route Management.

**Purpose:** Allows the administrator to review and moderate shared routes.

**Main UI elements:** Search by route name, location, creator, difficulty, or report status; route table with route name, creator, location, distance, difficulty, visibility, favourite count, report count, and status; map preview; actions for View, Hide, Archive, and Mark as Reviewed.

**User action flow:** The Platform Administrator searches or filters shared routes, opens a reported or suspicious route, checks the map preview and report context, then hides, archives, or marks the route as reviewed. Route moderation decisions focus on safety, privacy, and content quality.

**Related governance references:** `ADM-WF6`.

**Related component:** Explore / Route Component, Route Data Service, Google Maps / Mapbox APIs, Report Moderation.

**Basic/Premium difference:** Route management is for moderation and safety. It must not provide Premium Users with XP, rank, leaderboard score, or competitive advantages.

### 19.7 Notification / Report Management

**Screen name:** Notification / Report Management.

**Purpose:** Allows the administrator to create system notifications and handle reports or moderation cases.

**Main UI elements:** Notification section with notification title, message body, target audience, notification type, send now/schedule control, and notification history. Report section with report type, reported item, reported by, reason, status, admin decision, and actions for Resolve, Dismiss, Hide Route, Suspend User, and Archive Content.

**User action flow:** For notifications, the Platform Administrator drafts a message, selects target audience and notification type, then sends or schedules the notification. For reports, the administrator searches the report queue, reviews the reported item and reason, records a decision, and applies the appropriate soft moderation action.

**Related governance references:** `ADM-WF7`.

**Related component:** Notification Service, Firebase Cloud Messaging, Report Moderation, Route Data Service, User/Profile Data Service.

**Access and moderation rules:** Report actions should preserve moderation history. Dismiss, Hide Route, Suspend User, and Archive Content are preferred over hard deletion so the system remains auditable.

## 20. Medical Trainer/Expert Wireframes

Medical Trainer/Expert is an expert plan content provider in the MVP. This role can prepare structured expert plan material for administrative review, but it must not directly publish expert plans or directly write published plan records into Firebase. Governance access is controlled by `userRole`.

### 20.1 Expert Plan Submission Form

**Screen name:** Expert Plan Submission Form.

**Purpose:** Allows Medical Trainer/Expert to prepare structured expert plan content for admin review.

**Main UI elements:** Expert name, qualification, organisation, experience summary, plan title, goal distance, duration, difficulty, target user type, runs per week, plan description, expected outcome, weekly plan builder, warm-up instruction, cool-down instruction, rest day guidance, safety notes, injury prevention notes, medical disclaimer, Save Draft button, and Submit for Admin Review button.

**User action flow:** The Medical Trainer/Expert enters credential information and plan content, saves the submission as a draft if incomplete, or submits it for Platform Administrator review. Submission moves the content into the admin review queue; it does not publish the plan to Premium Users.

**Related governance references:** `EXP-WF1`, `ADM-WF4`.

**Related component:** Admin Expert Plan Management, Plan Data Service, User/Profile Data Service.

**Access and publication rules:** The form must not include a Publish Plan button. It must not imply direct database publication into the live Premium plan catalogue. The output is draft/submitted expert plan content awaiting Platform Administrator review.

### 20.2 Submitted Plan Status Page

**Screen name:** Submitted Plan Status Page.

**Purpose:** Allows Medical Trainer/Expert to view the review status of submitted plans and respond to revision requests.

**Main UI elements:** Submitted plan list, plan title, goal distance, submitted date, current status, admin comment, last updated, and actions for View Submission, Edit Draft, Respond to Revision, and Resubmit for Review. Status values should include Draft, Submitted, Pending Admin Review, Revision Requested, Approved, Published, Rejected, and Archived.

**User action flow:** The Medical Trainer/Expert opens the submitted plan list, checks the current status and admin comment, edits a draft, responds to revision feedback, or resubmits a revised plan. Approved or published status can be viewed, but publishing remains an administrator action.

**Related governance references:** `EXP-WF2`, `ADM-WF4`.

**Related component:** Admin Expert Plan Management, Plan Data Service, User/Profile Data Service.

**Access and publication rules:** Medical Trainer/Expert can view statuses and respond to revision requests only for their own submissions. They cannot approve, publish, update published catalogue records, or archive published expert plans.

## 21. Expert Plan Governance Flow

The expert plan governance flow is:

1. Medical Trainer/Expert submits plan content.
2. Platform Administrator reviews the submission.
3. Platform Administrator approves, requests revision, or rejects the submission.
4. Approved plans can be published by the Platform Administrator.
5. Premium Users can view/select only approved and published expert plans.

This flow separates content preparation from system publication. It keeps Medical Trainer/Expert as a specialist content provider, keeps Platform Administrator as the governance authority, and ensures Premium Users only consume reviewed content. It also preserves the architecture rule that premium functionality is controlled through `subscriptionStatus`, while operational governance is controlled through `userRole`.

## 22. MVP And Future Scope Notes

The MVP-focused user-facing wireframes are Home Dashboard, Onboarding, Plan Home, Today's Plan Detail, Edit Schedule, Run Start, Live Run, Run Summary, and Profile. These support activity tracking, basic analysis, beginner training plans, reminders, streak tracking, and XP progression.

Route sharing, territorial leaderboard, AI-assisted summaries, premium expert plans, Platform Administrator screens, Medical Trainer/Expert submission screens, and premium sharing visuals are documented because they are present in the wireframes, PRD, or supplied PDD wireframe plan, but they may be treated as Phase 2, premium, or governance extensions depending on final FYP scope. When F7 is implemented, Basic users can use basic route viewing, selection, reporting, and route sharing/upload; Premium adds advanced filters, saved collections, route comparison, and enhanced presentation. The design rule remains that the client displays XP, streak, level, rank, and leaderboard values after backend processing; it does not directly calculate or write those trusted values. Admin screens can view these values as read-only system outputs only.
