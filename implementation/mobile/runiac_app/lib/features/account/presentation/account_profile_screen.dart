import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../auth/domain/runiac_auth_service.dart';
import 'data/account_profile_demo_snapshots.dart';
import 'widgets/account_profile_identity.dart';
import 'widgets/account_profile_sections.dart';

class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({
    required this.authRepository,
    required this.onBack,
    this.snapshot = accountProfileDemoSnapshot,
    super.key,
  });

  final RuniacAuthRepository authRepository;
  final VoidCallback onBack;
  final AccountProfileDemoSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RuniacBackHeader(
              title: 'Account',
              tooltip: 'Back to Home',
              onBack: onBack,
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AccountIdentityCard(snapshot: snapshot),
                      const SizedBox(height: 14),
                      AccountPreviewNote(message: snapshot.previewNote),
                      const SizedBox(height: 22),
                      AccountSectionLabel(snapshot.setupSectionLabel),
                      const SizedBox(height: 8),
                      AccountSetupSection(items: snapshot.setupItems),
                      const SizedBox(height: 22),
                      AccountSectionLabel(snapshot.manageSectionLabel),
                      const SizedBox(height: 8),
                      AccountManageSection(
                        rows: snapshot.manageRows,
                        authRepository: authRepository,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        snapshot.footerCaption,
                        textAlign: TextAlign.center,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
