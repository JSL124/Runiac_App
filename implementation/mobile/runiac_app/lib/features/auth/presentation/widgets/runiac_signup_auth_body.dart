import 'package:flutter/material.dart';

import '../../domain/runiac_auth_service.dart';
import 'runiac_auth_buttons.dart';
import 'runiac_auth_fields.dart';
import 'runiac_auth_validators.dart';

class RuniacSignupAuthBody extends StatefulWidget {
  const RuniacSignupAuthBody({
    required this.authRepository,
    required this.onAuthenticated,
    required this.onLogin,
    super.key,
  });

  final RuniacAuthRepository authRepository;
  final VoidCallback onAuthenticated;
  final VoidCallback onLogin;

  @override
  State<RuniacSignupAuthBody> createState() => _RuniacSignupAuthBodyState();
}

class _RuniacSignupAuthBodyState extends State<RuniacSignupAuthBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final onAuthenticated = widget.onAuthenticated;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      onAuthenticated();
    } on RuniacAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.userMessage;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'We could not complete that auth step. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
          const RuniacAuthTitle(
            title: 'Create your account',
            subtitle: 'No pressure. Start at your own pace.',
          ),
          const SizedBox(height: 24),
          RuniacAuthTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'you@runiac.app',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: validateRuniacAuthEmail,
          ),
          const SizedBox(height: 14),
          RuniacAuthTextField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Create a password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            validator: validateRuniacNewPassword,
          ),
          const SizedBox(height: 20),
          RuniacAuthButton(
            label: _isSubmitting ? 'Creating...' : 'Create account',
            onPressed: _isSubmitting ? null : _submit,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            RuniacAuthFeedback(message: _errorMessage!, isError: true),
          ],
          const SizedBox(height: 16),
          const RuniacAuthDivider(),
          const SizedBox(height: 16),
          const RuniacAuthButton(
            label: 'Google sign-in coming later',
            onPressed: null,
            variant: RuniacAuthButtonVariant.google,
            icon: RuniacGoogleGlyph(),
          ),
          const SizedBox(height: 42),
          RuniacInlineAuthAction(
            text: 'Already have an account?',
            action: 'Log in',
            onPressed: widget.onLogin,
          ),
        ],
      ),
    );
  }
}
