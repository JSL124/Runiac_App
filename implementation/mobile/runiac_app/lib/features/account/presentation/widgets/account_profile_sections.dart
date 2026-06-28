import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';
import '../../../auth/domain/runiac_auth_service.dart';
import '../../domain/models/user_profile_read_model.dart';
import '../data/account_profile_demo_snapshots.dart';
import '../watch_health_apps_screen.dart';
import 'account_sign_out_row.dart';

class AccountSectionLabel extends StatelessWidget {
  const AccountSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: RuniacColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class AccountSetupSection extends StatelessWidget {
  const AccountSetupSection({required this.items, super.key});

  final List<AccountProfileInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RuniacColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _SetupRow(item: items[index]),
            if (index != items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: RuniacColors.border,
                indent: 58,
              ),
          ],
        ],
      ),
    );
  }
}

class AccountManageSection extends StatelessWidget {
  const AccountManageSection({
    required this.rows,
    required this.authRepository,
    this.onEditProfile,
    super.key,
  });

  final List<AccountProfileManageRow> rows;
  final RuniacAuthRepository authRepository;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows) ...[
          _ManageRow(row: row, onEditProfile: onEditProfile),
          const SizedBox(height: 8),
        ],
        AccountSignOutRow(authRepository: authRepository),
      ],
    );
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({required this.item});

  final AccountProfileInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RowIcon(icon: item.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  softWrap: true,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({required this.row, this.onEditProfile});

  final AccountProfileManageRow row;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return RuniacTappableSurface(
      semanticLabel: row.title,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.border),
      ),
      onTap: () {
        if (row.action == UserProfileManageAction.editProfile) {
          onEditProfile?.call();
          return;
        }
        if (row.action == UserProfileManageAction.watchHealthApps) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WatchHealthAppsScreen(),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(row.snackBarMessage)));
      },
      child: Row(
        children: [
          _RowIcon(icon: row.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
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
                Text(
                  row.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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

class _RowIcon extends StatelessWidget {
  const _RowIcon({required this.icon});

  final IconData icon;

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
      child: Icon(icon, color: RuniacColors.primaryBlue, size: 18),
    );
  }
}
