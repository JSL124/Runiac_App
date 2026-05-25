# Retrospective Policy

## Archive Philosophy

The Non-Operational Historical Archive is curated engineering memory. It preserves high-value learning about governance, workflow discipline, architectural tradeoffs, hallucination prevention, overengineering, and AI-assisted engineering practice.

The archive exists to preserve high-value engineering learning, not to maximize historical completeness.

Capture less, curate more.

The archive is not exhaustive operational history. Low-signal operational detail may be intentionally omitted so the archive remains useful over time.

Archive growth should prefer milestone-based, append-oriented updates. Restraint is preferred over accumulation, and each entry should justify why it is worth preserving.

## Trigger Conditions

Trigger conditions permit retrospective creation.

They do NOT require retrospective creation.

Retrospectives may be considered after:

- Phase closures
- Major governance redesigns
- Significant workflow simplifications
- Irreversible architectural or operational transitions
- Major milestone completions

Retrospectives should not be created for:

- Every commit
- Every capsule
- Minor fixes
- Routine maintenance
- Automatic generation

## Update Authority

AI may synthesize, summarize, or propose retrospective drafts when explicitly asked.

Humans approve and persist historical entries.

No autonomous historian behavior.

The archive forbids automatic persistence, autonomous updates, and self-triggered retrospective generation.

## Retrospective Schema

Retrospectives should reuse the schema established in `docs/meta/RUNIAC_REPOSITORY_EVOLUTION_REPORT.md`:

### Previous State

### Problem

### Why Existing Approach Failed

### New Mechanism Introduced

### Tradeoffs Introduced

### Long-term Outcome

### Historical Confidence

Historical Confidence values:

- High = verified by artifacts
- Medium = reconstructed reasoning
- Low = retrospective interpretation

## Forbidden Behaviors

Retrospectives must not introduce or support:

- Autonomous logging
- Commit-by-commit journaling
- retrospective recursion
- Operational authority
- Dependency input
- Automatic context loading
- Exhaustive chronology
- Operational rerouting
- ADR replacement
- Governance override

Retrospectives should not recursively analyze or summarize other retrospective documents unless explicitly justified.

They must not become operational truth, routing authority, execution authority, implementation authority, approval authority, dependency input for tooling, or automatic execution context.

## Historical Integrity

Retrospectives are preserved historical artifacts. They may reflect the understanding available at the time they were written.

Retrospectives may summarize, synthesize, and interpret historical tradeoffs, but they do not redefine historical operational truth.

Retrospectives may intentionally omit low-value detail to preserve archive clarity and long-term usefulness.

Retrospectives are reflective historical summaries. They do not replace ADRs or operational decision records.
