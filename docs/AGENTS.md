# Runiac Documentation Instructions

## Scope
- Applies to documentation under `docs/`, including PDD reference material, submitted assessment references, project-management notes, and non-operational meta/archive material.
- Documentation work is not implementation work. Do not add production source code, generated app files, Firebase config, tests, secrets, or private GPS/location data under `docs/`.
- More specific folder instructions override this file where present.

## Documentation Boundaries
- `docs/submissions/` contains frozen submitted assessment material. Do not edit, regenerate, replace, or repackage submitted files unless the user explicitly requests it.
- `docs/pdd/` contains internal working/reference PDD material. Follow `docs/pdd/AGENTS.md` for PDD deliverables, diagrams, wireframes, review gates, and role routing.
- `docs/meta/` is non-operational historical/archive material. It must not be treated as routing authority, approval evidence, implementation guidance, or active project state.
- `docs/project-management/` contains planning support. It must not override `PRD.md`, submitted PDD snapshots, `AGENTS.md`, roadmap routing, setup gates, or ADRs.

## Markdown Rules
- Preserve heading hierarchy unless restructuring is explicitly needed.
- Keep terminology consistent: Basic User, Premium User, Platform Administrator, Medical Trainer/Expert, `subscriptionStatus`, and `userRole`.
- Clearly separate current scope, future extension, out-of-scope items, assumptions, and decisions.
- Do not mix product/design documentation, implementation planning, and production code in the same document.
- After Markdown edits, check duplicated sections, broken links, inconsistent terminology, missing captions/references, and whether related diagrams or documents need updates.

## Review Expectations
- Use A0_ORCH to route documentation work.
- Use A6_REVIEW when documentation changes affect role rules, subscriptions, governance, backend-owned XP/leaderboard behavior, architecture assumptions, or PRD/PDD consistency.
- Use A8_OUTPUT_CHECKER before claiming documentation deliverables are Ready for commit.
- Use A14_ERROR_TRIAGE only for concrete, directly observed documentation errors and minimal scoped fixes.
