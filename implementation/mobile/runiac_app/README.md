# Runiac Flutter app

## M5 FlutterFire emulator-only run completion

The mobile app keeps `StaticRunRepository` as the default. FlutterFire wiring is
enabled only when the app is launched with:

```bash
flutter run \
  --dart-define=RUNIAC_FIREBASE_EMULATOR=true \
  --dart-define=RUNIAC_FIREBASE_EMULATOR_HOST=127.0.0.1
```

Use `RUNIAC_FIREBASE_EMULATOR_HOST=10.0.2.2` for an Android emulator that needs
to reach services running on the host machine.

Expected local emulator ports:

- Auth: `127.0.0.1:9099`
- Functions: `127.0.0.1:5001`
- Firestore: `127.0.0.1:8080`

The emulator project ID is `runiac-functions-test`. The Flutter app uses
non-secret demo `FirebaseOptions` only for emulator initialization. Do not run
`flutterfire configure`, do not add `firebase_options.dart`, do not add native
Firebase config files, and do not deploy from this app.

When `RUNIAC_FIREBASE_EMULATOR` is missing or false, the app uses the static
repository and does not initialize Firebase.
