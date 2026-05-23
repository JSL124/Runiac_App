# Runiac Mobile Implementation Instructions

## Scope
- Applies to future Flutter mobile application work under `implementation/mobile/`.
- A10_FLUTTER_IMPL owns Flutter UI, navigation, state, forms, GPS UI, local interaction, FCM handling, and client integration.
- Do not create `implementation/mobile/runiac_app/` manually; create it later with `flutter create runiac_app` when implementation starts.

## Test Placement
- Future Flutter unit and widget tests belong under `implementation/mobile/runiac_app/test/`.
- Future Flutter integration tests belong under `implementation/mobile/runiac_app/integration_test/`.
- Root-level `tests/` is for cross-system tests only.

## Constraints
- Flutter may display XP, streak, level, rank, weekly XP, monthly XP, and leaderboard values, but must not directly write trusted values.
- Basic/Premium access uses `subscriptionStatus`.
- Operational and governance access uses `userRole`.
- Premium UI gating must be backed by backend enforcement.
