# notification-center-hybrid-notifications

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved only after explicit routing.

Type: Flutter Notification Center settings shell plus hybrid local/FCM notification planning capsule.

## Status

Status: Proposed.

Captured on: 2026-07-07 Asia/Singapore.

Source: user interview in Codex conversation on 2026-07-07 Asia/Singapore.

This capsule is planning memory only. It does not select Phase 02, activate an implementation milestone, authorize Flutter code changes, authorize Firebase/FCM setup, or authorize native Android/iOS notification permission work.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A11_FIREBASE_IMPL -> A13_SECURITY_RULES -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

Use A10 for Flutter Notification Center UI, local notification settings, and client-side scheduling seams. Use A11 and A13 for FCM, Cloud Functions triggers, token handling, server-side suppression checks, and notification preference enforcement.

## Goal

Add an in-app Notification Center that lets users control Runiac MVP notifications through a master notification toggle and per-notification settings, while delivering time-based reminders locally and plan lifecycle updates through trusted backend/FCM paths.

## Product Decisions

- Use a hybrid notification model.
- The Account page should expose a `Notifications` row that opens the Notification Center as a child screen.
- Notification Center is the canonical in-app configuration surface for notification preferences.
- The Notification Center has a top-level `Notifications` master On/Off toggle.
- When the master toggle is Off, all child notification items are disabled and the user receives no local scheduled notifications or FCM notifications governed by these settings.
- When the master toggle is On, users can configure each child notification item with an iOS-style pill On/Off toggle.
- A child notification's time or frequency options are available only when that child item is On.
- The MVP screen should not include a Future/Admin Notices section.
- Platform Administrator broadcast notifications are a future Administrator Platform scope and are not part of this MVP capsule.
- Weekly progress summary notifications are excluded from MVP.

## Notification Items

### Plan-start reminder

- Default: On.
- Default reminder time: 30 minutes before plan start.
- User options when On:
  - 10 minutes before
  - 30 minutes before
  - 1 hour before
  - 2 hours before
- If a plan item has no start time, do not send a plan-start reminder for that item.
- Delivery: local scheduled notification.

### Today's plan reminder

- Default: On.
- Purpose: a day-start reminder that the user has a scheduled run today, separate from the plan-start reminder.
- Trigger condition: the user has a scheduled run today and has no completed activity yet that day.
- Default time: 8:00 AM.
- User options when On:
  - 7:00 AM
  - 8:00 AM
  - 9:00 AM
  - Custom
- Plan-start reminder and today's plan reminder may both be enabled for the same day.
- If the plan start time is earlier than the today's plan reminder time, suppress the today's plan reminder.
- Delivery: local scheduled notification.

### Missed run nudge

- Default: On.
- Trigger condition: the planned run start time has passed and the user has no completed activity for that day.
- Default send time: 2 hours after planned start.
- User options when On:
  - 1 hour after planned start
  - 2 hours after planned start
  - Evening reminder
- Rate limits:
  - Maximum 1 missed run nudge per day.
  - Maximum 3 missed run nudges per week.
- Copy must be guilt-free and beginner-friendly.
- Example tone: `If today's plan slipped, that's okay. Want to restart with something short?`
- Delivery: local scheduled notification.

### Plan updates

- Default: On.
- User options: On/Off only; no time selector.
- Send immediately after the relevant plan is actually published, refreshed, assigned, or made available to the affected user.
- Included MVP cases:
  - Weekly onboarding plan refresh: notify that this week's onboarding plan is available.
  - Post-onboarding plan arrival: notify that a new plan has arrived after onboarding ends.
- Excluded MVP cases:
  - Broad marketing alerts for newly approved expert plans.
  - Minor metadata-only changes.
  - Changes that should not be user-visible.
  - XP, rank, leaderboard, or competitive score updates.
- Delivery: trusted backend/FCM notification.

## UI Direction

- Keep the Notification Center compact and settings-focused, not a marketing or activity feed screen.
- Use a master row for `Notifications` at the top.
- Use grouped child rows below the master toggle.
- Use an iOS-style pill toggle for the master toggle and each child notification.
- Disabled child rows should remain visible but visually subdued when the master toggle is Off.
- Time options should use simple segmented choices, chips, or a compact picker matching the existing mobile UI style.
- Avoid long explanatory paragraphs in the settings UI.
- Use calm, beginner-friendly labels and copy.

Suggested grouping:

- `Reminders`
  - Plan-start reminder
  - Today's plan reminder
  - Missed run nudge
- `Plan updates`
  - Plan updates

## Preference Model

Future implementation should persist notification preferences per authenticated user.

Suggested logical fields:

- `notificationsEnabled`
- `planStartReminderEnabled`
- `planStartReminderOffsetMinutes`
- `todaysPlanReminderEnabled`
- `todaysPlanReminderLocalTime`
- `missedRunNudgeEnabled`
- `missedRunNudgeDelay`
- `planUpdatesEnabled`

The exact storage path and schema must be routed through A9/A11/A13 before implementation. The client may write notification preference settings for the signed-in user, but must not write backend-owned progression, XP, rank, leaderboard, subscription privilege, expert publication, or plan-publication state.

## Delivery Architecture

### Local scheduled notifications

Use local scheduling for:

- Plan-start reminder.
- Today's plan reminder.
- Missed run nudge.

The Flutter client may schedule, cancel, and reschedule these local reminders based on signed-in user preferences and the user's visible plan data. Scheduling must avoid writing backend-owned state and must respect the master notification toggle.

### Backend / FCM notifications

Use trusted backend/FCM paths for:

- Weekly onboarding plan available notification.
- New plan arrived after onboarding ends notification.

Cloud Functions or trusted backend code must enforce affected-user targeting, preference checks, and suppression rules before sending FCM messages. The client must not impersonate server-side plan publication, approval, or assignment events.

## Allowed Scope For Future Implementation

- Add a Notification Center child screen reachable from the Account page.
- Add master and child notification toggles.
- Add child time option controls for local reminder notification types.
- Persist notification preferences for the signed-in user after A9/A11/A13 routing.
- Add local scheduling seams for local reminders after dependency and native permission strategy is approved.
- Add FCM/backend notification planning or implementation only after explicit Firebase/backend routing.
- Add tests for visible settings behavior, default values, disabled states, and forbidden copy/data absence.

## Forbidden Scope

- No Phase 02 selection without separate routing.
- No implementation without explicit approval.
- No Firebase init.
- No `flutterfire configure`.
- No production FCM setup, APNs setup, or notification entitlement changes without separate approval.
- No native Android/iOS permission, manifest, Gradle, plist, or entitlement changes without separate approval.
- No new dependencies without separate approval.
- No Platform Administrator broadcast notification implementation.
- No Administrator Platform implementation.
- No broad expert-plan marketing notification.
- No weekly progress summary notification.
- No XP notification.
- No rank notification.
- No leaderboard score notification.
- No client-side XP, rank, leaderboard score, weekly XP, monthly XP, streak, level, subscription privilege, expert plan publication, or plan approval writes.
- No GPS route, precise location, activity history, or sensitive metrics in notification copy.
- No notification copy that shames, pressures, or over-competitively frames beginner users.

## Future Validation Plan

For a Flutter settings-only implementation slice:

```bash
git status --short
git diff --stat
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
cd /Users/leejinseo/Desktop/FYP_Runiac && ./tools/governance-ci/run-all-checks.sh
git status --short
```

For backend/FCM work, add A11/A13-owned Functions, Firestore rules, emulator, and security validation before implementation begins.

## Required Evidence For Future Closure

- Screenshot or manual QA evidence for Account page entry and Notification Center settings states.
- Evidence that master Off disables child controls and suppresses local/FCM-governed notifications.
- Evidence that child Off disables that child item's time options.
- Evidence that default values match this capsule.
- Test evidence for settings defaults and toggle behavior.
- Backend/FCM evidence only if the implementation slice includes server notification delivery.
- A6 review notes confirming backend-owned values and sensitive data are not exposed through notification copy or client writes.
- A8 output-checker verdict before Ready for commit.

## Rollback Conditions

- Notification settings imply XP, rank, leaderboard, or competitive reward mutation.
- Client code writes backend-owned progression, plan publication, or expert approval state.
- FCM/backend delivery can target the wrong user or bypass user notification preferences.
- Notification copy includes sensitive GPS route data, precise location, private activity history, or guilt/shame framing.
- Native notification permission or Firebase setup changes occur without separate approval.

## Exit Criteria

- [ ] Notification Center scope is routed and active.
- [ ] Target implementation files are explicitly listed before coding.
- [ ] Master and child toggle behavior is implemented.
- [ ] Local reminder defaults and options are implemented.
- [ ] Plan update notification preference is implemented.
- [ ] Required tests and validation pass.
- [ ] Required evidence is recorded.
- [ ] `CURRENT.md` is updated only if the capsule becomes active, closes, or changes roadmap state.
