# Runiac Agent Instructions

## Project Defaults
- Default mode is PDD_MODE unless the user explicitly asks for implementation, build, test, or code changes.
- Runiac is a beginner-focused running app for a Final Year Project.
- Current primary work is Project Design Document preparation.
- Use `grep` and `find` for repository searches.

## Commit Protocol
- Default: do not commit unless the user explicitly grants commit or auto-commit permission for the current task or workflow. Stop at Ready for commit by default.
- Auto-commit is limited to AGENTS instruction-system cleanup tasks when the user explicitly grants auto-commit permission for the current task. For all other tasks, stop at Ready for commit and provide manual git commands.
- Before committing, run `git status --short`, review `git diff`, identify task-relevant modified files, avoid staging unrelated pre-existing changes, stage only files directly related to the current task, run the required review/checker process, create a clear commit message using the repository style below, and report the commit hash and final status.
- If a task reaches Ready for commit but Codex is not allowed to commit automatically, provide exact manual git commands for the user. This applies when auto-commit permission was not granted, the task is outside the authorized AGENTS cleanup scope, the task includes PDD deliverables, diagrams, wireframe images, implementation, Firebase, tests, or other non-AGENTS files, or unrelated pre-existing changes make manual staging safer.
- Before showing manual commit commands, run `git status --short`, identify task-relevant files, identify unrelated pre-existing changes that should remain unstaged, avoid recommending `git add .`, provide explicit `git add <file>` commands only for task-relevant files, suggest an appropriate commit message, and include optional verification commands before commit. Use this format: `git status --short`; explicit `git add <task-relevant-file>` commands; `git diff --cached --stat`; `git diff --cached`; `git commit -m "type(scope): concise message"`. If unrelated changes exist, list them under "Do not stage these unrelated changes."
- PDD_MODE commits require A6_REVIEW and A8_OUTPUT_CHECKER before commit. Do not commit implementation, Firebase, test, or production source changes in PDD_MODE unless explicitly requested. Do not restore or stage deleted legacy `wireframe_assets/` files unless the current task explicitly includes that migration or cleanup.
- IMPLEMENTATION_MODE commits require relevant tests, or a clear explanation of why tests could not be run. Run A6_REVIEW if architecture, security, roles, entitlements, XP, leaderboard, or data model behaviour is affected. Run A12_QA_TEST and A13_SECURITY_RULES where relevant.
- Commit message style: use `docs(pdd): ...` for PDD documentation updates, `docs(agents): ...` for AGENTS.md or workflow instruction updates, `docs(wireframes): ...` for wireframe documentation or prompt assets, `docs(diagrams): ...` for PDD diagram source or rendered diagram updates, `chore(repo): ...` for repository structure or non-functional cleanup, `feat(...): ...` only for actual implementation features, and `fix(...): ...` only for bug fixes.
- If unrelated changes are present, do not stage them and mention them in the final response as left unstaged because unrelated.

## Non-Negotiable Runiac Rules
- Flutter handles UI, navigation, GPS tracking UI, and local interaction.
- Firebase Authentication handles identity.
- Firestore stores users, plans, activities, routes, XP summaries, and leaderboard data.
- Cloud Functions handle XP calculation, activity validation, streak update, level update, rank update, and leaderboard aggregation.
- The client must not directly calculate or write XP, level, rank, streak, leaderboard score, weekly XP, or monthly XP.
- Premium features must not rely only on hiding UI.
- Premium users must not receive XP, rank, leaderboard score, or competitive advantages.
- Basic/Premium feature access uses `subscriptionStatus`.
- Operational and governance access uses `userRole`.
- Basic User and Premium User must not be modelled as separate subclasses.
- Platform Administrator is the governance and CRUDS role.
- Medical Trainer/Expert is an expert plan content provider only and must not directly publish expert plans into the app or database.
- Platform Administrator reviews expert plan content for safety, completeness, beginner suitability, and consistency.
- Only Platform Administrator can approve, publish, update, archive, reject, suspend, or manage expert plans.
- Premium User can only view and select approved/published expert plans.
- Future Expert Dashboard may allow draft submission, but admin approval is still required before publishing.
- Treat GPS route data, activity history, profile data, and running metrics as sensitive user data.

## Path Protection
- In PDD_MODE, do not modify Flutter, Firebase, backend, Cloud Functions, tests, or production implementation files unless explicitly requested.
- In IMPLEMENTATION_MODE, do not rewrite PDD-only files unless explicitly required.
- Do not place production source code inside `docs/`.
- Keep `docs/pdd/` for design documentation only.
- `docs/pdd/diagrams/` is the canonical PDD diagram source location. Root `diagrams/` is legacy/reference-only; new edits and future authoritative diagram updates must target `docs/pdd/diagrams/` only.
- Folder-specific rules are in the closest AGENTS.md file.

## Markdown Documentation Management
- Preserve heading hierarchy unless restructuring is required.
- Do not mix PDD content, implementation planning, and production code in the same Markdown file.
- Keep terminology consistent: Basic User, Premium User, Platform Administrator, Medical Trainer/Expert.
- Separate MVP assumptions, future extensions, and out-of-scope items.
- After editing Markdown, check duplicated sections, terminology consistency, broken figure references, and whether diagrams, wireframes, or class model are affected.

## Agent Execution Model
- A0_ORCH is the workflow owner.
- A0 to A16 are role profiles and review lenses by default.
- Do not assume real parallel Codex subagents are available unless the user explicitly asks Codex to spawn subagents.
- If subagents are not explicitly requested, A0_ORCH should emulate specialist checks sequentially.
- Stop only when Ready for commit, Committed, or Blocked by missing information.

## Short Agent Role Index
- A0_ORCH: workflow owner and mode coordinator.
- A1_APP: application architecture PDD role.
- A2_PHYS: physical architecture PDD role.
- A3_COMP: component diagram PDD role.
- A4_CLASS: class diagram and data model PDD role.
- A5_WIRE: wireframe documentation, prompt, figure insertion, and PDD UI/UX design-review role.
- A6_REVIEW: consistency review role.
- A7_AGENT_ROUTER: new or ambiguous task routing role only.
- A8_OUTPUT_CHECKER: completeness and deliverable readiness role.
- A9_TRACE: requirement traceability role.
- A10_FLUTTER_IMPL: Flutter implementation role.
- A11_FIREBASE_IMPL: Firebase/backend implementation role.
- A12_QA_TEST: testing and QA role.
- A13_SECURITY_RULES: security and access-control review role.
- A14_ERROR_TRIAGE: detects concrete documentation, diagram, path, rule, and workflow errors, then applies minimal scoped fixes before routing back to review.
- A15_AGENT_AUDITOR: inspect-only AGENTS instruction-system audit role.
- A16_WORKFLOW_AUDITOR: optional inspect-only task-execution audit role that checks whether a specific completed or in-progress task used the correct owner, specialist agent, mode, file scope, review gate, readiness claim, and commit protocol.

## Agent Instruction Management Policy
- Keep root `AGENTS.md` concise and limited to global rules, mode defaults, non-negotiable Runiac constraints, path protection, the role index, commit protocol, and instruction-management policy.
- Folder-specific `AGENTS.md` files own local rules for PDD, diagrams, wireframes, implementation, Firebase, and tests.
- Detailed role definitions stay in `AGENT_ROLES.md` files, not root `AGENTS.md`.
- Treat `AGENTS.md` and `AGENT_ROLES.md` files as active instructions. Treat planning files and deliverable files as project context, not active agent instructions, unless explicitly invoked.
- Add new rules only when repeated mistakes, recurring workflow needs, or important project constraints justify them.
- Prefer small, scoped AGENTS changes over large instruction-system rewrites. Split large instruction sets into task-specific Markdown files rather than expanding root indefinitely.
- Do not duplicate long rules across many AGENTS files; keep root or the closest relevant folder file canonical and use short reminders elsewhere.
- Do not add a new numbered agent if an existing role can be safely extended with a mode, checklist, routing rule, or support document.
- Create a new numbered agent only when the responsibility is recurring, cannot be handled by an existing agent without making that agent unclear, has a distinct input/output pattern, has clear routing triggers, and does not duplicate A6_REVIEW, A8_OUTPUT_CHECKER, or A14_ERROR_TRIAGE.
- Do not renumber agents unless there is a strong reason and all references can be updated safely.
- Keep review, completeness checking, and concrete error triage as separate review passes.
- Keep instruction restructuring changes separate from feature or content changes where possible.
- If a rule changes project behavior, update `docs/pdd/AGENTS_CHANGELOG.md`.
- A0_ORCH must check whether an AGENTS.md update is needed when repeated mistakes occur.

## Mode-Specific Rule Files
- PDD work: `docs/pdd/AGENTS.md`
- PDD role details: `docs/pdd/AGENT_ROLES.md`
- Diagram work: `docs/pdd/diagrams/AGENTS.md`
- Wireframe and PDD UI/UX design work: `docs/pdd/wireframes/AGENTS.md`
- Implementation work: `implementation/AGENTS.md`
- Implementation role details: `implementation/AGENT_ROLES.md`
- Firebase/backend work: `firebase/AGENTS.md`
- Tests and QA: `tests/AGENTS.md`

## Roadmap Context Protocol

When starting any task:

1. Read `implementation/roadmap/CURRENT.md` first (always).
2. Read the active phase doc referenced in CURRENT.md.
3. Read relevant ADRs referenced in CURRENT.md.
4. Read `implementation/roadmap/snapshots/latest.md` for current state.

Do not load:
- `roadmap-stretch.md` unless explicitly instructed.
- archived snapshots unless explicitly instructed.
- future phase docs unless explicitly instructed.
- full `roadmap-summary.md` unless planning cross-phase work.
