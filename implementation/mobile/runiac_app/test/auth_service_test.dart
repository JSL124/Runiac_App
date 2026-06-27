import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/core/firebase/runiac_firebase_bootstrap.dart';
import 'package:runiac_app/features/auth/data/non_production_auth_repository.dart';
import 'package:runiac_app/features/auth/domain/runiac_auth_service.dart';
import 'package:runiac_app/features/run/data/run_repository_factory.dart';
import 'package:runiac_app/features/run/data/static_run_repository.dart';

import 'support/in_memory_runiac_auth_repository.dart';

void main() {
  group('RuniacAuthRepository seam', () {
    test(
      'in-memory fake contract creates, signs out, and signs in a user',
      () async {
        final repository = InMemoryRuniacAuthRepository();

        final created = await repository.createUserWithEmailAndPassword(
          email: 'new.runner@runiac.app',
          password: 'password123',
        );

        expect(created.uid, isNotEmpty);
        expect(created.email, 'new.runner@runiac.app');
        expect(repository.currentUser, created);

        await repository.signOut();
        expect(repository.currentUser, isNull);

        final signedIn = await repository.signInWithEmailAndPassword(
          email: 'new.runner@runiac.app',
          password: 'password123',
        );

        expect(signedIn, created);
        expect(repository.currentUser, created);
      },
    );

    test('auth state stream follows current user and sign-out', () async {
      final repository = InMemoryRuniacAuthRepository();
      final observed = <RuniacAuthUser?>[];
      final subscription = repository.authStateChanges().listen(observed.add);
      addTearDown(subscription.cancel);

      await repository.createUserWithEmailAndPassword(
        email: 'stream.runner@runiac.app',
        password: 'password123',
      );
      await repository.signOut();

      await pumpEventQueue();

      expect(observed, <RuniacAuthUser?>[
        null,
        const RuniacAuthUser(
          uid: 'fake-uid-1',
          email: 'stream.runner@runiac.app',
        ),
        null,
      ]);
    });

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
      'fake repository enforces weak-password and duplicate email errors',
      () async {
        final repository = InMemoryRuniacAuthRepository();

        await expectLater(
          repository.createUserWithEmailAndPassword(
            email: 'weak.runner@runiac.app',
            password: 'short',
          ),
          throwsA(
            isA<RuniacAuthException>().having(
              (error) => error.code,
              'code',
              RuniacAuthErrorCode.weakPassword,
            ),
          ),
        );

        await repository.createUserWithEmailAndPassword(
          email: 'taken.runner@runiac.app',
          password: 'password123',
        );
        await repository.signOut();

        await expectLater(
          repository.createUserWithEmailAndPassword(
            email: 'taken.runner@runiac.app',
            password: 'another-password',
          ),
          throwsA(
            isA<RuniacAuthException>().having(
              (error) => error.code,
              'code',
              RuniacAuthErrorCode.emailAlreadyInUse,
            ),
          ),
        );
      },
    );

    test(
      'fake repository enforces user-not-found and invalid-credential',
      () async {
        final repository = InMemoryRuniacAuthRepository();

        await expectLater(
          repository.signInWithEmailAndPassword(
            email: 'missing.runner@runiac.app',
            password: 'password123',
          ),
          throwsA(
            isA<RuniacAuthException>().having(
              (error) => error.code,
              'code',
              RuniacAuthErrorCode.userNotFound,
            ),
          ),
        );

        await repository.createUserWithEmailAndPassword(
          email: 'existing.runner@runiac.app',
          password: 'password123',
        );
        await repository.signOut();

        await expectLater(
          repository.signInWithEmailAndPassword(
            email: 'existing.runner@runiac.app',
            password: 'wrong-password',
          ),
          throwsA(
            isA<RuniacAuthException>().having(
              (error) => error.code,
              'code',
              RuniacAuthErrorCode.invalidCredential,
            ),
          ),
        );
      },
    );

    test('reset sent records recipient without signing the user in', () async {
      final repository = InMemoryRuniacAuthRepository();

      await repository.sendPasswordResetEmail(email: 'reset.runner@runiac.app');

      expect(repository.sentPasswordResetEmails, ['reset.runner@runiac.app']);
      expect(repository.currentUser, isNull);
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
