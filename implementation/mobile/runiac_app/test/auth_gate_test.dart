import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/auth/presentation/runiac_auth_gate.dart';

import 'support/auth_flow_test_helpers.dart';
import 'support/fake_runiac_auth_repository.dart';

void main() {
  testWidgets('showAuth false immediately renders child without auth stream', (
    tester,
  ) async {
    final repository = FakeRuniacAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RuniacAuthGate(
          authRepository: repository,
          showAuth: false,
          child: const Text('Protected app shell'),
        ),
      ),
    );

    expect(find.text('Protected app shell'), findsOneWidget);
    expect(repository.authStateListenCount, 0);
  });

  testWidgets(
    'loading state appears while waiting for first repository auth state',
    (tester) async {
      final repository = FakeRuniacAuthRepository();
      addTearDown(repository.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: RuniacAuthGate(
            authRepository: repository,
            showAuth: true,
            child: const Text('Protected app shell'),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('auth_gate_loading')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Protected app shell'), findsNothing);
    },
  );

  testWidgets('showAuth true reuses auth stream across parent rebuilds', (
    tester,
  ) async {
    final repository = FakeRuniacAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RuniacAuthGate(
          authRepository: repository,
          showAuth: true,
          child: const Text('Protected app shell A'),
        ),
      ),
    );

    expect(repository.authStateListenCount, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: RuniacAuthGate(
          authRepository: repository,
          showAuth: true,
          child: const Text('Protected app shell B'),
        ),
      ),
    );

    expect(repository.authStateListenCount, 1);

    repository.emitSignedIn();
    await tester.pumpAndSettle();

    expect(find.text('Protected app shell B'), findsOneWidget);
    expect(find.text('Protected app shell A'), findsNothing);
  });

  testWidgets('signed-out repository state shows auth flow', (tester) async {
    final repository = FakeRuniacAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RuniacAuthGate(
          authRepository: repository,
          showAuth: true,
          child: const Text('Protected app shell'),
        ),
      ),
    );

    repository.emitSignedOut();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('auth_welcome_runiac_logo')),
      findsOneWidget,
    );
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Protected app shell'), findsNothing);
  });

  testWidgets('signed-in repository user reaches app shell after restart', (
    tester,
  ) async {
    final repository = FakeRuniacAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showAuth: true,
        showOnboarding: true,
        enableForegroundGps: false,
        authRepository: repository,
      ),
    );

    repository.emitSignedIn();
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Welcome to Runiac'), findsNothing);
    expect(find.text('Step 1 of 16'), findsNothing);
  });

  testWidgets(
    'login form signs in through repository and opens after auth stream',
    (tester) async {
      final repository = FakeRuniacAuthRepository();
      addTearDown(repository.dispose);
      RuniacAuthCompletion? completion;

      await tester.pumpWidget(
        MaterialApp(
          home: RuniacAuthGate(
            authRepository: repository,
            showAuth: true,
            onAuthenticated: (value) {
              completion = value;
            },
            child: const Text('Protected app shell'),
          ),
        ),
      );

      repository.emitSignedOut();
      await tester.pump();
      await tapVisibleText(tester, 'Log in');
      await enterAuthCredentials(
        tester,
        email: 'runner@runiac.app',
        password: 'password123',
      );
      await tapVisibleText(tester, 'Sign in');

      expect(completion, RuniacAuthCompletion.login);
      await tester.pumpAndSettle();

      expect(repository.signInCalls, 1);
      expect(find.text('Protected app shell'), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);
    },
  );

  testWidgets('signed-out after signed-in returns to auth flow', (
    tester,
  ) async {
    final repository = FakeRuniacAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RuniacAuthGate(
          authRepository: repository,
          showAuth: true,
          child: const Text('Protected app shell'),
        ),
      ),
    );

    repository.emitSignedIn();
    await tester.pumpAndSettle();
    expect(find.text('Protected app shell'), findsOneWidget);

    repository.emitSignedOut();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('auth_welcome_runiac_logo')),
      findsOneWidget,
    );
    expect(find.text('Protected app shell'), findsNothing);
  });

  testWidgets('sign out returns to auth flow and allows login again', (
    tester,
  ) async {
    final repository = FakeRuniacAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showAuth: true,
        showOnboarding: true,
        enableForegroundGps: false,
        authRepository: repository,
      ),
    );

    repository.emitSignedIn();
    await tester.pumpAndSettle();

    expect(find.text('Good to see you'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Return to the Runiac welcome screen'), findsOneWidget);

    await tester.ensureVisible(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(
      find.byKey(const ValueKey('auth_welcome_runiac_logo')),
      findsOneWidget,
    );
    expect(find.text('Account'), findsNothing);

    await tapVisibleText(tester, 'Log in');
    await enterAuthCredentials(
      tester,
      email: 'runner@runiac.app',
      password: 'password123',
    );
    await tapVisibleText(tester, 'Sign in');

    expect(repository.signInCalls, 1);
    expect(find.text('Good to see you'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('sign out prevents double submit while pending', (tester) async {
    final repository = FakeRuniacAuthRepository();
    addTearDown(repository.dispose);
    repository.holdNextSignOut();

    await tester.pumpWidget(
      RuniacApp(
        showSplash: false,
        showAuth: true,
        enableForegroundGps: false,
        authRepository: repository,
      ),
    );

    repository.emitSignedIn();
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out'));
    await tester.pump();
    await tester.tap(find.text('Signing out...'));
    await tester.pump();

    expect(repository.signOutCalls, 1);

    repository.completePendingSignOut();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('auth_welcome_runiac_logo')),
      findsOneWidget,
    );
  });
}
