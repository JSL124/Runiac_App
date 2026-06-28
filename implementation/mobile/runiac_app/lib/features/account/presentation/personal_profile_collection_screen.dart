import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../domain/repositories/user_profile_persistence_repository.dart';
import 'widgets/profile_form_controls.dart';

class PersonalProfileCollectionScreen extends StatefulWidget {
  const PersonalProfileCollectionScreen({
    required this.uid,
    required this.emailLabel,
    required this.persistenceRepository,
    required this.onComplete,
    super.key,
  });

  final String uid;
  final String emailLabel;
  final UserProfilePersistenceRepository persistenceRepository;
  final ValueChanged<PersonalProfileDraft> onComplete;

  @override
  State<PersonalProfileCollectionScreen> createState() =>
      _PersonalProfileCollectionScreenState();
}

class _PersonalProfileCollectionScreenState
    extends State<PersonalProfileCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _weightController = TextEditingController();
  String _dateOfBirthIso = '';
  String _region = '';
  bool _checkingNickname = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_checkingNickname) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final draft = PersonalProfileDraft.tryCreate(
      fullName: _nameController.text,
      nickname: _nicknameController.text,
      weightKg: _weightController.text,
      dateOfBirthIso: _dateOfBirthIso,
      locationLabel: _region,
    );
    if (draft == null) {
      setState(() {
        _error = 'Choose your birthdate, weight, and Singapore region.';
      });
      return;
    }
    setState(() {
      _checkingNickname = true;
      _error = null;
    });
    try {
      final available = await widget.persistenceRepository.isNicknameAvailable(
        uid: widget.uid,
        nickname: draft.nickname,
      );
      if (!available) {
        setState(() {
          _error = 'Nickname is already taken.';
        });
        return;
      }
      widget.onComplete(draft);
    } catch (_) {
      setState(() {
        _error = 'We could not check that nickname. Try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _checkingNickname = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tell us about you',
                      style: TextStyle(
                        color: RuniacColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'These details shape your beginner running plan.',
                      style: TextStyle(
                        color: RuniacColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ReadOnlyEmail(value: widget.emailLabel),
                    const SizedBox(height: 12),
                    _ProfileField(
                      label: 'Name',
                      controller: _nameController,
                      validator: PersonalProfileDraft.validateFullName,
                    ),
                    const SizedBox(height: 12),
                    _ProfileField(
                      label: 'Nickname',
                      controller: _nicknameController,
                      validator: PersonalProfileDraft.validateNickname,
                    ),
                    const SizedBox(height: 12),
                    ProfileDateOfBirthField(
                      value: _dateOfBirthIso,
                      onChanged: (value) {
                        setState(() {
                          _dateOfBirthIso = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ProfileAgeReadOnlyField(dateOfBirthIso: _dateOfBirthIso),
                    const SizedBox(height: 12),
                    _ProfileField(
                      label: 'Weight in kilograms',
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: PersonalProfileDraft.validateWeight,
                    ),
                    const SizedBox(height: 12),
                    SingaporeRegionPickerField(
                      value: _region,
                      onChanged: (value) {
                        setState(() {
                          _region = value;
                        });
                      },
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
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _checkingNickname ? null : _continue,
                        style: RuniacButtonStyles.primary(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _checkingNickname
                              ? 'Checking nickname...'
                              : 'Continue to onboarding',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyEmail extends StatelessWidget {
  const _ReadOnlyEmail({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Email'),
      child: Text(value),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (value) => validator(value ?? ''),
    );
  }
}
