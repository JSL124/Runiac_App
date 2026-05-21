# Runiac AGENTS.md Changelog

## 2026-05-21 - Add PDD Review Gate

### Files modified
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENT_ROLES.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added an A0_ORCH-owned workflow decision rule so Codex can decide when A6_REVIEW and A8_OUTPUT_CHECKER are mandatory, optional, or unnecessary instead of stopping after only recommending review.

### Summary of changes
- Added `PDD_REVIEW_GATE` to `docs/pdd/AGENTS.md`.
- Clarified that A0_ORCH owns the gate and decides whether a task needs no review, A6_REVIEW only, A6_REVIEW plus A8_OUTPUT_CHECKER, or A14_ERROR_TRIAGE through the bounded error-fix loop.
- Made A6_REVIEW and A8_OUTPUT_CHECKER mandatory before Ready for commit for scoped PDD documentation apply tasks that affect canonical PDD deliverables or support files for figures, ordering, prompts, or references.
- Made A6_REVIEW and A8_OUTPUT_CHECKER mandatory for diagram or wireframe image path changes, figure numbering/caption/insertion-order changes, PRD traceability changes, role/subscription/governance wording changes, backend-owned progression rule changes or references, explicit continue/review/readiness requests, and any response that intends to say Ready for commit.
- Clarified that plan-only, inspect-only, search/find-only, review-only with no modifications, no-op, narrow typo-only, and unrelated project-management support tasks do not require full review unless the user asks for readiness or consistency could be affected.
- Clarified that concrete issues found by A6_REVIEW or A8_OUTPUT_CHECKER route to A14_ERROR_TRIAGE through the bounded error-fix loop, and A14 must return to the same reviewer and cannot declare readiness.
- Added a concise A0_ORCH role note in `docs/pdd/AGENT_ROLES.md`.
- Added no new agents and performed no agent renumbering.
- Confirmed A15_AGENT_AUDITOR remains instruction-system audit only and does not own PDD review decisions.

### Review required
- A6_REVIEW: verify the gate preserves A0 ownership, keeps A6 as consistency review, keeps A8 as completeness/readiness checking, keeps A14 concrete-error-only, and keeps A15 audit-only.
- A8_OUTPUT_CHECKER: verify the gate rule, A0 role note, and changelog entry exist; no PDD deliverable content, binary images, implementation code, new agents, or agent renumbering were introduced.

### Final status
Ready for commit.

## 2026-05-21 - Clarify Agent Boundaries

### Files modified
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENT_ROLES.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Clarified role ownership, handoff behavior, and conflict resolution across the existing agent instruction system without adding or renumbering agents.

### Summary of changes
- Added Agent Boundary Principles to require one accountable owner per task and prevent review, correction, or audit roles from becoming production owners.
- Added an Agent Boundary Matrix covering A0_ORCH through A15_AGENT_AUDITOR with Owns, Does not own, and Hands off to guidance.
- Added handoff output requirements for owner, reason, target role, scope, pass condition, and next-step type.
- Added conflict-resolution rules for A5/A6, A6/A8, A14/reviewer, A15/PDD review, A10/A11/A13, and mixed PDD/implementation tasks.
- Added no new agents and performed no agent renumbering.
- Confirmed A14_ERROR_TRIAGE remains correction-only and A15_AGENT_AUDITOR remains instruction-system audit only.

### Review required
- A6_REVIEW: verify the matrix and conflict rules preserve existing role boundaries, keep A14 correction-only, keep A15 audit-only, and do not create new ownership conflicts.
- A8_OUTPUT_CHECKER: verify the boundary principles, matrix, handoff rules, conflict-resolution rules, and changelog entry exist; no PDD deliverable content, implementation code, binary images, file names, new agents, or renumbering were introduced.

### Final status
Ready for commit.

## 2026-05-21 - Add A15 Agent Auditor

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENT_ROLES.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added A15_AGENT_AUDITOR as an inspect-only role for auditing the AGENTS instruction system as it grows.

### Summary of changes
- Added A15_AGENT_AUDITOR to the root role index.
- Added a short A15 routing note to `docs/pdd/AGENTS.md`.
- Added the detailed A15_AGENT_AUDITOR definition to `docs/pdd/AGENT_ROLES.md`.
- Defined A15 as an inspect-only instruction-system audit role for maintainability, duplication, role-boundary clarity, path-scope correctness, root bloat, changelog consistency, workflow drift, and new-agent justification checks.
- Confirmed A15 does not replace A6_REVIEW, A8_OUTPUT_CHECKER, or A14_ERROR_TRIAGE.
- Confirmed A15 does not review PDD deliverable content, wireframe UI/UX quality, diagram correctness, Flutter implementation quality, Firebase security implementation quality, or test implementation quality.
- Confirmed A15 does not declare final readiness or modify files directly during audit mode.
- Added no other new agents and performed no agent renumbering.

### Review required
- A6_REVIEW: verify A15 is inspect-only, does not duplicate A6/A8/A14, does not own PDD deliverable review, does not declare readiness, and preserves role boundaries.
- A8_OUTPUT_CHECKER: verify the root index, PDD routing note, detailed role definition, output format, and changelog entry exist; no PDD deliverable content, implementation code, binary images, or file names were modified.

### Final status
Ready for commit.

## 2026-05-21 - Add Bounded Error Fix Review Loop

### Files modified
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added a bounded workflow for fixing concrete review errors and routing them back to the same review role without creating an infinite loop or allowing broad uncontrolled edits.

### Summary of changes
- Added `BOUNDED_ERROR_FIX_REVIEW_LOOP` to `docs/pdd/AGENTS.md`.
- Limited the loop to concrete, verifiable errors found by A6_REVIEW or A8_OUTPUT_CHECKER, such as broken figure references, inconsistent figure numbering, broken image paths, contradictory role rules, invalid PlantUML output, Markdown formatting errors, mismatched canonical/support guidance, or direct contradictions between scoped PDD documents.
- Prohibited use of the loop for broad redesign, new feature planning, subjective UI preferences, large restructuring, implementation work, speculative improvements, and unrelated cleanup.
- Required A14_ERROR_TRIAGE to apply only the smallest scoped fix and route back to the same reviewing role.
- Set a maximum of two A14 fix attempts for the same issue before reporting Blocked with the remaining issue, affected files, safety reason, and user decision needed.
- Confirmed A14_ERROR_TRIAGE remains correction-only, A6_REVIEW remains consistency review, and A8_OUTPUT_CHECKER remains the only role that may declare final deliverable readiness.
- Added no new numbered agents and performed no agent renumbering.

### Review required
- A6_REVIEW: verify the loop preserves A6/A8/A14 role boundaries, does not broaden A14 authority, keeps final readiness under A8_OUTPUT_CHECKER, and prevents unrelated file changes.
- A8_OUTPUT_CHECKER: verify the loop policy and changelog entry exist, the two-attempt limit is documented, no production code or binary images were modified, no new numbered agents were added, and no agent renumbering occurred.

### Final status
Ready for commit.

## 2026-05-21 - Add Agent Instruction Management Policy

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added a lightweight policy for keeping the existing AGENTS instruction system maintainable without importing an external framework or restructuring the repository.

### Summary of changes
- Added an Agent Instruction Management Policy to root `AGENTS.md`.
- Clarified that root `AGENTS.md` should stay concise and folder-specific `AGENTS.md` files should own local detailed rules.
- Clarified that detailed role definitions belong in `AGENT_ROLES.md` files.
- Clarified that `AGENTS.md` and `AGENT_ROLES.md` files are active instructions, while planning and deliverable files are context unless explicitly invoked.
- Added criteria for when a new numbered agent may be created.
- Clarified that existing roles should be extended with a mode, checklist, routing rule, or support document when possible.
- Preserved the layered review-pass model for A5_WIRE, A6_REVIEW, A8_OUTPUT_CHECKER, and A14_ERROR_TRIAGE.
- Imported no external agent framework.
- Added no new numbered agents and performed no agent renumbering.

### Review required
- A6_REVIEW: verify the policy preserves current role boundaries, does not duplicate detailed role definitions, keeps root concise, preserves the layered review-pass model, and does not weaken Runiac constraints.
- A8_OUTPUT_CHECKER: verify the policy and changelog entry exist, no repository restructuring occurred, no binary images or production code were modified, no new numbered agents were added, and no agent renumbering was performed.

### Final status
Ready for commit.

## 2026-05-21 - Add PDD UI/UX Design Mode

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENT_ROLES.md`
- `docs/pdd/wireframes/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added controlled PDD_UIUX_DESIGN_MODE for PDD-stage wireframe review and extended A5_WIRE instead of adding separate UI/UX agents.

### Summary of changes
- Added PDD_UIUX_DESIGN_MODE to `docs/pdd/wireframes/AGENTS.md`.
- Extended A5_WIRE with UI/UX design-review responsibilities for wireframe flows, PRD traceability, beginner suitability, UI consistency, design-level accessibility, usability heuristics, and missing-state coverage.
- Confirmed Material Design 3 / Flutter-compatible concepts as the main mobile UI consistency reference.
- Confirmed Nielsen Norman Group usability heuristics, WCAG 2.2 principles, and Flutter accessibility awareness are design-review guidance only, not claims of legal, production, or implementation-level accessibility compliance.
- Clarified A5_WIRE owns UI/UX and wireframe-specific design work.
- Clarified A6_REVIEW checks cross-PDD consistency, A8_OUTPUT_CHECKER checks completeness/readiness, and A14_ERROR_TRIAGE remains correction-only for concrete detected errors.
- Added the layered PDD wireframe review-pass route: A5_WIRE -> A6_REVIEW -> A8_OUTPUT_CHECKER, with A14_ERROR_TRIAGE used only for concrete detected errors.
- Documented that one monolithic review agent is avoided because UI/UX, consistency, completeness, and concrete error correction require different review lenses.
- Added no new numbered UI/UX agents and performed no agent renumbering.
- Preserved canonical wireframe file decisions and the canonical `docs/pdd/wireframe-images/` path.

### Review required
- A6_REVIEW: verify PDD_UIUX_DESIGN_MODE stays under A5_WIRE, no new numbered UI/UX agents were added, no agent numbers changed, A14 remains correction-only, canonical wireframe files and image paths are preserved, and Runiac role/subscription/progression rules remain intact.
- A8_OUTPUT_CHECKER: verify the detailed mode rules, checklist, output format, role updates, boundary guidance, and changelog entry exist; no binary images, implementation files, Firebase files, test files, PRD requirements, or wireframe image filenames were changed.

### Final status
Ready for commit.

## 2026-05-21 - Add A14 Error Triage Role

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENT_ROLES.md`
- `docs/pdd/diagrams/AGENTS.md`
- `docs/pdd/wireframes/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added A14_ERROR_TRIAGE for concrete error detection and minimal PDD/AGENTS fixes.

### Summary of changes
- Added A14_ERROR_TRIAGE to the root role index.
- Added PDD workflow routing rules for using A14 after A6_REVIEW or A8_OUTPUT_CHECKER finds concrete fixable issues.
- Added the detailed A14 role profile to `docs/pdd/AGENT_ROLES.md`.
- Added short diagram and wireframe routing references for concrete path, rendering, and governance wording errors.
- Kept A14 scoped to minimal corrections and prohibited new architecture decisions, large rewrites, PDD_MODE implementation changes, legacy `wireframe_assets/` restoration, unrelated staging, and `git add .`.

### Review required
- A6_REVIEW: verify A14 does not overlap too much with A6 or A8, is clearly a correction agent and not a design owner, preserves PDD_MODE and path protection, does not permit implementation changes in PDD_MODE, routes back to A6/A8 after fixes, and preserves Runiac role, subscription, expert governance, and backend-owned progression rules.
- A8_OUTPUT_CHECKER: verify A14 appears in the root role index, the detailed role exists in `docs/pdd/AGENT_ROLES.md`, folder-specific references are short and not duplicated excessively, changelog was updated, no production code was modified, no unrelated files were staged, and no `wireframe_assets/` deletions were staged.

### Final status
Ready for commit.

## 2026-05-21 - Add Ready-for-Commit Manual Command Rule

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added Ready-for-commit manual git command rule.

### Summary of changes
- Updated the root Commit Protocol so that when work reaches Ready for commit but auto-commit is not allowed, Codex must provide exact manual git commands.
- Required `git status --short`, task-relevant file identification, unrelated-change identification, explicit file staging commands, verification commands, and a suggested commit message.
- Prohibited recommending `git add .` when unrelated changes may exist.
- Required unrelated pre-existing changes to be listed under "Do not stage these unrelated changes."
- Updated `docs/pdd/AGENTS.md` with a short reference to the root Commit Protocol for Ready-for-commit manual commands.

### Review required
- A6_REVIEW: verify auto-commit remains limited to explicitly authorized AGENTS cleanup tasks, non-auto-commit tasks stop at Ready for commit, Ready-for-commit tasks provide safe manual git commands, commands use explicit file staging rather than `git add .`, unrelated pre-existing changes are listed and left unstaged, deleted legacy `wireframe_assets/` files are not automatically staged, and no production code was modified.
- A8_OUTPUT_CHECKER: verify root `AGENTS.md` contains the Ready-for-commit manual command rule, folder-specific AGENTS files do not duplicate the full protocol unnecessarily, changelog was updated, and no unrelated files were staged or committed.

### Final status
Ready for commit.

## 2026-05-21 - Add Conditional Auto-Commit Protocol

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added conditional auto-commit protocol.

### Summary of changes
- Added the canonical Commit Protocol to the root `AGENTS.md`.
- Kept the default rule as no commit unless the user explicitly grants commit or auto-commit permission for the current task or workflow.
- Allowed auto-commit only after Ready for commit and after required review/checker steps pass.
- Required Codex to inspect status and diff, stage only task-relevant files, avoid unrelated pre-existing changes, use repository commit message style, and report the commit hash.
- Added PDD_MODE and IMPLEMENTATION_MODE commit safeguards, including A6_REVIEW/A8_OUTPUT_CHECKER for PDD commits and relevant tests/reviews for implementation commits.
- Added a short PDD workflow reference in `docs/pdd/AGENTS.md` instead of duplicating the full protocol.

### Review required
- A6_REVIEW: verify auto-commit requires explicit user permission, only task-relevant files may be staged, PDD_MODE still protects implementation/Firebase/test files, deleted legacy `wireframe_assets/` files are not automatically restored or staged, commit message conventions are clear, and no production code was modified.
- A8_OUTPUT_CHECKER: verify root `AGENTS.md` contains the canonical Commit Protocol, folder-specific AGENTS files do not duplicate the full protocol unnecessarily, changelog was updated, and no unrelated files were staged or committed during this instruction update unless auto-commit permission was explicitly granted.

### Final status
Ready for commit.

## 2026-05-21 - Clarify PDD Asset Paths and Instruction-Only Folders

### Files modified
- `docs/pdd/00-orchestration-plan.md`
- `implementation/AGENTS.md`
- `firebase/AGENTS.md`
- `tests/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Clarified canonical wireframe image path and instruction-only implementation/firebase/tests folders.

### Summary of changes
- Clarified that `docs/pdd/00-orchestration-plan.md` is a planning reference, not the active source of agent rules.
- Confirmed active Codex instructions live in repository `AGENTS.md` files and detailed PDD role profiles live in `docs/pdd/AGENT_ROLES.md`.
- Clarified that `wireframe.md` remains the readable wireframe source.
- Clarified that prepared PDD wireframe image assets live under `docs/pdd/wireframe-images/`.
- Marked `wireframe_assets/` as a legacy path that may appear in earlier planning notes or Git history.
- Confirmed `implementation/`, `firebase/`, and `tests/` currently contain instruction-only placeholders, not production source code, Firebase configuration, Cloud Functions, Firestore rules, or production test suites.

### Review required
- A6_REVIEW: verify PDD_MODE remains clear, `docs/pdd/wireframe-images/` is canonical for PDD wireframe images, `wireframe.md` remains the readable wireframe source, legacy `wireframe_assets/` is not restored, implementation/firebase/tests folders are instruction-only, and no production code was modified.
- A8_OUTPUT_CHECKER: verify all active AGENTS files still exist, canonical PDD deliverables are not unnecessarily changed, support files do not compete with canonical final files, no unnecessary folders were created, and no commit was made.

### Final status
Ready for commit.

## 2026-05-21 - Stabilize Canonical and Support Markdown Boundaries

### Files modified
- `docs/pdd/AGENTS.md`
- `docs/pdd/00-orchestration-plan.md`
- `docs/pdd/05-final-wireframe-section.md`
- `docs/pdd/05-final-wireframe-insertion-order.md`
- `docs/pdd/05-admin-expert-wireframe-figure-insert.md`
- `docs/pdd/05-wireframe-image-generation-prompts.md`
- `implementation/AGENTS.md`
- `firebase/AGENTS.md`
- `tests/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Stabilize the AGENTS.md structure and clarify canonical PDD deliverables versus support, draft, figure-insertion, prompt, and planning Markdown files.

### Summary of changes
- Confirmed `docs/pdd/05-wireframe-description.md` as the canonical wireframe description file.
- Marked support wireframe and orchestration files as non-canonical where appropriate.
- Clarified that `docs/pdd/00-orchestration-plan.md` is planning context, not the active source of agent rules.
- Clarified that `implementation/`, `firebase/`, and `tests/` currently contain future-mode instruction files and are not production implementation folders unless source files are added intentionally.
- Preserved the split between global root rules, PDD_MODE rules, detailed role profiles, diagram rules, wireframe rules, implementation rules, Firebase/security rules, and testing rules.

### Review required
- A6_REVIEW: verify consistency with Runiac PDD rules, canonical/support file boundaries, role governance, `subscriptionStatus`/`userRole` separation, expert plan governance, backend-owned XP/leaderboard processing, and PDD_MODE path protection.
- A8_OUTPUT_CHECKER: verify all active AGENTS.md and AGENT_ROLES.md files remain present, support files have notices, and no production code was modified.

### Final status
Ready for commit.

## 2026-05-21 - Restructure Agent Instructions

### Files changed
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENT_ROLES.md`
- `docs/pdd/diagrams/AGENTS.md`
- `docs/pdd/wireframes/AGENTS.md`
- `implementation/AGENTS.md`
- `implementation/AGENT_ROLES.md`
- `firebase/AGENTS.md`
- `tests/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
The root `AGENTS.md` had grown too long and repeated project rules across many agent descriptions. The instruction system was restructured so Codex can manage, review, modify, and generate Markdown documentation in a clean and maintainable way.

### Summary of rules moved or created
- Root `AGENTS.md` now holds global non-negotiable Runiac rules, mode defaults, path protection, Markdown management, AGENTS.md stewardship, and a short agent index.
- PDD_MODE rules and A0 to A8 summaries moved to `docs/pdd/AGENTS.md`.
- Detailed PDD role descriptions moved to `docs/pdd/AGENT_ROLES.md`.
- Diagram-specific rules moved to `docs/pdd/diagrams/AGENTS.md`.
- Wireframe-specific rules moved to `docs/pdd/wireframes/AGENTS.md`.
- IMPLEMENTATION_MODE rules and A9 to A13 summaries moved to `implementation/AGENTS.md`.
- Detailed implementation role descriptions moved to `implementation/AGENT_ROLES.md`.
- Firebase/backend security rules moved to `firebase/AGENTS.md`.
- QA and test-readiness rules moved to `tests/AGENTS.md`.

### Review required
- A6_REVIEW: verify consistency with Runiac PDD rules, role governance, `subscriptionStatus`/`userRole` separation, expert plan governance, server-side XP/leaderboard processing, and PDD_MODE path protection.
- A8_OUTPUT_CHECKER: verify all target AGENTS.md and AGENT_ROLES.md files exist and that long duplicate rules were removed from root.

### Final status
Ready for commit.
