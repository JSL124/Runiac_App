# Meta Knowledge Architecture

## Purpose

This document defines how the Runiac repository preserves long-term engineering evolution knowledge without creating operational drift, governance entropy, or uncontrolled archives.

The repository preserves structured evolution knowledge so future engineering and AI-assisted workflows can reuse important lessons, governance decisions, and workflow breakthroughs. It is not an exhaustive historical record and must not become a general archive of prompts, conversations, outputs, or timelines.

The guiding principles are:

- Store breakthroughs, not noise.
- Historical is not operational.
- Capture less, curate more.
- Prefer retrieval precision over archive size.
- Preserve high-value engineering evolution, not every trace of repository activity.

## Research Alignment

This architecture aligns conceptually with governed memory systems, context engineering, structured long-term memory, retrieval precision, human-curated memory, reflection-bounded retrieval, and separation between reflective memory and operational authority.

The design assumes that useful long-term memory is selective, structured, and curated. Larger archives are not automatically better because excess context can reduce retrieval quality, introduce stale assumptions, and blur the boundary between historical learning and current operational truth.

## MVP Layered Meta Knowledge Architecture

### Layer 1 - Operational Memory

Purpose:

- Execution routing.
- Current truth.
- Active governance.

Sources:

- `implementation/roadmap/CURRENT.md`
- Active phase documents.
- Active capsule documents.
- ADRs.
- Validated snapshots.

Operational Memory is authoritative. It controls current execution state, active constraints, approved gates, and repository routing. Meta knowledge documents must not override, reinterpret, or reroute these sources.

### Layer 2 - Historical Evolution Memory

Purpose:

- Architectural turning points.
- Governance evolution.
- Workflow breakthroughs.
- Failure lessons.
- Major engineering redesigns.

Example location:

- `docs/meta/retrospectives/`

Historical Evolution Memory is reflective and non-authoritative. It may explain how the repository evolved, why certain patterns emerged, and what lessons should be preserved, but it must not define current routing, active scope, approval state, or implementation authority.

### Layer 3 - Workflow Pattern Library

Purpose:

- Reusable AI engineering workflows.
- Reusable governance patterns.
- Reusable orchestration patterns.
- Reusable validation patterns.

Example location:

- `docs/meta/workflows/`

The Workflow Pattern Library is also reflective and non-authoritative. It preserves reusable patterns that may inform future work, but every future task must still obey Operational Memory and the closest active repository instructions.

## Authority Boundary

Meta knowledge layers are non-authoritative reflective layers.

Operational authority remains exclusively with:

- `implementation/roadmap/CURRENT.md`
- Active phase and capsule documents.
- ADRs.
- Validated snapshots.

Meta knowledge may support understanding, onboarding, retrospective learning, and workflow reuse. It must never become a routing source, approval source, gate source, or substitute for current operational context.

If a historical or workflow document conflicts with Operational Memory, Operational Memory wins.

## Store Breakthroughs, Not Noise

The archive exists to preserve high-value engineering evolution. It must remain intentionally small, curated, and retrieval-friendly.

Must store:

- Workflow breakthroughs.
- Governance redesigns.
- Failure lessons.
- Review pipeline evolution.
- Context engineering discoveries.
- Orchestration patterns.
- Architectural turning points.

Never store:

- Every prompt.
- Exhaustive logs.
- Commit-by-commit journaling.
- Every AI output.
- Every discussion.
- Raw chain-of-thought.
- Uncontrolled archives.

A useful entry should explain a durable lesson, reusable pattern, or meaningful repository evolution. If material does not improve future engineering judgment, validation quality, or governance clarity, it should not be promoted into meta knowledge.

## Human-Curated Only

Meta knowledge persistence is human-curated.

AI may:

- Summarize.
- Synthesize.
- Propose drafts.

Humans:

- Approve.
- Curate.
- Persist.
- Validate.

There must be no autonomous historian behavior. AI must not automatically create archives, generate retrospectives, infer origin stories, or persist historical claims without human approval and artifact-backed grounding.

Automatic archival generation is forbidden. Autonomous retrospective creation is forbidden.

## Entropy Prevention Rules

Meta knowledge must not introduce governance entropy or operational drift.

Explicitly forbidden:

- Operational rerouting from meta knowledge documents.
- Governance override from historical or workflow documents.
- Recursive retrospective analysis.
- Archive-driven routing.
- Automatic context loading from meta archives.
- Exhaustive chronology.
- Unbounded memory growth.
- Treating historical explanations as current approval evidence.
- Treating workflow patterns as active instructions without explicit routing.
- Using meta documents to bypass active phase, capsule, ADR, snapshot, or AGENTS instructions.

Meta knowledge is loaded only when relevant to a task and only as reflective context. It must not expand default task context, force broad retrieval, or require agents to read archives before ordinary work.

## Future Repository Genesis Requirement

A future file may be created at:

- `docs/meta/REPOSITORY_GENESIS.md`

Its intended purpose is to capture the repository's origin story in a bounded, artifact-backed way.

Requirements for that future file:

- It must be human-driven.
- It must rely on artifact-backed reconstruction.
- It must distinguish confirmed history from interpretation.
- It must not hallucinate rationale, events, motivations, or chronology.
- It must not become an operational routing document.
- It must not be created automatically.

This architecture does not create `REPOSITORY_GENESIS.md`, draft its contents, or invent repository history.

## Long-Term Philosophy

Runiac should use governed memory over exhaustive memory.

The repository should prefer compression over accumulation, retrieval quality over archive size, and reflective learning over historical completeness. Meta knowledge exists to preserve durable engineering insight while protecting operational speed.

Long-term memory is valuable only when it improves future judgment without burdening current execution. The repository should remain fast to operate, clear to route, and resistant to archive-driven confusion.
