import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../../../core/widgets/runiac_sheet_scaffold.dart';
import '../../you/presentation/widgets/you_surface_primitives.dart';
import '../domain/models/friends_read_model.dart';

enum FriendAction { remove, block, report }

Future<FriendAction?> showFriendActionsSheet(
  BuildContext context,
  FriendUserReadModel user,
) {
  return showModalBottomSheet<FriendAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) {
      final firstName = user.displayName.trim().split(RegExp(r'\s+')).first;
      return RuniacSheetScaffold(
        title: user.displayName,
        subtitle: 'Choose an action',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FriendActionTile(
              key: const ValueKey('friends-remove-action'),
              icon: Icons.person_remove_rounded,
              iconColor: RuniacColors.primaryBlue,
              medallionColor: RuniacColors.primaryBlue.withValues(alpha: 0.10),
              titleColor: RuniacColors.textPrimary,
              title: 'Remove Friend',
              caption: 'Remove $firstName from your friends',
              onTap: () => Navigator.of(context).pop(FriendAction.remove),
            ),
            const SizedBox(height: 10),
            _FriendActionTile(
              key: const ValueKey('friends-block-action'),
              icon: Icons.block_rounded,
              iconColor: RuniacColors.errorRed,
              medallionColor: RuniacColors.errorRed.withValues(alpha: 0.10),
              titleColor: RuniacColors.errorRed,
              title: 'Block',
              caption: 'Stop all contact both ways',
              onTap: () => Navigator.of(context).pop(FriendAction.block),
            ),
            const SizedBox(height: 10),
            _FriendActionTile(
              key: const ValueKey('friends-report-action'),
              icon: Icons.flag_rounded,
              iconColor: RuniacColors.primaryBlue,
              medallionColor: RuniacColors.primaryBlue.withValues(alpha: 0.10),
              titleColor: RuniacColors.textPrimary,
              title: 'Report',
              caption: 'Tell us what went wrong',
              onTap: () => Navigator.of(context).pop(FriendAction.report),
            ),
            const SizedBox(height: 4),
            // shrinkWrap + explicit padding: the default 48dp tap-target box
            // would leave a visible band of dead space under the label.
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(vertical: 11),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Cancel', style: YouTextStyles.bodyStrong),
            ),
          ],
        ),
      );
    },
  );
}

/// One tappable row in the Friends "..." action sheet: a tinted icon
/// medallion, a title/caption pair, and a trailing chevron. Visual styling
/// only — every tile still pops the same [FriendAction] value the sheet
/// always returned.
class _FriendActionTile extends StatelessWidget {
  const _FriendActionTile({
    required this.icon,
    required this.iconColor,
    required this.medallionColor,
    required this.titleColor,
    required this.title,
    required this.caption,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final Color medallionColor;
  final Color titleColor;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      onTap: onTap,
      height: 56,
      borderRadius: BorderRadius.circular(youInnerRadius),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(youInnerRadius),
        border: Border.all(color: RuniacColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medallionColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: YouTextStyles.bodyStrong.copyWith(color: titleColor),
                ),
                const SizedBox(height: 2),
                Text(caption, style: YouTextStyles.smallBody),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: RuniacColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

Future<bool> showFriendActionConfirmation(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool isDestructive = true,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final tint = isDestructive ? RuniacColors.errorRed : RuniacColors.primaryBlue;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: RuniacColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        icon: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: tint, size: 28),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: YouTextStyles.cardTitle,
        ),
        content: Text(
          body,
          textAlign: TextAlign.center,
          style: YouTextStyles.body,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('friends-confirm-action'),
            style: FilledButton.styleFrom(
              backgroundColor: isDestructive
                  ? RuniacColors.errorRed
                  : RuniacColors.primaryBlue,
              foregroundColor: RuniacColors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result == true;
}

String friendActionConfirmationBody(FriendAction action) {
  return switch (action) {
    FriendAction.remove =>
      'This removes the friendship. You can send a new friend request after 24 hours.',
    FriendAction.block =>
      'This removes the friendship and pending requests in both directions. '
          'You will no longer appear to each other in Friends, Search, or Feed.',
    // Report opens its own reason-picker sheet instead of this yes/no
    // confirmation dialog, so this body copy is never shown for it.
    FriendAction.report => '',
  };
}
