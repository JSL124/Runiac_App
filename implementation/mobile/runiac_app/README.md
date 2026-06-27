# Runiac Flutter app

## Auth and run-completion Firebase emulator boundary

The mobile app keeps non-production/static fallbacks as the default. FlutterFire
wiring is enabled only when the app is launched with:

```bash
flutter run \
  --dart-define=RUNIAC_FIREBASE_EMULATOR=true \
  --dart-define=RUNIAC_FIREBASE_EMULATOR_HOST=127.0.0.1
```

Use `RUNIAC_FIREBASE_EMULATOR_HOST=10.0.2.2` for an Android emulator that needs
to reach services running on the host machine. Local iOS Simulator and desktop
runs can use `127.0.0.1`.

Expected local emulator ports:

- Auth: `127.0.0.1:9099`
- Functions: `127.0.0.1:5001`
- Firestore: `127.0.0.1:8080`

The emulator project ID is `runiac-functions-test`. The Flutter app uses
non-secret demo `FirebaseOptions` only for emulator initialization. In emulator
mode, email/password signup, login, password reset, auth-state persistence, and
sign-out use Firebase Auth emulator wiring; run completion can use the local
Functions/Firestore emulator path. Google/OAuth remains disabled and must not
fake authentication.

When `RUNIAC_FIREBASE_EMULATOR` is missing or false, the app uses the static
run repository, a non-production auth repository, and does not initialize
Firebase. Do not run `flutterfire configure`, do not add `firebase_options.dart`,
do not add native Firebase config files, and do not deploy from this app.

## M4-C2 Mapbox run map demo boundary

The run map uses the local placeholder unless the app is launched with a
demo-only Mapbox public access token:

```bash
flutter run --dart-define=MAPBOX_PUBLIC_ACCESS_TOKEN=<demo-public-token>
```

Do not commit real `pk.` tokens, `sk.` tokens, `.env` token files, native
Mapbox token resources, or Mapbox download-token environment variables.

When the token is present, Mapbox map rendering may make network requests to
Mapbox for styles, tiles, and SDK resources. The Mapbox Maps SDK may also send
de-identified or unidentified location and usage telemetry according to Mapbox
SDK documentation and package notices. Runiac M4-C2 does not upload raw route
traces, GPS samples, positions, route polylines, or route traces to the Runiac
or Firebase backend; `completeRun` remains summary-only.

Mapbox logo and attribution controls must remain visible and clickable because
they provide Mapbox attribution and access to SDK telemetry controls. The
token-backed Mapbox demo remains not ready until a demo token is provided and
Android/iOS runtime QA confirms map rendering, route drawing, camera recenter,
and attribution visibility.
