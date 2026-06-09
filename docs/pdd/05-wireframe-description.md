# 05. Wireframe Descriptions

## 1. Source Basis And Assumptions

This section documents the existing Runiac wireframes for the Project Design Document. It is based on `wireframe.md`, the exported assets in `docs/pdd/wireframe-images/`, `PRD.md`, the component explanation in `docs/pdd/03-component-diagram.md`, and the supplied Platform Administrator and Medical Trainer/Expert wireframe plan.

The repository stores the wireframe source as `wireframe.md` and `docs/pdd/wireframe-images/` rather than `docs/wireframes/`, and the available PRD source is `PRD.md` rather than `docs/prd/Runiac_PRD.pdf`. The PRD defines use cases rather than separately numbered user stories, so this document treats the PRD use cases `UC-F1` to `UC-F10` as the related user-story references.

No redesign is proposed in this section. The descriptions explain the intent, visible elements, user flow, and system relationship of the existing wireframes. The current repository includes Basic User and Premium User mobile wireframe assets under `docs/pdd/wireframe-images/mobile-user/`, including the canonical 13-page onboarding flow under `docs/pdd/wireframe-images/mobile-user/shared/onboarding/`.

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

## 2.2 Basic And Premium Mobile Wireframe Coverage

The Basic User wireframes cover the beginner habit-formation journey from Home, plan review, run start, live tracking, cool-down, run summary, XP/streak feedback, Explore, Leaderboard, and Profile. These screens keep the core running experience available to Basic Users: GPS tracking, weekly beginner plans, reminders, streak visibility, XP display, profile history, and fair leaderboard participation where the Phase 2 leaderboard is included.

The Premium User wireframes keep the same mobile navigation structure and add deeper support around goal preparation, expert verified plans, advanced analytics, LLM-enhanced post-run summaries, saved routes, advanced route presentation, and enhanced sharing/status visuals. Premium screens must add interpretation, planning depth, convenience, or presentation value without changing XP, level, streak, rank, leaderboard score, weekly XP, or monthly XP outcomes.

Shared mobile screens should be read as common Basic/Premium user experiences unless a screen explicitly shows a locked Premium state or Premium-only enhancement. The existing images are treated as reusable PDD assets; this documentation clarification does not require mobile image regeneration.

| Coverage area | Basic User coverage | Premium User coverage | PDD image status |
| --- | --- | --- | --- |
| Onboarding / Profile Setup | Shared first-time setup for running goal, current running level, preferred schedule, session cautiousness, and health/safety readiness prompts. These answers initialise the user's first beginner running plan rather than acting as cosmetic profile fields. | Same setup; Premium access is checked later through `subscriptionStatus`. Premium expert-plan access remains separate from the Basic onboarding plan. | Canonical 13-page onboarding image set. |
| Home and plan entry | Daily plan, quick run action, XP progress, weekly plan preview, last-run summary, Premium upgrade entry. | Goal progress, richer last-run advice, recommended route content, Premium plan entry. | Existing images. |
| Plan detail and schedule | Standard weekly beginner plan, today's plan detail, edit schedule, start run. | Workout-wise detail, goal plan journey, expert plan discovery/detail, edit schedule. | Existing images. |
| Run and recovery | Run landing, guide, live tracking, pause/end, cool-down, summary, XP/streak update. | Same run spine with Premium summary and advanced analysis after completion. | Existing images. |
| Explore and routes | Map landing, shared route list, route detail, route selection, report route, basic selected-route management. | Advanced route detail, saved/favourite route management, route sharing presentation, route removal state. | Existing images. |
| Leaderboard and sharing | Territorial leaderboard map, regional rankings, league view, basic rank sharing. | Same fair ranking data plus leaderboard tips and enhanced visual share templates. | Existing images. |
| Profile / You | Streak, calendar, recent run history, runner level, plan entry. | Same progress role with Premium plan and goal-journey entry points. | Existing images. |

## 2.3 Basic And Premium Difference Boundary

Basic should remain a complete beginner running habit product. The wireframes should not lock GPS tracking, weekly beginner plans, reminders, streak progress, XP visibility, basic activity summaries, or fair leaderboard participation behind Premium. Premium adds value through advanced analytics, goal-based or adaptive plan experiences, approved/published expert plans, saved routes, richer route tools, enhanced post-run summaries, and improved sharing/status presentation.

Premium differences are fair only when they do not affect competitive outcomes. Premium Users must not receive extra XP, rank boosts, leaderboard score advantages, exclusive ranking data that changes competition, or client-side calculation privileges. Basic/Premium access is represented through `subscriptionStatus`; it must not be modelled as separate Basic User and Premium User subclasses.

The Flutter client may display XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP after backend processing, but it must not calculate, edit, or directly write those trusted progression or ranking values. Locked and upgrade screens should therefore describe Premium as deeper analytics, adaptive or goal-based planning, approved expert plan access, route convenience, and presentation/sharing value, not as a competitive advantage.

## 2.4 Mobile User Flow Coverage

The first-time Basic User flow is: Onboarding / Profile Setup -> Home Dashboard -> Today's Plan Detail -> Run Guide -> Run Landing -> Live Run -> Paused Run or End Run -> Cool Down -> Basic Run Summary -> XP and Streak Update -> Updated Home Dashboard. This flow should keep one clear next action at each step so beginner runners are not forced through deep configuration before their first run.

The Basic route and leaderboard flow is: Explore Map -> Route List or Route Detail -> Route Selected -> Run Landing, and separately Leaderboard Landing -> Regional Leaderboard -> More Ranking or League View -> optional Basic Share Leaderboard. Route selection should return clearly to either Run Landing or Explore, and leaderboard sharing should remain optional.

The Premium expert plan flow is: Premium Home or Plan -> Premium You Plan -> Explore Expert Goal Plan -> View Expert Plan Detail -> View Goal Plan Journey -> Premium Plan/Home. Premium Users must only see expert plans that are approved and published by the Platform Administrator.

The Premium post-run analysis flow is: Run Landing -> Live Run -> Paused Run or End Run -> Cool Down -> Premium Run Summary -> Premium Run Analysis -> XP and Streak Update -> Premium Updated Home. Advanced analysis should be available after the basic completion summary so the post-run result remains understandable.

Premium sharing and saving flows are optional branches from Premium Run Summary, Premium Route Detail, Premium My Route, and Premium Leaderboard Ranking Sharing. These flows should include privacy confirmation when route or location information may be exposed externally.

Route and GPS data are sensitive user data. Route sharing should ask for explicit confirmation and use privacy-aware wording, such as masking or avoiding unnecessary precise exposure of start/end locations where appropriate. Reported routes should enter Platform Administrator moderation rather than being handled as direct user-to-user disputes.

## 2.5 State Coverage Notes

Most state screens can be documented as notes in the PDD rather than generated as separate figures. Separate images should be added only when a state is central to the user flow or likely to confuse assessment readers.

| State | Relevant wireframe area | Documentation expectation |
| --- | --- | --- |
| Empty state | Profile history, saved routes, expert plan catalogue, leaderboard rank. | Explain the expected empty message and recovery action. |
| Loading state | Home, plan detail, route list, leaderboard, post-run summary, expert plans. | Note that loading should preserve navigation and avoid duplicate actions. |
| Error state | Schedule save, route/report submission, activity sync, summary generation. | Provide recoverable actions such as retry, cancel, or return. |
| Permission denied | Run Landing, Explore Map, notification setup. | Explain why permission is needed and provide settings/retry path. Location permission should be requested when the user starts a run or uses route features rather than forced during onboarding. |
| GPS unavailable | Run Landing and Live Run. | Keep activity controls safe; avoid awarding trusted progression until validation succeeds. |
| Location permission denied | Explore, Run, Leaderboard map. | Provide non-map fallback text where possible. |
| Network unavailable | Activity upload, route list, leaderboard, summary loading. | Support local run recording and later sync where applicable. |
| No route found | Explore Map and Route List. | Suggest widening search or returning to Explore; do not invent route recommendations outside PRD scope. |
| No plan selected | Home, Plan, Run Landing. | Direct user to onboarding/profile setup or plan selection. |
| Subscription locked | Expert plans, advanced analytics, saved routes, enhanced sharing. | Use clear Premium value messaging and allow return to the Basic flow. |
| Route privacy/restricted | Route detail, route sharing, social sharing. | Confirm before exposing route data and mask sensitive start/end locations where relevant. |

## 2.6 UI/UX And Accessibility Design-Level Notes

The mobile wireframes should use Material Design 3 / Flutter-compatible layout conventions at a PDD level: consistent top app structure, a persistent five-tab bottom navigation after onboarding, profile/settings access through the profile circle, clear card grouping, and consistent CTA wording such as Start Run, View Plan, Save Schedule, Resume, End Run, Share, and Upgrade.

For beginner usability, each screen should make the next action visible without requiring the user to understand the full app structure. Locked Premium cards should explain the additional value without making the Basic path feel blocked. Map-heavy screens should include textual route cards or ranking summaries so the user is not dependent on map interpretation alone.

Accessibility notes are design-level only and are not a WCAG compliance claim. The wireframes should account for readable text, tappable target awareness, non-colour-only indicators, labelled controls, screen-reader-friendly semantics where later implemented in Flutter, and recoverable errors. Error and permission states should explain what happened and how the user can continue.

## 2.7 Figure Grouping Guidance

For final PDD insertion, repeated Basic/Premium variants should be grouped into thematic figures instead of shown as isolated screens one by one. Recommended groups are Home Dashboard, Onboarding / Profile Setup, Plan Home and Today's Plan Detail, Edit Schedule, Run Start and Live Run, Cool Down and Run Summary, Explore Map and Route List, Route Detail and My Route, Leaderboard, Profile / You, and Premium Expert Plan Access. Onboarding / Profile Setup uses the canonical 13-page onboarding image sequence under `docs/pdd/wireframe-images/mobile-user/shared/onboarding/`; the other groups can reuse existing exported assets.

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

**Purpose:** Onboarding collects the user information required to initialise the user's first beginner running plan, including running goal, current running level, preferred schedule, session cautiousness, and relevant health/safety readiness prompts. Each question has a plan-generation purpose that affects schedule, intensity, duration, safety/cautiousness, motivation style, or route context.

**Main UI elements:** The onboarding flow uses a 13-page one-question-per-screen structure: Welcome / Setup Intro, Main Goal, Current Running Level, Weekly Availability, Preferred Running Days, Preferred Running Time, Session Length, Running Place, Motivation Style, Health Condition, Symptoms During Physical Activity, Plan Cautiousness, and Plan Preview / Confirmation. The canonical images are stored under `docs/pdd/wireframe-images/mobile-user/shared/onboarding/`.

**User action flow:** The user creates or accesses an account, answers the onboarding questions, reviews the generated beginner plan preview, confirms the plan, and then proceeds to the generated running plan or Home Dashboard. Location permission should be requested later when starting a run or using route features, not forced during onboarding.

**Health and safety note:** The health/safety questions are design-level readiness prompts inspired by common physical activity readiness screening principles. They help guide plan cautiousness and safety messaging only; they do not diagnose, treat, provide medical advice, clear users for exercise, or claim clinical compliance. Users with pain, symptoms, or health concerns should be advised to speak to a healthcare professional before starting or increasing exercise.

**Onboarding input-to-plan mapping:**

| Onboarding question | Conceptual planning input | Generated plan effect | Fallback/default | Safety boundary |
| --- | --- | --- | --- | --- |
| Main Goal | Goal type / progression target | Sets the plan goal label and target progression, such as habit building, first 5K base, 10K preparation starter, or stamina support. | Build habit. | A 10K goal should start with a base or 5K-style plan when the user is completely new. |
| Current Running Level | Starting difficulty | Sets the starting week difficulty and run/walk ratio. | New runner. | Unknown or low confidence starts conservatively. |
| Weekly Availability | Weekly run count | Sets the number of planned runs per week. | Three days, or two days if caution exists. | Avoids overloading beginners and preserves rest days where possible. |
| Preferred Running Days | Schedule and rest-day placement | Places planned sessions and spaces rest days. | Auto-spaced days. | Rest-day spacing should override crowded preferences. |
| Preferred Running Time | Reminder/display time | Sets reminder and schedule display timing. | Flexible. | Does not affect plan intensity. |
| Session Length | Duration cap | Caps initial workout length. | 20 minutes, or 15 minutes if caution exists. | Duration is reduced when health/safety answers indicate caution. |
| Running Place | Route/context note | Adds context for treadmill, road, track, park, or mixed running. | Mixed. | Does not request location permission during onboarding. |
| Motivation Style | Coaching/reminder/advice tone | Adjusts motivational wording, reminder tone, or UI emphasis. | Clear weekly plan. | Must not increase intensity for leaderboard- or XP-oriented users. |
| Health Condition | Caution flag | Selects safety messaging and a more cautious starting plan when needed. | Conservative if skipped. | Readiness signal only; no diagnosis, treatment, or exercise clearance. |
| Symptoms During Physical Activity | Strong caution flag | Triggers stronger caution messaging and a conservative starting plan. | Conservative if skipped. | Recommends speaking to a healthcare professional when symptoms or concerns exist. |
| Plan Cautiousness | Final intensity adjustment | Applies final gentle, balanced, or normal beginner intensity adjustment. | Balanced, or gentle if health/safety caution exists. | Safety/caution signals override a normal-plan preference. |

**Initial plan templates:**

| Template | When selected | Weekly structure | Session style | Duration range | Plan preview text |
| --- | --- | --- | --- | --- | --- |
| Very Gentle Start | Complete beginners, users with health/safety concern, users with concerning symptoms, skipped health/safety answers, or users choosing very cautious progression. | Two to three sessions per week with rest days between sessions where possible. | Walk-first or short run/walk progression. | 15-20 minutes. | `2-3 runs/week · walk-first intervals · gentle progression`. |
| Balanced Beginner Plan | Default for most beginner users without strong caution signals. | Around three runs per week if availability allows, with rest days between runs where possible. | Beginner run/walk intervals with gradual progression. | 20-30 minutes. | `3 runs/week · run/walk intervals · 20 min/session`. |
| Confidence Builder / First 5K Prep | Users who can already walk/run and select first 5K or stamina goals. | Three runs per week with spaced sessions. | Longer run/walk blocks progressing toward more continuous running. | 25-35 minutes. | `3 runs/week · longer run/walk blocks · 5K base`. |
| 10K Preparation Starter | Users selecting 10K whose current level and availability support longer preparation. | Three to four sessions per week only when suitable. | Base-building before 10K progression. | 30-45 minutes. | `Base phase first · 10K goal later`. |

**Conflict and fallback rules:**

| Situation | Planning behaviour |
| --- | --- |
| User chooses four days per week but selects only two preferred days. | Schedule the two chosen days and suggest adding one or two flexible days. |
| User chooses two days per week but selects five preferred days. | Choose the two best-spaced days and keep the others as alternatives. |
| Weekly availability is Not sure. | Default to three days, or two days if a health/safety concern exists. |
| Session length is Not sure. | Default to 20 minutes, or 15 minutes if caution exists. |
| 10K goal plus completely new current level. | Start with a Balanced Beginner or First 5K base before 10K progression. |
| Leaderboard challenge plus new runner or safety concern. | Keep leaderboard as motivation only; do not increase intensity. |
| Expert guidance plus Basic User. | Show the standard beginner plan. Premium expert plans remain a separate Premium feature. |
| User selects Set up later. | Create a conservative default starter plan. |
| User skips health/safety pages. | Default to a conservative plan. |
| User selects a health condition concern. | Use Very Gentle Start or a reduced Balanced Beginner Plan with safety messaging. |
| User selects concerning symptoms. | Show a cautious plan suggestion and recommend speaking to a healthcare professional before starting or increasing exercise. |
| User selects normal beginner plan but health/safety answers indicate caution. | Safety overrides the normal preference; use Very Gentle Start or a reduced Balanced Beginner Plan. |

**Plan Preview expectation:** The final onboarding page should show the selected goal, current level, weekly schedule, session length, suggested starting plan, first-week preview, and safety/cautiousness setting. Example preview text: `Suggested Starting Plan: 3 runs/week · run/walk intervals · 20 min/session`; `First Week Preview: Run 1: Walk/run intervals; Run 2: Easy run/walk; Run 3: Confidence run`. If safety concerns exist, the preview should state that a very gentle start is recommended and advise the user to speak to a healthcare professional before starting or increasing exercise if they have symptoms or health concerns.

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

**Progression boundary:** XP, streak, level, rank, weekly XP, monthly XP, and leaderboard-related values shown in the summary or XP update screens are backend-owned outputs. The mobile interface displays the results after processing; it must not calculate, edit, or directly write those values.

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

**Purpose:** Route Detail helps the user inspect a selected shared route, decide whether to use it for a future run, report unsafe or inappropriate content, and share route information when the Phase 2 route-sharing feature is implemented. The screen should support beginner confidence by separating social appreciation, personal saving, and actual next-run route selection into distinct actions.

**Main UI elements:** The route detail screens show the route map preview, distance, estimated time, difficulty, route tags such as Easy or Loop, elevation chart, runner notes, compact Like count, Bookmark Save action, Select Route action, share action, and report action. The compact Like row sits below the route title and displays only a heart icon plus numeric count, such as `♡ 128`, without an additional Likes label. The Like heart should be visually clear at 22-24 px and should have a design-level tappable area of at least 44 x 44 px. The unliked state uses an outline heart, while the liked state uses a filled heart and the route accent colour.

**Route action model:** Like, Bookmark Save, and Select Route have separate meanings. Like records social appreciation for the shared route and must not create a saved route. Bookmark Save records the user's personal saved/bookmarked route state and must not increment the like count. Select Route starts the route-selection flow and must not immediately change the user's next-run route without confirmation. The bottom action area should therefore contain an icon-only Bookmark Save button with the semantic label `Save route` and a large primary `Select Route` button. Premium users may receive richer saved-route collection management elsewhere, but route liking, saving, and selection must not create XP, rank, leaderboard, subscription, or entitlement advantages.

**Select Route confirmation flow:** When the user taps `Select Route`, the app should open a confirmation step instead of selecting the route immediately. The confirmation view should show the route name, distance, estimated time, difficulty, route type or tag, a runner-notes or safety summary sourced from the route notes, and the actions `Cancel` and `Confirm Route`. The summary should be concise, with a maximum of 140 characters when notes are shortened. If another route is already selected for the next run, the confirmation flow should show the warning `This will replace your current selected route.` and require an explicit proceed action before replacement.

**Saving and success states:** During `Confirm Route` persistence, the screen should show a full-screen dim overlay with a centred loading card using the exact copy `Setting up your next run...`. Successful confirmation saves the route as a planned route and sets it as the selected route for the next run-start flow. The success state should show the title `Route selected`, the body `This route has been saved and set for your next run.`, and the actions `Start Run`, `View Planned Routes`, and `Stay Here`. If the user chooses `Stay Here`, the detail page returns with the primary button still labelled `Select Route` but disabled, with no additional selected-state message such as `Selected for your next run`. The Bookmark Save control should show the saved/bookmarked state after successful confirmation because the route has been saved as a planned route.

**Failure and recovery states:** Failed confirmation must not save the planned route and must not set the selected next-run route. The `Confirm Route` action should return to a retryable state after failure. If the user is not signed in, the route-selection failure copy should be `Sign in to select this route.` with a `Sign In` action. If the user is offline, the copy should be `You seem to be offline. Try again when you're connected.` with a `Try Again` action. If Firestore persistence fails, the copy should be `We couldn't select this route. Please try again.` with a `Try Again` action. Like count may update optimistically only if the design also states that the previous like count and liked state are restored when persistence fails.

**User action flow:** The user selects a route from the map or route list, reviews route details, optionally likes or bookmarks the route, taps `Select Route`, confirms the route, sees saving feedback, and then chooses whether to start a run, view planned routes, or stay on the detail page. If there is a route issue, the user opens the report flow, selects a reason, and submits the report for Platform Administrator moderation. After completing a run, Basic users may submit a basic shared route when F7 is implemented, while Premium users receive richer route-sharing controls and presentation.

**Share, privacy, and moderation note:** The share icon should share the route name, distance, and route link. Route sharing should require user confirmation before publishing or externally sharing route information. Where appropriate, the interface should avoid unnecessary precise exposure of private route details, and reported routes should be reviewed through Platform Administrator moderation. Route, user, profile, GPS route, activity, and running-metric data are sensitive user data. Route-selection persistence should write only planned-route and selected next-run route fields, and must not write entitlement, subscription, XP, streak, level, rank, leaderboard, weekly XP, monthly XP, or other competitive fields.

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

**Entitlement and privacy note:** Saved/favourite route collections are Premium convenience features controlled by `subscriptionStatus`. They must not affect XP, rank, leaderboard score, weekly XP, or monthly XP, and route-management screens should continue to treat GPS route data as sensitive.

## 15. Leaderboard

**Screen name:** Leaderboard Landing Page, Click Regional Page, Click Region Leaderboard Page, View More Leaderboard Page, View More Ranking Page, View League Page, View Tips for Leaderboard Page, Basic Share Leaderboard Page, Premium Leaderboard Ranking Sharing Page.

**Purpose:** The Leaderboard screens present level-based territorial competition, allowing users to see rankings in relevant regions and league divisions.

**Main UI elements:** The landing page includes a territorial leaderboard map, weekly/monthly XP tabs, and ranked area preview. Regional pages show the current region, top runners, user rank preview, and sharing actions. More ranking pages show expanded ranking lists and nearby user rank. League pages show available divisions. Tips explain leaderboard mechanics. Share pages generate a rank card for external sharing.

**User action flow:** The user opens Leaderboard, selects or zooms into a region, views regional rankings, expands the ranking list, checks league divisions, reads leaderboard tips, and optionally shares their rank.

**Related user stories:** `UC-F5`, `UC-F8`, `UC-F9`.

**Related component:** Leaderboard Component, Leaderboard Aggregation Function, XP and Streak Function, Google Maps / Mapbox APIs, Premium / Entitlement Component, OS Share Sheet / Social Media.

**Basic/Premium difference:** Ranking access must remain fair for both Basic and Premium users. Basic can participate in leaderboard views and basic sharing. Premium unlocks richer visual sharing templates and presentation, but does not receive extra XP, ranking boost, or competitive information advantage.

**Leaderboard fairness note:** Leaderboard aggregation and ranking values are backend-owned. Leaderboard tips and sharing screens should explain ranking behaviour without implying that the client can manipulate score, rank, weekly XP, or monthly XP. Premium sharing templates are presentation/status value only.

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

**Entitlement boundary:** Upgrade messaging should make clear that Premium access is controlled by `subscriptionStatus`. Premium benefits are deeper analytics, adaptive or goal-based planning, approved expert plan access, richer route tools, and presentation/sharing value. The upgrade screen must not imply extra XP, rank boosts, leaderboard score advantages, weekly XP/monthly XP advantages, or client-side control over backend-owned progression values.

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
