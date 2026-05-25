# Artifact Inventory Schema

> **STATUS:** Planning/Non-Authoritative until approved through operational-authority sources.

## Purpose

This document defines schema rules for a possible Artifact Inventory. It is a non-operational schema reference only.

It does not create artifact inventory entries, approve artifacts, validate artifacts, reconstruct repository history, or grant operational authority.

## Scope

This schema may describe the fields, controlled vocabularies, authority boundaries, and validation checks that a future Artifact Inventory would need if separately approved.

This document is limited to schema rules. It does not define live inventory content or an operational inventory process.

## Non-Authority Boundary

`docs/meta/` remains a non-operational historical and reflective archive.

This schema has no routing authority, execution authority, implementation authority, approval authority, or dependency authority. It must not be used as operational truth, approval evidence, implementation guidance, or dependency input for operational tooling.

If this document conflicts with operational-authority sources, the operational-authority sources control.

## Operational Authority Sources

Operational authority can only originate from approved operational-authority sources:

- `implementation/roadmap/CURRENT.md`
- Active phase documents
- Active capsule documents
- ADRs
- Validated snapshots

Artifacts under `docs/meta/` must not override `implementation/roadmap/CURRENT.md`, active phase/capsule documents, ADRs, or validated snapshots.

## Required Safeguards

- This document defines schema rules only.
- It does not create inventory entries.
- It does not reconstruct repository history.
- It does not create timelines.
- It does not create Genesis material.
- It does not create retrospectives.
- It does not introduce autonomous archive systems.
- It does not make `docs/meta` operational authority.
- It does not allow reflective or historical artifacts to override operational sources.
- `required_external_review_gate_ref` is external-reference-only.
- `confidence_review_gate` is external-reference-only.
- Review gate fields must not create, modify, imply, approve, satisfy, or bypass any gate.

## Required Schema Fields

- `inventory_id`: Stable schema record identifier. It must not imply artifact approval.
- `artifact_ref`: Path, document reference, or external reference for the artifact.
- `artifact_type`: Artifact category, such as roadmap, ADR, snapshot, review record, PDD document, diagram, wireframe, meta document, or external reference.
- `artifact_scope`: Bounded scope classification from the controlled vocabulary.
- `artifact_status`: Lifecycle or status classification from the controlled vocabulary.
- `evidence_basis`: Evidence type supporting the schema record metadata.
- `provenance_status`: Classification of how the artifact or source origin is known.
- `confidence_level`: Confidence in the inventory metadata, not in artifact authority.
- `authority_classification`: Classification of the artifact authority relationship.
- `validation_status`: Review or validation state of the inventory metadata.
- `created_by_process`: Process that created the inventory metadata, such as human-approved, agent-proposed, or governance-routed.
- `last_reviewed`: Date or review marker for the metadata review.
- `notes_policy`: Bounded rule controlling what notes may contain.

## Optional Schema Fields

- `artifact_owner`: Person, role, or process responsible for artifact stewardship, when known.
- `related_artifacts`: Bounded references to related artifacts.
- `supersedes`: Reference to an artifact this artifact supersedes.
- `superseded_by`: Reference to an artifact that supersedes this artifact.
- `external_reference`: External source reference, when applicable.
- `required_external_review_gate_ref`: External-reference-only pointer to an existing required review gate.
- `confidence_review_gate`: External-reference-only pointer to an existing confidence review gate.
- `retention_policy`: Retention or archival handling classification.
- `exclusion_reason`: Reason an artifact is excluded from inventory use or authority claims.

## Controlled Vocabularies

### artifact_scope

- `operational_governance`
- `pdd_documentation`
- `implementation_planning`
- `meta_non_operational`
- `review_record`
- `external_reference`
- `excluded`

### artifact_status

- `proposed`
- `draft`
- `active`
- `approved`
- `superseded`
- `archived`
- `rejected`
- `blocked`
- `missing`

### evidence_basis

- `direct_artifact`
- `operational_authority_reference`
- `validated_snapshot_reference`
- `approved_review_record`
- `external_reference`
- `user_supplied`
- `unknown`

### provenance_status

- `confirmed`
- `recovered_from_artifact`
- `user_supplied`
- `recreated_proposal`
- `unknown_unusable`

### confidence_level

- `high`
- `medium`
- `low`
- `unresolved`

### authority_classification

- `operational_authority`
- `non_operational_reference`
- `reflective_historical`
- `external_reference_only`
- `prohibited_as_authority`

### validation_status

- `unreviewed`
- `pending_a6_review`
- `pending_a8_output_check`
- `reviewed_not_approved`
- `approved_by_operational_source`
- `blocked`

### notes_policy

- `factual_only`
- `bounded_context_only`
- `no_inference`
- `external_reference_only`
- `excluded`

## Review Gate Field Rules

`required_external_review_gate_ref` is external-reference-only.

`confidence_review_gate` is external-reference-only.

These fields may reference existing gates only. They must not create, modify, imply, approve, satisfy, bypass, or replace any gate.

## Validated Snapshot Definition

A validated snapshot is a snapshot that has been explicitly accepted by the active governance process and is referenced, approved, or ratified through at least one operational-authority source: CURRENT.md, an active phase/capsule document, an ADR, or an approved validation/review record. Snapshot-like documents, archived snapshots, draft summaries, or reflective notes are not validated snapshots unless this acceptance path is explicit.

## Authority Classification Clarification

`authority_classification: operational_authority` only identifies artifacts already authoritative through approved operational sources; it does not confer authority.

No value in `authority_classification` can make `docs/meta` operational authority. Authority must be established outside this schema through approved operational-authority sources.

## Forbidden Uses

This schema must not be used to:

- Create inventory entries.
- Reconstruct repository history.
- Create timelines.
- Create Genesis material.
- Create retrospectives.
- Introduce autonomous archive systems.
- Make `docs/meta` operational authority.
- Infer authority from reflective documents.
- Treat historical explanations as approval evidence.
- Bypass active phase, capsule, ADR, snapshot, or AGENTS instructions.
- Run or authorize Flutter, Firebase, build, deploy, init, scaffold, source, or test work.

## Validation Requirements

Before any future change claims readiness:

- Confirm the change is limited to the approved target file or explicitly approved scope.
- Confirm the exact status banner remains present.
- Confirm the exact validated snapshot definition remains present.
- Confirm all required schema fields are present.
- Confirm all optional schema fields are present.
- Confirm controlled vocabularies remain bounded.
- Confirm no inventory entries are created.
- Confirm no repository history reconstruction is introduced.
- Confirm no timelines, Genesis material, retrospectives, or archive automation are introduced.
- Confirm `docs/meta` remains non-operational.
- Confirm `authority_classification: operational_authority` remains identification-only and does not confer authority.
- Confirm review gate fields remain external-reference-only and cannot create, modify, imply, approve, satisfy, bypass, or replace gates.

## Future Change Control

Future changes to this schema must be explicitly routed through operational-authority sources and reviewed against the current roadmap context.

Schema changes must remain separate from inventory-entry creation, repository history reconstruction, retrospective creation, Genesis material, timeline creation, and autonomous archive behavior.
