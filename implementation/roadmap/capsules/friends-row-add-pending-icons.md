# friends-row-add-pending-icons

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's explicit Friends UI request.

Type: static Flutter frontend-only refinement of the existing Friends screen rows.

## Status

Status: In progress.

Routed on: 2026-07-13 Asia/Singapore.

Depends on: `implementation/roadmap/capsules/home-social-dropdown-friends-shell.md` for the existing static Friends shell and demo read models.

## Goal

Keep the existing Friends screen tabs and Requests row intact while making the compact row contract consistent with the Home profile badge treatment:

- `Friends`: badge plus runner name only.
- `Search` and `Suggested`: badge plus runner name, with the supplied Add icon at the trailing edge.
- After Add, the same user shows the supplied Pending icon instead. Pending is a disabled, noninteractive local display state.
- `Requests`: preserve its current invitation copy and Accept / Decline controls unchanged.

## Allowed Scope

- `implementation/mobile/runiac_app/lib/features/friends/presentation/friends_screen.dart`
- `implementation/mobile/runiac_app/lib/features/friends/presentation/widgets/friends_rows.dart`
- `implementation/mobile/runiac_app/lib/features/friends/presentation/widgets/friend_row_identity.dart`
- `implementation/mobile/runiac_app/lib/core/widgets/runiac_level_profile_badge.dart` for shared initials centering only.
- `implementation/mobile/runiac_app/lib/core/assets/runiac_assets.dart`
- `implementation/mobile/runiac_app/assets/images/friends/friends_add.png`
- `implementation/mobile/runiac_app/assets/images/friends/friends_pending.png`
- `implementation/mobile/runiac_app/pubspec.yaml` for registering only the two supplied image assets; no package or dependency changes.
- `implementation/mobile/runiac_app/test/friends_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/home_static_ui_test.dart` for the shared Home badge regression only.
- `implementation/mobile/runiac_app/test/runiac_level_profile_badge_test.dart`
- `implementation/mobile/runiac_app/DESIGN.md`
- This capsule and append-only routing in `implementation/roadmap/CURRENT.md`.
- `tools/governance-ci/check-diff-hygiene.sh` only if the new capsule path must be added to its routed-capsule allowlist.

## Behavior Contract

- Use the supplied person-add icon for available `Add` actions and the supplied pending-clock icon after a request is sent.
- Remove the opaque white background from the supplied pending source asset while preserving its black icon silhouette and antialiasing.
- Keep the controls at least 44 by 44 logical pixels, aligned to the row trailing edge with the existing card padding.
- Expose one accessible action label per state: `Add <name>` while available and `Pending <name>` after it is sent. Decorative badge/icon semantics must not duplicate the runner name or action.
- Add state is session-local `setState` only. It must be shared by Search and Suggested for the current screen instance and reset when the screen is re-entered.
- A Pending state must not invoke another action or persist anything.
- Preserve the existing `FriendRequestRow` layout, invitation copy, Accept / Decline semantics, and session-local request behavior byte-for-byte unless a compiler-only adjustment is required.
- Keep one- and two-letter initials horizontally centered and scaled inside compact profile discs without clipping.
- Show the backend-supplied level label when present; when absent, show the display-only compact placeholder `Lv.0` without deriving XP, level progress, or rank.

## Forbidden Scope

- No Firebase, Auth, Firestore, Cloud Functions, FCM, feed code, repositories, or `users/{uid}/friends` / friend-request I/O.
- No persistence, network calls, optimistic backend state, notification delivery, undo, or request cancellation.
- No change to the tab structure, shell navigation, Social dropdown, Requests layout, Accept / Decline behavior, or Home dashboard screen composition.
- No client-side calculation or mutation of XP, level, rank, streak, leaderboard score, weekly XP, monthly XP, subscription privilege state, or expert plan publication state.
- No new dependencies, Android/iOS/native changes, deployment, build artifacts, staging, commit, or push.

## Validation Plan

- Start with the focused Friends widget tests in red for Add/Pending state behavior, then verify them green after implementation.
- Run `dart format` on changed Dart sources, `flutter analyze --no-pub`, the focused Friends widget test, `flutter test`, and `git diff --check`.
- Inspect the generated PNGs for a transparent pending background and valid asset registration.
- Use a real Flutter screen surface where available to verify Search and Suggested actions, Pending's noninteractive state, the untouched Requests row, and narrow mobile layout.

## Done When

- [ ] Friends rows show only the compact badge and name.
- [ ] Search and Suggested show a trailing Add icon for available runners.
- [ ] Tapping Add changes only that user's visible action to the noninteractive Pending icon for the current screen session.
- [ ] Pending artwork has no opaque white background.
- [ ] Requests remain visually and behaviorally unchanged.
- [ ] One- and two-letter initials remain centered without clipping in compact badges.
- [ ] Every Friends identity badge shows a level pill, using `Lv.0` only when the supplied label is empty.
- [ ] Focused and relevant regression validation pass, with any pre-existing failures reported separately.
- [ ] No backend, persistence, progression, entitlement, navigation, or unrelated UI behavior is introduced.
