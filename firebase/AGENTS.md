# Runiac Firebase and Backend Instructions

## Scope
- Applies to Firebase Authentication, Cloud Firestore, Cloud Functions, Firebase Cloud Messaging, Firebase Cloud Storage, Firestore Security Rules, and trusted backend workflows.
- Use only in IMPLEMENTATION_MODE unless the user explicitly asks for Firebase design documentation.
- This folder currently contains Firebase/security guidance only.
- No production Firebase configuration, Cloud Functions, or Firestore rules currently exist in this folder; instruction-only files here are not production Firebase code.
- If production Firebase files are added later, they must follow these rules.
- Do not add Cloud Functions, Firestore rules, or Firebase config unless implementation work is explicitly requested.

## Access and Enforcement Rules
- `subscriptionStatus` and `userRole` may be mirrored for display, but enforcement must not rely only on client-side fields.
- Flutter client cannot upgrade `subscriptionStatus` or `userRole`.
- Privileged actions must go through trusted backend logic, Cloud Functions, Firebase Auth custom claims, Firestore Security Rules, or equivalent trusted enforcement.
- Firestore Security Rules are not filters; client queries must be designed to satisfy access rules.
- Admin-only collections must not be queried by normal mobile users.
- Public/published content queries must use safe status constraints such as `status == "published"` where appropriate.

## Trusted Backend Ownership
- XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, and leaderboard aggregation are backend-owned.
- Activity validation must occur before activity data affects XP, streaks, levels, ranks, or leaderboards.
- Medical Trainer/Expert cannot publish expert plans.
- Platform Administrator-only operations must be enforced server-side.
- Platform Administrator owns expert plan review, approval, publishing, update, archive, reject, suspend, and management actions.

## Privacy Guidance
- Treat GPS route data, activity history, profile data, and running metrics as sensitive user data.
- Avoid exposing exact route history unless the user explicitly shares it.
- Do not include precise private location data in screenshots, logs, test evidence, or public documentation.
- Route sharing should use user-controlled visibility and privacy masking where appropriate.
