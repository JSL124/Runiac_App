import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/core/firebase/runiac_firebase_bootstrap.dart';
import 'package:runiac_app/features/auth/data/non_production_auth_repository.dart';
import 'package:runiac_app/features/auth/domain/runiac_auth_service.dart';
import 'package:runiac_app/features/run/data/run_repository_factory.dart';
import 'package:runiac_app/features/run/data/static_run_repository.dart';

void main() {
  group('Runiac auth service', () {
    test('maps FirebaseAuthException codes to beginner-friendly errors', () {
      const cases = <_FirebaseAuthErrorCase>[
        _FirebaseAuthErrorCase(
          firebaseCode: 'weak-password',
          appCode: RuniacAuthErrorCode.weakPassword,
          message: 'Use a stronger password with at least 8 characters.',
        ),
        _FirebaseAuthErrorCase(
          firebaseCode: 'email-already-in-use',
          appCode: RuniacAuthErrorCode.emailAlreadyInUse,
          message: 'An account already exists for this email. Try logging in.',
        ),
        _FirebaseAuthErrorCase(
          firebaseCode: 'user-not-found',
          appCode: RuniacAuthErrorCode.userNotFound,
          message: 'No Runiac account was found for this email.',
        ),
        _FirebaseAuthErrorCase(
          firebaseCode: 'wrong-password',
          appCode: RuniacAuthErrorCode.wrongPassword,
          message: 'That email and password do not match.',
        ),
        _FirebaseAuthErrorCase(
          firebaseCode: 'invalid-credential',
          appCode: RuniacAuthErrorCode.invalidCredential,
          message: 'That email and password do not match.',
        ),
        _FirebaseAuthErrorCase(
          firebaseCode: 'not-a-real-code',
          appCode: RuniacAuthErrorCode.unknown,
          message: 'We could not complete that auth step. Please try again.',
        ),
      ];

      for (final testCase in cases) {
        final error = RuniacAuthException.fromFirebaseCode(
          testCase.firebaseCode,
        );

        expect(error.code, testCase.appCode, reason: testCase.firebaseCode);
        expect(
          error.userMessage,
          testCase.message,
          reason: testCase.firebaseCode,
        );
        expect(error.firebaseCode, testCase.firebaseCode);
      }
    });

    test(
      'non-production auth fallback stays signed out and unavailable',
      () async {
        const repository = NonProductionAuthRepository();
        final observed = <RuniacAuthUser?>[];
        final subscription = repository.authStateChanges().listen(observed.add);
        addTearDown(subscription.cancel);

        await pumpEventQueue();

        expect(repository.currentUser, isNull);
        expect(observed, <RuniacAuthUser?>[null]);

        await expectLater(
          repository.createUserWithEmailAndPassword(
            email: 'runner@runiac.app',
            password: 'password123',
          ),
          throwsA(
            isA<RuniacAuthException>().having(
              (error) => error.code,
              'code',
              RuniacAuthErrorCode.authUnavailable,
            ),
          ),
        );
        await expectLater(
          repository.signInWithEmailAndPassword(
            email: 'runner@runiac.app',
            password: 'password123',
          ),
          throwsA(
            isA<RuniacAuthException>().having(
              (error) => error.userMessage,
              'message',
              'Runiac sign-in is only available in the local Firebase emulator right now.',
            ),
          ),
        );
        await expectLater(
          repository.sendPasswordResetEmail(email: 'runner@runiac.app'),
          throwsA(isA<RuniacAuthException>()),
        );
        await expectLater(
          repository.signOut(),
          throwsA(isA<RuniacAuthException>()),
        );
        expect(repository.currentUser, isNull);
      },
    );

    test(
      'bootstrap returns signed-out auth fallback outside emulator',
      () async {
        final bootstrap = await RuniacFirebaseBootstrap.initialize(
          config: const RuniacFirebaseRuntimeConfig(useFirebaseEmulator: false),
        );

        expect(bootstrap.runRepository, isA<StaticRunRepository>());
        expect(bootstrap.authRepository, isA<NonProductionAuthRepository>());
        expect(bootstrap.authRepository.currentUser, isNull);
      },
    );
  });
}

class _FirebaseAuthErrorCase {
  const _FirebaseAuthErrorCase({
    required this.firebaseCode,
    required this.appCode,
    required this.message,
  });

  final String firebaseCode;
  final RuniacAuthErrorCode appCode;
  final String message;
}
