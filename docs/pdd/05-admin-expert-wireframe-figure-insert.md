# Platform Administrator and Medical Trainer/Expert Wireframe Figures

The following wireframes document the controlled web-based governance screens for Runiac. These screens are separate from the mobile user application wireframes and support administration, moderation, expert plan review, and expert plan submission workflows.

## Admin/Expert Governance Flow Overview

The Admin/Expert governance flow explains how expert plan content moves from specialist preparation to controlled publication. The Medical Trainer/Expert acts only as an expert content provider. This role can create draft expert plan content and submit it for Platform Administrator review, but it must not directly publish plans or directly place published plans into the Premium User catalogue.

The lifecycle begins when the Medical Trainer/Expert creates a draft expert plan using the Expert Plan Submission Form. The expert enters plan details, weekly structure, target beginner profile, safety notes, injury-prevention guidance, and disclaimer information. When the content is ready, the expert submits the plan for admin review. The submitted plan then appears in the Platform Administrator's pending expert plan queue, which may be accessed from the Admin Dashboard, Expert Plan Review screen, or Plan Management screen.

The Platform Administrator reviews the submitted plan for safety, completeness, beginner suitability, and consistency with Runiac standards. After review, the administrator may request revision, approve, reject, archive, or publish only after approval. If revision is requested, the Medical Trainer/Expert can view the administrator comment on the Submitted Plan Status Page, update the submission, and resubmit it for review. If the plan is rejected or archived, it remains unavailable to Premium Users. If the plan is approved, the Platform Administrator can publish it through the controlled admin workflow.

Premium Users can view and select only expert plans that are both approved and published. Basic/Premium feature access is controlled through `subscriptionStatus`, while operational and governance access is controlled through `userRole`. Premium expert plans must not create XP, rank, leaderboard score, or other competitive advantages; they provide richer plan guidance only.

**Recommended insertion point:** Place this overview before the individual Admin/Expert wireframe figures in the PDD wireframe section. It should appear immediately after the introductory paragraph for Platform Administrator and Medical Trainer/Expert wireframes.

**Expert Plan Review Queue note:** An additional Expert Plan Review Queue wireframe is optional, not necessary. The existing Admin Dashboard, Expert Plan Review, Plan Management, Expert Plan Submission Form, and Submitted Plan Status Page already provide enough screen-level coverage for the PDD. A separate queue screen may be added later only if the final document needs a more explicit list view of pending expert submissions.

**Suggested future figure caption:** "Figure 5.X: Admin/Expert Expert Plan Governance Flow from expert draft submission to administrator-controlled publication."

## Figure 5.1: Admin Dashboard

![Figure 5.1: Admin Dashboard](wireframe-images/platform-admin/admin-dashboard.png)

The Admin Dashboard provides the Platform Administrator with a high-level overview of system activity and pending governance tasks. It summarises user counts, premium/basic distribution, expert plan queues, route reports, active notifications, and recent administrative activity.

**Role supported:** Platform Administrator.

**Key design purpose:** To provide a central entry point for administrative monitoring and quick access to user, plan, route, notification, and report management.

**Governance/access-control note:** Access to this screen is controlled by `userRole = Platform Administrator`; it is not controlled by `subscriptionStatus`.

## Figure 5.2: User Management

![Figure 5.2: User Management](wireframe-images/platform-admin/user-management.png)

The User Management wireframe allows the Platform Administrator to search, filter, and manage user accounts. It shows account information in a table using `subscriptionStatus` for Basic/Premium access and `userRole` for operational roles.

**Role supported:** Platform Administrator.

**Key design purpose:** To support account search, account review, role inspection, and soft moderation actions such as suspension.

**Governance/access-control note:** Basic/Premium is not modelled as separate account classes. Feature tier is represented by `subscriptionStatus`, while governance access is represented by `userRole`.

## Figure 5.3: User Detail / Role Control

![Figure 5.3: User Detail / Role Control](wireframe-images/platform-admin/user-detail-role-control.png)

The User Detail / Role Control screen provides a detailed view of one user account, including profile data, access information, running summary, moderation notes, and administrative actions. XP, level, streak, rank, and leaderboard-related values are displayed only as read-only system-calculated fields.

**Role supported:** Platform Administrator.

**Key design purpose:** To let administrators inspect user status, update role or account status, add notes, and apply soft moderation actions without changing trusted progression data.

**Governance/access-control note:** The administrator must not directly edit XP, level, streak, rank, or leaderboard score. These values are calculated by server-side processing.

## Figure 5.4: Expert Plan Review

![Figure 5.4: Expert Plan Review](wireframe-images/platform-admin/expert-plan-review.png)

The Expert Plan Review screen allows the Platform Administrator to evaluate submitted expert plan content before publication. It includes plan details, provider information, weekly schedule, safety notes, review checklist, comments, and decision actions.

**Role supported:** Platform Administrator.

**Key design purpose:** To ensure expert plans are reviewed for safety, beginner suitability, completeness, and consistency with Runiac standards before Premium Users can access them.

**Governance/access-control note:** Medical Trainer/Expert does not publish plans. Only the Platform Administrator can approve and publish expert plans after review.

## Figure 5.5: Plan Management

![Figure 5.5: Plan Management](wireframe-images/platform-admin/plan-management.png)

The Plan Management wireframe supports administrative management of system goal plans and expert plans. It distinguishes System Plan and Expert Plan records and shows lifecycle statuses such as Submitted, Pending Review, Revision Requested, Approved, Published, Archived, and Rejected.

**Role supported:** Platform Administrator.

**Key design purpose:** To provide a controlled interface for searching, creating, viewing, editing, and archiving training plans.

**Governance/access-control note:** Premium expert plans must not create XP or leaderboard scoring advantages. Premium access is controlled by `subscriptionStatus`, while plan publication is controlled by Platform Administrator governance.

## Figure 5.6: Route Management

![Figure 5.6: Route Management](wireframe-images/platform-admin/route-management.png)

The Route Management screen allows the Platform Administrator to search, inspect, and moderate shared routes. It includes a route table, map preview, report details, and actions such as View, Hide, Archive, and Mark as Reviewed.

**Role supported:** Platform Administrator.

**Key design purpose:** To support route safety, privacy, and content moderation for community-shared routes.

**Governance/access-control note:** Route moderation is a safety and governance function. It must not provide Premium Users with XP, rank, leaderboard score, or competitive advantages.

## Figure 5.7: Notification / Report Management

![Figure 5.7: Notification / Report Management](wireframe-images/platform-admin/notification-report-management.png)

The Notification / Report Management wireframe combines administrative notification creation with report handling. It includes notification targeting and history, as well as report review fields and moderation actions.

**Role supported:** Platform Administrator.

**Key design purpose:** To allow administrators to send system notifications and resolve moderation cases from one controlled governance screen.

**Governance/access-control note:** Report actions use soft outcomes such as Resolve, Dismiss, Hide Route, Suspend User, and Archive Content. The screen does not include XP or leaderboard modification controls.

## Figure 5.8: Expert Plan Submission Form

![Figure 5.8: Expert Plan Submission Form](wireframe-images/medical-trainer-expert/expert-plan-submission-form.png)

The Expert Plan Submission Form allows a Medical Trainer/Expert to prepare structured expert plan content for administrative review. It captures expert credentials, plan details, weekly schedule, safety guidance, injury-prevention notes, and a medical disclaimer.

**Role supported:** Medical Trainer/Expert.

**Key design purpose:** To standardise expert plan content submission while keeping publication under administrative control.

**Governance/access-control note:** The screen includes Save Draft and Submit for Admin Review only. It must not include a Publish Plan action.

## Figure 5.9: Submitted Plan Status Page

![Figure 5.9: Submitted Plan Status Page](wireframe-images/medical-trainer-expert/submitted-plan-status-page.png)

The Submitted Plan Status Page allows a Medical Trainer/Expert to track submitted expert plans and respond to revision requests. It shows statuses such as Draft, Submitted, Pending Admin Review, Revision Requested, Approved, Published, Rejected, and Archived.

**Role supported:** Medical Trainer/Expert.

**Key design purpose:** To let experts view submission status, edit drafts, respond to administrator comments, and resubmit plans for review.

**Governance/access-control note:** Medical Trainer/Expert cannot directly publish plans. Published status appears only after Platform Administrator approval and publishing.
