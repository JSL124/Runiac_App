Standalone only — not integrated into run_plan_review.sh yet.

## Context Class Decision

- selected_class: workflow
- reason: User explicitly declared context class 'workflow'.
- source: user-declared
- excluded_classes_considered: N/A — user explicitly declared class

## Plan Scope

### allowed_planning_paths
- workflow: tools/agent-review/**, .claude/settings.json
- always_read: AGENTS.md, CLAUDE.md

### excluded_planning_paths
- large_or_expensive: docs/submissions/**, **/*.pdf, **/*.png, **/*.jpg, **/*.jpeg, **/*.svg
- generated: **/node_modules/**, **/build/**, **/.dart_tool/**, test-evidence/**
- sensitive: .env, .env.*, secrets/**

### inventory_summary
- Source: git ls-files
- Listed files limit: 200
- Directory depth limit: 3
- Inventory byte limit: 50000

### applied_invariants
- XP/streak/level/rank/leaderboard are backend-owned.
- Flutter may display trusted values but must not directly write official XP/rank/leaderboard values.
- subscriptionStatus controls Basic/Premium access.
- userRole controls operational/governance roles.
- Medical Trainer/Expert submits draft expert plans only.
- Platform Administrator approves/rejects/publishes/archives expert plans.
- AI/LLM must not become official XP/rank/leaderboard logic.

## Review Budget Hint

- review_enabled: 1
- review_mode: lite
- file_budget: 3
- skip_reason_required: no

## Forbidden Content Pattern Summary

- No secrets/API keys
- No production project IDs
- No precise GPS coordinates committed as fixture/static data

## Inventory

### Git Status Summary
```text
?? implementation/traceability/tool-smoke-tests/
```

### Compact File List
```text
.claude/settings.json
.gitignore
AGENTS.md
CLAUDE.md
PDD_diagram_plan.md
PRD.md
diagrams/README.md
diagrams/application_architecture/application_architecture.md
diagrams/application_architecture/application_architecture.mmd
diagrams/application_architecture/application_architecture_drawio_notes.md
diagrams/class_diagram/class_diagram.drawio
diagrams/class_diagram/class_diagram.md
diagrams/class_diagram/class_diagram_final_reference.md
diagrams/class_diagram/class_diagram_plan.md
diagrams/class_diagram/class_diagram_simplified.drawio
diagrams/class_diagram/class_diagram_simplified.md
diagrams/component_diagram/component_diagram.drawio
diagrams/component_diagram/component_diagram.md
diagrams/component_diagram/component_diagram_plan.md
diagrams/physical_architecture/README.md
diagrams/physical_architecture/physical_architecture.md
diagrams/physical_architecture/physical_architecture.mmd
docs/pdd/00-orchestration-plan.md
docs/pdd/01-application-architecture.md
docs/pdd/02-physical-architecture.md
docs/pdd/03-component-diagram.md
docs/pdd/04-class-diagram.md
docs/pdd/05-admin-expert-wireframe-figure-insert.md
docs/pdd/05-final-wireframe-insertion-order.md
docs/pdd/05-final-wireframe-section.md
docs/pdd/05-wireframe-description.md
docs/pdd/05-wireframe-image-generation-prompts.md
docs/pdd/06-consistency-review.md
docs/pdd/AGENTS.md
docs/pdd/AGENTS_CHANGELOG.md
docs/pdd/AGENT_ROLES.md
docs/pdd/PDD_WORD_PDF_FORMATTING_CHECKLIST.md
docs/pdd/RUNIAC_PDD_ASSEMBLED_DRAFT.md
docs/pdd/diagrams/AGENTS.md
docs/pdd/diagrams/application-architecture.puml
docs/pdd/diagrams/class-diagram.puml
docs/pdd/diagrams/component-diagram.puml
docs/pdd/diagrams/physical-architecture.puml
docs/pdd/wireframe-images/shared-governance/.gitkeep
docs/pdd/wireframes/AGENTS.md
docs/project-management/RUNIAC_AGENT_REVIEW_TODO.md
docs/project-management/RUNIAC_PROJECT_PLAN.md
firebase/AGENTS.md
firebase/README.md
firebase/emulators/README.md
firebase/emulators/seed-data/.gitkeep
firebase/messaging/README.md
implementation/AGENTS.md
implementation/AGENT_ROLES.md
implementation/README.md
implementation/mobile/AGENTS.md
implementation/mobile/README.md
implementation/shared/README.md
implementation/traceability/README.md
implementation/traceability/decisions/2026-05-23T13-38-25_codex_decision.md
implementation/traceability/decisions/2026-05-23T13-56-50_codex_decision.md
implementation/traceability/decisions/2026-05-23T14-20-53_codex_decision.md
implementation/traceability/decisions/2026-05-23T17-25-47_codex_decision.md
implementation/traceability/decisions/2026-05-24T04-16-49_codex_decision.md
implementation/traceability/decisions/2026-05-24T06-03-44_codex_decision.md
implementation/traceability/plans/2026-05-23T13-12-57_codex_plan.md
implementation/traceability/plans/2026-05-23T13-50-49_codex_plan.md
implementation/traceability/plans/2026-05-23T14-20-53_codex_plan.md
implementation/traceability/plans/2026-05-23T17-25-47_codex_plan.md
implementation/traceability/plans/2026-05-24T04-16-49_codex_plan.md
implementation/traceability/plans/2026-05-24T06-03-44_codex_plan.md
implementation/traceability/reviews/2026-05-23T13-31-29_claude_review.md
implementation/traceability/reviews/2026-05-23T13-52-52_claude_review.md
implementation/traceability/reviews/2026-05-23T14-20-53_claude_review.md
implementation/traceability/reviews/2026-05-23T17-25-47_claude_review.md
implementation/traceability/reviews/2026-05-24T04-16-49_claude_review.md
implementation/traceability/reviews/2026-05-24T06-03-44_external_review_skipped.md
test-evidence/AGENTS.md
test-evidence/README.md
test-evidence/emulator-runs/.gitkeep
test-evidence/manual-test-runs/.gitkeep
test-evidence/reports/.gitkeep
test-evidence/screenshots/.gitkeep
tests/AGENTS.md
tests/README.md
tests/cross-system/.gitkeep
tests/e2e/.gitkeep
tests/firebase-rules/.gitkeep
tests/fixtures/.gitkeep
tests/functions-integration/.gitkeep
tests/harness/README.md
tools/agent-review/README.md
tools/agent-review/profiles/generic/README.md
tools/agent-review/profiles/generic/context-policy.yml
tools/agent-review/profiles/runiac/README.md
tools/agent-review/profiles/runiac/agent-review.env.example
tools/agent-review/profiles/runiac/context-policy.yml
tools/agent-review/profiles/runiac/prompts/01_codex_create_plan.md
tools/agent-review/profiles/runiac/prompts/02_claude_review_plan.md
tools/agent-review/profiles/runiac/prompts/03_codex_final_review_decision.md
tools/agent-review/profiles/runiac/prompts/04_codex_implement_approved_plan.md
tools/agent-review/profiles/runiac/prompts/05_claude_review_plan_lite.md
tools/agent-review/runner/build_context_packet.sh
tools/agent-review/runner/lib/common.sh
tools/agent-review/runner/run_plan_review.sh
wireframe.md
```

### Applied Broad Exclusions
node_modules, build, .dart_tool, .git, docs/submissions, secrets, .env files, PDFs, images, SVGs
