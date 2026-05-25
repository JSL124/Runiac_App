# Repository Workflow Record

> **NON-OPERATIONAL RECORD:** This document is a curated process/workflow record only. It is not operational truth, approval evidence, routing authority, setup-gate authority, implementation guidance, or dependency input for tooling. If this record conflicts with `implementation/roadmap/CURRENT.md`, active roadmap capsules, ADRs, setup gates, validated snapshots, or active `AGENTS.md` instructions, those operational-authority sources control.

## Purpose

This artifact-backed summary describes the current Runiac repository workflow discipline at a high level. It exists to preserve reusable process understanding without turning `docs/meta/` into an operational source.

The record is intentionally bounded. It does not reconstruct full repository history, define approval state, replace roadmap routing, or authorize implementation work.

## Current Discipline

Runiac currently uses layered context retrieval before work begins. The intended workflow starts from `implementation/roadmap/CURRENT.md`, then follows any active phase or capsule routing, relevant ADRs, and `implementation/roadmap/snapshots/latest.md`. Folder-level `AGENTS.md` files then provide local scope rules for the area being changed.

This discipline keeps active operational truth separate from reflective archive material. `docs/meta/` may preserve curated workflow learning, but it must not drive routing, approval, setup gates, or implementation decisions.

## Capsule-Based Execution

Bounded work is routed through explicit roadmap context or a capsule before files are changed. A capsule should define purpose, allowed files, forbidden actions, validation requirements, and review expectations.

For documentation/governance tasks, the capsule boundary is used to prevent drift into implementation, source generation, setup actions, broad archive creation, or unapproved historical reconstruction.

## Validation-First Workflow

The current discipline expects repository state to be verified before work starts. Typical checks include clean working tree status, branch alignment, recent commit context, active roadmap state, and relevant snapshot state.

Validation results must be reported as actual command results. Expected outputs must not be presented as if they were observed.

## A0/A6/A8 Review Discipline

A0_ORCH owns routing, mode coordination, and task classification. For bounded documentation/governance work, A0_ORCH identifies the active scope, chooses the responsible path, and keeps implementation work out of documentation-only tasks.

A6_REVIEW checks consistency, governance boundaries, architecture drift, role and subscription terminology, backend-owned progression rules, and conflicts with operational authority.

A8_OUTPUT_CHECKER checks completeness, readiness claims, modified file lists, validation evidence, and whether the output stays inside the approved scope.

## Human Approval Gates

Human approval remains required for higher-risk work, especially irreversible or external actions. The current setup-gate discipline separates review readiness from execution approval.

Review results, clean status, or agent-generated decisions do not authorize Flutter scaffold execution, Firebase setup, production service changes, deployment, source creation, or tests unless a human-approved task explicitly grants that scope.

## Commit and Push Discipline

The repository uses explicit commit and push discipline. Work should be reviewed before readiness claims, task-relevant files should be staged intentionally, and unrelated changes should remain untouched.

Push actions should be separately approved when required by the task. Commit messages should match the repository style and distinguish documentation, agents, diagrams, wireframes, implementation features, and fixes.

## Non-Operational Meta Boundary

`docs/meta/` is a reflective archive. Its content may explain workflow discipline, archive policy, schemas, or curated engineering learning, but it must not become operational authority.

This record does not create artifact inventory entries, timelines, repository Genesis material, autonomous archive systems, or approval evidence. It does not replace ADRs, setup gates, snapshots, roadmap routing, or active instructions.

## Pre-Scaffold Boundary

Runiac remains in a pre-scaffold governance state until separately approved work changes that state. This record does not authorize Flutter scaffold execution, Firebase initialization, dependency installation, builds, deploys, production source files, generated platform files, or production tests.

Any future scaffold or setup action must follow the active roadmap context, setup gates, ADRs, and explicit human approval.

## Backend-Owned Progression Boundary

The workflow discipline preserves the Runiac rule that official XP, streak, level, rank, leaderboard score, weekly XP, and monthly XP are backend-owned. Flutter may display trusted values, but the client must not directly calculate or write official progression or competitive ranking fields.

Cloud Functions and backend enforcement remain responsible for trusted progression and leaderboard updates when implementation is eventually authorized. Premium features must not create competitive scoring advantages.

## Use and Limits

Use this document only as a bounded process reference when a human explicitly asks for meta/archive or workflow context.

Do not use this document to infer current approval state, select implementation work, bypass roadmap routing, satisfy setup gates, or load archive material into ordinary operational planning.
