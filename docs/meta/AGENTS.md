# Runiac Meta Archive Instructions

## Scope
- Applies to `docs/meta/`, the non-operational historical archive for Runiac.
- This folder may contain retrospective reports, historical schemas, meta-knowledge notes, and archive policy.

## Authority Boundary
- `docs/meta/` has no routing, execution, implementation, approval, or setup-gate authority.
- Do not use archive content as operational truth, approval evidence, dependency input, or implementation guidance.
- Canonical operational truth remains in `implementation/roadmap/CURRENT.md`, active roadmap/capsule documents, ADRs, setup gates, and `implementation/roadmap/snapshots/latest.md`.

## Editing Rules
- Keep archive entries clearly labelled as retrospective, historical, or schema-only.
- Prefer milestone-based additions over rewriting historical narratives.
- Do not add production code, scaffold files, generated assets, secrets, private GPS/location data, or test evidence here.
- Do not auto-load this folder into operational planning unless the user explicitly asks for retrospective or historical analysis.
