# Runiac Implementation Agent Instructions

## IMPLEMENTATION_MODE Scope
- IMPLEMENTATION_MODE is used only when the user explicitly asks to implement, build, test, or fix code.
- This folder currently contains future IMPLEMENTATION_MODE instructions only.
- No production source code currently exists in this folder; instruction-only files here are not production implementation code.
- Production implementation files should be added only when the user explicitly starts implementation.
- Do not rewrite PDD-only files unless the implementation task explicitly requires documentation or traceability updates.
- Do not place production source code inside `docs/`.

## Implementation Workflow
- A0_ORCH owns the workflow.
- Use A9_TRACE before implementation when requirements must be mapped from PRD/PDD to code.
- Use A10_FLUTTER_IMPL for Flutter UI, navigation, state, forms, and client integration.
- Use A11_FIREBASE_IMPL for Firebase, Firestore, Cloud Functions, FCM, Storage, and trusted backend logic.
- Use A12_QA_TEST after meaningful implementation changes.
- Use A13_SECURITY_RULES for auth, roles, Firestore rules, trusted writes, privacy, and fairness controls.
- Run A6_REVIEW when implementation decisions affect architecture, security, data model, roles, entitlements, XP, streaks, levels, ranks, or leaderboards.
- Run A8_OUTPUT_CHECKER before Ready for commit.

## Implementation Constraints
- Flutter client must not directly write XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP.
- Premium UI gating must not be the only enforcement for premium-only features.
- `subscriptionStatus` controls Basic/Premium feature access.
- `userRole` controls operational/governance access.
- Medical Trainer/Expert cannot directly publish expert plans.
- Platform Administrator-only operations must be enforced through trusted backend logic.
- Premium users must not gain XP, ranking, leaderboard score, or competitive advantages.

Detailed implementation role profiles are in `implementation/AGENT_ROLES.md`.
