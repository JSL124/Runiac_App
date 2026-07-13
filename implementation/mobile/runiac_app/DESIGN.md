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

### Onboarding Guide Overlay

- **Structure**: selected guide character beside a compact support bubble, anchored 20px above the safe-area bottom.
- **Blue-guide motion**: the Blue guide enters from a randomly selected left or right edge using the matching eight-frame running GIF, then switches to the supplied Blue idle GIF after an 800ms transform-only run-in. The bubble fades in only after arrival; other character selections retain their static facing sprite.
- **Placement**: when entering from the left the character rests at the lower-left with the bubble to its right; when entering from the right this layout mirrors. This keeps the guidance surface in the lower safe area instead of obscuring the active question.
- **Accessibility**: reduced-motion users see the final idle pose and readable bubble immediately. The bubble remains dismissible by its close control or a tap away.

### Level Profile Badge

- **Structure**: circular pale-blue profile disc, blue-tinted ring track, orange progress arc, centered runner initial, and an overlapping orange level pill.
- **Variants**: compact Home dashboard trigger and larger Account identity profile mark.
- **Colors**: `RuniacColors.primaryBlue` for the initial/ring track, `RuniacColors.accentOrange` for progress and level pill, `RuniacColors.white` for pill text.
- **Spacing**: stable square ring sizing; the pill overlaps the lower ring edge and keeps a minimum readable width.
- **States**: display-only in the current UI; tap behavior belongs to the surrounding Home profile trigger.
- **Accessibility**: profile trigger keeps the `Profile` semantic action, and the visual badge exposes the level label as supportive profile context.
- **Boundary**: level and progress are read-only display values. The Flutter client must not calculate or write trusted XP, level, rank, streak, or leaderboard progression.

### Account Division Badge

- **Structure**: a compact square division emblem appears immediately before the Account nickname within the identity row.
- **Ranked state**: reuse the matching Leaderboard league image supplied by the backend-owned `divisionKey`; do not repeat the division name as visible text beside the nickname.
- **Unranked state**: preserve the same footprint with an unfilled, low-emphasis shield outline and no visible `Unranked` text. The level pill remains independent and continues to show `Lv.0`.
- **Accessibility**: expose the backend-provided division label through image semantics even when the unranked badge is visually empty.
- **Boundary**: division key and label are read-only backend outputs. Flutter maps a supplied key to an asset but must not derive division from level, XP, rank, or leaderboard state.

### Account Profile Badge

- **Structure**: the Account identity header uses the shared `RuniacLevelProfileBadge`, matching the Home/Feed profile component style with a blue profile disc, white initials, orange progress arc, and orange level pill.
- **Sizing**: Account uses the larger identity variant so the same component can anchor the profile page without changing the compact Home/Feed row treatments.
- **Data**: initials, level label, and progress fraction are read-only display values from the trusted account/progress read model.
- **Boundary**: Flutter must not derive, calculate, or write XP, level, rank, streak, or leaderboard progression from the Account badge.

### Account Challenge Badge Case

- **Structure**: the Account page places the supplied illustrated 3x3 challenge case directly below the level progress gauge. Nine transparent badge assets are overlaid at the source-slot centres as a static fit preview.
- **States**: current usage is a visual asset-fit preview only; earned and unearned collection states are not implemented.
- **Sizing**: the case retains its source aspect ratio; badge images scale from its width so every badge stays centred in its intended slot.
- **Accessibility**: the complete case is announced as a single image summary; individual decorative badge images are excluded.
- **Boundary**: a future earned/unearned badge state must come from a trusted challenge/progression read model. Flutter must not calculate or write challenge completion, XP, level, rank, streak, or leaderboard values.

### Home Stage Map

- **Structure**: one full-width illustrated background per plan week with exactly seven stage stones, a weekday caption per real weekday slot, and one guide character attached to the active stone.
- **Layout**: each complete background draws one seven-stone chevron, alternating `<`, `>`, `<` as backgrounds stack. Every chevron starts and ends at the horizontal centre so the path is continuous across background seams. Vertical intervals stay uniform, and the bottom/first background reserves at least one bottom-navigation-height of visual clearance beneath the lowest stone caption.
- **Sizing**: stone diameter is responsive within a 92–108px mobile range. The guide character is 0.86 times its stone width and is anchored by its feet, which rest on the stone's visible standing surface (just above the plate's vertical centre) so the body rises above the plate and the plate stays visible beneath. Foot anchoring is character-agnostic: it derives from the rendered sprite height plus one shared transparent foot-inset allowance, never per-asset pixel offsets.
- **Landing**: on first Home-dashboard entry, the map scrolls toward the rendered guide-character box centre one-third up from the viewport bottom when that location is reachable; otherwise it stops at the nearest valid map position. Runners can then scroll freely to inspect every stage.
- **States**: completed, current, missed, future, run, and rest visuals retain their existing assets and backend-read-only meaning. The character follows the real local weekday slot rather than the first unfinished workout.
- **Missed treatment**: an incomplete run stone before today's weekday is desaturated and darkened, with a neutral dash badge and `Missed stage` semantics. This avoids shame-oriented copy and does not rely on color alone.
- **Date rollover**: the app shell refreshes its local calendar day at midnight and on app resume, then reloads the trusted streak projection and rebuilds Home/You plan displays for the new date.
- **Reschedule sync**: schedule edits update the shared generated-plan store, so Home rebuilds the same week from the new weekday assignment without duplicating plan state.
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

### Home Social Dropdown

- **Structure**: an always-visible `Social` trigger pill sits directly below the header profile badge, reusing the shared dark translucent header control decoration (radius 999, white border, soft shadow) with a `Social` label and a drop-down/up arrow. Tapping it expands a compact white menu card (radius 18, `cardBorder` border, `softCardShadow`, ~180px wide) right-aligned below the header with two rows: `Friends` (`people_outline`) and `Challenge` (`emoji_events_outlined`).
- **States**: collapsed shows only the trigger with a down arrow. Expanded flips the arrow up, renders the menu panel, and mounts a full-surface tap-outside dismissal barrier between the map and the header layer; the barrier intentionally blocks map interaction only while the menu is open and is unmounted when closed so stage taps and closed-state semantics are unaffected. `Friends` closes the menu and forwards to the caller's navigation callback; `Challenge` closes the menu and shows only the `Challenge is coming soon!` SnackBar (coming-soon state, no navigation).
- **Colors**: trigger text/icon white on the shared header control fill; menu card `white` surface, `primaryBlue` item icons, `textPrimary` w800 item labels, `border` divider between rows.
- **Accessibility**: the trigger announces `Social menu` as a button; each menu row announces its label (`Friends`, `Challenge`) as a button. The trigger stays within the header gradient's existing bottom padding so the taller right column does not clip on 360px-wide layouts.
- **Boundary**: navigation trigger only. The dropdown reads and writes no social data, performs no friend/request queries, and never calculates or mutates XP, level, rank, streak, or leaderboard values. Challenge behavior beyond the SnackBar stub is future scope.

### Friends Screen (static shell)

- **Structure**: `RuniacBackHeader` titled `Friends`, a compact 4-segment `YouSegmentedControl` (`Friends` / `Search` / `Suggested` / `Requests`), and a per-tab body of white rows (radius 18, `border` outline) led by a compact 42px `RuniacLevelProfileBadge` with a 16px level pill, a w800 `textPrimary` display name, and a w700 `textSecondary` subtitle.
- **Per-tab states**: `Friends` lists accepted friends or an empty state; `Search` shows a hint state until a query is typed, then case-insensitive name matches over the searchable demo users, with a `No runners found` empty state for no matches; `Suggested` lists recommended runners or an empty state; `Requests` lists incoming requests with pill `Accept` (filled `primaryBlue`) and `Decline` (outlined white) actions, and an empty state once none remain.
- **Session-local accept/decline**: Accept moves the request row to the top of the Friends list and Decline removes it — both are local `setState` display rearrangements only, reset on screen re-entry; nothing is persisted.
- **Accessibility**: Accept/Decline announce `Accept <name>` / `Decline <name>` as buttons; the search field announces `Search runners`; row badges are excluded from semantics so the adjacent name remains the single readable identity.
- **Boundary**: friend relationships, request state, and level labels are backend-owned; the demo snapshots supply pre-formatted `Lv.x` display strings and the client never derives levels, XP, rank, or streak values. The client never writes `users/{uid}/friends`, the module contains no Firebase imports, and its accepted-friends naming stays compatible with the feed's accepted-friends contract. The future profile badge-collection slot is out of scope for this shell.

### Weekly Plan Day Row

- **Structure**: aligned weekday, status node, workout title/status copy, and an optional detail chevron.
- **States**: completed, completed today, today upcoming, future upcoming, rest, missed, and inactive.
- **Missed treatment**: an incomplete running session whose scheduled day has passed uses a muted `textSecondary` surface, a neutral dash node, and the explicit status label `Missed`. The treatment stays non-judgmental and never relies on color alone.
- **Interaction**: missed workouts may still open their read-only workout detail, but do not expose Start or Edit schedule actions. Only future workouts may be rescheduled.
- **Boundary**: missed is a date-and-read-model display state only. The client does not change trusted completion, streak, XP, rank, or leaderboard values.

### Feed Profile Badge

- **Structure**: Feed post and comment author rows reuse the Home dashboard `RuniacLevelProfileBadge` with a compact level pill inside the profile mark rather than a separate text label.
- **Data**: `authorLevelLabel` is a backend-owned profile snapshot. Flutter may compact the trusted display string from `Level 6` to `Lv.6` for row density, but it must not derive the numeric level. The pill stays absent when the trusted snapshot is empty.
- **Sizing**: Feed rows use a 42-44px badge with a 16px pill so the level stays attached to the profile component without increasing row density.
- **Accessibility**: the adjacent author name remains the readable identity; the badge is decorative in Feed rows to avoid duplicate profile announcements.
- **Boundary**: Flutter must not derive, calculate, or write level progression for Feed profile badges.

### Feed Comment Sheet

- **Structure**: the existing scroll-controlled Runiac modal route contains a centered drag handle and `Comments` title, a newest-first comment list, and a keyboard-safe composer fixed to the bottom of the sheet.
- **Comment row**: the same compact `RuniacLevelProfileBadge` treatment used by the Home dashboard leads a compact author/time line and multiline body, including the trusted level pill when the comment snapshot provides it. The current author receives one `more_horiz` action; edit and delete are never exposed on another runner's comment.
- **Composer**: one rounded `Join the conversation...` field fills the available width without a leading profile badge. A familiar send icon is the only submit action. Edit mode is explicit, cancellable, and reuses the composer without changing sheet geometry.
- **Owner actions**: edit/delete selection and destructive confirmation use Runiac modal bottom sheets. Delete remains red and requires confirmation.
- **Colors**: white sheet surface, `sectionSurfaceStrong` avatars/composer fill, `primaryBlue` author initials and send action, `textSecondary` timestamps, `errorRed` destructive action.
- **Spacing**: `space2` for compact metadata, `space3` between comment rows, `space4` horizontal sheet padding, and stable 40-48px interactive targets.
- **States**: initial loading, pagination loading, empty, offline read-only, validation error, submitting, editing, delete confirmation, and recoverable load/mutation failure.
- **Accessibility**: avatar initials are decorative beside a textual author name; owner menus and send/edit actions have semantic labels; body text remains selectable by screen readers and is never truncated.
- **Boundary**: Firestore Rules enforce comment ownership for update/delete. Flutter sends body intent only and never writes the post's backend-owned aggregate `commentCount`.

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
