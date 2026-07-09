# home-stage-map-density-polish

## Mode / Status

Mode: IMPLEMENTATION_MODE, explicitly requested by the user on 2026-07-10 Asia/Singapore.

Status: Completed locally at `74f9c219 feat(home): refine stage map density and guide` after the user explicitly authorized the implementation and Blue idle GIF commit on 2026-07-10 Asia/Singapore.

## Goal

Make each Home stage-map background feel deliberately filled by seven larger stage stones, alternate one `<` chevron then one `>` chevron with centre-aligned seam endpoints, scale the guide character with the larger stones, use the supplied animated Blue guide on Home, and keep the first background's lowest weekday label clear of the bottom navigation.

## Scope

- Preserve exactly seven display slots per plan week/background.
- Use one seven-stone `<` or `>` chevron per background, alternating by section with centre-aligned endpoints and even vertical spacing.
- Enlarge stones responsively for narrow and standard mobile widths.
- Enlarge the guide character proportionally and keep its bubble/tap target aligned.
- Use the supplied Blue runner GIF for the Home guide at rest and during plan-to-plan movement; other characters retain their direction-specific PNG sprites.
- Reserve bottom clearance on the first/bottom background for its weekday label.
- Update only focused Stage Map layout tests and design documentation.

## Allowed Files

- `implementation/mobile/runiac_app/DESIGN.md`
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_background_sequence.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map.dart`
- `implementation/mobile/runiac_app/assets/images/characters/blue_idle/blue_runner_idle.gif`
- `implementation/mobile/runiac_app/pubspec.yaml`
- `implementation/mobile/runiac_app/test/home_stage_background_sequence_test.dart`
- `implementation/mobile/runiac_app/test/home_stage_map_model_test.dart`
- `implementation/mobile/runiac_app/test/home_stage_map_widget_test.dart`
- This capsule, `implementation/roadmap/CURRENT.md`, and `implementation/roadmap/snapshots/latest.md`

## Forbidden Scope

- No plan/progress semantics, XP, streak, level, rank, leaderboard, Firebase, Home Guide request/response behavior, navigation, dependency, or native-platform changes.
- No character-asset changes beyond registering the supplied animated Blue Home guide GIF.
- Do not overwrite unrelated Home Guide or Leaderboard working-tree changes.
- No commit or push without separate permission.

## Validation

- Focused anchor tests prove seven anchors, alternating horizontal placement, uniform vertical rhythm, and bottom safe clearance.
- Focused widget tests prove enlarged stones and character geometry.
- Focused asset-selection tests prove the GIF is Blue-only on Home while other characters retain direction-specific PNG sprites.
- `flutter analyze --no-pub`, focused Flutter tests, `git diff --check`, and roadmap routing pass.
- Final simulator visual acceptance remained user-owned because the user explicitly asked Codex not to run a simulator; the later explicit commit authorization closed that gate without a new Codex simulator run.

## Done When

- [x] Seven enlarged stones fill each background in a readable zigzag.
- [x] The guide character scales with the stones.
- [x] The supplied Blue runner GIF is restricted to the Blue Home guide.
- [x] First-background weekday copy retains its reserved bottom-navigation clearance in the layout model.
- [x] Focused geometry and widget tests pass.
- [x] User explicitly authorizes the final implementation and Blue idle GIF commit.
- [x] Scope review passes and the task is Ready for commit after that acceptance.
