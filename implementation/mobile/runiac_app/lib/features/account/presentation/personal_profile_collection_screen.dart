import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../domain/repositories/user_profile_persistence_repository.dart';

class PersonalProfileCollectionScreen extends StatefulWidget {
  const PersonalProfileCollectionScreen({
    required this.emailLabel,
    required this.onComplete,
    super.key,
  });

  final String emailLabel;
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
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _regionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final draft = PersonalProfileDraft.tryCreate(
      fullName: _nameController.text,
      nickname: _nicknameController.text,
      age: _ageController.text,
      weightKg: _weightController.text,
      locationLabel: _regionController.text,
    );
    if (draft == null) {
      return;
    }
    widget.onComplete(draft);
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
                    _ProfileField(
                      label: 'Age',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      validator: PersonalProfileDraft.validateAge,
                    ),
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
                    _ProfileField(
                      label: 'Region',
                      controller: _regionController,
                      validator: PersonalProfileDraft.validateLocationLabel,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _continue,
                        style: RuniacButtonStyles.primary(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Continue to onboarding'),
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
