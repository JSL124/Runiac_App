# Governance CI Check Contract

## Metadata

- Status: Draft contract only
- Owner: A0_ORCH
- Phase: Phase 01 - Governance CI

## Purpose

Define deterministic, scaffold-baseline-safe governance checks for repository hygiene, forbidden-scope detection, roadmap context discipline, and evidence readiness. This document is a contract only; it does not define GitHub Actions and does not implement scripts.

## Check Contracts

| Script name | Purpose | Scanned paths | Allowlist | Pass criteria | Fail criteria |
| --- | --- | --- | --- | --- | --- |
| `check-pre-scaffold-scope.sh` | Confirm the repository remains within the approved scaffold-baseline boundary and no unauthorized app/config files were introduced. | `.` with shallow path filters | Approved stock Flutter scaffold under `implementation/mobile/runiac_app/`, roadmap/docs placeholders, README files, AGENTS files, `.gitkeep` | Stock Flutter scaffold markers are limited to `implementation/mobile/runiac_app/`; no Firebase config, production source/config, `firebase.json`, `.firebaserc`, app `package.json`, `google-services.json`, or `GoogleService-Info.plist` found outside an explicitly approved boundary. | Any forbidden scaffold/config/source marker appears outside an explicit approved boundary. |
| `check-sensitive-paths.sh` | Confirm sensitive/config/private artifacts are ignored or denied by governance policy. | `.gitignore`, `.claude/settings.json`, `tools/agent-review/profiles/runiac/context-policy.yml` | `.env.example`, `.env.*.example`, documented placeholders | Required deny/ignore patterns exist for `.env*`, nested `.env*`, secrets, Firebase config, service accounts, signing files, private GPS/location/route artifacts, and test evidence. | Required pattern missing, malformed JSON/YAML, or broad private-data pattern replaced with unsafe generic matching. |
| `check-roadmap-routing.sh` | Confirm roadmap context routing is deterministic. | `implementation/roadmap/CURRENT.md`, active phase file, `implementation/roadmap/snapshots/latest.md` | None | `CURRENT.md` names one active phase, required reading order is present, snapshot commit hash is present, and forbidden scope remains explicit. | Missing active phase, stale Phase 00 routing after closure, missing snapshot hash, or missing forbidden-scope language. |
| `check-agent-governance.sh` | Confirm root agent governance remains concise and aligned with current constraints. | `AGENTS.md` | Existing role index and mode-specific rule list | Non-negotiable Runiac rules, commit protocol, canonical diagram path, roadmap context protocol, and path protection are present. | Rules missing, duplicated into conflicting versions, or canonical `docs/pdd/diagrams/` ownership weakened. |
| `check-diff-hygiene.sh` | Confirm staged or working diff is reviewable before commit. | `git status --short`, `git diff --check`, optional path-filtered `git diff --stat` | Task-approved files only | No whitespace errors, no unrelated modified files, and no forbidden generated/source/config files in the diff. | Whitespace errors, unrelated paths, or forbidden implementation/config artifacts present. |

## Output Structure

Sample pass:

```text
CHECK check-roadmap-routing PASS
scanned_paths=implementation/roadmap/CURRENT.md,implementation/roadmap/snapshots/latest.md
message=Active phase and snapshot metadata are deterministic.
```

Sample fail:

```text
CHECK check-sensitive-paths FAIL
scanned_paths=.gitignore,.claude/settings.json,tools/agent-review/profiles/runiac/context-policy.yml
message=Missing nested .env deny pattern: Read(./**/.env.*)
next_step=Update governance policy, then rerun once.
```

## False-Positive Prevention Rules

- Do not fail on negated safety text such as "Do not run firebase init" or "without creating Firebase config".
- Do not use naive bare-keyword blocking for terms such as `secret`, `token`, `gps`, `route`, or `location`.
- Match sensitive private GPS/location/route artifacts only with narrow private-name patterns such as `gps-private`, `private-gps`, `route-private`, `private-route`, `location-private`, and `private-location`.
- Treat documentation references to forbidden commands as safe when they are clearly governance instructions, prohibitions, examples, or review evidence.
- Prefer path-based checks and structured JSON/YAML parsing over broad text scans when the file format supports it.
- Report the exact path, pattern, or line class that caused a failure so reviewers can distinguish real drift from documentation examples.

## Escalation Policy

- A failing governance check blocks Ready for commit until A6_REVIEW and A8_OUTPUT_CHECKER review the failure.
- If a failure involves secrets, production Firebase, scaffold/config creation, private GPS data, approval bypass, or command execution scope, escalate to human review approval before retrying implementation work.
- If the check result is ambiguous, classify it as a review finding rather than auto-fixing it.
- Do not weaken allowlists to pass a check without explicit human approval and a documented reason.

## Retry Limit Policy

- Maximum automated retry attempts: 2.
- Retry only after a scoped change that directly addresses the reported failure.
- After 2 failed attempts, stop and require human review approval before further changes.

## Scaffold-Baseline Safety Boundary

These checks must not run Flutter, Firebase, npm, scaffold, init, build, deploy, dependency installation, emulators, or production service commands. They may use deterministic shell, Git, JSON/YAML parsing, and Markdown/path inspection only.
