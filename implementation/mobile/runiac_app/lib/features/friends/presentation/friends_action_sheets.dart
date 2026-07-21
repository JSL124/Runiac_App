import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../domain/models/friends_read_model.dart';

enum FriendAction { remove, block, report }

Future<FriendAction?> showFriendActionsSheet(
  BuildContext context,
  FriendUserReadModel user,
) {
  return showModalBottomSheet<FriendAction>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('friends-remove-action'),
              leading: const Icon(Icons.person_remove_outlined),
              title: const Text('Remove Friend'),
              onTap: () => Navigator.of(context).pop(FriendAction.remove),
            ),
            ListTile(
              key: const ValueKey('friends-block-action'),
              leading: const Icon(Icons.block_outlined),
              title: const Text('Block'),
              onTap: () => Navigator.of(context).pop(FriendAction.block),
            ),
            ListTile(
              key: const ValueKey('friends-report-action'),
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () => Navigator.of(context).pop(FriendAction.report),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<bool> showFriendActionConfirmation(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool isDestructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
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
