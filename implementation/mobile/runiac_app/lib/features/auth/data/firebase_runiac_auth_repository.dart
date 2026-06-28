import 'package:firebase_auth/firebase_auth.dart';

import '../domain/runiac_auth_service.dart';

class FirebaseRuniacAuthRepository implements RuniacAuthRepository {
  const FirebaseRuniacAuthRepository({required this.firebaseAuth});

  final FirebaseAuth firebaseAuth;

  @override
  Stream<RuniacAuthUser?> authStateChanges() {
    return firebaseAuth.authStateChanges().map(_mapUser);
  }

  @override
  RuniacAuthUser? get currentUser => _mapUser(firebaseAuth.currentUser);

  @override
  Future<RuniacAuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _runAuthOperation(
      () => firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw RuniacAuthException.fromFirebaseCode(error.code);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const RuniacAuthException(
        code: RuniacAuthErrorCode.userNotFound,
        userMessage: 'Please sign in again before verifying your email.',
      );
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw RuniacAuthException.fromFirebaseCode(error.code);
    }
  }

  @override
  Future<RuniacAuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _runAuthOperation(
      () => firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (error) {
      throw RuniacAuthException.fromFirebaseCode(error.code);
    }
  }

  Future<RuniacAuthUser> _runAuthOperation(
    Future<UserCredential> Function() operation,
  ) async {
    try {
      return _mapCredential(await operation());
    } on FirebaseAuthException catch (error) {
      throw RuniacAuthException.fromFirebaseCode(error.code);
    }
  }

  RuniacAuthUser _mapCredential(UserCredential credential) {
    final user = credential.user;
    if (user == null) {
      throw const RuniacAuthException(
        code: RuniacAuthErrorCode.unknown,
        userMessage: 'We could not complete that auth step. Please try again.',
      );
    }
    return _mapUser(user)!;
  }

  RuniacAuthUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    return RuniacAuthUser(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
    );
  }
}
