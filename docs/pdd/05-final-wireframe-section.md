# 5. Wireframe Descriptions

> **Support/draft notice:** This file is a support draft for wireframe section assembly. The canonical final wireframe description file is `docs/pdd/05-wireframe-description.md`. Do not treat this file as the final source unless it is explicitly promoted.

This section presents the Runiac wireframes prepared for the Project Design Document. The wireframes are divided into two groups. The first group covers the mobile user experience for Basic User and Premium User. The second group covers controlled web-based governance screens for Platform Administrator and Medical Trainer/Expert.

The mobile wireframes are based on the completed Basic and Premium user flows. The Admin/Expert wireframes are web dashboard or controlled portal screens and are separate from the mobile app interface. Basic/Premium feature access is represented through `subscriptionStatus`, while operational and governance access is represented through `userRole`.

The mobile figures should be grouped by user journey rather than inserted as every individual Basic/Premium screen. Most Basic/Premium mobile images already exist under `docs/pdd/wireframe-images/mobile-user/`, including the canonical 13-page onboarding sequence under `docs/pdd/wireframe-images/mobile-user/shared/onboarding/`. State coverage such as loading, empty, permission denied, GPS unavailable, network unavailable, no route found, no plan selected, subscription locked, and route privacy/restricted access can normally be explained as notes under the relevant figure group instead of separate figures.

## 5.1 Mobile User Wireframes

### Figure 5.1: Home Dashboard

**Suggested source:** Basic Home Page, View Updated Home Page, Premium Home Page, Premium Updated Home Page.

**Caption:** Home Dashboard wireframes showing daily plan guidance, XP progress, weekly plan preview, last-run information, and Premium dashboard extensions.

The Home Dashboard is the main entry point for Basic User and Premium User. It supports daily running guidance, habit visibility, and quick access to the current plan or run start flow. Premium versions add richer goal-plan and route suggestions, but do not create XP or leaderboard scoring advantages.

### Figure 5.2: Onboarding / Profile Setup

**Suggested source:** Canonical 13-page onboarding sequence under `wireframe-images/mobile-user/shared/onboarding/`.

**Caption:** Onboarding wireframes showing one-question-per-page setup for generating the user's first beginner running plan.

Onboarding collects the information required to initialise the user's first beginner running plan, including running goal, current level, weekly availability, preferred days, preferred time, session length, running place/context, motivation style, health/cautiousness inputs, and final plan preview. Health/safety inputs are readiness and cautiousness signals only; they do not diagnose, treat, provide medical advice, clear users for exercise, or claim clinical compliance. Location permission is not requested during onboarding and is requested later when starting a run or using route features.

### Figure 5.3: Plan Home and Today's Plan Detail

**Suggested source:** Basic You Plan Page, Premium You Plan Page, Today's Plan Page, Tuesday's Plan Detail Page, Premium Today's Plan Detail Page.

**Caption:** Training plan wireframes showing weekly plan progress, daily plan detail, session guidance, XP reward display, and start-run entry points.

These wireframes show how users review weekly plans and inspect individual sessions before running. The screens connect Training Plan, Reminder / Notification, Run Tracking, and XP / Streak / Level display. Premium plan details provide richer guidance, while XP remains server-side calculated.

### Figure 5.4: Edit Schedule

**Suggested source:** Edit Plan Schedule Page.

**Caption:** Edit Schedule wireframe showing day/time changes, schedule details, change reason, save, and cancel actions.

The Edit Schedule screen supports realistic beginner habit formation by allowing users to adjust planned sessions rather than abandon the plan. Schedule updates affect plan display and reminders but do not directly award XP.

### Figure 5.5: Run Start and Live Run

**Suggested source:** Run Landing Page, Run Guide Page, Run Tracking Page, Paused Run Tracking Page.

**Caption:** Run flow wireframes showing route/plan confirmation, pre-run guide, active GPS tracking, pause, resume, and end-run controls.

These screens represent the core activity recording journey. Flutter handles the live interaction, map display, and GPS tracking interface, while completed activity processing and trusted progression updates are handled by backend services.

### Figure 5.6: Cool Down and Run Summary

**Suggested source:** Cool Down Landing/Intro, Slow Walking Tracking, Stretching Tracking, Cool Down Completed, Basic Run Summary Page, Premium Run Summary Page, Premium Run Analysis Page, XP & Streak Update.

**Caption:** Post-run wireframes showing recovery guidance, activity summary, XP/streak update, and Premium run analysis.

The post-run flow closes the activity session and converts run data into understandable feedback. Basic users receive essential metrics and beginner-friendly summaries, while Premium users may receive deeper analysis. XP, streak, level, and leaderboard-related values are displayed after server-side calculation.

## 5.2 Route, Leaderboard, and Profile Wireframes

### Figure 5.7: Explore Map and Route List

**Suggested source:** Maps Landing Page, View List of Shared Route Page.

**Caption:** Explore and route discovery wireframes showing map preview, search, nearby shared routes, filters, and route cards.

These screens support community route discovery and route selection. Basic users can browse and select routes when route sharing is implemented, while Premium users may receive richer filters and saved-route management. Route features must not create ranking or XP advantages.

### Figure 5.8: Route Detail and My Route

**Suggested source:** Basic Map Detail Page, Premium Shared Map Detail Page, Route Selected Page, Success Selecting Route Page, Basic My Route Page, Premium My Route Page, Report Route screens.

**Caption:** Route detail and saved-route wireframes showing route information, select-route confirmation, reporting, selected-route management, and Premium saved-route extensions.

The route detail flow allows users to inspect, select, report, and manage routes. Reported routes are handled by Platform Administrator moderation. Premium route features focus on convenience and presentation rather than competitive advantage.

### Figure 5.9: Leaderboard

**Suggested source:** Leaderboard Landing Page, Click Regional Page, View More Ranking Page, View League Page, Leaderboard Sharing Page.

**Caption:** Leaderboard wireframes showing territorial ranking, regional detail, league views, expanded rankings, and sharing.

Leaderboard screens show level-based territorial competition using precomputed backend ranking data. Basic and Premium users can access fair ranking information; Premium may receive enhanced sharing templates but no XP, rank, or leaderboard score advantage.

### Figure 5.10: Profile / You

**Suggested source:** Basic You Page, Premium You Landing Page.

**Caption:** Profile wireframes showing streak, calendar, recent runs, runner level, and plan entry points.

The Profile area gives the user a personal progress view and links to recent run history and plan details. It displays progression information but does not calculate trusted XP, streak, level, or leaderboard values on the client.

### Figure 5.11: Premium Expert Plan Access

**Suggested source:** Explore Expert Goal Plan Page, View Expert Plan Detail Page, View Goal Plan Journey Page, Premium You Plan Page.

**Caption:** Premium expert plan wireframes showing expert plan discovery, published plan detail, goal-plan journey, and Premium plan progress.

Premium Users can view and select only expert plans that have been approved and published by the Platform Administrator. Access is controlled by `subscriptionStatus`, while publication is controlled by administrator governance through `userRole`.

## 5.3 Admin/Expert Governance Flow Overview

The Admin/Expert governance flow explains how expert plan content moves from specialist preparation to controlled publication. The Medical Trainer/Expert acts only as an expert content provider. This role can create draft expert plan content and submit it for Platform Administrator review, but it must not directly publish plans or directly place published plans into the Premium User catalogue.

![Support Figure: Admin/Expert Governance Flow Overview](wireframe-images/shared-governance/admin-expert-governance-flow-overview.png)

The lifecycle begins when the Medical Trainer/Expert creates a draft expert plan using the Expert Plan Submission Form. The expert enters plan details, weekly structure, target beginner profile, safety notes, injury-prevention guidance, and disclaimer information. When the content is ready, the expert submits the plan for admin review. The submitted plan then appears in the Platform Administrator's pending expert plan queue, which may be accessed from the Admin Dashboard, Expert Plan Review screen, or Plan Management screen.

The Platform Administrator reviews the submitted plan for safety, completeness, beginner suitability, and consistency with Runiac standards. After review, the administrator may request revision, approve, reject, archive, or publish only after approval. If revision is requested, the Medical Trainer/Expert can view the administrator comment on the Submitted Plan Status Page, update the submission, and resubmit it for review. If the plan is rejected or archived, it remains unavailable to Premium Users. If the plan is approved, the Platform Administrator can publish it through the controlled admin workflow.

Premium Users can view and select only expert plans that are both approved and published. Basic/Premium feature access is controlled through `subscriptionStatus`, while operational and governance access is controlled through `userRole`. Premium expert plans must not create XP, rank, leaderboard score, or other competitive advantages; they provide richer plan guidance only.

**Support figure note:** The governance overview, expert plan review queue, expert plan publish confirmation, and expert revision response images are current support assets for explaining the controlled expert-plan lifecycle.

## 5.4 Platform Administrator Wireframes

### Figure 5.12: Admin Dashboard

![Figure 5.12: Admin Dashboard](wireframe-images/platform-admin/admin-dashboard.png)

**Caption:** Admin Dashboard showing system status, pending expert plans, reported routes, active notifications, quick actions, and recent activity.

This screen gives the Platform Administrator a central overview of governance workload and system activity. It supports quick movement into user management, expert plan review, plan management, route moderation, notification sending, and report handling. Access is controlled by `userRole = Platform Administrator`, not by `subscriptionStatus`.

### Figure 5.13: User Management

![Figure 5.13: User Management](wireframe-images/platform-admin/user-management.png)

**Caption:** User Management screen showing account search, filters, user table, and View/Edit/Suspend actions.

User Management supports administrator search and review of user accounts. Basic/Premium access is represented through `subscriptionStatus`, while operational identity is represented through `userRole`. Basic User and Premium User are not separate account classes, and Suspend is treated as a soft moderation action.

### Figure 5.14: User Detail / Role Control

![Figure 5.14: User Detail / Role Control](wireframe-images/platform-admin/user-detail-role-control.png)

**Caption:** User Detail / Role Control screen showing profile, access information, read-only running summary, moderation notes, and admin actions.

This screen lets administrators inspect one user, update role or account status, add notes, and apply moderation actions. XP, level, streak, rank, and leaderboard-related data are shown only as read-only system-calculated fields. The administrator must not directly edit XP, level, streak, rank, or leaderboard score.

### Figure 5.15: Expert Plan Review

![Figure 5.15: Expert Plan Review](wireframe-images/platform-admin/expert-plan-review.png)

**Caption:** Expert Plan Review screen showing submitted plan details, provider information, weekly schedule, safety notes, review checklist, admin comments, and decision buttons.

Expert Plan Review is the controlled approval screen for expert-submitted plan content. It ensures safety, beginner suitability, completeness, and consistency with Runiac standards before publication. Medical Trainer/Expert does not publish plans; Platform Administrator publishes only after review and approval.

### Support Figure: Expert Plan Review Queue

![Support Figure: Expert Plan Review Queue](wireframe-images/platform-admin/expert-plan-review-queue.png)

**Caption:** Expert Plan Review Queue showing pending expert plan submissions, review status, provider information, and administrator review actions.

The Expert Plan Review Queue support figure shows how submitted Medical Trainer/Expert plans enter the Platform Administrator review workflow. Queue actions remain administrator-controlled; Medical Trainer/Expert cannot approve or publish expert plans.

### Figure 5.16: Plan Management

![Figure 5.16: Plan Management](wireframe-images/platform-admin/plan-management.png)

**Caption:** Plan Management screen showing system and expert plan records, lifecycle statuses, search filters, and View/Edit/Archive actions.

Plan Management allows the administrator to manage Runiac system goal plans and approved expert plans. It distinguishes System Plan and Expert Plan records and supports lifecycle states such as Submitted, Pending Review, Revision Requested, Approved, Published, Archived, and Rejected. Premium expert plans must not create XP, rank, leaderboard score, or competitive advantages.

### Support Figure: Expert Plan Publish Confirmation

![Support Figure: Expert Plan Publish Confirmation](wireframe-images/platform-admin/expert-plan-publish-confirmation.png)

**Caption:** Expert Plan Publish Confirmation showing administrator pre-publication checks before making an approved expert plan visible.

The Expert Plan Publish Confirmation support figure documents the controlled publication checkpoint after expert plan approval. Platform Administrator publishes only after review and approval, and publication must not create XP, rank, leaderboard score, or other competitive advantages for Premium Users.

### Figure 5.17: Route Management

![Figure 5.17: Route Management](wireframe-images/platform-admin/route-management.png)

**Caption:** Route Management screen showing shared route search, route table, map preview, report detail preview, and soft moderation actions.

Route Management supports administrative review and moderation of shared routes. It helps handle unsafe, inappropriate, or reported routes through actions such as Hide, Archive, and Mark as Reviewed. Route moderation is for safety and privacy only; it must not grant Premium Users competitive advantages.

### Figure 5.18: Notification / Report Management

![Figure 5.18: Notification / Report Management](wireframe-images/platform-admin/notification-report-management.png)

**Caption:** Notification / Report Management screen showing notification creation, notification history, report table, and moderation actions.

This screen combines system notification management with report handling. It supports administrative communication and moderation decisions such as Resolve, Dismiss, Hide Route, Suspend User, and Archive Content. The screen must not include XP, streak, level, rank, or leaderboard score modification controls.

## 5.5 Medical Trainer/Expert Wireframes

### Figure 5.19: Expert Plan Submission Form

![Figure 5.19: Expert Plan Submission Form](wireframe-images/medical-trainer-expert/expert-plan-submission-form.png)

**Caption:** Expert Plan Submission Form showing expert credentials, plan details, weekly plan builder, safety guidance, and submission controls.

This screen allows Medical Trainer/Expert to prepare structured expert plan content for Platform Administrator review. It standardises expert input while keeping publication controlled by Runiac governance. The screen includes Save Draft and Submit for Admin Review only; it must not include a Publish Plan button.

### Figure 5.20: Submitted Plan Status Page

![Figure 5.20: Submitted Plan Status Page](wireframe-images/medical-trainer-expert/submitted-plan-status-page.png)

**Caption:** Submitted Plan Status Page showing submitted expert plans, review statuses, admin comments, and revision-response actions.

This screen allows Medical Trainer/Expert to track submitted plans, edit drafts, respond to revision requests, and resubmit for review. Published status is shown only as an outcome of Platform Administrator approval and publishing. Medical Trainer/Expert cannot approve, publish, archive published plans, or directly write published plan records.

### Support Figure: Expert Plan Revision Response

![Support Figure: Expert Plan Revision Response](wireframe-images/medical-trainer-expert/expert-plan-revision-response.png)

**Caption:** Expert Plan Revision Response showing Medical Trainer/Expert updates after a Platform Administrator revision request.

The Expert Plan Revision Response support figure clarifies the revision loop after the administrator requests changes. Medical Trainer/Expert can revise and resubmit content only; approval and publication remain Platform Administrator responsibilities.
