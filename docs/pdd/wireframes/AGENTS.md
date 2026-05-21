# Runiac PDD Wireframe Instructions

## Scope
- Applies to PDD wireframe descriptions, wireframe prompt sets, figure insertion text, and admin/expert wireframe assets.
- Keep wireframes PDD-level and explanatory.
- Do not add implementation code.

## PDD_UIUX_DESIGN_MODE
- PDD_UIUX_DESIGN_MODE is a controlled PDD preparation mode for reviewing, refining, and documenting Runiac wireframes.
- A0_ORCH owns routing and workflow coordination. A5_WIRE owns this mode and performs the wireframe-specific UI/UX design work.
- Use this mode for reviewing wireframe flows, preparing PDD wireframe descriptions, checking UI consistency across screens, reviewing design-level accessibility or usability issues, aligning wireframes with PRD features, and preparing implementation handoff notes without writing Flutter code.
- Use Nielsen Norman Group's 10 usability heuristics as usability review guidance.
- Use WCAG 2.2 principles as design-level accessibility review guidance.
- Use Flutter accessibility awareness for design considerations such as tappable targets, labels, semantics, feedback, and recoverable errors.
- Use Material Design 3 / Flutter-compatible UI concepts as the main mobile UI consistency reference.
- These references are design-review guidance only. Do not claim legal, production, or implementation-level accessibility compliance from wireframe or PDD review.

## PDD_UIUX_DESIGN_MODE Allowed Actions
- Update Markdown documentation.
- Add or update wireframe description guidance.
- Add UI/UX review checklists.
- Add PDD figure insertion text templates.
- Add UI consistency rules.
- Add accessibility review criteria.
- Recommend wireframe improvements in text.
- Add implementation handoff notes only as documentation, not source code.

## PDD_UIUX_DESIGN_MODE Prohibited Actions
- Do not modify binary image files.
- Do not rename existing wireframe images.
- Do not create Flutter implementation files.
- Do not create Firebase implementation files.
- Do not create test implementation files.
- Do not change Firebase architecture.
- Do not add new PRD features.
- Do not change user roles without explicit instruction.
- Do not convert Basic User and Premium User into separate class diagram subclasses.
- Do not allow client-side writing of XP, streak, level, leaderboard score, rank, weekly XP, or monthly XP.
- Do not make broad redesigns unless justified by PRD alignment, usability, accessibility, or PDD clarity.
- Do not claim WCAG compliance or production accessibility compliance from wireframe-only review.
- Do not restore, stage, or rename legacy `wireframe_assets/` unless explicitly requested.

## PDD_UIUX_DESIGN_MODE Checklist

When PDD_UIUX_DESIGN_MODE is active, check:

### 1. PRD Traceability
- Which PRD feature does this screen support?
- Is the screen consistent with the current Runiac scope?
- Is the screen clearly MVP, future extension, or out-of-scope?

### 2. User Flow Clarity
- Can a beginner runner understand the next action?
- Is the flow too deep or confusing?
- Are back actions and next actions clear?
- Are destructive or irreversible actions protected by confirmation where needed?

### 3. Role and Subscription Clarity
- Is Basic/Premium/Admin/Expert behavior clear?
- Are Premium locked states understandable and not hostile?
- Is Medical Trainer/Expert prevented from publishing directly?
- Is Platform Administrator clearly responsible for approval, publish, archive, reject, hide, suspend, deactivate, or dismiss actions where relevant?

### 4. Navigation Consistency
- Are bottom tabs consistent?
- Is profile/settings access consistent?
- Are CTA labels consistent?
- Are map overlays and modal screens used consistently?
- Are screen titles and figure names consistent with existing wireframe asset names?

### 5. State Coverage
- Empty state.
- Loading state.
- Error state.
- Permission denied state.
- GPS unavailable state.
- Location permission denied state.
- Network unavailable state.
- No route found state.
- No plan selected state.
- Subscription locked state.
- Route privacy or restricted access state where relevant.

### 6. Accessibility and Usability
- Clear labels.
- Readable text.
- Tap target awareness.
- Contrast awareness.
- Screen-reader-friendly semantics.
- Clear feedback and error recovery.
- Non-color-only indicators.
- Map-heavy screens should provide non-map textual support where appropriate.

### 7. PDD Readiness
- Figure title.
- Screen purpose.
- Main user actions.
- Related PRD features.
- Role relevance.
- Notes for insertion into the PDD.
- Whether the figure belongs in final PDD prose or support documentation only.

### 8. Severity Classification
- Critical: blocks PRD/PDD correctness, role governance, or core user flow.
- Major: creates serious UX confusion, missing state coverage, or inconsistent PDD explanation.
- Minor: local wording, naming, layout, or consistency issue.
- Suggestion: optional improvement that should not block readiness.

## PDD_UIUX_DESIGN_MODE Output Format
- Scope reviewed.
- Screens or files affected.
- PRD feature traceability.
- UX findings with severity.
- Accessibility findings with severity.
- UI consistency findings with severity.
- PDD insertion notes if relevant.
- Recommended changes.
- Risks or assumptions.
- Whether A6_REVIEW, A8_OUTPUT_CHECKER, or A14_ERROR_TRIAGE should run next.

## Required Platform Administrator Wireframes
- Admin Dashboard
- User Management
- User Detail / Role Control
- Expert Plan Review
- Plan Management
- Route Management
- Notification / Report Management

## Required Medical Trainer/Expert Wireframes
- Expert Plan Submission Form
- Submitted Plan Status Page

## Wireframe Rules
- If broken wireframe image paths, duplicate wireframe sections, missing canonical/support labels, or admin/expert governance wording errors are found, route to A14_ERROR_TRIAGE for minimal correction, then return to A6_REVIEW and A8_OUTPUT_CHECKER.
- Medical Trainer/Expert screens must not include a Publish button.
- Expert Plan Submission Form uses Save Draft and Submit for Admin Review.
- Submitted Plan Status Page does not include a Publish button.
- Platform Administrator screens use web/admin dashboard style.
- Medical Trainer/Expert screens use controlled web submission portal style.
- Admin-visible XP, level, streak, rank, and leaderboard data must be read-only.
- Destructive actions should normally be Archive, Hide, Suspend, Deactivate, Reject, or Dismiss rather than hard delete.
- Basic/Premium access uses `subscriptionStatus`.
- Operational/governance access uses `userRole`.
- Premium users must not receive XP, rank, leaderboard score, or competitive advantages.
- Wireframe image prompts should be low-fidelity black-and-white prompts suitable for PDD image generation.
- UI/UX review findings should be handled by A5_WIRE unless they are concrete errors requiring A14_ERROR_TRIAGE.
- A6_REVIEW should run after A5_WIRE modifies wireframe or UI/UX documentation.
- A8_OUTPUT_CHECKER should run before declaring the wireframe deliverable ready for commit or final PDD insertion.
- A14_ERROR_TRIAGE is correction-only. Use it only for directly observed errors such as broken paths, missing referenced figures, contradictory role rules, invalid generated diagram output, or clear mismatch between a file reference and existing repository content.

## Layered Review-Pass Routing
- Do not create a new review agent for wireframe or UI/UX review.
- Use a layered review-pass model instead of one monolithic review agent.
- For PDD wireframe work, use: A5_WIRE -> A6_REVIEW -> A8_OUTPUT_CHECKER.
- Use A14_ERROR_TRIAGE only if a concrete detected error requires a minimal scoped fix.
- A5_WIRE performs wireframe-specific UI/UX review under PDD_UIUX_DESIGN_MODE.
- A6_REVIEW performs cross-document consistency review and is not a completeness checker.
- A8_OUTPUT_CHECKER performs final completeness and deliverable-readiness review and is not a broad consistency reviewer.
- A14_ERROR_TRIAGE is not a design owner, reviewer, or output checker.
- A5_WIRE should not declare final readiness alone; final readiness requires A6_REVIEW and A8_OUTPUT_CHECKER after A5_WIRE changes.
- This model avoids one monolithic review agent because UI/UX, consistency, completeness, and concrete error correction require different review lenses. Keep the existing agent numbering and use separate review passes rather than adding more numbered review agents.

## Expert Plan Governance Flow
Medical Trainer/Expert submits plan content -> plan enters admin review queue -> Platform Administrator reviews -> approve / request revision / reject -> Platform Administrator publishes approved plans -> Premium User can view/select published expert plans.

## Canonical Wireframe Files
- `docs/pdd/05-wireframe-description.md` is the canonical final wireframe description file.
- `docs/pdd/05-final-wireframe-section.md` is a support or duplicate/draft file unless existing repository notices say otherwise.
- `docs/pdd/05-final-wireframe-insertion-order.md` is a support file for figure ordering.
- `docs/pdd/05-admin-expert-wireframe-figure-insert.md` is a support file for admin/expert figure insertion.
- `docs/pdd/05-wireframe-image-generation-prompts.md` is a prompt asset, not final PDD prose.
- `docs/pdd/wireframe-images/` is the canonical PDD wireframe image structure.
- Legacy `wireframe_assets/` should be treated as source/history only unless migration or restoration is explicitly requested.

## Privacy Guidance
- Treat GPS route data, activity history, profile data, and running metrics as sensitive user data.
- Avoid exposing exact private route history unless the user explicitly shares it.
- Do not include precise private location data in screenshots, logs, test evidence, or public documentation.
- Route sharing should use user-controlled visibility.
