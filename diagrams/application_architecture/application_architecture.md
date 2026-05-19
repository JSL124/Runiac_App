# Application Architecture Diagram

> Diagram category: PDD / System Architecture Design / Application Architecture Diagram

## Purpose

This diagram explains how the Runiac mobile application is organized internally and how the application modules interact with Firebase backend services and external services.

Unlike the physical architecture diagram, this diagram focuses on application responsibility boundaries:

| Layer | Meaning |
| --- | --- |
| User Layer | Basic User, Premium User, and Platform Administrator roles. |
| Flutter Mobile Application | Presentation modules, application managers, and device service adapters inside the mobile app. |
| Firebase Backend / BaaS | Authentication, Firestore, Cloud Functions processing, and Firebase Cloud Messaging. |
| External Services | Maps, geocoding, social sharing, and AI/LLM summary generation. |

## Main Architecture Flows

- Authentication and onboarding use Firebase Authentication and Cloud Firestore to store account, goal, fitness, and health-profile data.
- Run Tracking uses smartphone GPS and optional wearable data through device adapters, then stores the completed run in the local run buffer before upload.
- Cloud Functions validates uploaded activities, derives metrics, updates XP, streak, and level, adjusts plan data, and triggers leaderboard updates.
- Training Plan modules read and write plan data through Firestore and Cloud Functions.
- Reminder checks run in Cloud Functions and deliver push notifications through Firebase Cloud Messaging.
- Route Sharing uses maps, region mapping, privacy masking, Firestore route storage, and route moderation.
- Territorial Leaderboard uses XP, level division, geocoded region data, and aggregated leaderboard records.
- Premium post-run summaries use Cloud Functions to prepare activity context, call the external AI/LLM service, and store generated summary text in Firestore.
- Sharing flows generate in-app share cards and send them to external social platforms through the OS share sheet.

## Current Diagram Source

- Mermaid source: `application_architecture.mmd`
- Draw.io screenshot reference: `application_architecture_drawio_screenshot_2026-05-20_0013.png`
- Screenshot interpretation notes: `application_architecture_drawio_notes.md`

## PDD Notes

- Keep this diagram focused on modules and data/control flow.
- Do not list every wireframe screen here; group screens into feature modules.
- Use the UI wireframe catalogue section for screen-level detail.
- If MVP and Phase 2 separation is required in the final visual export, mark Route Sharing, Territorial Leaderboard, Social Sharing, and AI Summary as Phase 2 modules.
