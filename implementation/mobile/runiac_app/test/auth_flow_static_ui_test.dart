import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/auth/presentation/runiac_auth_flow_screen.dart';

void main() {
  testWidgets('auth renders before onboarding when enabled', (tester) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showAuth: true,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    expect(
      find.byKey(const ValueKey('auth_welcome_runiac_logo')),
      findsOneWidget,
    );
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Welcome to Runiac'), findsNothing);
    expect(find.text('Good to see you'), findsNothing);
  });

  testWidgets('auth welcome routes to login, password recovery, and signup', (
    tester,
  ) async {
    var authenticated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RuniacAuthFlowScreen(
          onAuthenticated: (_) {
            authenticated = true;
          },
        ),
      ),
    );

    await tapVisibleText(tester, 'Log in');

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Email or username'), findsNothing);
    expect(find.text('alex.morgan'), findsNothing);
    expect(find.text('password'), findsNothing);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Forgot email or username?'), findsNothing);

    await tapVisibleText(tester, 'Forgot password?');
    expect(find.text('Reset your password'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);

    await tapVisibleText(tester, 'Back to log in');
    await tapVisibleText(tester, 'Sign up');
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('First name'), findsNothing);
    expect(find.text('Alex'), findsNothing);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    await enterAuthCredentials(
      tester,
      email: 'new.runner@runiac.app',
      password: 'password123',
    );
    await tapVisibleText(tester, 'Create account');
    expect(authenticated, isTrue);
  });

  testWidgets('login validates email and password before completion', (
    tester,
  ) async {
    var authenticated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RuniacAuthFlowScreen(
          onAuthenticated: (_) {
            authenticated = true;
          },
        ),
      ),
    );

    await tapVisibleText(tester, 'Log in');
    await tapVisibleText(tester, 'Sign in');

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(authenticated, isFalse);

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tapVisibleText(tester, 'Sign in');

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(authenticated, isFalse);

    await enterAuthCredentials(
      tester,
      email: 'runner@runiac.app',
      password: 'password123',
    );
    await tapVisibleText(tester, 'Sign in');

    expect(authenticated, isTrue);
  });

  testWidgets(
    'signup validates email and stronger password before onboarding',
    (tester) async {
      var authenticated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RuniacAuthFlowScreen(
            onAuthenticated: (_) {
              authenticated = true;
            },
          ),
        ),
      );

      await tapVisibleText(tester, 'Sign up');
      await enterAuthCredentials(
        tester,
        email: 'runner@runiac.app',
        password: 'short',
      );
      await tapVisibleText(tester, 'Create account');

      expect(find.text('Use at least 8 characters'), findsOneWidget);
      expect(authenticated, isFalse);

      await enterAuthCredentials(
        tester,
        email: 'runner@runiac.app',
        password: 'password123',
      );
      await tapVisibleText(tester, 'Create account');

      expect(authenticated, isTrue);
    },
  );

  testWidgets('password reset validates email before showing reset feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RuniacAuthFlowScreen(onAuthenticated: (_) {})),
    );

    await tapVisibleText(tester, 'Log in');
    await tapVisibleText(tester, 'Forgot password?');
    await tapVisibleText(tester, 'Send reset link');

    expect(find.text('Enter your email'), findsOneWidget);
    expect(
      find.text('Password reset will connect to Firebase Auth later.'),
      findsNothing,
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'runner@runiac.app',
    );
    await tapVisibleText(tester, 'Send reset link');

    expect(
      find.text('Password reset will connect to Firebase Auth later.'),
      findsOneWidget,
    );
  });

  testWidgets('login auth completion hands off to the app shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showAuth: true,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    await tapVisibleText(tester, 'Log in');
    await enterAuthCredentials(
      tester,
      email: 'runner@runiac.app',
      password: 'password123',
    );
    await tapVisibleText(tester, 'Sign in');

    expect(find.text('Welcome to Runiac'), findsNothing);
    expect(find.text('Step 1 of 16'), findsNothing);
    expect(find.text('Good to see you'), findsOneWidget);
  });

  testWidgets('signup auth completion hands off to onboarding', (tester) async {
    await tester.pumpWidget(
      const RuniacApp(
        showSplash: false,
        showAuth: true,
        showOnboarding: true,
        enableForegroundGps: false,
      ),
    );

    await tapVisibleText(tester, 'Sign up');
    await enterAuthCredentials(
      tester,
      email: 'runner@runiac.app',
      password: 'password123',
    );
    await tapVisibleText(tester, 'Create account');

    expect(find.text('Welcome to Runiac'), findsOneWidget);
    expect(find.text('Step 1 of 16'), findsOneWidget);
    expect(find.text('Good to see you'), findsNothing);
  });

  testWidgets('auth flow remains reachable on phone and tablet viewports', (
    tester,
  ) async {
    addTearDown(tester.view.reset);

    for (final size in [const Size(390, 844), const Size(768, 1024)]) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: RuniacAuthFlowScreen(
            key: ValueKey('auth_flow_${size.width}_${size.height}'),
            onAuthenticated: (_) {},
          ),
        ),
      );

      expect(find.text('Sign up'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      await tapVisibleText(tester, 'Log in');
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);

      await tapVisibleText(tester, 'Forgot password?');
      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Send reset link'), findsOneWidget);

      await tapVisibleText(tester, 'Back to log in');
      await tapVisibleText(tester, 'Sign up');
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    }
  });
}

Future<void> tapVisibleText(WidgetTester tester, String text) async {
  final finder = find.text(text).first;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterAuthCredentials(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
  await tester.pumpAndSettle();
}
