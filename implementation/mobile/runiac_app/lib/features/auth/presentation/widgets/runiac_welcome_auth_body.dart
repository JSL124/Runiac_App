import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import 'runiac_auth_buttons.dart';
import 'runiac_auth_fields.dart';

class RuniacWelcomeAuthBody extends StatelessWidget {
  const RuniacWelcomeAuthBody({
    required this.onSignup,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onSignup;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 56),
        const RuniacHeroMark(),
        const SizedBox(height: 24),
        const Text(
          'Build a running habit that sticks, one easy step at a time.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RuniacColors.primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 84),
        RuniacAuthButton(label: 'Sign up', onPressed: onSignup),
        const SizedBox(height: 14),
        RuniacAuthButton(
          label: 'Log in',
          onPressed: onLogin,
          variant: RuniacAuthButtonVariant.secondary,
        ),
        const SizedBox(height: 18),
        const Text.rich(
          TextSpan(
            text: 'By continuing you agree to our ',
            children: [
              TextSpan(
                text: 'Terms',
                style: TextStyle(
                  color: RuniacColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: RuniacColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
