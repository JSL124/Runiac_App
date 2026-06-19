# Runiac Visual Policy

## Status

- Source of truth: Run Summary visual inspect.
- Scope: Flutter UI implementation guidance.
- Account page: application target, not baseline.
- This document is implementation-facing guidance derived from live Flutter UI patterns. It is not an ADR and does not authorize backend, Firebase, native, dependency, roadmap, or phase changes.

## Purpose

Runiac UI should feel beginner-friendly, calm, supportive, coherent, low-pressure, mobile-first, and easy to scan.

Core principle:

`Fix visual inconsistency by aligning design axes, not by adding decoration.`

## Baseline Surface

Run Summary is the baseline visual source because it represents Runiac's core product loop: Track -> Analyze -> Feedback.

It combines completed run feedback, pace graph, analysis preview, AI coaching, completed route map, heart-rate/source display, and beginner-friendly data truthfulness in one screen. Its current structure is a white, scrollable completion surface with compact back header, centered source label, route/map preview, hero distance, simple metric grid, Pace Over Time card, Advanced Analysis preview, AI Coaching Summary, and fixed bottom actions.

Account and other screens should adapt to the policy. They should not redefine it.

## Source Of Truth Rules

- New UI must inspect the local screen pattern first.
- Reuse existing local and theme tokens before adding new visual choices.
- Do not introduce new colors, radii, shadows, icons, or spacing patterns unless they are already established locally or explicitly approved.
- Consistency beats novelty.

## Design Axes

Every Flutter UI change should be reviewed against these axes:

- Radius: use the established radius scale and align nested shapes.
- Color: keep blue/orange roles stable and meaningful.
- Spacing: preserve repeated gutters, section gaps, and internal rhythm.
- Typography: keep hierarchy repeated, readable, and mobile-first.
- Shadows/borders/surfaces: prefer quiet, border-first surfaces.
- Icons: use icons to clarify meaning, not to decorate.
- Component rhythm: keep title, content, and action order predictable.
- Copy tone: write supportive, non-punitive copy.
- Beginner-friendly UX: reduce metric overload and pressure.
- Data truthfulness: show unavailable, mock, low-data, and backend-deferred states honestly.

## Radius Policy

Use the established Run Summary scale:

- 20px for primary cards and surfaces.
- 14-16px for controls and previews.
- Smaller radii only for nested chart or detail elements.

Align nested radii so inner elements feel related to outer cards. Avoid random one-off radius values. Avoid mixing sharp and soft card styles in one screen unless the difference communicates a real hierarchy.

## Color Policy

- Use Runiac blue for identity, hierarchy, metrics, and calm structure.
- Use orange sparingly for primary actions, route/current signal, and low-data attention.
- Prefer white and soft bordered surfaces.
- Avoid random purple, green, or decorative accents.
- Semantic colors are allowed only for real meaning.
- Health and wearable screens must not look medical or alarming unless showing a real warning or error state.

## Spacing Policy

- Prefer a 4/8px rhythm.
- Reuse page gutters and section gaps.
- Group-internal gaps must be tighter than section-to-section gaps.
- Avoid accidental blank spaces.
- Avoid arbitrary spacing values unless already established locally.

Run Summary establishes useful reference values: 16px side gutters for major cards, about 20px source/header padding, about 22px section gaps, and about 12px label-to-card gaps.

## Typography Policy

- Keep hierarchy repeated and easy to scan.
- Use strong hero values only for core result surfaces.
- Use section labels around the 16px rhythm where appropriate.
- Use helper and body copy around the 12-14px rhythm.
- Avoid too many competing weights and sizes.
- Prioritize mobile readability.

Run Summary establishes a completion-specific hierarchy: 72px hero distance, 23px metric values, 16px section labels, and 12-14px helper/body copy. Do not force the 72px hero treatment onto non-result screens.

## Shadows, Borders, And Surfaces Policy

- Prefer white surfaces with soft borders.
- Avoid heavy shadows unless they communicate action priority or floating controls.
- Use one border/shadow language per screen.
- Avoid randomly mixing border-only, heavy-shadow, and filled panels.

Run Summary mainly uses white surfaces, soft borders, and restrained shadows. Primary action elevation and floating map controls are exceptions because they communicate priority or physical layering.

## Icon Policy

- Icons must clarify meaning, not decorate.
- Metrics should usually be text-first, not icon-grid-first.
- Avoid decorative icon-heavy rows when they create a generated-looking rhythm.
- Use the existing local icon treatment if the screen already has one.

Run Summary intentionally avoids icon-heavy metric tiles. Preserve that restraint for result, analysis, and metric-heavy surfaces.

## Component Rhythm Policy

- Prefer title -> content -> action rhythm.
- Avoid unnecessary card-within-card patterns.
- Preserve a clear section sequence.
- For completion and analysis surfaces, Run Summary rhythm may be used: map -> hero result -> metrics -> evidence cards -> coaching -> actions.
- Do not force this exact sequence onto all screens.

For settings, account, and management surfaces, list rhythm may be appropriate. It should still follow the same radius, color, spacing, copy, and truthfulness rules.

## Copy Policy

Copy must be supportive, beginner-safe, non-punitive, and free of shame, guilt, aggressive performance pressure, fake precision, and misleading health/sensor/progression claims.

Good examples:

- `You started your run today — that still counts`
- `Connect a watch to see heart rate`
- `Heart rate was not shared`
- `Adding watch runs comes next.`

Avoid:

- `Bad run`
- `Poor performance`
- `Connected` when not actually connected
- `Synced` when mock-only
- Fake heart-rate estimates

## Beginner-Friendly UX Policy

- Keep primary actions obvious and low-pressure.
- Make metric groups scannable before making them dense.
- Avoid guilt, shame, or competitive pressure as motivation.
- Prefer helpful next-step copy over judgment.
- Use fewer, clearer sections instead of many decorative panels.
- Treat incomplete or short activity as valid user effort without overstating analysis.

## Data Truthfulness Policy

- Show unavailable data as unavailable.
- Do not append units to unavailable placeholders if it creates fake metrics; avoid `-- bpm` and `-- kcal`.
- Do not show low-data demo analysis as real analysis.
- Use clear helper text for unavailable heart rate or missing sensor data.
- Source labels must reflect the actual source or preview/mock status.
- Backend/progression-deferred states must not be presented as awarded progress.

Low-data states should use truthful guard overlays, softened actions, or hidden actions where appropriate. A low-data graph may preview shape only when it is clearly guarded and cannot be mistaken for real analysis.

## Health And Wearable UI Policy

- Never imply HealthKit, Health Connect, Garmin, or any watch source is connected unless real permission and integration exist.
- Use preview wording for mock flows.
- Do not estimate heart rate from pace, speed, age, effort, or calories.
- Imported workouts must not imply XP, streak, or leaderboard contribution unless backend validation exists.
- `Garmin via Health` means an imported health-source path, not direct Garmin integration.

## Backend-Owned Values Policy

Flutter UI must never imply client-side mutation or direct award of:

- XP
- Streak
- Level
- Rank
- Leaderboard score
- Weekly/monthly XP
- Subscription privilege state
- Expert plan publication state

Flutter may display trusted backend results after approved backend processing. It must not present placeholder, mock, local, or preview values as official progression or entitlement state.

## Global Vs Screen-Specific

Globalize:

- Blue/orange roles.
- Radius scale.
- Border-first surface treatment.
- Section rhythm principles.
- Text-first metrics.
- Icon restraint.
- Truthful unavailable states.
- Supportive copy tone.

Keep Run Summary-specific:

- 72px distance hero.
- Pace chart geometry.
- Locked preview sample graph.
- Exact route painter details.
- Exact section names.
- XP action placement.
- Completed-map interaction.

## Account Page Application Notes

Account should later adapt to this policy by:

- Using white bordered surfaces.
- Keeping blue/orange calm and meaningful.
- Using meaningful icons only.
- Aligning card and list radii to the shared scale.
- Keeping preview, prototype, and account-authority copy truthful.
- Placing Watch & Health Apps under Manage, not Activity History.

Account is a settings/profile surface. It should consume the visual policy without becoming the baseline for result, analysis, or feedback screens.

## Implementation Checklist

Before finishing a Flutter UI change, check:

- Did I inspect the local screen pattern?
- Did I reuse existing tokens and components?
- Did I avoid new colors, radii, and shadows?
- Did I keep copy beginner-friendly?
- Did I avoid fake data and fake claims?
- Did I avoid screenshot/golden tests unless the user asked?
- Did I keep backend, native, and dependency scope out unless approved?

## Review Checklist

MUST FIX:

- Unreadable text.
- Clipping or overflow.
- Broken alignment.
- Misleading hierarchy.
- Misleading health, sensor, or progression claims.
- Low-data states that look like real analysis.

SHOULD FIX:

- Inconsistent card rhythm.
- Decorative icons without meaning.
- Weak spacing hierarchy.
- Random one-off values.
- Excessive nested cards.

FUTURE IMPROVEMENT:

- Shared component library.
- Cross-screen token extraction.
- Motion policy.
- Global design-system refactor.
