# leaderboard-help-modal-shell

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode for future implementation: implementation-approved.

Type: Flutter static frontend-only Leaderboard help modal/sheet shell.

## Status

Status: Active; reactivated after `github-actions-flutter-validation-baseline` CI parity closure.

Routed on: 2026-05-27 Asia/Singapore.

Deferred on: 2026-05-27 Asia/Singapore.

Resumable on: 2026-05-27 Asia/Singapore.

Reactivated on: 2026-05-27 Asia/Singapore.

Depends on: `implementation/roadmap/capsules/leaderboard-map-first-landing-shell.md` closed at `b1ed742 feat(mobile): add leaderboard map landing shell`.

Deferred because: hosted GitHub Actions previously ran governance checks but did not yet run the Flutter analyze/test validation expected by this product capsule. `github-actions-flutter-validation-baseline` is now closed after local validation and hosted GitHub Actions PASS for `587cc0e`.

Reactivated because: hosted Flutter validation CI parity is complete. This reactivation is routing-only; no help modal implementation has occurred yet, and the capsule must not be marked completed or superseded until its future implementation and validation are finished.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A5_WIRE -> A10_FLUTTER_IMPL -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Make the existing Leaderboard info button open a concise beginner-friendly help modal/sheet explaining leagues and leaderboard readiness without implying live ranking data exists.

## Starting Context

- `leaderboard-map-first-landing-shell` is closed.
- The current Leaderboard landing shell already has a visual and semantic info affordance labeled `Leaderboard information`.
- Read-only inspection found no modal, help sheet, bottom sheet, or info trigger behavior yet.
- This capsule is the next narrow step in the refined map-first Leaderboard direction.

## Intended UX Direction

- Use the existing `Leaderboard information` affordance as the trigger.
- Preferred UI is a compact modal bottom sheet or centered modal with clear close behavior.
- The help UI should feel like help, not a data view.
- Keep tone concise, calm, beginner-friendly, and non-intimidating.
- Match the existing frosted, blue, navy, and orange Leaderboard palette.
- Avoid long paragraphs and avoid competitive pressure.

## Suggested Safe Content

- Title: `Leagues`
- Copy: `Leagues group runners by broad progress bands so the board feels fair and beginner-friendly.`
- Copy: `Weekly and monthly views will help compare progress once leaderboard data is ready.`
- Copy: `Real rankings will be calculated safely by Runiac later.`

## Avoided Copy / Content

- No numbers, ranks, XP totals, or runner names.
- No `your current rank`.
- No `live leaderboard`.
- No wording that implies backend data already exists.

## Allowed Scope

- Local Leaderboard presentation-only help modal/sheet shell.
- Make the existing Leaderboard info affordance trigger the help UI.
- Add concise static beginner-help copy explaining leagues and leaderboard readiness.
- Add clear dismiss behavior.
- Keep the current map-first landing shell and overlay hierarchy intact.
- Add or update widget coverage only for stable visible help content and absence of forbidden fake leaderboard content.

## Allowed Files For Future Implementation

- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/test/widget_test.dart` only if stable visible expectations need updates.

## Recommended Not Allowed

- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`, because the modal can be local to `LeaderboardTab`.

## Forbidden Scope

- No region tap behavior.
- No region preview bottom sheet.
- No leaderboard rows.
- No fake users.
- No fake ranks.
- No fake XP.
- No fake scores.
- No fake levels.
- No fake streaks.
- No real leaderboard data.
- No leaderboard aggregation.
- No client-side XP calculation.
- No client-side rank calculation.
- No client-side score calculation.
- No XP mutation.
- No rank mutation.
- No score mutation.
- No weekly XP or monthly XP mutation.
- No Firebase, Auth, Firestore, Cloud Functions, FCM, or backend work.
- No GPS/location permission or state.
- No native Android/iOS changes.
- No dependency changes.
- No shell, navigation, route, AppBar, or bottom-navigation changes.
- No Home, Maps, Run, or You/Profile changes.
- No scaffold, build, init, deploy, Firebase setup, or `flutterfire configure` commands.
- No Phase 02 selection.

## Future Validation Plan

```bash
git status --short
git diff --stat
git diff --check
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test
cd /Users/leejinseo/Desktop/FYP_Runiac && ./tools/governance-ci/run-all-checks.sh
git status --short
```

No backend, Firebase, GPS, security-rules, Cloud Functions, or leaderboard aggregation tests are required for this static frontend-only help modal/sheet capsule.

## Future Widget Test Guidance

- Confirm the Leaderboard info trigger exists.
- Confirm tapping the info trigger opens help content.
- Confirm dismissing the help UI closes it.
- Confirm forbidden fake content remains absent, including numeric ranks, XP totals, fake names, leaderboard rows, and region preview content.
- Do not test exact pixels, exact colors, private widget internals, or modal implementation internals.

## Risk Notes

- Help copy must not imply live ranking data, current rank, or backend data availability.
- The modal must not drift into a league list, ranking list, profile row, or leaderboard preview.
- Region tap behavior and region preview bottom sheet behavior remain separate future work and are not authorized here.

## Done When

- [ ] The existing `Leaderboard information` affordance opens a concise help modal/sheet.
- [ ] The help UI can be dismissed.
- [ ] Help copy remains beginner-friendly and does not imply live backend data.
- [ ] No region tap, region preview bottom sheet, leaderboard rows, fake users, fake ranks, fake XP, fake scores, fake levels, fake streaks, or backend-owned values are introduced.
- [ ] No forbidden files or scopes are touched.
- [ ] Required validation passes.
