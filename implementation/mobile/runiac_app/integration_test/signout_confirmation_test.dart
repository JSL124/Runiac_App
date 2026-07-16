import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:runiac_app/app.dart';

import '../test/support/fake_runiac_auth_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('account sign out requires confirmation before signing out', (
    tester,
  ) async {
    const pauseForScreenshot = bool.fromEnvironment(
      'RUNIAC_QA_PAUSE_FOR_SCREENSHOT',
    );
    final repository = FakeRuniacAuthRepository();
    addTearDown(repository.dispose);

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

    expect(find.text('Profile'), findsOneWidget);
    await tester.ensureVisible(find.text('Sign out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 0);
    expect(find.text('Sign out?'), findsOneWidget);
    expect(
      find.text('You can sign back in with your email any time.'),
      findsOneWidget,
    );
    expect(find.text('Stay signed in'), findsOneWidget);

    final staySignedIn = find.text('Stay signed in');
    await tester.ensureVisible(staySignedIn);
    await tester.pumpAndSettle();

    if (pauseForScreenshot) {
      // Marker used by QA automation before taking an external simulator shot.
      // ignore: avoid_print
      print('RUNIAC_QA_READY_CONFIRMATION');
      await Future<void>.delayed(const Duration(seconds: 45));
      await tester.pump();
    }

    await tester.tap(staySignedIn);
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 0);
    expect(find.text('Sign out?'), findsNothing);
    expect(find.text('Profile'), findsOneWidget);

    repository.holdNextSignOut();

    await tester.ensureVisible(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 0);
    expect(find.text('Sign out?'), findsOneWidget);

    final confirmSignOut = find.text('Sign out').last;
    await tester.ensureVisible(confirmSignOut);
    await tester.pumpAndSettle();
    await tester.tap(confirmSignOut);
    await tester.pump();

    expect(repository.signOutCalls, 1);
    final signingOutCta = find.descendant(
      of: find.byKey(const ValueKey('account_sign_out_confirmation')),
      matching: find.text('Signing out...'),
    );
    expect(signingOutCta, findsAtLeastNWidgets(1));

    await tester.tap(signingOutCta.last);
    await tester.pump();

    expect(repository.signOutCalls, 1);

    repository.completePendingSignOut();
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Profile'), findsNothing);
  });
}
