import 'package:flutter/material.dart';

import '../../account/data/firestore_user_profile_repository.dart';
import '../../account/domain/models/user_profile_read_model.dart';
import '../../account/domain/repositories/user_profile_repository.dart';
import '../../splash/presentation/splash_three_soft_dots_screen.dart';
import '../domain/runiac_auth_service.dart';

class RuniacProfileSetupGate extends StatefulWidget {
  const RuniacProfileSetupGate({
    required this.authRepository,
    required this.profileRepository,
    required this.currentUser,
    required this.child,
    this.onLoadedProfile,
    this.onRecoverableProfileMissing,
    super.key,
  });

  final RuniacAuthRepository authRepository;
  final UserProfileRepository profileRepository;
  final RuniacAuthUser currentUser;
  final Widget child;
  final ValueChanged<UserProfileReadModel>? onLoadedProfile;
  final VoidCallback? onRecoverableProfileMissing;

  @override
  State<RuniacProfileSetupGate> createState() => _RuniacProfileSetupGateState();
}

class _RuniacProfileSetupGateState extends State<RuniacProfileSetupGate> {
  Future<bool>? _profileSetupProbeFuture;
  String? _profileSetupProbeUid;

  @override
  void didUpdateWidget(covariant RuniacProfileSetupGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authRepository != widget.authRepository ||
        oldWidget.profileRepository != widget.profileRepository ||
        oldWidget.currentUser.uid != widget.currentUser.uid) {
      _profileSetupProbeUid = null;
      _profileSetupProbeFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _profileSetupProbeFor(widget.currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _ProfileSetupProbeLoadingScreen();
        }

        if (snapshot.hasError) {
          return _ProfileSetupProbeErrorScreen(
            message: _isRecoverableProfileSetupError(snapshot.error)
                ? 'We could not load your profile setup. Please sign in again.'
                : 'We could not check your profile setup. Please try again.',
          );
        }

        if (snapshot.data == false) {
          return const _ProfileSetupProbeLoadingScreen();
        }

        return widget.child;
      },
    );
  }

  Future<bool> _profileSetupProbeFor(String uid) {
    if (_profileSetupProbeUid != uid || _profileSetupProbeFuture == null) {
      _profileSetupProbeUid = uid;
      _profileSetupProbeFuture = _validateSignedInProfileSetup(uid);
    }
    return _profileSetupProbeFuture!;
  }

  Future<bool> _validateSignedInProfileSetup(String probedUid) async {
    final authRepository = widget.authRepository;
    final profileRepository = widget.profileRepository;
    try {
      final profile = await profileRepository.loadUserProfile();
      widget.onLoadedProfile?.call(profile);
      return true;
    } catch (error) {
      if (!_isRecoverableProfileSetupError(error)) {
        rethrow;
      }
      if (authRepository.currentUser?.uid == probedUid) {
        widget.onRecoverableProfileMissing?.call();
        await authRepository.signOut();
        return false;
      }
      return true;
    }
  }

  bool _isRecoverableProfileSetupError(Object? error) {
    return error is CurrentUserProfileException &&
        (error.reason == CurrentUserProfileFailureReason.missing ||
            error.reason == CurrentUserProfileFailureReason.invalid);
  }
}

class _ProfileSetupProbeErrorScreen extends StatelessWidget {
  const _ProfileSetupProbeErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _ProfileSetupProbeLoadingScreen extends StatelessWidget {
  const _ProfileSetupProbeLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const SplashThreeSoftDotsScreen();
  }
}
