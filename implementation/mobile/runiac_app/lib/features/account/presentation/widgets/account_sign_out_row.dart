import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';
import '../../../auth/domain/runiac_auth_service.dart';

class AccountSignOutRow extends StatefulWidget {
  const AccountSignOutRow({required this.authRepository, super.key});

  final RuniacAuthRepository authRepository;

  @override
  State<AccountSignOutRow> createState() => _AccountSignOutRowState();
}

class _AccountSignOutRowState extends State<AccountSignOutRow> {
  bool _isSigningOut = false;

  Future<void> _handleSignOut() async {
    if (_isSigningOut) {
      return;
    }
    setState(() {
      _isSigningOut = true;
    });

    try {
      await widget.authRepository.signOut();
      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSigningOut = false;
      });
      final message = switch (error) {
        RuniacAuthException(:final userMessage) => userMessage,
        _ => 'We could not sign you out. Please try again.',
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      semanticLabel: 'Sign out',
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      onTap: _isSigningOut ? null : _handleSignOut,
      child: Row(
        children: [
          const _SignOutIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSigningOut ? 'Signing out...' : 'Sign out',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Return to the Runiac welcome screen',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (_isSigningOut)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            const Icon(
              Icons.chevron_right_rounded,
              color: RuniacColors.textSecondary,
              size: 22,
            ),
        ],
      ),
    );
  }
}

class _SignOutIcon extends StatelessWidget {
  const _SignOutIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RuniacColors.sectionSurfaceStrong,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.logout_rounded,
        color: RuniacColors.accentOrange,
        size: 18,
      ),
    );
  }
}
