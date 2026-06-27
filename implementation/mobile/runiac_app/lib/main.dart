import 'package:flutter/material.dart';

import 'app.dart';
import 'core/firebase/runiac_firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrap = await RuniacFirebaseBootstrap.initialize();

  runApp(
    RuniacApp(
      runRepository: bootstrap.runRepository,
      showAuth: true,
      showOnboarding: true,
    ),
  );
}
