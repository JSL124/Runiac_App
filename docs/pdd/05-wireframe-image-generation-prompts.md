# A5_WIRE Wireframe Image Generation Prompts

> **Prompt asset notice:** This file is a prompt asset for generating wireframe images. It is not final PDD prose.

These prompts are for generating low-fidelity black-and-white web wireframe images for the Runiac PDD. They cover the Platform Administrator and Medical Trainer/Expert governance screens.

## 1. Admin Dashboard

**Role:** Platform Administrator

**Purpose:** Provides an overview of system status and pending administrative tasks.

**Final image-generation prompt:**

Create a low-fidelity black-and-white web admin dashboard wireframe for the Runiac PDD. The screen should use a clean academic project-documentation style, simple rectangular sections, readable labels, no colours, no gradients, and no decorative illustrations. Use a desktop web layout, not a mobile layout. Add a fixed left sidebar titled "Runiac Admin Panel" with navigation items: Dashboard, Users, Expert Plans, Plans, Shared Routes, Notifications, Reports, Settings. At the top of the main content area, add a header reading "Runiac Admin Panel - Admin Dashboard".

The main content should show eight rectangular overview cards arranged in a grid: Total Users, Premium Users, Active Basic Users, Pending Expert Plans, Published Expert Plans, Reported Routes, Pending Reports, Active Notifications. Below the overview cards, add a "Quick Actions" section with rectangular buttons: Manage Users, Review Expert Plans, Manage Plans, Manage Shared Routes, Send Notification, View Reports. Add a "Recent Activity" table below with columns: Time, Activity Type, Item, Performed By, Status. Use placeholder rows such as "Expert plan submitted", "Route report received", "User suspended", "Notification scheduled". The layout should be clear, spacious, and consistent with a university PDD wireframe.

**Important constraints:** Use only black, white, and grey wireframe styling. Platform Administrator access is controlled by `userRole`. Do not show mobile UI. Do not show XP editing or leaderboard manipulation controls.

## 2. User Management

**Role:** Platform Administrator

**Purpose:** Allows the administrator to search, view, and manage user accounts.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for a Runiac Platform Administrator screen. Use the header "Runiac Admin Panel - User Management" and the same left sidebar navigation as the admin dashboard. The design must be simple, rectangular, readable, and suitable for an academic PDD. At the top of the main area, place a wide search bar labelled "Search by name, email, or user ID".

Below the search bar, create a filter panel with dropdown or input placeholders for `subscriptionStatus`, `userRole`, `accountStatus`, joined date, and last active. Under the filters, show a large user table with columns: Name, Email, subscriptionStatus, userRole, Account Status, Last Active, Actions. Example row values should show Basic/Premium through `subscriptionStatus`, and operational roles through `userRole` such as User, Platform Administrator, and Medical Trainer/Expert. In the Actions column, place small wireframe buttons: View, Edit, Suspend. Keep all controls as plain rectangular placeholders. Add a small note under the table: "Basic/Premium is controlled by subscriptionStatus; governance access is controlled by userRole."

**Important constraints:** Do not represent Basic User and Premium User as separate account classes. Use `subscriptionStatus` for Basic/Premium. Use `userRole` for User, Platform Administrator, or Medical Trainer/Expert. Use Suspend as a soft governance action.

## 3. User Detail / Role Control

**Role:** Platform Administrator

**Purpose:** Allows the administrator to inspect one user and manage access or moderation status.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - User Detail / Role Control". Include the same left sidebar used across the admin screens. The main layout should use simple cards and tables. At the top, show a user profile summary card with placeholders for avatar box, name, email, user ID, joined date, and last active.

Create an "Access Information" card showing `subscriptionStatus`, `userRole`, and `accountStatus`. Create a "Running Summary" card or table with Total Activities, Total Distance, Level, Total XP, Current Streak, Registered Leaderboard Area, Rank, and Leaderboard Score. Mark Level, Total XP, Current Streak, Rank, Registered Leaderboard Area, and Leaderboard Score with a clear "Read-only / system-calculated" label. Add a "Moderation" section with Report Count, Account Warnings, and Admin Notes. Add an "Admin Actions" section with rectangular buttons or controls: Update userRole, Update accountStatus, Suspend, Reactivate, Add Admin Note, View Activity History. The page should clearly separate editable governance fields from read-only progression fields.

**Important constraints:** XP, level, streak, rank, and leaderboard score must be read-only. The admin must not directly edit XP, level, streak, rank, weekly XP, monthly XP, or leaderboard score. Use `subscriptionStatus` and `userRole` labels exactly.

## 4. Expert Plan Review

**Role:** Platform Administrator

**Purpose:** Allows the administrator to review expert-submitted plans before publication.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - Expert Plan Review". Include the same admin sidebar. At the top of the content area, create a plan header panel with Plan Title, Goal Distance, Duration, Difficulty, Runs per Week, and Current Status. Use a status example such as "Pending Admin Review" or "Approved".

Below the header, create a provider information panel with Submitted By, Provider Type, Qualification Summary, and Submitted Date. Add a large weekly schedule table with columns: Week, Session, Distance/Duration, Intensity, Notes. Add a Safety Notes section with placeholder text rows for warm-up/cool-down notes, beginner suitability, injury prevention notes, and medical disclaimer. Add an Admin Review Checklist panel with checkbox rows such as "Beginner suitable", "Safe progression", "Clear rest days", "No medical diagnosis", "Consistent with Runiac standards". Add an Admin Comment text box. At the bottom, place decision buttons: Approve, Request Revision, Reject, Publish Approved Plan, Archive. Include a small label: "Review and publishing performed by Platform Administrator."

**Important constraints:** Medical Trainer/Expert does not publish. Platform Administrator publishes only after review and approval. Premium Users can only view/select approved and published expert plans. Use Archive or Reject rather than hard delete.

## 5. Plan Management

**Role:** Platform Administrator

**Purpose:** Allows the administrator to manage Runiac system goal plans and approved expert plans.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - Plan Management". Use consistent sidebar navigation and a simple PDD-style wireframe layout. At the top of the main content, include a search and filter panel with fields for Plan Type, Goal Distance, Difficulty, Status, and Last Updated. Include a prominent rectangular button labelled "Create New System Goal Plan".

Below the filters, create a plan table with columns: Plan Title, Plan Type, Goal, Duration, Difficulty, Status, Last Updated, Actions. Show example plan types as "System Plan" and "Expert Plan". Show example statuses such as Submitted, Pending Review, Revision Requested, Approved, Published, Archived, and Rejected. In the Actions column, include View, Edit, and Archive buttons. Add a small explanatory note near the table: "System plans and expert plans are distinguishable. Expert plans become visible to Premium Users only after approval and publication."

**Important constraints:** Use `subscriptionStatus` for Premium access to expert plans. Premium expert plans must not create XP or leaderboard scoring advantages. Archive should be shown instead of hard delete.

## 6. Route Management

**Role:** Platform Administrator

**Purpose:** Allows the administrator to review and moderate shared routes.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - Route Management". Include the same left sidebar. The main content should start with a search and filter panel labelled "Search shared routes" with fields for route name, location, creator, difficulty, and report status.

Create a large route table with columns: Route Name, Creator, Location, Distance, Difficulty, Visibility, Favourite Count, Report Count, Status, Actions. In the Actions column, include View, Hide, Archive, and Mark as Reviewed. To the right or below the table, add a map preview placeholder box labelled "Map Preview" with a simple route line placeholder. Add a "Report Detail Preview" panel showing reported item, reported by, reason, report date, status, and admin decision. Keep all sections rectangular and wireframe-like with no decorative maps or colours.

**Important constraints:** Route management is for moderation, safety, and privacy. It must not give Premium Users XP, rank, leaderboard score, or competitive advantages. Use Hide, Archive, and Mark as Reviewed as soft moderation actions.

## 7. Notification / Report Management

**Role:** Platform Administrator

**Purpose:** Allows the administrator to create system notifications and handle reports or moderation cases.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Runiac Admin Panel - Notification / Report Management". Use a consistent admin sidebar and simple rectangular content areas. Split the main content into two large panels: "Notification Management" and "Report Management".

In the Notification Management panel, include a notification form with fields for Notification Title, Message Body, Target Audience, Notification Type, and Send Now / Schedule. Add simple buttons labelled Save Draft, Send Now, and Schedule. Below the form, add a Notification History table with columns: Title, Target Audience, Type, Scheduled Time, Sent Status, Created By. In the Report Management panel, add a report table with columns: Report Type, Reported Item, Reported By, Reason, Date, Status, Admin Decision, Actions. In the Actions column, include Resolve, Dismiss, Hide Route, Suspend User, and Archive Content.

**Important constraints:** Use soft moderation decisions. Reports should support auditability. Do not include hard delete. Notification targeting should be shown as an admin communication tool, not as a way to alter XP, streak, rank, or leaderboard score.

## 8. Expert Plan Submission Form

**Role:** Medical Trainer/Expert

**Purpose:** Allows Medical Trainer/Expert to prepare structured expert plan content for admin review.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Expert Plan Submission Portal - Expert Plan Submission Form". This must be a web portal layout, not a mobile app. Use simple rectangular form sections, clear readable text, no colour, no illustrations, and no high-fidelity styling. Include a top header labelled "Expert Plan Submission Portal" and a simple left sidebar with items: New Submission, Submitted Plans, Drafts, Profile.

The main form should contain an "Expert Information" section with fields for Expert Name, Qualification, Organisation, Experience Summary, and Contact Email. Add a "Plan Basic Information" section with Plan Title, Goal Distance, Duration, Difficulty, Target User Type, and Runs per Week. Add a Plan Description section with large text areas for Plan Description and Expected Outcome. Add a Weekly Plan Builder table with columns: Week, Run Session, Distance/Duration, Intensity, Rest Day Guidance, Notes. Add a Safety section with Beginner Suitability, Injury Prevention Notes, When to Stop Running, and Medical Disclaimer. At the bottom, include only two buttons: Save Draft and Submit for Admin Review.

**Important constraints:** Do not include a Publish Plan button. Do not imply direct publication to the live Premium plan catalogue or direct writing of published plans into Firebase. Submission goes to the Platform Administrator review queue.

## 9. Submitted Plan Status Page

**Role:** Medical Trainer/Expert

**Purpose:** Allows Medical Trainer/Expert to view the review status of submitted plans and respond to revision requests.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web wireframe for "Expert Plan Submission Portal - Submitted Plan Status Page". Use the same Expert Plan Submission Portal header and sidebar as the submission form. The layout should be clean, rectangular, and suitable for a PDD wireframe.

At the top, add a small summary strip with counts for Draft, Submitted, Pending Admin Review, Revision Requested, Approved, Published, Rejected, and Archived. Below it, create a submitted plan list table with columns: Plan Title, Goal Distance, Submitted Date, Current Status, Admin Comment, Last Updated, Actions. Use visible status examples: Draft, Submitted, Pending Admin Review, Revision Requested, Approved, Published, Rejected, Archived. In the Actions column, include View Submission, Edit Draft, Respond to Revision, and Resubmit for Review. Add a right-side or bottom detail preview panel showing selected plan title, latest admin comment, required changes, and next allowed action.

**Important constraints:** Do not include a Publish button. Medical Trainer/Expert can view status and respond to revision requests, but cannot approve, publish, archive published plans, or directly write published plan records. Publication remains a Platform Administrator action.

## Supplemental Admin/Expert Governance Wireframes

These supplemental prompts clarify the expert plan governance flow for the PDD. They should be used only to generate additional low-fidelity black-and-white wireframe images under the canonical `docs/pdd/wireframe-images/` path.

## 10. Admin/Expert Governance Flow Overview

**Target file path:** `docs/pdd/wireframe-images/shared-governance/admin-expert-governance-flow-overview.png`

**Screen purpose:** Explains the full expert plan lifecycle from Medical Trainer/Expert draft preparation through Platform Administrator review, approval, publication, and Premium User access.

**Role:** Shared governance overview for Medical Trainer/Expert, Platform Administrator, and Premium User access context.

**Layout sections:**
- Header: "Runiac Expert Plan Governance Flow"
- Three swimlane columns: Medical Trainer/Expert, Platform Administrator, Premium User
- Flow steps: Draft Plan, Submit for Admin Review, Admin Review Queue, Review Checklist, Request Revision / Reject / Approve, Publish Approved Plan, View Published Expert Plan
- Status legend: Draft, Submitted, Pending Admin Review, Revision Requested, Rejected, Approved, Published, Archived
- Governance notes panel: `userRole` controls governance access; `subscriptionStatus` controls Premium plan access

**Key labels/buttons:** Save Draft, Submit for Admin Review, Request Revision, Reject, Approve, Publish Approved Plan, View Published Expert Plan, "Approved is not Published", "Premium Users see approved + published plans only".

**Negative constraints:** Do not show a Publish button in the Medical Trainer/Expert lane. Do not imply direct expert publication. Do not show Basic/Premium as separate subclasses. Do not show colourful UI, photo-realistic elements, implementation code, Firebase collection names, API names, or database write details. Do not show XP, rank, streak, level, leaderboard score, weekly XP, or monthly XP controls.

**Final image-generation prompt:**

Create a low-fidelity black-and-white PDD wireframe image titled "Runiac Expert Plan Governance Flow". Use a clean desktop/tablet documentation layout with simple rectangles, arrows, readable labels, and no colour. The image should be a governance flow overview, not an implementation diagram.

Arrange the main content as three vertical swimlane columns labelled "Medical Trainer/Expert", "Platform Administrator", and "Premium User". In the Medical Trainer/Expert lane, show boxes for "Draft Expert Plan", "Save Draft", "Submit for Admin Review", "Respond to Revision", and "Resubmit for Review". In the Platform Administrator lane, show boxes for "Admin Review Queue", "Review Safety + Completeness + Beginner Suitability", "Request Revision", "Reject", "Approve", and "Publish Approved Plan". In the Premium User lane, show one final box: "View / Select Published Expert Plan".

Use arrows to show the lifecycle: draft plan -> submit for admin review -> admin review queue -> review decision -> revision loop back to expert response if needed -> approve -> publish approved plan -> Premium User view/select. Add a small status legend with Draft, Submitted, Pending Admin Review, Revision Requested, Rejected, Approved, Published, and Archived. Add a governance note panel reading: "Medical Trainer/Expert prepares and revises content only. Platform Administrator controls approval and publication. Premium Users can access only approved and published expert plans." Add a second note reading: "`userRole` controls governance access; `subscriptionStatus` controls Basic/Premium feature access."

Important constraints: use only black, white, and grey wireframe styling. Do not include a Publish button or direct publication action in the Medical Trainer/Expert lane. Do not imply direct expert writes to the published catalogue. Do not include implementation code, Firebase collection names, API names, or database diagrams. Do not show XP, rank, streak, level, leaderboard score, weekly XP, or monthly XP editing controls. Keep all text readable and suitable for an academic PDD.

## 11. Expert Plan Review Queue

**Target file path:** `docs/pdd/wireframe-images/platform-admin/expert-plan-review-queue.png`

**Screen purpose:** Shows the Platform Administrator's list view for submitted expert plans waiting for review, revision tracking, approval, rejection, or publication follow-up.

**Role:** Platform Administrator.

**Layout sections:**
- Admin panel header and sidebar
- Queue summary cards
- Search and filter panel
- Expert plan submission table
- Selected submission preview panel
- Admin action area
- Governance note

**Key labels/buttons:** Runiac Admin Panel - Expert Plan Review Queue, Pending Admin Review, Revision Requested, Approved Not Published, Published, Rejected, Archived, Search plans, Filter by Status, Filter by Provider, View Submission, Open Review, Request Revision, Reject, Approve, Publish Approved Plan, Archive.

**Negative constraints:** Do not show Medical Trainer/Expert publishing controls. Do not merge Approved and Published into one status. Do not show hard delete. Do not show direct XP, rank, streak, level, leaderboard score, weekly XP, or monthly XP edits. Do not show colourful UI, photo-realistic elements, implementation code, Firebase names, API names, or database tables.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web admin wireframe for "Runiac Admin Panel - Expert Plan Review Queue". Use the same plain admin panel style as the other Runiac Platform Administrator wireframes: fixed left sidebar, simple rectangles, readable table text, no colour, no gradients, and no decorative images.

Include a left sidebar titled "Runiac Admin Panel" with navigation items: Dashboard, Users, Expert Plans, Plans, Shared Routes, Notifications, Reports, Settings. In the main content area, add a page header "Expert Plan Review Queue". Below the header, show summary cards labelled "Pending Admin Review", "Revision Requested", "Approved Not Published", "Published", "Rejected", and "Archived".

Add a search and filter row with fields labelled "Search plans", "Filter by Status", "Filter by Provider", "Goal Distance", and "Submitted Date". Below the filters, create a large table with columns: Plan Title, Submitted By, Provider Qualification, Goal Distance, Difficulty, Submitted Date, Current Status, Last Admin Action, Actions. Use example statuses such as Pending Admin Review, Revision Requested, Approved, Approved Not Published, Published, Rejected, and Archived. In the Actions column, show buttons: View Submission, Open Review, Request Revision, Reject, Approve, Publish Approved Plan, Archive.

On the right side or below the table, add a selected submission preview panel with Plan Title, Provider, Safety Notes Summary, Beginner Suitability Notes, Latest Admin Comment, and Next Required Action. Add a governance note at the bottom: "Platform Administrator reviews, approves, rejects, archives, and publishes expert plans. Medical Trainer/Expert can submit and revise only."

Important constraints: use only black, white, and grey wireframe styling. Keep Approved separate from Published. Do not include hard delete. Do not show Medical Trainer/Expert publication controls. Do not include implementation code, Firebase collection names, API names, or database table details. Do not show XP, rank, streak, level, leaderboard score, weekly XP, or monthly XP editing controls. Keep the design PDD-ready, readable, and consistent with a desktop admin panel.

## 12. Expert Plan Publish Confirmation

**Target file path:** `docs/pdd/wireframe-images/platform-admin/expert-plan-publish-confirmation.png`

**Screen purpose:** Confirms that only a Platform Administrator can publish an already approved expert plan and makes the distinction between approval and publication visible.

**Role:** Platform Administrator.

**Layout sections:**
- Admin panel header and sidebar
- Approved plan summary
- Pre-publication checklist
- Visibility and access confirmation panel
- Confirmation warning panel
- Action buttons
- Audit note

**Key labels/buttons:** Runiac Admin Panel - Publish Expert Plan, Current Status: Approved, Publication Status: Not Published, Publish Approved Plan, Cancel, Return to Review Queue, Beginner suitability checked, Safety notes reviewed, Premium visibility only, Confirm publication.

**Negative constraints:** Do not show this screen as available to Medical Trainer/Expert. Do not show publication before approval. Do not show Basic Users receiving premium access. Do not imply XP or leaderboard advantages from Premium expert plans. Do not show colourful UI, photo-realistic elements, implementation code, Firebase names, API names, database write details, or hard delete.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web admin wireframe for "Runiac Admin Panel - Publish Expert Plan". Use a clean Platform Administrator panel layout with a left sidebar, rectangular sections, readable labels, no colour, no gradients, and no decorative elements.

The main content should show an approved expert plan ready for publication. At the top, include a plan summary panel with labels: Plan Title, Submitted By, Goal Distance, Duration, Difficulty, Approved By, Approved Date, Current Status: Approved, Publication Status: Not Published. Below it, add a "Pre-Publication Checklist" panel with checkbox rows: Beginner suitability checked, Safety notes reviewed, Weekly schedule complete, Medical disclaimer included, Runiac standard consistency checked, No competitive XP or leaderboard advantage.

Add a "Visibility and Access" panel showing "Visible to Premium Users after publication", "`subscriptionStatus` controls Premium access", and "Basic Users do not see Premium expert plan catalogue". Add a confirmation warning panel reading: "Approved is not the same as Published. Publishing makes this plan available in the Premium expert plan catalogue." At the bottom, include action buttons: Publish Approved Plan, Cancel, Return to Review Queue. Include a small audit note: "Publication action is performed by Platform Administrator through `userRole` governance access."

Important constraints: use only black, white, and grey wireframe styling. This is a Platform Administrator confirmation screen only. Do not show Medical Trainer/Expert publishing controls. Do not show publication before approval. Do not imply Premium Users receive XP, rank, leaderboard score, or competitive advantages. Do not include implementation code, Firebase collection names, API names, database tables, or hard delete controls. Keep all text readable and PDD-ready.

## 13. Expert Plan Revision Response

**Target file path:** `docs/pdd/wireframe-images/medical-trainer-expert/expert-plan-revision-response.png`

**Screen purpose:** Allows Medical Trainer/Expert to read an administrator revision request, update draft content, respond with a revision note, and resubmit for admin review.

**Role:** Medical Trainer/Expert.

**Layout sections:**
- Expert Plan Submission Portal header and sidebar
- Revision request summary
- Admin comments and required changes
- Editable plan update sections
- Expert response note
- Resubmission controls
- Governance note

**Key labels/buttons:** Expert Plan Submission Portal - Revision Response, Current Status: Revision Requested, Admin Comment, Required Changes, Update Plan Details, Update Weekly Schedule, Update Safety Notes, Expert Response Note, Save Draft, Resubmit for Admin Review, Back to Submitted Plans.

**Negative constraints:** Do not include Publish, Approve, Reject, Archive Published Plan, or direct catalogue controls. Do not show the expert changing published records. Do not show Firebase, API, database, or implementation details. Do not show XP, rank, streak, level, leaderboard score, weekly XP, or monthly XP controls. Do not use colour, photo-realistic elements, or mobile app layout.

**Final image-generation prompt:**

Create a low-fidelity black-and-white desktop web portal wireframe for "Expert Plan Submission Portal - Revision Response". Use a simple Medical Trainer/Expert portal style, not a mobile app and not an admin dashboard. Use readable labels, rectangular panels, plain table/form placeholders, no colour, no gradients, and no decorative images.

Include a top header labelled "Expert Plan Submission Portal" and a left sidebar with New Submission, Submitted Plans, Drafts, Profile. In the main content area, add the page title "Revision Response". At the top, show a revision summary panel with Plan Title, Goal Distance, Submitted Date, Current Status: Revision Requested, Reviewed By: Platform Administrator, and Last Review Date.

Below the summary, add an "Admin Comment and Required Changes" panel with text rows labelled Admin Comment, Required Change 1, Required Change 2, Safety Concern, Beginner Suitability Note. Add editable form sections for "Update Plan Details", "Update Weekly Schedule", and "Update Safety Notes". The weekly schedule section should be a table with columns Week, Session, Distance/Duration, Intensity, Rest Day Guidance, Notes. Add an "Expert Response Note" text area labelled "Explain how the requested changes were addressed". At the bottom, include only these action buttons: Save Draft, Resubmit for Admin Review, Back to Submitted Plans.

Add a small governance note: "Medical Trainer/Expert can revise and resubmit content only. Platform Administrator remains responsible for approval and publication." Important constraints: do not include Publish, Approve, Reject, Archive Published Plan, or direct catalogue controls. Do not imply the expert updates published plans. Do not include implementation code, Firebase collection names, API names, or database details. Do not show XP, rank, streak, level, leaderboard score, weekly XP, or monthly XP controls. Keep the image black-and-white, low-fidelity, readable, and suitable for a university PDD.

## Supplemental Mobile User Wireframe Prompt Plan

The Basic/Premium mobile wireframe image set mostly already exists under `docs/pdd/wireframe-images/mobile-user/`. Do not generate or modify images from this prompt plan until an explicit image-generation task is requested.

## Onboarding Version 2 Plan-Generation Notes

Onboarding Version 2 treats onboarding answers as inputs for the user's first beginner running plan. The questions are not decorative profile fields. Each page should have a clear plan-generation purpose affecting schedule, intensity, duration, safety/cautiousness, motivation tone, or route context.

The existing 13-page onboarding V1 images under `docs/pdd/wireframe-images/mobile-user/shared/onboarding/` can remain the visual baseline for now. Pages 2-12 can keep their V1 images because their questions already map to plan-generation inputs. Regenerate only selected pages later unless a visual review finds a concrete issue:
- `01-onboarding-welcome-page.png` should be regenerated later so the intro explains that setup generates the user's first running plan.
- `13-onboarding-plan-preview-page.png` should be regenerated later so the preview shows the selected plan template, session length, first-week preview, and safety/cautiousness setting.
- `09-onboarding-motivation-style-page.png` is optional later refinement only if the wording implies motivation choices increase plan intensity or difficulty.

Conceptual input-to-plan mapping:

| Onboarding input | Generated plan effect |
| --- | --- |
| Main Goal | Sets the goal type and progression target. |
| Current Running Level | Sets starting difficulty and run/walk ratio. |
| Weekly Availability | Sets weekly run count. |
| Preferred Running Days | Places sessions and rest days. |
| Preferred Running Time | Sets reminder and schedule display timing. |
| Session Length | Sets the starting duration cap. |
| Running Place | Adds route/context notes only; it must not request location permission during onboarding. |
| Motivation Style | Adjusts coaching, reminder, and advice tone; it must not increase intensity. |
| Health Condition | Sets a caution flag only. |
| Symptoms During Physical Activity | Sets a stronger caution flag only. |
| Plan Cautiousness | Applies the final intensity adjustment. |

Initial plan templates for preview and documentation:
- Very Gentle Start: for complete beginners, skipped health/safety answers, health/safety concerns, concerning symptoms, or very cautious preference. Uses shorter sessions, lower frequency where needed, walk-first or run/walk progression, and conservative progression.
- Balanced Beginner Plan: the default for most beginner users. Uses about three runs per week when availability allows, rest days between runs where possible, run/walk intervals, and gradual progression.
- Confidence Builder / First 5K Prep: for users who can already walk/run and choose first 5K or stamina goals. Uses longer run/walk blocks and gradual movement toward more continuous running.
- 10K Preparation Starter: only when current level and availability support it. Otherwise, the plan should recommend a 5K or base-building plan first.

Conflict and fallback rules:
- Four days per week plus only two selected preferred days: schedule the two chosen days and suggest adding one or two flexible days.
- Two days per week plus five selected preferred days: choose the two best-spaced days and keep the others as alternatives.
- Weekly availability Not sure: default to three days, or two days if a health/safety concern exists.
- Session length Not sure: default to 20 minutes, or 15 minutes if caution exists.
- 10K goal plus completely new level: start with Balanced Beginner or First 5K base before 10K.
- Leaderboard challenge plus new level or safety concern: keep leaderboard as motivation but do not increase intensity.
- Expert guidance plus Basic User: show the standard beginner plan; Premium expert plans remain separate.
- Set up later: create a conservative default starter plan.
- Skipped health/safety: default to a conservative plan.
- Health condition concern: use Very Gentle Start or reduced Balanced Beginner Plan with a safety note.
- Concerning symptoms: show a cautious plan suggestion and recommend speaking to a healthcare professional before starting or increasing exercise.
- Normal plan preference plus health/safety caution: safety overrides; use Very Gentle Start or reduced Balanced Beginner Plan.

Health/safety inputs are readiness and cautiousness signals only. They must not be framed as medical diagnosis, treatment, medical advice, medical clearance, exercise clearance, or clinical compliance. Location permission is not requested during onboarding; it is requested later when starting a run or using route features.

Plan Preview V2 should show:
- Selected goal.
- Current level.
- Weekly schedule.
- Session length.
- Suggested starting plan.
- First-week preview.
- Safety/cautiousness setting.
- Primary action: Create My Plan.
- Secondary action: Edit Answers.

Example Plan Preview text:
- Suggested Starting Plan: `3 runs/week · run/walk intervals · 20 min/session`.
- First Week Preview: `Run 1: Walk/run intervals`, `Run 2: Easy run/walk`, `Run 3: Confidence run`.
- If safety concerns exist: `Very gentle start recommended. Speak to a healthcare professional before starting or increasing exercise if you have symptoms or health concerns.`

## 14. Onboarding / Profile Setup

> **Combined draft/support note:** This prompt describes the older single-page Profile Setup summary image. Onboarding Version 2 uses the 13-page flow under `docs/pdd/wireframe-images/mobile-user/shared/onboarding/`. Keep this combined prompt only as support/reference unless an explicit task asks to regenerate the combined draft image.

**Target file path:** `docs/pdd/wireframe-images/mobile-user/shared/onboarding-profile-setup-page.png`

**Screen purpose:** Shows the first-time setup flow that collects beginner running information before the user enters the main app.

**Role:** Shared Basic User and Premium User onboarding.

**Layout sections:**
- Portrait mobile phone frame
- Header: "Profile Setup"
- Subtitle: "Help Runiac create a beginner-friendly running plan."
- Progress step indicator for first-time onboarding
- Main Goal card with Start Running, Build Habit, and Prepare for Distance options
- Current Level card with New Runner, Returning After Break, and Run/Walk Beginner options
- Preferred Schedule card with day chips and a preferred time selector
- Health & Safety card with compact readiness options
- Safety note explaining that Runiac is not a medical service
- Primary action: Continue
- Secondary text action: Set up later

**Key labels/buttons:** Profile Setup, Help Runiac create a beginner-friendly running plan, Main Goal, Start Running, Build Habit, Prepare for Distance, Current Level, New Runner, Returning After Break, Run/Walk Beginner, Preferred Schedule, Health & Safety, Any health concern that may affect running?, No concern, Injury/Pain, Heart/BP or Breathing, Not sure, Continue, Set up later.

**Negative constraints:** Do not show the bottom navigation because onboarding occurs before the user reaches the main app. Do not show Premium-only upsell content on this first-time setup screen. Do not include high-fidelity colours, gradients, photos, branding, decorative illustrations, real user data, implementation code, Firebase collection names, API names, database fields, XP calculation, leaderboard rank, backend-owned values, subscription purchase controls, medical diagnosis language, treatment claims, medical clearance claims, or clinical compliance claims.

**Final image-generation prompt:**

Create a low-fidelity black-and-white mobile app wireframe for the Runiac PDD titled "Profile Setup". Use a portrait phone frame with a clean Flutter / Material-compatible card-based layout. Keep the design beginner-friendly, readable, and suitable for a university Project Design Document. Use only black, white, and grey wireframe styling. Do not use high-fidelity colours, gradients, photos, branding, decorative illustrations, or real user data.

This is a first-time onboarding screen before the user reaches the main app, so do not include bottom navigation. At the top, show the screen title "Profile Setup" and subtitle "Help Runiac create a beginner-friendly running plan." Add a small onboarding progress indicator.

In the main content, show a "Main Goal" card with selectable options: Start Running, Build Habit, Prepare for Distance. Show a "Current Level" card with selectable options: New Runner, Returning After Break, Run/Walk Beginner. Show a "Preferred Schedule" card with day chips and a preferred time selector. Show a "Health & Safety" card with the question "Any health concern that may affect running?" and compact options: No concern, Injury/Pain, Heart/BP or Breathing, Not sure.

Add a small safety note: "Runiac is not a medical service. If you have pain, symptoms, or health concerns, speak to a healthcare professional before starting or increasing exercise." At the bottom, include a primary "Continue" button and a secondary text action "Set up later".

Important constraints: do not include Firebase names, database fields, APIs, implementation details, XP calculation, leaderboard rank, backend-owned values, subscription purchase controls, medical diagnosis language, treatment claims, medical clearance claims, or clinical compliance claims. The screen should document beginner-friendly profile setup and safety awareness only.
