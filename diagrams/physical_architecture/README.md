# Physical Architecture Diagram

> Diagram category: PDD / System Architecture Design / Physical Architecture Diagram
> Current source status: screenshot and reconstructed Mermaid source saved on 2026-05-20.

## Purpose

This diagram explains the physical/runtime architecture of the real Runiac app. It focuses on where each part of the system runs and which external services are involved.

The diagram is intentionally organized into three major zones:

| Zone | Meaning |
| --- | --- |
| Frontend | User device, mobile sensors, optional wearable, and Runiac Flutter mobile app. |
| Firebase Backend / BaaS | Firebase services used by Runiac: Authentication, Cloud Functions, Cloud Firestore, and Cloud Messaging. |
| External Services | Non-Firebase services used by the app: AI/LLM, OS share sheet/social media, geocoding/region mapping, and maps API. |

## Architecture Understanding

The Basic/Premium user uses Runiac on an iOS or Android mobile device. The mobile device provides GPS/location data, while an optional wearable device can provide heart-rate or other supported activity metrics. These data sources feed the Runiac Flutter mobile application.

The Flutter app communicates with Firebase Authentication for login/session handling, Cloud Firestore for app data reads and writes, and Cloud Functions for backend processing after run activity upload.

Cloud Functions is responsible for server-side processing:

- validating completed running activity;
- calculating XP, streak, and level;
- storing leaderboard ranking updates;
- storing post-run summaries;
- preparing reminders;
- mapping route coordinates to regions;
- requesting Premium post-run summary generation from the external AI/LLM service.

Firebase Cloud Messaging sends run/rest reminder push notifications back to the mobile device.

External services are used as follows:

- `AI / LLM Service`: generates Premium post-run summary text through Cloud Functions.
- `OS Share Sheet / Social Media`: used by the Flutter app to share run summaries and rank cards.
- `Geocoding / Region Mapping`: maps route coordinates to leaderboard regions.
- `Google Maps / Mapbox API`: provides map tiles and route display support.

## Current Diagram Source

- Current screenshot: `physical_architecture_current.png`
- Mermaid source: `physical_architecture.mmd`

## Notes For Final PDD Export

- If exporting from draw.io/Figma, use `physical_architecture_current.png` as the current visual reference and keep the three-zone layout.
- Keep `Cloud Functions` as the only backend component that talks directly to `AI / LLM Service` and `Geocoding / Region Mapping`.
- Do not connect `AI / LLM Service` directly to `Cloud Firestore`.
- Use `Cloud Functions -> Cloud Firestore` for storing validated activities, XP/streak/level, leaderboard rankings, and post-run summaries.
- Use `Firebase Cloud Messaging -> iOS / Android Mobile Device` for push reminders.
- Use `Runiac Flutter Mobile Application -> Google Maps / Mapbox API` for map tiles and route display.
- Use `Runiac Flutter Mobile Application -> OS Share Sheet / Social Media` for sharing run/rank cards.
