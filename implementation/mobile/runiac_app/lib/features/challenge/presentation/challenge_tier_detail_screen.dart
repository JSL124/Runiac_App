import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../domain/challenge_copy.dart';
import '../domain/models/challenge_tier.dart';
import '../domain/repositories/challenge_repository.dart';
import 'challenge_friend_picker_screen.dart';
import 'challenge_lobby_screen.dart';
import 'widgets/challenge_badge_image.dart';
import 'widgets/challenge_widgets.dart';

/// Tier detail: badge hero, rules card, and the single `Create challenge` CTA.
///
/// When the user already holds a slot the CTA is disabled and a
/// "View current challenge" seam is offered instead. Solo vs group is resolved
/// later at lobby start — this screen only creates the recruiting lobby.
class ChallengeTierDetailScreen extends StatefulWidget {
  const ChallengeTierDetailScreen({
    required this.tier,
    required this.repository,
    required this.onBack,
    this.slotHeld = false,
    this.earned = false,
    this.onViewCurrentChallenge,
    this.invitableFriendsLoader = noChallengeInvitableFriends,
    this.clock,
    super.key,
  });

  final ChallengeTier tier;
  final ChallengeRepository repository;
  final bool slotHeld;
  final bool earned;
  final VoidCallback onBack;
  final VoidCallback? onViewCurrentChallenge;
  final ChallengeInvitableFriendsLoader invitableFriendsLoader;
  final DateTime Function()? clock;

  @override
  State<ChallengeTierDetailScreen> createState() =>
      _ChallengeTierDetailScreenState();
}

class _ChallengeTierDetailScreenState extends State<ChallengeTierDetailScreen> {
  bool _creating = false;

  Future<void> _create() async {
    if (_creating) {
      return;
    }
    setState(() => _creating = true);
    try {
      final result = await widget.repository.createLobby(widget.tier.tierId);
      if (!mounted) {
        return;
      }
      setState(() => _creating = false);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ChallengeLobbyScreen(
            challengeId: result.challengeId,
            repository: widget.repository,
            onBack: () => Navigator.of(context).pop(),
            invitableFriendsLoader: widget.invitableFriendsLoader,
            clock: widget.clock,
          ),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ChallengeFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() => _creating = false);
      _showError(ChallengeCopy.failureMessage(failure.reason));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _creating = false);
      _showError(ChallengeCopy.failureMessage('UNKNOWN'));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final tier = widget.tier;
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        child: Column(
          children: [
            RuniacBackHeader(
              title: challengeTierTitle(tier.tierId),
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ChallengeBadgeImage(tierId: tier.tierId, size: 132),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        Text(
                          challengeTierTitle(tier.tierId),
                          style: const TextStyle(
                            color: RuniacColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        ChallengeStatusChip(
                          label: tier.difficultyLabel,
                          color: RuniacColors.primaryBlue,
                        ),
                        if (widget.earned)
                          const ChallengeStatusChip(
                            label: ChallengeCopy.earned,
                            color: RuniacColors.successGreen,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ChallengeRulesCard(
                      targetMeters: tier.targetMeters,
                      durationDays: tier.durationDays,
                      maxParticipants: tier.maxParticipants,
                      personalMinimumMeters: tier.personalMinimumMeters,
                    ),
                    const SizedBox(height: 20),
                    if (widget.slotHeld) ...[
                      const Text(
                        ChallengeCopy.alreadyHaveChallengeInProgress,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: RuniacColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        style: RuniacButtonStyles.primary(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: widget.slotHeld || _creating ? null : _create,
                        child: _creating
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: RuniacColors.white,
                                ),
                              )
                            : const Text(ChallengeCopy.createChallenge),
                      ),
                    ),
                    if (widget.slotHeld &&
                        widget.onViewCurrentChallenge != null) ...[
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: widget.onViewCurrentChallenge,
                        child: const Text(ChallengeCopy.viewCurrentChallenge),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
