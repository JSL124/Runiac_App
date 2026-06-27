import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';

enum _AuthStep { welcome, login, signup, forgotPassword }

enum RuniacAuthCompletion { login, signup }

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Enter your email';
  }

  final hasValidShape = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  if (!hasValidShape) {
    return 'Enter a valid email';
  }

  return null;
}

String? _validateRequiredPassword(String? value) {
  if ((value ?? '').isEmpty) {
    return 'Password is required';
  }

  return null;
}

String? _validateNewPassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) {
    return 'Password is required';
  }

  if (password.length < 8) {
    return 'Use at least 8 characters';
  }

  return null;
}

class RuniacAuthFlowScreen extends StatefulWidget {
  const RuniacAuthFlowScreen({required this.onAuthenticated, super.key});

  final ValueChanged<RuniacAuthCompletion> onAuthenticated;

  @override
  State<RuniacAuthFlowScreen> createState() => _RuniacAuthFlowScreenState();
}

class _RuniacAuthFlowScreenState extends State<RuniacAuthFlowScreen> {
  _AuthStep _step = _AuthStep.welcome;

  void _show(_AuthStep step) {
    setState(() {
      _step = step;
    });
  }

  void _showRecoveryMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.sectionSurface,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _AuthScreenFrame(
            key: ValueKey(_step),
            child: switch (_step) {
              _AuthStep.welcome => _WelcomeAuthBody(
                onSignup: () => _show(_AuthStep.signup),
                onLogin: () => _show(_AuthStep.login),
              ),
              _AuthStep.login => _LoginAuthBody(
                onAuthenticated: () {
                  widget.onAuthenticated(RuniacAuthCompletion.login);
                },
                onSignup: () => _show(_AuthStep.signup),
                onForgotPassword: () => _show(_AuthStep.forgotPassword),
              ),
              _AuthStep.signup => _SignupAuthBody(
                onAuthenticated: () {
                  widget.onAuthenticated(RuniacAuthCompletion.signup);
                },
                onLogin: () => _show(_AuthStep.login),
              ),
              _AuthStep.forgotPassword => _RecoveryAuthBody(
                icon: Icons.lock_reset_rounded,
                title: 'Reset your password',
                description:
                    'No worries. Enter your email and we will send a reset link.',
                fieldLabel: 'Email',
                fieldHint: 'you@runiac.app',
                buttonLabel: 'Send reset link',
                onSubmit: () => _showRecoveryMessage(
                  'Password reset will connect to Firebase Auth later.',
                ),
                onLogin: () => _show(_AuthStep.login),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _AuthScreenFrame extends StatelessWidget {
  const _AuthScreenFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _WelcomeAuthBody extends StatelessWidget {
  const _WelcomeAuthBody({required this.onSignup, required this.onLogin});

  final VoidCallback onSignup;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 56),
        const _HeroMark(),
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
        _AuthButton(label: 'Sign up', onPressed: onSignup),
        const SizedBox(height: 14),
        _AuthButton(
          label: 'Log in',
          onPressed: onLogin,
          variant: _AuthButtonVariant.secondary,
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

class _LoginAuthBody extends StatefulWidget {
  const _LoginAuthBody({
    required this.onAuthenticated,
    required this.onSignup,
    required this.onForgotPassword,
  });

  final VoidCallback onAuthenticated;
  final VoidCallback onSignup;
  final VoidCallback onForgotPassword;

  @override
  State<_LoginAuthBody> createState() => _LoginAuthBodyState();
}

class _LoginAuthBodyState extends State<_LoginAuthBody> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 36),
          const _AuthTitle(
            title: 'Welcome back',
            subtitle: 'Let us keep your running habit going.',
          ),
          const SizedBox(height: 26),
          const _AuthTextField(
            label: 'Email',
            hintText: 'you@runiac.app',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: [AutofillHints.email],
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          const _AuthTextField(
            label: 'Password',
            hintText: 'Enter your password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: [AutofillHints.password],
            validator: _validateRequiredPassword,
          ),
          const SizedBox(height: 22),
          _AuthButton(label: 'Sign in', onPressed: _submit),
          const SizedBox(height: 18),
          const _AuthDivider(),
          const SizedBox(height: 18),
          _AuthButton(
            label: 'Continue with Google',
            onPressed: widget.onAuthenticated,
            variant: _AuthButtonVariant.google,
            icon: const _GoogleGlyph(),
          ),
          const SizedBox(height: 22),
          _AuthTextLink(
            label: 'Forgot password?',
            onPressed: widget.onForgotPassword,
          ),
          const SizedBox(height: 42),
          _InlineAuthAction(
            text: 'Do not have an account?',
            action: 'Sign up',
            onPressed: widget.onSignup,
          ),
        ],
      ),
    );
  }
}

class _SignupAuthBody extends StatefulWidget {
  const _SignupAuthBody({required this.onAuthenticated, required this.onLogin});

  final VoidCallback onAuthenticated;
  final VoidCallback onLogin;

  @override
  State<_SignupAuthBody> createState() => _SignupAuthBodyState();
}

class _SignupAuthBodyState extends State<_SignupAuthBody> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 36),
          const _AuthTitle(
            title: 'Create your account',
            subtitle: 'No pressure. Start at your own pace.',
          ),
          const SizedBox(height: 24),
          const _AuthTextField(
            label: 'Email',
            hintText: 'you@runiac.app',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: [AutofillHints.email],
            validator: _validateEmail,
          ),
          const SizedBox(height: 14),
          const _AuthTextField(
            label: 'Password',
            hintText: 'Create a password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: [AutofillHints.newPassword],
            validator: _validateNewPassword,
          ),
          const SizedBox(height: 20),
          _AuthButton(label: 'Create account', onPressed: _submit),
          const SizedBox(height: 16),
          const _AuthDivider(),
          const SizedBox(height: 16),
          _AuthButton(
            label: 'Continue with Google',
            onPressed: widget.onAuthenticated,
            variant: _AuthButtonVariant.google,
            icon: const _GoogleGlyph(),
          ),
          const SizedBox(height: 42),
          _InlineAuthAction(
            text: 'Already have an account?',
            action: 'Log in',
            onPressed: widget.onLogin,
          ),
        ],
      ),
    );
  }
}

class _RecoveryAuthBody extends StatefulWidget {
  const _RecoveryAuthBody({
    required this.icon,
    required this.title,
    required this.description,
    required this.fieldLabel,
    required this.fieldHint,
    required this.buttonLabel,
    required this.onSubmit,
    required this.onLogin,
  });

  final IconData icon;
  final String title;
  final String description;
  final String fieldLabel;
  final String fieldHint;
  final String buttonLabel;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  @override
  State<_RecoveryAuthBody> createState() => _RecoveryAuthBodyState();
}

class _RecoveryAuthBodyState extends State<_RecoveryAuthBody> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 42),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: RuniacColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                widget.icon,
                color: RuniacColors.primaryBlue,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: RuniacColors.primaryBlue,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: RuniacColors.primaryBlue,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          _AuthTextField(
            label: widget.fieldLabel,
            hintText: widget.fieldHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: _validateEmail,
          ),
          const SizedBox(height: 22),
          _AuthButton(label: widget.buttonLabel, onPressed: _submit),
          const SizedBox(height: 70),
          _InlineAuthAction(
            text: 'Remembered it?',
            action: 'Back to log in',
            onPressed: widget.onLogin,
          ),
        ],
      ),
    );
  }
}

class _AuthTitle extends StatelessWidget {
  const _AuthTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: RuniacColors.primaryBlue,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: RuniacColors.primaryBlue,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _HeroMark extends StatelessWidget {
  const _HeroMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 340,
        height: 190,
        child: Semantics(
          label: 'Runiac logo',
          image: true,
          child: Image.asset(
            'assets/images/splash/runiac_splash_logo.png',
            key: const ValueKey('auth_welcome_runiac_logo'),
            width: 330,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
  });

  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      style: const TextStyle(
        color: RuniacColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixIcon: obscureText
            ? const Icon(
                Icons.visibility_outlined,
                color: RuniacColors.textSecondary,
              )
            : null,
        labelStyle: const TextStyle(
          color: RuniacColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        hintStyle: TextStyle(
          color: RuniacColors.primaryBlue.withValues(alpha: 0.45),
          fontWeight: FontWeight.w600,
        ),
        errorStyle: const TextStyle(
          color: RuniacColors.accentOrange,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: RuniacColors.sectionSurfaceStrong,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: RuniacColors.cardBorder,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: RuniacColors.cardBorder,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: RuniacColors.primaryBlue,
            width: 2,
          ),
        ),
      ),
    );
  }
}

enum _AuthButtonVariant { primary, secondary, google }

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.label,
    required this.onPressed,
    this.variant = _AuthButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final _AuthButtonVariant variant;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 10)],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      height: 1,
    );

    if (variant == _AuthButtonVariant.primary) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: RuniacColors.primaryBlue,
          foregroundColor: RuniacColors.white,
          textStyle: textStyle,
          shape: shape,
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: RuniacColors.white,
        foregroundColor: variant == _AuthButtonVariant.google
            ? RuniacColors.textPrimary
            : RuniacColors.primaryBlue,
        side: BorderSide(
          color: RuniacColors.primaryBlue.withValues(alpha: 0.12),
          width: 2,
        ),
        textStyle: textStyle,
        shape: shape,
      ),
      child: child,
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: RuniacColors.cardBorder, thickness: 2),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: TextStyle(
              color: RuniacColors.primaryBlue.withValues(alpha: 0.45),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: RuniacColors.cardBorder, thickness: 2),
        ),
      ],
    );
  }
}

class _AuthTextLink extends StatelessWidget {
  const _AuthTextLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: RuniacColors.primaryBlue,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    );
  }
}

class _InlineAuthAction extends StatelessWidget {
  const _InlineAuthAction({
    required this.text,
    required this.action,
    required this.onPressed,
  });

  final String text;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: RuniacColors.primaryBlue,
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: RuniacColors.border),
        shape: BoxShape.circle,
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: RuniacColors.primaryBlue,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
