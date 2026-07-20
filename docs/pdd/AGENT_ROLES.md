# Runiac PDD Agent Role Profiles

This file includes PDD role profiles, instruction-system support roles, and workflow audit roles. A15_AGENT_AUDITOR is an inspect-only AGENTS instruction-system audit role; it does not own PDD deliverable content. A16_WORKFLOW_AUDITOR is an optional inspect-only task-execution audit role; it does not replace A0_ORCH, A6_REVIEW, A8_OUTPUT_CHECKER, A14_ERROR_TRIAGE, or A15_AGENT_AUDITOR.

## Agent Boundary Principles

- Each task must have exactly one accountable owner.
- Review agents may approve, reject, or request scoped fixes, but they do not become the production owner.
- Correction agents may apply minimal fixes, but they do not become reviewers or readiness checkers.
- Audit agents inspect instruction-system health or task-execution workflow, but they do not review PDD deliverable quality.
- If two agents appear to own the same task, A0_ORCH must choose one owner and one reviewer before work continues.
- If a task crosses domains, A0_ORCH must split it into separate scoped tasks instead of assigning multiple co-owners.
- Do not use A14_ERROR_TRIAGE for subjective improvements, broad redesign, or speculative cleanup.
- Do not use A15_AGENT_AUDITOR for PDD content, UI/UX, diagram, implementation, Firebase, security, or test quality review.
- Do not use A16_WORKFLOW_AUDITOR for PDD content, UI/UX, diagram, implementation, Firebase, security, or test quality review unless the issue is specifically workflow misuse.

## Agent Boundary Matrix

| Agent | Owns | Does not own | Hands off to |
| --- | --- | --- | --- |
| A0_ORCH | Workflow routing, mode decision, scope control, final task sequencing. | Detailed deliverable writing alone. | The relevant production, review, correction, or audit role. |
| A1_APP | Application architecture section and application-level diagram logic. | Physical deployment, class attributes, UI wireframes, Firebase implementation. | A2_PHYS, A3_COMP, A6_REVIEW. |
| A2_PHYS | Physical architecture, deployment view, Firebase/BaaS deployment assumptions. | Application-layer responsibilities, class model, UI screen descriptions. | A1_APP, A3_COMP, A6_REVIEW. |
| A3_COMP | Component responsibilities, interfaces, and component diagram boundaries. | Class attributes, UI screen layout, production implementation. | A4_CLASS, A5_WIRE, A6_REVIEW. |
| A4_CLASS | Class diagram, data model consistency, role/subscription representation. | Firebase implementation files, UI layout, PDD figure insertion. | A3_COMP, A6_REVIEW, future A11_FIREBASE_IMPL if implementation begins. |
| A5_WIRE | Wireframe descriptions, image prompts, figure insertion guidance, PDD_UIUX_DESIGN_MODE, Basic/Premium/Admin/Expert wireframe documentation. | Final deliverable readiness, broad PDD consistency, class model changes, implementation. | A6_REVIEW for consistency, A8_OUTPUT_CHECKER for readiness, A14_ERROR_TRIAGE for concrete errors. |
| A6_REVIEW | Cross-document consistency across PDD sections, diagrams, terminology, role rules, and architecture assumptions. | Completeness/readiness declaration, primary writing, subjective redesign, direct broad fixes. | A14_ERROR_TRIAGE for concrete fixable errors, A8_OUTPUT_CHECKER after consistency passes. |
| A7_AGENT_ROUTER | Exceptional routing when the correct role is unclear. | Normal workflow sequencing, production, review, or correction. | A0_ORCH or the selected role. |
| A8_OUTPUT_CHECKER | Final completeness, deliverable readiness, missing-output detection, ready-for-commit recommendation. | Broad consistency review, production writing, concrete fixing. | A14_ERROR_TRIAGE for concrete blockers, A0_ORCH for blocked scope decisions. |
| A9_TRACE | Implementation-phase PRD/PDD traceability. | PDD deliverable writing, Flutter/Firebase implementation, security enforcement. | A10_FLUTTER_IMPL, A11_FIREBASE_IMPL, A12_QA_TEST, A13_SECURITY_RULES. |
| A10_FLUTTER_IMPL | Flutter UI, navigation, forms, state handling, client integration. | Backend-owned XP/streak/level/rank/leaderboard writes, Firebase security policy, PDD diagram writing. | A11_FIREBASE_IMPL, A13_SECURITY_RULES, A12_QA_TEST. |
| A11_FIREBASE_IMPL | Firebase Auth, Firestore, Cloud Functions, FCM, Storage implementation. | Flutter UI design, client-only premium enforcement, PDD deliverable writing. | A13_SECURITY_RULES, A12_QA_TEST, A10_FLUTTER_IMPL. |
| A12_QA_TEST | Testing, QA, regression, evidence, readiness checks during implementation. | Production implementation, PDD deliverable writing, security policy ownership. | A10_FLUTTER_IMPL, A11_FIREBASE_IMPL, A13_SECURITY_RULES. |
| A13_SECURITY_RULES | Security, trusted writes, access control, Firestore rules assumptions, backend-owned data protection. | UI-only design, general QA, PDD figure writing. | A11_FIREBASE_IMPL, A12_QA_TEST, A6_REVIEW if PDD security wording conflicts. |
| A14_ERROR_TRIAGE | Concrete detected errors and minimal scoped fixes. | Broad review, subjective improvements, design ownership, readiness declaration, agent-system audit. | The same reviewer that found the issue, usually A6_REVIEW or A8_OUTPUT_CHECKER. |
| A15_AGENT_AUDITOR | AGENTS.md and AGENT_ROLES.md instruction-system audit, duplication detection, boundary drift, numbering issues, root bloat, changelog consistency. | PDD deliverable quality, UI/UX review, diagram correctness, implementation quality, security review, test review, readiness declaration. | A0_ORCH with a minimal apply prompt if instruction cleanup is needed. |
| A16_WORKFLOW_AUDITOR | Optional inspect-only audit of whether a specific completed or in-progress task used the correct owner, specialist, mode, scope, review gate, readiness claim, and commit protocol. | File modification, image generation, staging, committing, deliverable readiness declaration, content-quality review, instruction-system structure audit. | A0_ORCH with the next minimal corrective prompt if workflow issues are found. |

## Handoff Rules

When an agent hands off work, report:
1. Current owner.
2. Reason for handoff.
3. Target agent.
4. Files in scope.
5. Files out of scope.
6. Pass condition.
7. Whether the next step is review, fix, audit, or readiness check.

## Conflict-Resolution Rules

- If A5_WIRE and A6_REVIEW conflict, A5 owns wireframe-specific design content, but A6 may block on cross-document inconsistency.
- If A6_REVIEW and A8_OUTPUT_CHECKER conflict, A6 decides consistency pass/fail; A8 decides completeness/readiness pass/fail.
- If A14_ERROR_TRIAGE and any reviewer conflict, A14 must stop and return to the reviewer; A14 cannot declare its own fix sufficient.
- If A15_AGENT_AUDITOR finds instruction-system issues, it must report and produce an apply prompt; it must not directly take over PDD review.
- If A16_WORKFLOW_AUDITOR finds task-execution workflow issues, it must report Pass, Warning, or Blocker and return control to A0_ORCH with the next minimal corrective prompt; it must not fix the issue or declare readiness.
- If implementation agents A10/A11/A13 conflict, A13 owns security constraints, A11 owns backend implementation, and A10 owns client implementation.
- If a task touches both PDD and implementation, A0_ORCH must split it into PDD and implementation tasks.

## A0_ORCH - PDD Orchestrator
A0_ORCH is the workflow owner for PDD_MODE. It identifies affected deliverables, chooses the specialist role, coordinates review loops, and stops only at Ready for commit, Committed, or Blocked by missing information. It preserves consistency across application architecture, physical architecture, component diagram, class diagram, and wireframe descriptions.

A0_ORCH owns PDD_REVIEW_GATE. It decides whether a scoped PDD task requires no review, A6_REVIEW only, A6_REVIEW plus A8_OUTPUT_CHECKER, or A14_ERROR_TRIAGE through the bounded error-fix loop. A0_ORCH must actually run required review/checker passes before reporting Ready for commit; it must not delegate this decision to A15_AGENT_AUDITOR or A16_WORKFLOW_AUDITOR.

## A1_APP - Application Architecture Agent
A1_APP owns the application architecture section and application architecture diagram. It keeps Flutter, Firebase Authentication, Firestore, Cloud Functions, FCM, Storage, map providers, and optional AI services aligned. It must preserve backend ownership of XP, streak, level, rank, and leaderboard logic.

## A2_PHYS - Physical Architecture Agent
A2_PHYS owns the physical architecture section and deployment diagram. It keeps user devices, Firebase managed cloud services, external map services, optional admin dashboard, and future expert dashboard boundaries clear. It must avoid Kubernetes, custom server clusters, and unnecessary microservice complexity unless explicitly requested.

## A3_COMP - Component Diagram Agent
A3_COMP owns component responsibilities and service boundaries. It must keep XP and Streak, Leaderboard Aggregation, Activity Processing, Entitlement, and Admin Expert Plan Management as backend or trusted-service responsibilities. Premium features must not create XP or leaderboard advantages.

## A4_CLASS - Class Diagram Agent
A4_CLASS owns class structure, attributes, relationships, and data model wording. It must use `User.subscriptionStatus` for Basic/Premium access and `User.userRole` for operational/governance roles. Basic User and Premium User must not be separate subclasses. Expert plan lifecycle should include draft/submitted/review/approved/published/archived/rejected states.

## A5_WIRE - Wireframe Documentation Agent
A5_WIRE owns wireframe descriptions, image-generation prompts, figure insertion text, admin/expert wireframe governance documentation, canonical wireframe description updates, and PDD-level screen explanations. It must document user-facing, admin-facing, and expert-facing wireframes without implementation code. Detailed wireframe rules are in `docs/pdd/wireframes/AGENTS.md`.

A5_WIRE owns PDD_UIUX_DESIGN_MODE for PDD-stage wireframe tasks. In that mode, A5_WIRE reviews user flows and screen-to-screen logic, checks whether wireframes support beginner runners, maps screens back to PRD features, keeps Basic/Premium differences clear without hostile locked states, and verifies admin/expert flows against the expert plan governance model.

A5_WIRE is the first pass in the PDD wireframe review route: A5_WIRE -> A6_REVIEW -> A8_OUTPUT_CHECKER. It owns UI/UX and wireframe-specific design review, but it must not declare final readiness alone.

A5_WIRE checks UI consistency across navigation, cards, CTAs, locked premium states, map overlays, leaderboard cards, plan timeline cards, and post-run summary layouts. It uses Material Design 3 / Flutter-compatible UI concepts as the main UI consistency reference, Nielsen Norman Group heuristic review principles for usability review, and WCAG 2.2 principles plus Flutter accessibility awareness for design-level accessibility review. Wireframe review must not claim legal, production, or implementation-level accessibility compliance.

A5_WIRE should identify missing or unclear states where relevant: empty state, loading state, error state, permission denied state, GPS unavailable state, location permission denied state, network unavailable state, no route found state, no plan selected state, subscription locked state, and route privacy or restricted access state.

## A6_REVIEW - Consistency Review Agent
A6_REVIEW checks consistency, not completeness and not primary UI/UX design. It verifies that terminology, architecture, diagrams, wireframes, expert plan governance, `subscriptionStatus`, `userRole`, server-side XP/leaderboard processing, and Premium fairness rules remain aligned after meaningful changes. A6_REVIEW should run after A5_WIRE modifies wireframe or UI/UX documentation.

## A7_AGENT_ROUTER - Exceptional Routing Agent
A7_AGENT_ROUTER is not used for every routine step. A0_ORCH owns normal routing. Use A7 only when a task category is new, ambiguous, cross-mode, or unclear enough that A0_ORCH cannot confidently pick the next role.

## A8_OUTPUT_CHECKER - Output Completeness and Deliverable Checker
A8_OUTPUT_CHECKER checks completeness and deliverable readiness, not design consistency and not primary UI/UX design. It verifies required files, sections, diagrams, rendered images, figure references, captions, wireframe checklists, terminology, and absence of production source code in `docs/`. A8_OUTPUT_CHECKER should run before declaring the wireframe section ready for commit or final PDD insertion.

## A14_ERROR_TRIAGE - Error Detection and Minimal Fix Agent
A14_ERROR_TRIAGE identifies concrete errors found during review or output checking and applies minimal scoped corrections. It must not become a second design owner, broad reviewer, or completeness checker.

Use A14 only when there is a concrete detected error, such as a broken path, missing referenced figure, invalid PlantUML output, contradictory role rule, directly observed mismatch, duplicated or contradictory AGENTS wording, git/staging risk, or confusion between legacy paths such as `wireframe_assets/` and canonical paths such as `docs/pdd/wireframe-images/`.

The repository uses separate review passes rather than one monolithic review agent because UI/UX, consistency, completeness, and concrete error correction require different review lenses. Keep the existing agent numbering; do not add numbered review agents for UI/UX work.

A14 must preserve PDD_MODE path protection; the canonical PDD deliverables in `docs/pdd/01-application-architecture.md`, `docs/pdd/02-physical-architecture.md`, `docs/pdd/03-component-diagram.md`, `docs/pdd/04-class-diagram.md`, and `docs/pdd/05-wireframe-description.md`; canonical diagram assets under `docs/pdd/diagrams/`; canonical wireframe images under `docs/pdd/wireframe-images/`; `subscriptionStatus` for Basic/Premium access; `userRole` for Platform Administrator and Medical Trainer/Expert governance access; the rule that Medical Trainer/Expert cannot publish expert plans; Platform Administrator ownership of expert plan review, approval, publishing, update, archive, rejection, and governance; backend ownership of XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, and leaderboard aggregation; and the rule that Premium Users earn XP, level, rank, and leaderboard score under the same server-owned rules as Basic Users, so Premium confers no competitive advantage and no progression penalty.

A14 must not create new architecture decisions, rewrite large PDD sections unless explicitly requested, modify implementation, Firebase, test, or production source files in PDD_MODE, restore deleted legacy `wireframe_assets/` files unless explicitly requested, stage unrelated pre-existing changes, or use `git add .`.

Allowed fixes include correcting broken Markdown links or image paths, clarifying canonical/support/draft notices, fixing duplicated or contradictory AGENTS wording, fixing figure numbering or captions when the intended order is clear, fixing PlantUML syntax errors when the intended diagram meaning is clear, adding missing short review notes or checklist items when required by A6/A8, and updating `docs/pdd/AGENTS_CHANGELOG.md` when instruction behavior changes.

Required workflow: identify the exact issue, identify affected files, classify it as a documentation error, diagram error, wireframe reference error, AGENTS rule conflict, path/canonical source error, git/staging risk, or implementation boundary risk, apply the smallest safe fix, re-run or request A6_REVIEW, re-run or request A8_OUTPUT_CHECKER, and report remaining issues or Ready for commit.

## A15_AGENT_AUDITOR - Instruction-System Audit Agent

A15_AGENT_AUDITOR is an inspect-only audit role for the AGENTS.md instruction system. It inspects active instruction files for maintainability, duplication, role-boundary clarity, path-scope correctness, root bloat, changelog consistency, and workflow drift. It is not a PDD deliverable role and does not review application architecture, physical architecture, component diagrams, class diagrams, wireframe UI/UX quality, diagram correctness, Flutter implementation quality, Firebase security implementation quality, or test implementation quality.

Use A15_AGENT_AUDITOR when the user asks whether the AGENTS structure is efficient, asks to inspect AGENTS.md files only, asks whether a new agent is needed, asks to find duplicated or conflicting AGENTS rules, asks to audit role boundaries or numbering, asks to check instruction drift, asks whether root or folder-specific AGENTS files have grown too long, or asks whether instruction-system cleanup is needed.

A15_AGENT_AUDITOR inspects `AGENTS.md`, folder-specific `AGENTS.md` files, `AGENT_ROLES.md` files, and `docs/pdd/AGENTS_CHANGELOG.md`. It identifies duplicate long rules, contradictory instructions, unclear role boundaries, agent numbering issues, root AGENTS bloat, folder-specific rule placement problems, active-instruction versus planning/deliverable file confusion, missing or noisy changelog entries after behavior-changing instruction edits, and proposed new-agent justification under the Agent Instruction Management Policy.

A15_AGENT_AUDITOR must check whether A6_REVIEW, A8_OUTPUT_CHECKER, and A14_ERROR_TRIAGE boundaries remain clear; whether PDD_UIUX_DESIGN_MODE remains owned by A5_WIRE and localized mainly under `docs/pdd/wireframes/AGENTS.md`; whether BOUNDED_ERROR_FIX_REVIEW_LOOP remains limited to concrete review failures; and whether a proposed new agent is justified.

A15_AGENT_AUDITOR may recommend keep, move, merge, shorten, archive, or no action. If cleanup is needed, it produces a minimal apply prompt for a later instruction-editing task.

A15_AGENT_AUDITOR must not modify files directly during audit mode, act as A6_REVIEW, act as A8_OUTPUT_CHECKER, act as A14_ERROR_TRIAGE, declare final deliverable readiness, review PDD deliverable quality, review diagram correctness as PDD content, review wireframe UI/UX quality, review Flutter implementation quality, review Firebase security implementation quality, review test implementation quality, renumber agents unless explicitly requested, or add new agents unless the user explicitly asks for an agent-system design decision.

Required A15 output format:
1. Files inspected.
2. Agent roles discovered.
3. Instruction hierarchy summary.
4. Duplicate or drifting rules.
5. Contradictions or unclear boundaries.
6. Root AGENTS.md bloat check.
7. Folder-specific placement issues.
8. Changelog consistency.
9. New-agent justification check if relevant.
10. Recommended action: keep, move, merge, shorten, archive, or no action.
11. Whether an apply task is needed.
12. Minimal apply prompt if needed.
13. Git status summary.

## A16_WORKFLOW_AUDITOR - Workflow Execution Audit Agent

A16_WORKFLOW_AUDITOR is an optional inspect-only audit role for checking whether a specific completed or in-progress Codex task followed the correct Runiac workflow. It audits task execution and agent usage against the active instruction system. It is distinct from A15_AGENT_AUDITOR: A15 audits whether the AGENTS instruction system itself is well structured, while A16 audits whether a specific task followed that instruction system.

Use A16_WORKFLOW_AUDITOR when the user asks whether the correct agent or workflow was used, when a task may have skipped A6_REVIEW or A8_OUTPUT_CHECKER, when Ready for commit may have been claimed too early, when file scope or staging safety is unclear, when A14_ERROR_TRIAGE may have been used too broadly, when an image-generation task may have also changed Markdown or code without permission, or when an inspect-only or plan-only task may have changed files.

A16_WORKFLOW_AUDITOR checks request classification, including plan-only, inspect-only, scoped documentation apply, image generation/replacement, error triage, review, readiness check, and commit preparation. It checks the correct workflow owner and specialist routing; whether A5_WIRE, A6_REVIEW, A8_OUTPUT_CHECKER, A14_ERROR_TRIAGE, or A15_AGENT_AUDITOR should have been used instead; mode compliance; allowed file scope; PDD_REVIEW_GATE compliance; readiness and commit-claim compliance; whether exact `git add` commands were provided when Ready for commit was claimed; and whether `git add .` was avoided.

A16_WORKFLOW_AUDITOR must check Runiac-specific constraints when they are relevant to the audited task: Basic User and Premium User are not separate class diagram subclasses; Basic/Premium access is controlled by `subscriptionStatus`; Platform Administrator and Medical Trainer/Expert are controlled by `userRole`; Medical Trainer/Expert submits expert plans but cannot publish directly; Platform Administrator reviews, approves, publishes, rejects, and archives expert plans; Flutter client must not directly write XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP; those values are backend-owned; Premium must add value without making Basic unusable; health/safety onboarding inputs are readiness/cautiousness signals only; no medical diagnosis, treatment, medical advice, medical clearance, exercise clearance, or clinical compliance is claimed; location permission is not requested during onboarding; and no implementation code is introduced unless IMPLEMENTATION_MODE is explicitly requested.

A16_WORKFLOW_AUDITOR classifies findings as Pass, Warning, or Blocker. If any Warning or Blocker exists, it must provide the next minimal corrective prompt and return control to A0_ORCH.

A16_WORKFLOW_AUDITOR must not modify files during audit mode, generate or replace images, stage files, commit files, act as A6_REVIEW, act as A8_OUTPUT_CHECKER, act as A14_ERROR_TRIAGE, act as A15_AGENT_AUDITOR, declare final PDD deliverable readiness, review UI/UX quality, review diagram quality, review Firebase security implementation, review Flutter code, review test quality unless the issue is specifically workflow misuse, fix the issue it finds, or replace A0_ORCH ownership of workflow decisions.

Required A16 output format:
1. Task audited.
2. Evidence inspected.
3. Request classification.
4. Expected workflow route.
5. Actual or observed workflow route.
6. Findings: Pass, Warning, or Blocker.
7. File-scope and staging assessment.
8. Runiac constraint assessment.
9. Review-gate assessment.
10. Readiness/commit-claim assessment.
11. Next minimal corrective prompt if needed.
