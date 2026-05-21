# Runiac PDD Agent Instructions

## PDD_MODE Scope
- PDD_MODE is used for Project Design Document preparation.
- Do not write implementation code unless explicitly asked.
- Do not modify Flutter, Firebase, backend, Cloud Functions, tests, or production implementation files.
- Keep PDD outputs academic, concise, and realistic for a university FYP.

## Required PDD Deliverables
1. Application Architecture
2. Physical Architecture
3. Component Diagram
4. Class Diagram
5. Wireframe descriptions

Canonical deliverable files:
- `docs/pdd/01-application-architecture.md`
- `docs/pdd/02-physical-architecture.md`
- `docs/pdd/03-component-diagram.md`
- `docs/pdd/04-class-diagram.md`
- `docs/pdd/05-wireframe-description.md`

Support files such as `docs/pdd/00-orchestration-plan.md`, `docs/pdd/05-final-wireframe-section.md`, `docs/pdd/05-final-wireframe-insertion-order.md`, `docs/pdd/05-admin-expert-wireframe-figure-insert.md`, and `docs/pdd/05-wireframe-image-generation-prompts.md` are planning, draft, figure-insertion, or prompt assets. They are not canonical final deliverables unless explicitly promoted.

## PDD Documentation Rules
- Produce PDD-ready explanation.
- Use clear academic wording without overcomplicated enterprise architecture.
- Preserve heading hierarchy unless restructuring is required.
- Keep terminology consistent: Basic User, Premium User, Platform Administrator, Medical Trainer/Expert.
- Separate MVP assumptions, future extensions, and out-of-scope items.
- Do not mix PDD content, implementation planning, and production source code in the same Markdown file.
- After editing Markdown, check duplicated sections, terminology consistency, broken figure references, and whether diagrams, wireframes, or class model are affected.
- Treat `docs/pdd/00-orchestration-plan.md` as planning context, not the active instruction source.

## PDD Workflow
- A0_ORCH owns the workflow and chooses the needed PDD role.
- PDD work stops at Ready for commit by default. If auto-commit is not allowed, provide manual git commands following the root `AGENTS.md` Commit Protocol. PDD deliverable changes are not auto-committed unless separately authorized.
- Use A1_APP, A2_PHYS, A3_COMP, A4_CLASS, or A5_WIRE based on the affected deliverable.
- Use PDD_UIUX_DESIGN_MODE for wireframe flow review, UI consistency review, design-level accessibility/usability review, PRD alignment of screens, and wireframe implementation handoff notes. A5_WIRE owns this mode; detailed rules live in `docs/pdd/wireframes/AGENTS.md`.
- Apply PDD_REVIEW_GATE after PDD documentation, diagram, wireframe, or instruction-system tasks to decide whether A6_REVIEW, A8_OUTPUT_CHECKER, both, or neither are required.
- When PDD_REVIEW_GATE requires A6_REVIEW and A8_OUTPUT_CHECKER, do not merely recommend them. Actually run A6_REVIEW after the edit, and if A6_REVIEW passes, run A8_OUTPUT_CHECKER in the same task where feasible.
- If A6_REVIEW or A8_OUTPUT_CHECKER finds issues, route back to the correct specialist role, correct the issue, and review again.
- Use A14_ERROR_TRIAGE only when A6_REVIEW or A8_OUTPUT_CHECKER finds concrete fixable errors such as broken paths, missing referenced figures, invalid PlantUML output, contradictory role rules, or directly observed mismatches. A14 must apply the smallest safe correction, then route back to A6_REVIEW and A8_OUTPUT_CHECKER.
- A14 must not introduce new architecture decisions or rewrite large sections unless explicitly requested.
- A14 must not become a second design owner, broad reviewer, or completeness checker.
- In PDD_MODE, A14 must not modify implementation, Firebase, test, or production source files.
- A7_AGENT_ROUTER is only for new, ambiguous, or unclear task categories.
- Use A15_AGENT_AUDITOR only for inspect-only AGENTS instruction-system audits, not for PDD deliverable review or readiness checking.

## PDD_REVIEW_GATE

Purpose: A0_ORCH uses PDD_REVIEW_GATE to decide whether a task requires no review, A6_REVIEW only, A6_REVIEW plus A8_OUTPUT_CHECKER, or A14_ERROR_TRIAGE through the bounded error-fix loop.

PDD_REVIEW_GATE is a workflow decision rule owned by A0_ORCH. It does not create a new numbered agent, does not renumber existing agents, and does not make A15_AGENT_AUDITOR responsible for PDD review decisions.

### Mandatory A6_REVIEW + A8_OUTPUT_CHECKER

A6_REVIEW and A8_OUTPUT_CHECKER are mandatory before Ready for commit when a scoped PDD documentation apply task modifies any canonical PDD deliverable:
- `docs/pdd/01-application-architecture.md`
- `docs/pdd/02-physical-architecture.md`
- `docs/pdd/03-component-diagram.md`
- `docs/pdd/04-class-diagram.md`
- `docs/pdd/05-wireframe-description.md`

A6_REVIEW and A8_OUTPUT_CHECKER are also mandatory before Ready for commit when a scoped PDD documentation apply task modifies any support file that affects figures, ordering, prompts, or references:
- `docs/pdd/05-final-wireframe-section.md`
- `docs/pdd/05-final-wireframe-insertion-order.md`
- `docs/pdd/05-admin-expert-wireframe-figure-insert.md`
- `docs/pdd/05-wireframe-image-generation-prompts.md`

A6_REVIEW and A8_OUTPUT_CHECKER are mandatory in these additional cases:
- Diagram or wireframe image path changes.
- Figure numbering, caption, or insertion order changes.
- PRD feature traceability changes.
- User role, `subscriptionStatus`, `userRole`, Basic/Premium, Admin/Expert, or governance wording changes.
- Backend-owned value rules change or are referenced: XP, streak, level, rank, leaderboard score, weekly XP, monthly XP.
- The user asks to continue workflow, prepare for commit, ready the change, or run review.
- The response intends to say Ready for commit.

For mandatory cases:
- Do not merely recommend A6_REVIEW or A8_OUTPUT_CHECKER.
- Actually run A6_REVIEW after the edit.
- If A6_REVIEW passes, actually run A8_OUTPUT_CHECKER in the same task where feasible.
- Ready for commit may only be reported after A6_REVIEW passes, A8_OUTPUT_CHECKER passes, `git status --short` is checked, and exact files to stage are listed.

### A6_REVIEW Only

A0_ORCH may require A6_REVIEW without A8_OUTPUT_CHECKER when a task changes PDD consistency assumptions but is not being readied for commit and does not affect deliverable completeness, figure readiness, image paths, captions, insertion order, or output packaging. If the user later asks for Ready for commit, A8_OUTPUT_CHECKER becomes mandatory before readiness is reported.

### Light Or No-Review Cases

A6_REVIEW and A8_OUTPUT_CHECKER are not mandatory for:
- Plan-only tasks.
- Inspect-only tasks.
- Search/find-only tasks.
- Review-only tasks with no file modifications.
- No-op checks.
- Typo-only edits that do not alter meaning, paths, figure references, scope, roles, or workflow behavior.
- Project-management support documents that do not affect PDD deliverables, unless the user asks for readiness.

For light or no-review cases:
- A0_ORCH should report why A6_REVIEW and A8_OUTPUT_CHECKER are not required.
- If the user asks for Ready for commit anyway, run A8_OUTPUT_CHECKER at minimum and run A6_REVIEW if consistency could be affected.

### A14_ERROR_TRIAGE Routing

If A6_REVIEW or A8_OUTPUT_CHECKER finds a concrete, verifiable issue, route to A14_ERROR_TRIAGE through BOUNDED_ERROR_FIX_REVIEW_LOOP. Examples include a broken figure reference, mismatched figure number, missing image path, contradictory role rule, invalid PlantUML/rendered diagram mismatch, or canonical/support file contradiction.

A14_ERROR_TRIAGE must apply only the smallest scoped fix, return to the same reviewer that found the issue, and must not declare readiness.

### Required PDD_REVIEW_GATE Output

When A0_ORCH applies PDD_REVIEW_GATE, report:
1. Task type.
2. Files changed or expected to change.
3. Review gate decision: No review required, A6 only, A6 + A8 required, or A14 loop required.
4. Reason for the decision.
5. Next required role.
6. Ready-for-commit status if applicable.

## PDD Review-Pass Model
- Do not create a monolithic review agent for PDD work.
- Use separate review passes because UI/UX design, cross-document consistency, deliverable completeness, and concrete error correction require different review lenses.
- For PDD wireframe work, use: A5_WIRE -> A6_REVIEW -> A8_OUTPUT_CHECKER.
- Use A14_ERROR_TRIAGE only if a concrete error is found.
- A5_WIRE owns UI/UX and wireframe-specific design review, but it must not declare final readiness alone.
- Final readiness requires A6_REVIEW and A8_OUTPUT_CHECKER after A5_WIRE changes.

## BOUNDED_ERROR_FIX_REVIEW_LOOP

Purpose: allow concrete errors found during review to be fixed and re-reviewed in a controlled loop until the issue is resolved or safely blocked.

Use this loop only when A6_REVIEW or A8_OUTPUT_CHECKER identifies a concrete, verifiable error, such as a broken figure reference, inconsistent figure numbering, broken image path, contradictory role rule, invalid PlantUML source or rendered output, Markdown formatting error, mismatched canonical/support file guidance, or direct contradiction between scoped PDD documents.

Do not use this loop for broad redesign, new feature planning, subjective UI preference changes, large restructuring, implementation work, speculative improvements, or unrelated cleanup.

Required flow:
1. A6_REVIEW or A8_OUTPUT_CHECKER identifies the concrete issue and states the exact file(s), exact problem, expected correction, and pass condition.
2. A14_ERROR_TRIAGE applies the smallest scoped fix only.
3. The same review role that found the issue rechecks the same scoped files.
4. If the issue is resolved, continue normal workflow: after A6_REVIEW passes, run A8_OUTPUT_CHECKER; after A8_OUTPUT_CHECKER passes, report Ready for commit.
5. If the issue remains, repeat the loop only if the issue is still concrete, the scope has not expanded, and the next fix is still minimal.
6. Stop after a maximum of two A14_ERROR_TRIAGE fix attempts for the same issue.
7. If the issue still fails after two A14 attempts, stop as Blocked and report the remaining issue, files involved, why it could not be resolved safely, and the user decision needed.

Loop constraints:
- Do not use `git add .`.
- Do not stage unrelated files.
- Do not modify binary image files unless the original task explicitly permits it.
- Do not restore deleted legacy `wireframe_assets/` files unless explicitly requested.
- Do not broaden scope after the loop starts.
- Do not combine multiple unrelated fixes into one loop.
- Do not let A14_ERROR_TRIAGE decide final readiness.
- A14_ERROR_TRIAGE must route back to A6_REVIEW or A8_OUTPUT_CHECKER after fixing.
- A8_OUTPUT_CHECKER is the only role that may declare final deliverable readiness.
- Final readiness must include `git status --short` and exact files to stage.

When the loop is used, report:
1. Issue detected.
2. Reviewing role.
3. Fixing role.
4. Attempt number.
5. Files in scope.
6. Fix applied.
7. Re-review result.
8. Pass/fail.
9. If pass, next workflow step.
10. If fail, whether another attempt is allowed.
11. If blocked, exact reason and user decision needed.

## PDD Role Summary
- A0_ORCH: coordinates full PDD tasks until Ready for commit, Committed, or Blocked.
- A1_APP: application architecture.
- A2_PHYS: physical architecture.
- A3_COMP: component responsibilities and component diagram.
- A4_CLASS: class diagram and data model.
- A5_WIRE: wireframe descriptions, prompts, figure insertion, and PDD_UIUX_DESIGN_MODE.
- A6_REVIEW: consistency review, not completeness.
- A7_AGENT_ROUTER: exception routing for unclear tasks.
- A8_OUTPUT_CHECKER: completeness and deliverable readiness, not consistency.
- A14_ERROR_TRIAGE: concrete error detection and minimal scoped fixes before returning to review.
- A15_AGENT_AUDITOR: inspect-only AGENTS instruction-system audit role; not a PDD deliverable reviewer and not a readiness checker.

Detailed PDD role profiles, the Agent Boundary Matrix, handoff rules, and conflict-resolution rules are in `docs/pdd/AGENT_ROLES.md`.

## A15 Instruction-System Audit Routing

Use A15_AGENT_AUDITOR when the user asks whether the AGENTS structure is efficient; asks to inspect AGENTS.md files only; asks whether a new agent is needed; asks to find duplicated, conflicting, or unclear AGENTS rules; asks to audit role boundaries, numbering, or instruction drift; asks whether root `AGENTS.md` or folder-specific `AGENTS.md` files have grown too long; or asks whether instruction-system cleanup is needed.

Do not use A15_AGENT_AUDITOR for PDD content consistency review, PDD output completeness review, concrete bug fixing, Flutter/Firebase/test implementation review, wireframe UI/UX review, or diagram correctness review. Use A6_REVIEW, A8_OUTPUT_CHECKER, A14_ERROR_TRIAGE, A5_WIRE, or the relevant implementation/testing role instead.

## Runiac PDD Constraints
- Basic/Premium access uses `subscriptionStatus`.
- Governance roles use `userRole`.
- Medical Trainer/Expert cannot directly publish expert plans.
- Platform Administrator owns expert plan review, approval, publishing, update, and archive.
- XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, and leaderboard aggregation remain server-side.
- Flutter client must not directly write trusted progression or ranking values.
- Premium users must not receive XP, ranking, leaderboard score, or competitive advantages.
- Basic User and Premium User are not separate subclasses.

## A8 PDD Checklist
A8_OUTPUT_CHECKER must check:
- Application Architecture exists.
- Physical Architecture exists.
- Component Diagram exists.
- Class Diagram exists.
- Wireframe descriptions exist.
- Required admin/expert wireframe descriptions or prompt sets are present when relevant.
- Figure references and captions are present where needed.
- Terminology is consistent.
- No production source code is placed inside `docs/`.
