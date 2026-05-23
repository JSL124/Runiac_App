# Runiac Testing and QA Instructions

## Scope
- Applies to automated tests, manual QA notes, regression checks, security-rule verification, build checks, and commit-readiness evidence.
- Use in IMPLEMENTATION_MODE and for documentation deliverable readiness when requested.
- This folder currently contains QA/testing guidance only.
- No production test suite currently exists in this folder unless added later intentionally; instruction-only files here are not production test suites or test evidence.
- Test files or evidence should be added only when implementation or testing work is explicitly requested.
- Root-level `tests/` is for cross-system tests, Firebase rules tests, Functions integration tests, e2e scenarios, shared fixtures, and future test harness orchestration.
- Flutter unit, widget, and integration tests must live inside the future Flutter app root, not in root-level `tests/`.

## QA Responsibilities
- Verify changed behaviour against mapped PRD/PDD requirements.
- Check Basic/Premium access through `subscriptionStatus`.
- Check operational/governance access through `userRole`.
- Verify Medical Trainer/Expert cannot directly publish expert plans.
- Verify Platform Administrator-only operations are protected.
- Verify Premium users do not gain XP, rank, leaderboard score, or competitive advantages.
- Verify Flutter does not directly write XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP.

## Evidence Rules
- Record what was tested, what passed, and what was not run.
- Include manual QA steps when automated tests are not available.
- Do not include precise private location data in screenshots, logs, or public test evidence.
- Before Ready for commit, confirm required tests, docs, config updates, and review notes are present.
