import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../../auth/domain/runiac_auth_service.dart';
import '../../onboarding/domain/models/local_onboarding_draft.dart';
import '../../onboarding/presentation/onboarding_flow_screen.dart';
import '../../plan/domain/services/beginner_adaptive_plan_generator.dart';
import '../../plan/presentation/current_session_generated_plan.dart';
import '../domain/models/user_profile_read_model.dart';
import '../domain/repositories/user_profile_persistence_repository.dart';
import 'widgets/profile_form_controls.dart';

class AccountEditProfileScreen extends StatefulWidget {
  const AccountEditProfileScreen({
    required this.authRepository,
    required this.persistenceRepository,
    required this.profile,
    required this.onBack,
    super.key,
  });

  final RuniacAuthRepository authRepository;
  final UserProfilePersistenceRepository persistenceRepository;
  final UserProfileReadModel profile;
  final VoidCallback onBack;

  @override
  State<AccountEditProfileScreen> createState() =>
      _AccountEditProfileScreenState();
}

class _AccountEditProfileScreenState extends State<AccountEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _weightController;
  late String _dateOfBirthIso;
  late String _region;
  bool _saving = false;
  bool _checkingNickname = false;
  bool? _nicknameAvailable = true;
  String? _nicknameStatusMessage;
  int _nicknameCheckGeneration = 0;
  Timer? _nicknameCheckTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile.fullName.isEmpty
          ? widget.profile.displayName
          : widget.profile.fullName,
    );
    _nicknameController = TextEditingController(
      text: widget.profile.nickname.isEmpty
          ? widget.profile.displayName
          : widget.profile.nickname,
    );
    _weightController = TextEditingController(
      text: widget.profile.weightKg?.toString() ?? '',
    );
    _dateOfBirthIso = widget.profile.dateOfBirthIso;
    _region = widget.profile.locationLabel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _weightController.dispose();
    _nicknameCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _checkingNickname) {
      setState(() {
        _error = 'Wait for the nickname check to finish.';
      });
      return;
    }
    if (_nicknameAvailable == false) {
      setState(() {
        _error = 'Choose an available nickname.';
      });
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final user = widget.authRepository.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Sign in again before saving your profile.';
      });
      return;
    }
    final draft = PersonalProfileDraft.tryCreate(
      fullName: _nameController.text,
      nickname: _nicknameController.text,
      dateOfBirthIso: _dateOfBirthIso,
      weightKg: _weightController.text,
      locationLabel: _region,
    );
    if (draft == null) {
      setState(() {
        _error = 'Choose your birthdate, weight, and Singapore region.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final available = await widget.persistenceRepository.isNicknameAvailable(
        uid: user.uid,
        nickname: draft.nickname,
      );
      if (!available) {
        setState(() {
          _nicknameAvailable = false;
          _nicknameStatusMessage = 'Nickname is already taken.';
          _error = 'Nickname is already taken.';
        });
        return;
      }
      setState(() {
        _nicknameAvailable = true;
        _nicknameStatusMessage = 'Nickname is available.';
      });
      await widget.persistenceRepository.savePersonalProfile(
        uid: user.uid,
        profile: draft.toPersonalSnapshot(),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on NicknameAvailabilityCheckException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _nicknameCheckErrorMessage(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'We could not save your profile. Try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _scheduleNicknameCheck(String value) {
    _nicknameCheckTimer?.cancel();
    final nickname = value.trim();
    final generation = ++_nicknameCheckGeneration;
    if (PersonalProfileDraft.validateNickname(nickname) != null) {
      setState(() {
        _checkingNickname = false;
        _nicknameAvailable = null;
        _nicknameStatusMessage = null;
      });
      return;
    }
    final user = widget.authRepository.currentUser;
    if (user == null) {
      setState(() {
        _checkingNickname = false;
        _nicknameAvailable = null;
        _nicknameStatusMessage = null;
      });
      return;
    }
    setState(() {
      _checkingNickname = true;
      _nicknameAvailable = null;
      _nicknameStatusMessage = 'Checking nickname...';
      if (_error == 'Nickname is already taken.' ||
          _error == 'Choose an available nickname.' ||
          _error ==
              'Nickname check is blocked by Firestore rules. Deploy the updated rules or use the emulator.' ||
          _error == 'We could not check that nickname. Try again.') {
        _error = null;
      }
    });
    _nicknameCheckTimer = Timer(const Duration(milliseconds: 350), () async {
      try {
        final available = await widget.persistenceRepository
            .isNicknameAvailable(uid: user.uid, nickname: nickname);
        if (!mounted || generation != _nicknameCheckGeneration) {
          return;
        }
        setState(() {
          _checkingNickname = false;
          _nicknameAvailable = available;
          _nicknameStatusMessage = available
              ? 'Nickname is available.'
              : 'Nickname is already taken.';
        });
      } on NicknameAvailabilityCheckException catch (error) {
        if (!mounted || generation != _nicknameCheckGeneration) {
          return;
        }
        setState(() {
          _checkingNickname = false;
          _nicknameAvailable = null;
          _nicknameStatusMessage = _nicknameCheckErrorMessage(error);
        });
      } catch (_) {
        if (!mounted || generation != _nicknameCheckGeneration) {
          return;
        }
        setState(() {
          _checkingNickname = false;
          _nicknameAvailable = null;
          _nicknameStatusMessage =
              'We could not check that nickname. Try again.';
        });
      }
    });
  }

  void _retakeOnboarding() {
    if (_checkingNickname) {
      setState(() {
        _error = 'Wait for the nickname check to finish.';
      });
      return;
    }
    if (_nicknameAvailable == false) {
      setState(() {
        _error = 'Choose an available nickname.';
      });
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final personalProfile = PersonalProfileDraft.tryCreate(
      fullName: _nameController.text,
      nickname: _nicknameController.text,
      dateOfBirthIso: _dateOfBirthIso,
      weightKg: _weightController.text,
      locationLabel: _region,
    );
    if (personalProfile == null) {
      setState(() {
        _error = 'Choose your birthdate, weight, and Singapore region.';
      });
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _RetakeOnboardingScreen(
          authRepository: widget.authRepository,
          persistenceRepository: widget.persistenceRepository,
          personalProfile: personalProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email =
        widget.authRepository.currentUser?.email ?? 'Email unavailable';

    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Edit profile',
              tooltip: 'Back to Account',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Section(
                        title: 'Personal details',
                        children: [
                          _ReadOnlyValue(label: 'Email', value: email),
                          _ProfileField(
                            label: 'Name',
                            controller: _nameController,
                            validator: PersonalProfileDraft.validateFullName,
                          ),
                          _ProfileField(
                            label: 'Nickname',
                            controller: _nicknameController,
                            validator: PersonalProfileDraft.validateNickname,
                            onChanged: _scheduleNicknameCheck,
                          ),
                          if (_nicknameStatusMessage != null)
                            _NicknameStatusText(
                              message: _nicknameStatusMessage!,
                              available: _nicknameAvailable,
                            ),
                          ProfileDateOfBirthField(
                            value: _dateOfBirthIso,
                            onChanged: (value) {
                              setState(() {
                                _dateOfBirthIso = value;
                              });
                            },
                          ),
                          ProfileAgeReadOnlyField(
                            dateOfBirthIso: _dateOfBirthIso,
                          ),
                          _ProfileField(
                            label: 'Weight in kilograms',
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () =>
                                FocusScope.of(context).unfocus(),
                            suffixIcon: IconButton(
                              tooltip: 'Hide keyboard',
                              onPressed: () => FocusScope.of(context).unfocus(),
                              icon: const Icon(Icons.keyboard_hide),
                            ),
                            validator: PersonalProfileDraft.validateWeight,
                          ),
                          SingaporeRegionPickerField(
                            value: _region,
                            onChanged: (value) {
                              setState(() {
                                _region = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        title: 'Onboarding result',
                        children: [
                          for (final item in widget.profile.setupItems)
                            _ReadOnlyValue(
                              label: item.title,
                              value: item.value,
                            ),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: _retakeOnboarding,
                              style: RuniacButtonStyles.secondary(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Retake onboarding'),
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: RuniacColors.accentOrange,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed:
                              _saving ||
                                  _checkingNickname ||
                                  _nicknameAvailable == false
                              ? null
                              : _save,
                          style: RuniacButtonStyles.primary(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(_saving ? 'Saving...' : 'Save changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _nicknameCheckErrorMessage(NicknameAvailabilityCheckException error) {
  return switch (error.reason) {
    NicknameAvailabilityFailureReason.rulesUnavailable =>
      'Nickname check is blocked by Firestore rules. Deploy the updated rules or use the emulator.',
    NicknameAvailabilityFailureReason.unavailable =>
      'We could not check that nickname. Try again.',
  };
}

class _RetakeOnboardingScreen extends StatefulWidget {
  const _RetakeOnboardingScreen({
    required this.authRepository,
    required this.persistenceRepository,
    required this.personalProfile,
  });

  final RuniacAuthRepository authRepository;
  final UserProfilePersistenceRepository persistenceRepository;
  final PersonalProfileDraft personalProfile;

  @override
  State<_RetakeOnboardingScreen> createState() =>
      _RetakeOnboardingScreenState();
}

class _RetakeOnboardingScreenState extends State<_RetakeOnboardingScreen> {
  String? _error;

  Future<bool> _completeRetake(LocalOnboardingDraft draft) async {
    final user = widget.authRepository.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Sign in again before saving your onboarding result.';
      });
      return false;
    }
    final plan = const BeginnerAdaptivePlanGenerator().generate(draft);
    try {
      await widget.persistenceRepository.saveOnboardingProfile(
        uid: user.uid,
        profile: UserProfileOnboardingSnapshot(
          displayName: widget.personalProfile.displayName,
          fullName: widget.personalProfile.fullName,
          nickname: widget.personalProfile.nickname,
          avatarInitials: widget.personalProfile.avatarInitials,
          nicknameKey: widget.personalProfile.nicknameKey,
          dateOfBirthIso: widget.personalProfile.dateOfBirthIso,
          ageYears: widget.personalProfile.ageYears,
          weightKg: widget.personalProfile.weightKg,
          locationLabel: widget.personalProfile.locationLabel,
          fitnessLevel: draft.experience.value,
          goals: <String>[draft.goal.value],
          availability: <String, Object>{
            'weeklySessions': draft.availability.value,
            'preferredDays': draft.preferredDays
                .map((day) => day.value)
                .toList(growable: false),
            'preferredTime': draft.preferredTime.value,
            'sessionLengthMinutes': draft.sessionLength.value,
          },
          planCautiousness: draft.planCautiousness.value,
          healthSafetyReadiness: <String, Object>{
            'comfort': draft.healthComfort.value,
            'activitySymptoms': draft.activitySymptoms
                .map((symptom) => symptom.value)
                .toList(growable: false),
            'recentRunningConsistency': draft.recentRunningConsistency.value,
            'currentWeeklyRunFrequency': draft.currentWeeklyRunFrequency.value,
            'continuousRunCapacity': draft.continuousRunCapacity.value,
            'runningPlace': draft.runningPlace.value,
            'motivationStyle': draft.motivationStyle.value,
          },
        ),
      );
      if (!mounted) {
        return true;
      }
      final store = CurrentSessionGeneratedPlanScope.maybeOf(context);
      if (store != null && !store.setActivePlan(plan)) {
        store.clear();
      }
      Navigator.of(context).pop();
      return true;
    } catch (_) {
      setState(() {
        _error = 'We could not save your onboarding result. Try again.';
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OnboardingFlowScreen(onComplete: _completeRetake),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                tooltip: 'Cancel onboarding retake',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ),
        if (_error != null)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Material(
                color: RuniacColors.accentOrange,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: RuniacColors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: RuniacColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final child in children) ...[
              child,
              if (child != children.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value.isEmpty ? 'Not set' : value),
    );
  }
}

class _NicknameStatusText extends StatelessWidget {
  const _NicknameStatusText({required this.message, required this.available});

  final String message;
  final bool? available;

  @override
  Widget build(BuildContext context) {
    final color = available == false
        ? RuniacColors.accentOrange
        : RuniacColors.textSecondary;
    return Text(
      message,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onEditingComplete,
    this.onChanged,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
      validator: (value) => validator(value ?? ''),
    );
  }
}
