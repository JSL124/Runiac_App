# Runiac Project Roadmap And Phase TODO

## 1. Document Purpose And Boundaries

This document is a project-management support roadmap for Runiac. It helps track the expected Final Year Project phases from the completed PRD through PDD, PTD / Project Progress Report, PUM, backlog preparation, implementation, testing evidence, prototype presentation, and final submission.

This document is not an `AGENTS.md` instruction file. It does not override `PRD.md`, PDD deliverables, future PTD or PUM documents, `AGENTS.md` instruction files, implementation rules, Firebase/security rules, or testing rules. If this roadmap conflicts with a canonical requirements, design, instruction, or implementation document, the canonical document takes priority.

Implementation tasks must not start until IMPLEMENTATION_MODE is explicitly requested. Until then, `implementation/`, `firebase/`, and `tests/` remain instruction-only planning areas and must not be treated as production source folders.

## 2. Current Project Status

| Area | Status | Notes |
| --- | --- | --- |
| PRD | Completed | `PRD.md` is the requirements baseline and contains F1-F10 functional requirements, non-functional requirements, methodology, timeline, platform, database, architecture, and risks. |
| PDD | In progress | `docs/pdd/` contains active PDD design work, including application architecture, physical architecture, component diagram, class diagram, and wireframe descriptions. |
| Implementation | Not started | No Flutter, Firebase, backend, or test implementation should be created until IMPLEMENTATION_MODE is explicitly requested. |

## 3. Phase Overview

| Phase | Primary Output | Status |
| --- | --- | --- |
| PRD Completed | Requirements baseline | Completed |
| PDD In Progress | Design document sections and figures | In progress |
| PTD / Project Progress Report | Technical report and progress explanation | Future |
| PUM / Preliminary User Manual | Role-based user manual | Future |
| User Stories / Product Backlog | Implementable backlog traced to PRD F1-F10 | Future |
| Implementation Planning | Build sequence and technical work plan | Future |
| Flutter/Firebase Implementation | Working prototype/application | Future, blocked until IMPLEMENTATION_MODE |
| Testing / QA Evidence | Test plan, test execution, and evidence | Future |
| Prototype Presentation | Prototype demo and presentation material | Future |
| Final Submission | Final documents, source, evidence, and presentation package | Future |

## 4. Assessment Milestones

| Milestone | Expected Evidence | Runiac Planning Note |
| --- | --- | --- |
| Session 1 Assessment | Preliminary Technical Documentation, Preliminary User Manual, Peer Assessment, Presentation Slides, and Functional Prototype. | PDD should be completed first, then PTD/PUM and prototype preparation should use PRD/PDD as sources. |
| Prototype Demo | Functional product with limited functionalities on the intended platform. | This means a working Flutter/Firebase prototype, not wireframes alone. Wireframes can guide the demo flow before implementation starts. |
| Final Assessment | Finalized documents, implemented system, testing evidence, and project evidence. | Final checks should confirm traceability from PRD to design, implementation, and QA evidence. |
| Final Presentation | Project scope, learning objectives, research findings, development tools, prototype demonstration, and future development. | Presentation should separate completed prototype features from planned future improvements. |
| Final Online Submission | Final report package, source files, evidence, and required submission artifacts. | Submission should exclude unrelated files, secrets, private user data, and sensitive location traces. |

## 5. PRD Completed

### Purpose
Confirm that Runiac has a stable requirements baseline before continuing design and implementation planning.

### TODO Checklist
- [x] Complete market survey and project scope.
- [x] Define target users and user roles.
- [x] Define F1-F10 functional requirements.
- [x] Define non-functional requirements.
- [x] Define selected methodology, platform, database, languages, architecture, and risks.
- [ ] Use PRD F1-F10 as the traceability baseline for future backlog and implementation planning.

### Related Repo Files/Folders
- `PRD.md`
- `PRD_assets/`

### Relevant Agent / Workflow Owner
- A0_ORCH for workflow control.
- A9_TRACE later when converting PRD requirements into backlog and implementation tasks.

### Exit Criteria
- PRD remains stable and available as the source of requirements.
- Later documents and backlog items trace back to PRD scope instead of introducing unrelated features.

### Risks And Boundaries
- Do not change PRD requirements through this roadmap.
- Do not add new app features during later planning unless the PRD is explicitly updated through a separate approved task.

## 6. PDD In Progress

### Purpose
Complete the Project Design Document based on the current PRD and teacher sample expectations for architecture, diagrams, user interface, and entity/data design coverage.

### TODO Checklist
- [x] Prepare application architecture design.
- [x] Prepare physical architecture design.
- [x] Prepare component diagram and component responsibilities.
- [x] Prepare class diagram and data model explanation.
- [x] Prepare mobile, admin, and expert wireframe descriptions.
- [ ] Complete consistency review across PDD sections.
- [ ] Complete output readiness check before commit or submission packaging.
- [ ] Confirm figure references, image paths, captions, and support files are aligned.

### Related Repo Files/Folders
- `docs/pdd/01-application-architecture.md`
- `docs/pdd/02-physical-architecture.md`
- `docs/pdd/03-component-diagram.md`
- `docs/pdd/04-class-diagram.md`
- `docs/pdd/05-wireframe-description.md`
- `docs/pdd/diagrams/`
- `docs/pdd/wireframe-images/`
- `docs/pdd/05-wireframe-image-generation-prompts.md`

### Relevant Agent / Workflow Owner
- A0_ORCH for workflow sequencing.
- A1_APP for application architecture.
- A2_PHYS for physical architecture.
- A3_COMP for component diagram.
- A4_CLASS for class diagram and data model.
- A5_WIRE for wireframe descriptions and PDD_UIUX_DESIGN_MODE.
- A6_REVIEW for consistency review.
- A8_OUTPUT_CHECKER for completeness and readiness.
- A14_ERROR_TRIAGE only for concrete detected errors.

### Exit Criteria
- PDD sections are complete enough for academic submission.
- Diagrams, wireframes, terminology, role rules, and architecture assumptions are consistent.
- No implementation code is placed inside `docs/`.

### Risks And Boundaries
- PDD must not become implementation code.
- Basic User and Premium User must not be modelled as separate subclasses.
- `subscriptionStatus` controls Basic/Premium access.
- `userRole` controls Platform Administrator and Medical Trainer/Expert governance access.
- XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP remain backend-owned.

## 7. PTD / Project Progress Report

### Purpose
Prepare the technical and progress report expected after preliminary design. Based on the teacher sample, this phase should explain implementation rationale, platforms, proposed plan, functional requirements, user stories, use cases, workflow, architecture design, database design, data flow, sequence diagrams, UI design, non-functional requirements, schedule, team organization, and risks.

### TODO Checklist
- [ ] Decide the repository location for PTD / Project Progress Report support files.
- [ ] Document any functionality updates from the PRD without silently changing the approved scope.
- [ ] Prepare an updated WBS or milestone breakdown for remaining work.
- [ ] Update systems design requirements based on the finalized PDD.
- [ ] Explain validation and verification approach for the prototype and final system.
- [ ] Summarize implementation rationale from PRD and PDD.
- [ ] Reuse PRD functional requirements F1-F10 without changing scope.
- [ ] Add user stories or reference the backlog document once created.
- [ ] Include use case, workflow, data flow, and sequence coverage where required.
- [ ] Include database and data ownership design consistent with PDD.
- [ ] Include UI design references from PDD wireframes.
- [ ] Include NFRs, schedule, team organization, and project risks.

### Related Repo Files/Folders
- `PRD.md`
- `docs/pdd/`
- Future PTD or progress report folder, if created.

### Relevant Agent / Workflow Owner
- A0_ORCH for scope and sequencing.
- A9_TRACE for requirement traceability.
- A6_REVIEW for consistency with PRD/PDD.
- A8_OUTPUT_CHECKER for completeness before readiness.

### Exit Criteria
- PTD / Project Progress Report explains how the design will become a buildable system.
- Technical choices remain consistent with Flutter, Firebase, Firestore, Cloud Functions, and backend-owned trusted calculations.

### Risks And Boundaries
- Do not duplicate PDD content so heavily that files drift apart.
- Do not create production implementation files while writing PTD.
- Do not introduce database fields, APIs, or implementation details that conflict with PRD/PDD.

## 8. PUM / Preliminary User Manual

### Purpose
Prepare a role-based preliminary user manual that explains how intended users interact with Runiac screens and workflows.

### TODO Checklist
- [ ] Decide the repository location for PUM support files.
- [ ] Create prerequisites and account access assumptions.
- [ ] During PDD, use wireframes to draft the manual structure and expected screen coverage.
- [ ] After the functional prototype exists, use or add prototype screenshots for major functionalities.
- [ ] Document role-based usage steps for Basic User mobile workflows.
- [ ] Document role-based usage steps for Premium User mobile workflows.
- [ ] Document role-based usage steps for Platform Administrator governance workflows.
- [ ] Document role-based usage steps for Medical Trainer/Expert submission workflows.
- [ ] Add screen descriptions and usage steps based on PDD wireframes first, then update them against prototype screens.
- [ ] Keep troubleshooting and safety notes user-facing, not implementation-focused.

### Related Repo Files/Folders
- `docs/pdd/05-wireframe-description.md`
- `docs/pdd/wireframe-images/`
- Future PUM folder, if created.

### Relevant Agent / Workflow Owner
- A0_ORCH for scope.
- A5_WIRE for UI and screen-description alignment.
- A6_REVIEW for terminology and role consistency.
- A8_OUTPUT_CHECKER for readiness.

### Exit Criteria
- PUM is role-based and readable by non-developer users.
- Major prototype functionalities are supported by screenshots or equivalent visual evidence once the prototype exists.
- Basic User, Premium User, Platform Administrator, and Medical Trainer/Expert flows are separated clearly.

### Risks And Boundaries
- Do not describe unimplemented or out-of-scope features as available.
- Do not expose sensitive data, private GPS route details, or admin-only operations as normal user actions.
- Do not imply Medical Trainer/Expert can directly publish expert plans.

## 9. User Stories / Product Backlog

### Purpose
Convert PRD requirements into implementable backlog items that can guide development without changing the agreed project scope.

### TODO Checklist
- [ ] Create epics aligned to PRD F1-F10.
- [ ] Write user stories for Basic User, Premium User, Platform Administrator, and Medical Trainer/Expert where relevant.
- [ ] Add acceptance criteria for each story.
- [ ] Add priority labels such as MVP, should-have, future extension, or out-of-scope.
- [ ] Group stories by sprint, milestone, or assessment phase.
- [ ] Record dependencies between stories, screens, backend rules, and test evidence.
- [ ] Mark each story as MVP, future extension, or out-of-scope.
- [ ] Link stories to PDD screens, components, classes, and backend responsibilities.
- [ ] Separate implementation tasks from documentation tasks.

### Related Repo Files/Folders
- `PRD.md`
- `docs/pdd/`
- Future backlog or project-management file.

### Relevant Agent / Workflow Owner
- A0_ORCH for phase control.
- A9_TRACE for PRD/PDD traceability.
- A6_REVIEW for consistency checks.

### Exit Criteria
- Each backlog item traces to PRD F1-F10 or an approved non-functional requirement.
- No story invents new product features beyond the PRD.
- MVP and future extension boundaries are clear.
- Priority, grouping, and dependency information is present before implementation planning begins.

### Risks And Boundaries
- Do not add new features just because they seem useful.
- Do not allow Premium stories to create XP, rank, leaderboard score, or competitive advantages.
- Do not allow client-side stories to write backend-owned trusted values.

## 10. Implementation Planning

### Purpose
Plan the build sequence before implementation begins, so Flutter, Firebase, backend logic, access control, and QA work are coordinated.

### TODO Checklist
- [ ] Confirm IMPLEMENTATION_MODE has been explicitly requested before creating production code.
- [ ] Decide initial Flutter project structure when implementation starts.
- [ ] Decide Firebase setup sequence when implementation starts.
- [ ] Plan authentication, user profile, subscription, and role enforcement.
- [ ] Plan run tracking, activity storage, plan selection, routes, leaderboard, and post-run summary implementation order.
- [ ] Plan backend-owned XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP processing.
- [ ] Plan QA evidence and security review checkpoints.

### Related Repo Files/Folders
- `implementation/AGENTS.md`
- `implementation/AGENT_ROLES.md`
- `firebase/AGENTS.md`
- `tests/AGENTS.md`
- Future production source folders after implementation starts.

### Relevant Agent / Workflow Owner
- A0_ORCH for mode control.
- A9_TRACE for mapping requirements to tasks.
- A10_FLUTTER_IMPL for Flutter planning once implementation begins.
- A11_FIREBASE_IMPL for backend planning once implementation begins.
- A13_SECURITY_RULES for trusted writes and access control.
- A12_QA_TEST for test planning.

### Exit Criteria
- Build order is clear.
- Implementation can start without changing PRD/PDD scope.
- Security, access control, and backend-owned trusted values are planned before coding.

### Risks And Boundaries
- Do not start implementation without explicit IMPLEMENTATION_MODE.
- Do not treat UI hiding as the only Premium enforcement.
- Do not place production source code inside `docs/`.

## 11. Flutter/Firebase Implementation

### Purpose
Build the Runiac mobile app and backend services according to PRD, PDD, PTD, and backlog scope.

### TODO Checklist
- [ ] Start only after the user explicitly requests IMPLEMENTATION_MODE.
- [ ] Create Flutter app structure and navigation.
- [ ] Implement authentication and profile setup.
- [ ] Implement Basic/Premium feature presentation with backend-backed entitlement checks.
- [ ] Implement running plan, run tracking, route exploration, leaderboard, and post-run summary flows.
- [ ] Implement Firebase Auth, Firestore, Cloud Functions, FCM, Storage, and security rules where required.
- [ ] Keep XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP backend-owned.
- [ ] Add tests or manual QA evidence as implementation progresses.

### Related Repo Files/Folders
- Future Flutter project files.
- Future Firebase/backend files.
- `implementation/`
- `firebase/`
- `tests/`

### Relevant Agent / Workflow Owner
- A0_ORCH for workflow sequencing.
- A10_FLUTTER_IMPL for Flutter client work.
- A11_FIREBASE_IMPL for Firebase/backend work.
- A13_SECURITY_RULES for security and access-control checks.
- A12_QA_TEST for verification.
- A6_REVIEW if implementation decisions affect architecture, data model, roles, entitlements, XP, streaks, levels, ranks, or leaderboards.

### Exit Criteria
- MVP prototype is functional enough for testing and presentation.
- Trusted writes are protected by backend/security rules rather than client-only logic.
- Implementation remains traceable to PRD/PDD/backlog.

### Risks And Boundaries
- Do not let Flutter directly write trusted progression or ranking values.
- Do not let Premium users gain competitive scoring advantages.
- Do not let Medical Trainer/Expert publish expert plans directly.
- Do not add production implementation files during documentation-only phases.

## 12. Testing / QA Evidence

### Purpose
Produce evidence that the implemented Runiac system works against requirements, access rules, core workflows, and project constraints.

### TODO Checklist
- [ ] Create a test plan mapped to PRD F1-F10 and NFRs.
- [ ] Prepare manual QA scripts for mobile user, admin, and expert workflows.
- [ ] Test Basic/Premium access through `subscriptionStatus`.
- [ ] Test governance access through `userRole`.
- [ ] Test backend-owned XP, streak, level, rank, and leaderboard updates.
- [ ] Test privacy-sensitive route and activity data handling.
- [ ] Record test execution evidence, results, defects, and fixes.

### Related Repo Files/Folders
- `tests/AGENTS.md`
- Future test files or QA evidence folders.
- Future implementation files.

### Relevant Agent / Workflow Owner
- A12_QA_TEST for test planning and evidence.
- A13_SECURITY_RULES for security and trusted-write checks.
- A10_FLUTTER_IMPL and A11_FIREBASE_IMPL for implementation fixes found by testing.
- A8_OUTPUT_CHECKER for readiness checks.

### Exit Criteria
- Test evidence supports final submission.
- Known critical issues are fixed or clearly documented.
- Core MVP flows are verified.

### Risks And Boundaries
- Do not include precise private location data in public screenshots, logs, or evidence.
- Do not mark testing complete without clear evidence.
- Do not use tests to justify adding new features outside PRD scope.

## 13. Prototype Presentation

### Purpose
Prepare a presentation that explains the project scope, learning objectives, research findings, development tools, prototype demonstration, and future development direction.

### TODO Checklist
- [ ] Summarize Runiac project scope and beginner-runner focus.
- [ ] Summarize learning objectives and research findings.
- [ ] Explain development tools and platform choices.
- [ ] Prepare prototype demo flow.
- [ ] Prepare a timed demo script for the prototype presentation slot.
- [ ] Prepare demo account and test data assumptions that avoid private or sensitive data.
- [ ] Prepare fallback screenshots or a short recording in case the live demo fails.
- [ ] Show key Basic User, Premium User, Platform Administrator, and Medical Trainer/Expert workflows as relevant.
- [ ] Separate completed prototype features from future development items.
- [ ] Explain future development without overstating completed work.

### Related Repo Files/Folders
- `PRD.md`
- `docs/pdd/`
- Future implementation files and screenshots.
- Future presentation folder, if created.

### Relevant Agent / Workflow Owner
- A0_ORCH for scope.
- A8_OUTPUT_CHECKER for ensuring presentation inputs are complete.
- A12_QA_TEST for demo readiness evidence after implementation.

### Exit Criteria
- Presentation accurately reflects completed work.
- Prototype demo path is rehearsed and supported by evidence.
- Future work is clearly separated from implemented scope.
- Fallback screenshots or recording are ready if live demonstration is not reliable.

### Risks And Boundaries
- Do not claim future extension features as completed.
- Do not expose private user data in demo screenshots or logs.
- Do not present UI wireframes as implemented screens unless the prototype matches them.

## 14. Final Submission

### Purpose
Prepare the final submission package with all required documents, source code, test evidence, presentation material, and any required appendices.

### TODO Checklist
- [ ] Confirm final PRD, PDD, PTD / progress report, PUM, backlog, implementation, QA evidence, and presentation files.
- [ ] Check document consistency and formatting.
- [ ] Check source code and configuration are ready for submission.
- [ ] Check test evidence and demo materials are included.
- [ ] Confirm no unrelated temporary files or private data are included.
- [ ] Prepare final version notes and submission checklist.

### Related Repo Files/Folders
- Repo-wide final deliverables.
- `PRD.md`
- `docs/pdd/`
- Future PTD, PUM, backlog, implementation, Firebase, tests, and presentation files.

### Relevant Agent / Workflow Owner
- A0_ORCH for final sequencing.
- A8_OUTPUT_CHECKER for final readiness.
- A6_REVIEW for final consistency where needed.
- A12_QA_TEST for test evidence confirmation.
- A13_SECURITY_RULES for privacy and access-control evidence.

### Exit Criteria
- Final submission is complete, consistent, and traceable to project requirements.
- Required files are present and unrelated or sensitive files are excluded.

### Risks And Boundaries
- Do not rush final submission without checking consistency between documents and prototype.
- Do not stage or submit unrelated files.
- Do not include secrets, private data, or sensitive location traces.

## 15. Cross-Phase Risks And Boundaries

- PRD is the requirements baseline; roadmap items must trace back to PRD F1-F10 or documented non-functional requirements.
- PDD describes design; it must not become production implementation.
- PTD and PUM should reference PRD/PDD rather than silently changing scope.
- Product backlog items must not invent new features.
- Implementation requires explicit IMPLEMENTATION_MODE.
- Flutter client must not directly write XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP.
- Premium features must add value without giving competitive scoring advantages.
- Medical Trainer/Expert must not directly publish expert plans.
- Platform Administrator remains the governance role for expert plan approval and publication.
- Sensitive route, activity, profile, and running metric data must be handled carefully in documentation, testing evidence, and demos.

## 16. Next Immediate TODO

The immediate priority is completing the current PDD phase before starting PTD, PUM, backlog, or implementation work.

- [ ] Finish any remaining PDD wireframe, figure, or prompt planning work.
- [ ] Run A6_REVIEW for PDD consistency where recent changes affect PDD support files.
- [ ] Run A8_OUTPUT_CHECKER before declaring PDD deliverables ready.
- [ ] Keep implementation planning as documentation only until IMPLEMENTATION_MODE is explicitly requested.
- [ ] After PDD readiness, plan PTD / Project Progress Report structure using PRD and PDD as sources.
