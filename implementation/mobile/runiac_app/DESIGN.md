# Runiac Design System

## 1. Atmosphere & Identity

Runiac feels like a calm beginner running companion: clear, encouraging, and light enough for a new runner to trust without feeling judged. The signature is a blue-first mobile surface with orange reserved for warm action moments, using soft rounded structure and restrained motion.

## 2. Color

### Palette

| Role | Token | Light | Dark | Usage |
|------|-------|-------|------|-------|
| Surface/primary | `RuniacColors.background` | `#FFFFFF` | `#172033` | Main screen background |
| Surface/secondary | `RuniacColors.sectionSurface` | `#F4F7FF` | `#172033` | Calm screen panels and auth surfaces |
| Surface/strong | `RuniacColors.sectionSurfaceStrong` | `#EEF3FF` | `#172033` | Tinted icon and input surfaces |
| Surface/inner | `RuniacColors.innerTileSurface` | `#F7FAFF` | `#172033` | Inner tiles and secondary form fills |
| Text/primary | `RuniacColors.textPrimary` | `#172033` | `#FFFFFF` | Headlines and primary labels |
| Text/secondary | `RuniacColors.textSecondary` | `#6B7280` | `#DCE5FF` | Supporting copy and helper text |
| Border/default | `RuniacColors.border` | `#E6EAF2` | `#DCE5FF` | Field, button, and divider outlines |
| Border/brand | `RuniacColors.cardBorder` | `#DCE5FF` | `#DCE5FF` | Blue-tinted card edges |
| Accent/primary | `RuniacColors.primaryBlue` | `#2F50C7` | `#DCE5FF` | Primary CTAs, links, focus, logo |
| Accent/action | `RuniacColors.accentOrange` | `#FC6818` | `#FC6818` | High-emphasis action accents |
| Feedback/success | `RuniacColors.successGreen` | `#15803D` | `#15803D` | Positive validation and available states |
| Feedback/error | `RuniacColors.errorRed` | `#DC2626` | `#DC2626` | Blocking validation and unavailable states |

### Rules

- Use blue for identity and primary auth actions.
- Use orange sparingly for warmth and action emphasis, never for competitive pressure.
- Add new semantic colors to `RuniacColors` before using them in UI code.

## 3. Typography

### Scale

| Level | Size | Weight | Line Height | Tracking | Usage |
|-------|------|--------|-------------|----------|-------|
| Display | 36px | 800 | 1.12 | 0 | Auth welcome and major mobile moments |
| H1 | 28px | 800 | 1.15 | 0 | Screen titles |
| H2 | 22px | 800 | 1.2 | 0 | Section titles |
| H3 | 18px | 800 | 1.25 | 0 | Card titles |
| Body | 16px | 600 | 1.4 | 0 | Primary body copy |
| Body/sm | 14px | 600 | 1.35 | 0 | Secondary copy |
| Caption | 12px | 700 | 1.3 | 0 | Form labels and helper text |

### Font Stack

- Primary: Flutter platform sans via `ThemeData`, matching the current Flutter scaffold.
- Mono: not used in product UI.
- Serif: not used.

### Rules

- Keep mobile labels readable at 12px or larger.
- Avoid negative letter spacing in compact panels and buttons.

## 4. Spacing & Layout

### Base Unit

All spacing derives from a base of 4px.

| Token | Value | Usage |
|-------|-------|-------|
| `space1` | 4px | Tight icon gaps |
| `space2` | 8px | Compact groups |
| `space3` | 12px | Small vertical rhythm |
| `space4` | 16px | Button gaps and field padding |
| `space5` | 20px | Screen horizontal padding |
| `space6` | 24px | Card padding and section separation |
| `space8` | 32px | Major panel separation |
| `space10` | 40px | Large hero separation |

### Grid

- Max content width: mobile-first, constrained to 430px for auth surfaces.
- Column system: single-column mobile layout with stacked actions.
- Breakpoints: Flutter adaptive constraints, with narrow layouts verified at 360px.

### Rules

- Prefer `SafeArea`, `SingleChildScrollView`, and constrained content over fixed viewport assumptions.
- Fixed-format controls use stable minimum heights so labels and hover/focus states do not shift layout.

## 5. Components

### Auth Flow Screen

- **Structure**: `Scaffold` -> `SafeArea` -> constrained scroll body -> hero/header, fields, CTA stack, helper links.
- **Variants**: welcome, login, signup, forgot password.
- **Fields**: login and signup collect Email and Password only.
- **Identity provider**: email/password uses the injected auth repository. In emulator runs this is Firebase Auth emulator-backed; non-emulator runs use the non-production repository because production Firebase config is not present.
- **Validation**: local form validation covers email shape, required login password, and minimum signup password length. Firebase Auth remains the identity authority for account creation, login, password reset, persisted auth state, and sign-out.
- **Loading and errors**: login, signup, reset, and account sign-out disable their submitting controls while work is in progress, show operation-specific loading labels, and surface mapped beginner-friendly auth error messages.
- **Google/OAuth**: Google sign-in uses the approved Firebase Auth Google provider path. The auth UI shows a neutral `Continue with Google` button, disables auth actions while Google sign-in is pending, and maps provider/Firebase errors to beginner-friendly auth feedback. Google sign-in may complete either the login handoff or the signup/profile-collection handoff depending on the screen where the user started it.
- **Routing**: `RuniacAuthGate` observes the auth-state stream. Signed-out users see the auth flow, signed-in users see the app shell, signup immediately enters onboarding when onboarding is enabled, and login/restart skips onboarding.
- **Sign-out**: the Account screen includes a Sign out row that calls the auth repository, shows a signing-out state, and returns the user to the welcome/auth flow through the auth-state gate.
- **Profile bootstrap**: signup does not create `users/{uid}` or `userProfiles/{uid}` records. Profile bootstrap is deferred until onboarding completion because auth only has email/password, and the Flutter client must not write backend-owned role, subscription, XP, streak, level, rank, leaderboard, validation, premium, or expert-publication fields.
- **Emulator boundary**: Firebase Auth is emulator-only for this auth flow. Android debug emulator runs require cleartext traffic so the app can reach local emulator hosts such as `10.0.2.2`; this debug allowance is not a production Firebase configuration.
- **Welcome mark**: show the Runiac logo asset directly without a backing circle.
- **Spacing**: `space4`, `space5`, `space6`, and `space8`.
- **States**: default, tap, focus, loading/disabled, error feedback, and auth-state completion handoff.
- **Accessibility**: semantic buttons, labeled text fields, visible focus through Material defaults.
- **Motion**: short `AnimatedSwitcher` screen transition only.

### Primary Auth Button

- **Structure**: full-width `FilledButton` with optional icon.
- **Variants**: primary blue, secondary outlined, Google-style neutral.
- **Spacing**: 56px height, 16px radius, `space4` internal gap.
- **States**: default, disabled, pressed, focus from Material.
- **Accessibility**: text label is always visible and high contrast.
- **Motion**: Material press feedback only.

### Level Profile Badge

- **Structure**: circular pale-blue profile disc, blue-tinted ring track, orange progress arc, centered runner initial, and an overlapping orange level pill.
- **Variants**: compact Home dashboard trigger and larger Account identity profile mark.
- **Colors**: `RuniacColors.primaryBlue` for the initial/ring track, `RuniacColors.accentOrange` for progress and level pill, `RuniacColors.white` for pill text.
- **Spacing**: stable square ring sizing; the pill overlaps the lower ring edge and keeps a minimum readable width.
- **States**: display-only in the current UI; tap behavior belongs to the surrounding Home profile trigger.
- **Accessibility**: profile trigger keeps the `Profile` semantic action, and the visual badge exposes the level label as supportive profile context.
- **Boundary**: level and progress are read-only display values. The Flutter client must not calculate or write trusted XP, level, rank, streak, or leaderboard progression.

### Home Stage Map

- **Structure**: one full-width illustrated background per plan week with exactly seven stage stones, a weekday caption per real weekday slot, and one guide character attached to the active stone.
- **Layout**: each complete background draws one seven-stone chevron, alternating `<`, `>`, `<` as backgrounds stack. Every chevron starts and ends at the horizontal centre so the path is continuous across background seams. Vertical intervals stay uniform, and the bottom/first background reserves at least one bottom-navigation-height of visual clearance beneath the lowest stone caption.
- **Sizing**: stone diameter is responsive within a 92–108px mobile range. The guide character is slightly narrower than its stone and is anchored by its feet, which rest on the stone's visible standing surface (just above the plate's vertical centre) so the body rises above the plate and the plate stays visible beneath. Foot anchoring is character-agnostic: it derives from the rendered sprite height plus one shared transparent foot-inset allowance, never per-asset pixel offsets.
- **Landing**: on first Home-dashboard entry, the map scrolls toward a guide position about one-third of the viewport height from the top when that location is reachable; otherwise it stops at the nearest valid map position. Runners can then scroll to inspect every stage.
- **States**: completed, current, future, run, and rest visuals retain their existing assets and backend-read-only meaning.
- **Accessibility**: the current stage keeps its semantic button target; weekday captions remain display-only; the character's interactive upper-body target must not steal the stage tap target.
- **Motion**: current-stage pulse and guide walking behavior keep the existing reduced-motion handling and animate only transform/opacity-compatible properties. The Blue Home guide uses the supplied animated GIF at rest and during plan-to-plan movement; other characters retain their direction-specific PNG sprites.
- **Boundary**: layout and decoration are display-only. Plan completion and current-stage state remain derived from trusted completed scheduled-workout IDs.

### Home Guide Bubble

- **Structure**: an eligible current stage opens a compact white guide bubble above the character. Once its bundle resolves, it presents the local sequence plan summary, running tip, progression check-in, then returns to the summary. The bubble body advances only after a bundle message resolves; close hides it; the character reopens the current message.
- **Sizing and layout**: width is the smaller of 280px and viewport width minus 24px, with a 12px horizontal safe inset. The bubble clamps above the character within the available safe area, uses `space3`-adjacent compact padding, and keeps all accepted copy visible rather than truncating it. Three lines is the normal target for the approved short-copy budget, including text scale 1.3.
- **States**: loading says `Preparing your guide...` and does not advance. An unavailable bundle uses the existing supportive fallback copy. A changed stage/request restarts at the summary; hide/reopen and repeated taps reuse the same in-memory bundle without a new request.
- **Accessibility**: the bubble body announces message kind and its next action, such as `Plan summary. Tap to hear a running tip.` The close control has a visible 44×44px target and the semantic label `Close guide message`. The character retains its upper-body-only semantic action so the current-stage target remains available.
- **Motion**: message readability never depends on typing or transition animation. Reduced motion keeps the existing guide/pulse behavior disabled and shows the full resolved bubble copy immediately.
- **Boundary**: the bubble only renders server/local-agent supplied display copy. Flutter does not calculate progression, activity facts, XP, level, rank, streak, or leaderboard data, and does not persist guide-cycle state.

## 6. Motion & Interaction

### Timing

| Type | Duration | Easing | Usage |
|------|----------|--------|-------|
| Micro | 100-150ms | ease-out | Button press feedback |
| Standard | 200-300ms | ease-in-out | Auth screen changes |

### Rules

- Animate only opacity and transform-like transitions.
- Respect Material focus, tap, and semantics behavior.
- Avoid scroll listeners for auth and onboarding surfaces.

## 7. Depth & Surface

### Strategy

Mixed, with soft tonal surfaces first and subtle shadows only for major brand marks or elevated auth cards.

| Level | Value | Usage |
|-------|-------|-------|
| Subtle | `RuniacColors.softCardShadow` | Resting cards |
| Brand | `RuniacColors.primaryButtonShadow` | Blue CTA or logo emphasis |
| Action | `RuniacColors.orangeButtonShadow` | Orange action emphasis |

Depth stays light. The UI should feel friendly, not glossy or competitive.
