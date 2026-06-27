import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:runiac_app/core/firebase/runiac_firebase_bootstrap.dart';
import 'package:runiac_app/features/run/data/run_repository_factory.dart';

import 'support/auth_emulator_flow_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('email password auth uses Firebase emulator app path', (
    tester,
  ) async {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final email = 'runiac-auth-$timestamp@example.test';
    const password = 'RuniacPass123!';
    const wrongPassword = 'RuniacWrong123!';

    final bootstrap = await RuniacFirebaseBootstrap.initialize(
      config: RuniacFirebaseRuntimeConfig(
        useFirebaseEmulator: true,
        emulatorHost: firebaseEmulatorHost,
      ),
      enableAnonymousEmulatorSignIn: false,
    );
    final rawAuthDiagnostics = await probeRawFirebaseAuth(
      timestamp: timestamp,
      password: password,
    );
    final authRepository = DiagnosticAuthRepository(bootstrap.authRepository);
    addTearDown(authRepository.signOut);

    await authRepository.signOut();
    await pumpRuniac(tester, bootstrap, authRepository: authRepository);

    await signUp(tester, email: email, password: password);
    await waitForText(
      tester,
      'Welcome to Runiac',
      reason: 'signup should authenticate and open onboarding',
      diagnostics: '${authRepository.diagnostics}\n$rawAuthDiagnostics',
    );
    expect(find.text('Welcome to Runiac'), findsOneWidget);
    expect(find.text('Step 1 of 16'), findsOneWidget);
    expect(find.text('Good to see you'), findsNothing);

    await authRepository.signOut();
    await waitForText(
      tester,
      'Sign up',
      reason: 'repository sign-out should return to the auth welcome screen',
      diagnostics: authRepository.diagnostics,
    );
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    await logIn(tester, email: email, password: password);
    await waitForText(
      tester,
      'Good to see you',
      reason: 'login should authenticate and skip signup-only onboarding',
      diagnostics: authRepository.diagnostics,
    );
    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);

    await signOutFromAccount(tester);
    await waitForText(
      tester,
      'Sign up',
      reason: 'account sign-out should return to the auth welcome screen',
      diagnostics: authRepository.diagnostics,
    );
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Good to see you'), findsNothing);

    await requestPasswordReset(tester, email: email);
    await waitForText(
      tester,
      'If an account exists for that email, a reset link will be sent.',
      reason: 'password reset should surface the success confirmation',
      diagnostics: authRepository.diagnostics,
    );
    expect(
      find.text(
        'If an account exists for that email, a reset link will be sent.',
      ),
      findsOneWidget,
    );

    await tapVisibleText(tester, 'Back to log in');
    await attemptWrongPassword(
      tester,
      email: email,
      wrongPassword: wrongPassword,
    );
    await waitForText(
      tester,
      'That email and password do not match.',
      reason: 'wrong-password login should surface mapped auth error text',
      diagnostics: authRepository.diagnostics,
    );
    expect(find.text('That email and password do not match.'), findsOneWidget);
    expect(find.text('Good to see you'), findsNothing);
  });
}
