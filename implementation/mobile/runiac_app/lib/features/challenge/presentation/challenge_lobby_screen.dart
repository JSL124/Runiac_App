import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import '../../../core/widgets/runiac_back_header.dart';
import '../../../core/widgets/runiac_buttons.dart';
import '../domain/challenge_copy.dart';
import '../domain/challenge_countdown.dart';
import '../domain/models/active_challenge.dart';
import '../domain/models/challenge_enums.dart';
import '../domain/models/challenge_invitation_summary.dart';
import '../domain/models/challenge_participant_row.dart';
import '../domain/repositories/challenge_repository.dart';
import 'challenge_friend_picker_screen.dart';
import 'challenge_progress_screen.dart';
import 'widgets/challenge_badge_image.dart';
import 'widgets/challenge_widgets.dart';

/// The RECRUITING lobby: roster, closes-in countdown, owner start/cancel/invite
/// or member leave. Solo vs group is resolved at start via a confirm sheet.
///
/// [pendingInvitations] is an owner-facing seam for Pending/Declined chips.
/// `getActiveChallenge` does not surface the owner's sent invitations, so it
/// defaults to empty until such a read exists; accepted members always render
/// from the trusted participant roster.
class ChallengeLobbyScreen extends StatefulWidget {
  const ChallengeLobbyScreen({
    required this.challengeId,
    required this.repository,
    required this.onBack,
    this.invitableFriendsLoader = noChallengeInvitableFriends,
    this.pendingInvitations = const <ChallengeInvitationSummary>[],
    this.clock,
    this.ticker,
    super.key,
  });

  final String challengeId;
  final ChallengeRepository repository;
  final VoidCallback onBack;
  final ChallengeInvitableFriendsLoader invitableFriendsLoader;
  final List<ChallengeInvitationSummary> pendingInvitations;
  final DateTime Function()? clock;
  final ChallengeTicker? ticker;

  @override
  State<ChallengeLobbyScreen> createState() => _ChallengeLobbyScreenState();
}

class _ChallengeLobbyScreenState extends State<ChallengeLobbyScreen> {
  ActiveChallenge? _challenge;
  ChallengeCountdownController? _countdown;
  bool _loading = true;
  bool _expired = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _countdown?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final challenge = await widget.repository.activeChallenge();
      if (!mounted) {
        return;
      }
      if (challenge == null ||
          challenge.status == ChallengeInstanceStatus.expired ||
          challenge.status.isTerminal) {
        setState(() {
          _loading = false;
          _expired = true;
        });
        return;
      }
      _countdown?.dispose();
      _countdown = ChallengeCountdownController(
        clock: widget.clock ?? DateTime.now,
        ticker: widget.ticker,
        scheduledEndsAt:
            DateTime.fromMillisecondsSinceEpoch(challenge.lobbyExpiresAtMs),
      );
      setState(() {
        _challenge = challenge;
        _loading = false;
        _expired = false;
      });
    } on ChallengeFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = ChallengeCopy.failureMessage(failure.reason);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = ChallengeCopy.failureMessage('UNKNOWN');
      });
    }
  }

  List<ChallengeParticipantRow> get _roster {
    final challenge = _challenge;
    if (challenge == null) {
      return const <ChallengeParticipantRow>[];
    }
    final owner = <ChallengeParticipantRow>[];
    final others = <ChallengeParticipantRow>[];
    for (final row in challenge.participants) {
      if (row.role == ChallengeParticipantRole.owner) {
        owner.add(row);
      } else {
        others.add(row);
      }
    }
    return <ChallengeParticipantRow>[...owner, ...others];
  }

  int get _acceptedInviteeCount => _roster
      .where((row) => row.role == ChallengeParticipantRole.member && !row.hasLeft)
      .length;

  int get _pendingInviteeCount => widget.pendingInvitations
      .where((invite) => invite.status == ChallengeInvitationStatus.pending)
      .length;

  int get _inviteCap => _challenge?.rules.maxInvitedFriends ?? 0;

  bool get _canInvite =>
      (_acceptedInviteeCount + _pendingInviteeCount) < _inviteCap;

  bool get _isSoloStart => _acceptedInviteeCount == 0;

  Future<void> _runAction(Future<void> Function() action) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await action();
    } on ChallengeFailure catch (failure) {
      if (mounted) {
        _showError(ChallengeCopy.failureMessage(failure.reason));
      }
    } catch (_) {
      if (mounted) {
        _showError(ChallengeCopy.failureMessage('UNKNOWN'));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openInvitePicker() async {
    final friends = await widget.invitableFriendsLoader();
    if (!mounted) {
      return;
    }
    final selected = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute<List<String>>(
        builder: (context) => ChallengeFriendPickerScreen(
          friends: friends,
          cap: _inviteCap,
          alreadyInvited: _acceptedInviteeCount + _pendingInviteeCount,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (!mounted || selected == null || selected.isEmpty) {
      return;
    }
    await _runAction(() async {
      await widget.repository
          .invite(challengeId: widget.challengeId, uids: selected);
      await _load();
    });
  }

  Future<void> _confirmStart() async {
    final solo = _isSoloStart;
    final message = solo
        ? ChallengeCopy.startSoloConfirm
        : ChallengeCopy.startGroupConfirm(_roster.length);
    final confirmed = await _showConfirmSheet(
      title: ChallengeCopy.startChallenge,
      message: message,
      confirmLabel: ChallengeCopy.startChallenge,
    );
    if (confirmed != true) {
      return;
    }
    await _runAction(() async {
      await widget.repository.start(challengeId: widget.challengeId);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => ChallengeProgressScreen(
            challengeId: widget.challengeId,
            repository: widget.repository,
            clock: widget.clock,
            ticker: widget.ticker,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
    });
  }

  Future<void> _confirmCancel() async {
    final confirmed = await _showConfirmSheet(
      title: ChallengeCopy.cancelChallenge,
      message: ChallengeCopy.cancelChallengeConfirm,
      confirmLabel: ChallengeCopy.cancelChallenge,
      destructive: true,
    );
    if (confirmed != true) {
      return;
    }
    await _runAction(() async {
      await widget.repository.cancelLobby(challengeId: widget.challengeId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _leaveLobby() async {
    final confirmed = await _showConfirmSheet(
      title: ChallengeCopy.leaveLobby,
      message: 'Leave this lobby? You can be invited again later.',
      confirmLabel: ChallengeCopy.leaveLobby,
      destructive: true,
    );
    if (confirmed != true) {
      return;
    }
    await _runAction(() async {
      await widget.repository.withdraw(challengeId: widget.challengeId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<bool?> _showConfirmSheet({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: RuniacColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    style: RuniacButtonStyles.primary(
                      tone: destructive
                          ? RuniacButtonTone.orange
                          : RuniacButtonTone.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Not now'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RuniacColors.background,
      body: SafeArea(
        child: Column(
          children: [
            RuniacBackHeader(
              title: _challenge == null
                  ? ChallengeCopy.challengeTitle
                  : challengeTierTitle(_challenge!.tierId),
              onBack: widget.onBack,
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const ChallengeLoadingState();
    }
    if (_expired) {
      return const ChallengeEmptyState(
        title: ChallengeCopy.lobbyExpiredTitle,
        icon: Icons.hourglass_disabled_outlined,
      );
    }
    final challenge = _challenge;
    if (challenge == null) {
      return ChallengeErrorState(
        message: _error ?? ChallengeCopy.exploreError,
        onRetry: _load,
      );
    }
    return _buildLobby(challenge);
  }

  Widget _buildLobby(ActiveChallenge challenge) {
    final isOwner = challenge.isCurrentUserOwner;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          children: [
            ChallengeBadgeImage(tierId: challenge.tierId, size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challengeTierTitle(challenge.tierId),
                    style: const TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _ClosesIn(controller: _countdown),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CapacityLine(
          invited: _acceptedInviteeCount + _pendingInviteeCount,
          cap: _inviteCap,
        ),
        const SizedBox(height: 10),
        ..._roster.map(_rosterTile),
        ...widget.pendingInvitations.map(_invitationTile),
        const SizedBox(height: 20),
        if (isOwner) ...[
          OutlinedButton.icon(
            onPressed: _busy || !_canInvite ? null : _openInvitePicker,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text(ChallengeCopy.inviteFriends),
          ),
          const SizedBox(height: 10),
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
              onPressed: _busy ? null : _confirmStart,
              child: const Text(ChallengeCopy.startChallenge),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _busy ? null : _confirmCancel,
            style: TextButton.styleFrom(
              foregroundColor: RuniacColors.errorRed,
            ),
            child: const Text(ChallengeCopy.cancelChallenge),
          ),
        ] else ...[
          const Text(
            ChallengeCopy.waitingForOwner,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _busy ? null : _leaveLobby,
              style: OutlinedButton.styleFrom(
                foregroundColor: RuniacColors.errorRed,
                side: const BorderSide(color: RuniacColors.errorRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(ChallengeCopy.leaveLobby),
            ),
          ),
        ],
      ],
    );
  }

  Widget _rosterTile(ChallengeParticipantRow row) {
    final isOwner = row.role == ChallengeParticipantRole.owner;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ChallengeCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            ChallengeInitialsAvatar(
              initials: row.avatarInitialsSnapshot,
              highlighted: row.isCurrentUser,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.displayNameSnapshot,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isOwner) ...[
                    const SizedBox(height: 2),
                    const Text(
                      ChallengeCopy.ownerLabel,
                      style: TextStyle(
                        color: RuniacColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isOwner) ...[
              const SizedBox(width: 8),
              row.hasLeft
                  ? const ChallengeStatusChip(
                      label: ChallengeCopy.leftTheChallenge,
                      color: RuniacColors.textSecondary,
                    )
                  : const ChallengeStatusChip(
                      label: ChallengeCopy.chipAccepted,
                      color: RuniacColors.successGreen,
                    ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _invitationTile(ChallengeInvitationSummary invite) {
    final declined = invite.status == ChallengeInvitationStatus.declined;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ChallengeCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            const ChallengeInitialsAvatar(initials: '…'),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Invited runner',
                style: TextStyle(
                  color: RuniacColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ChallengeStatusChip(
              label: declined
                  ? ChallengeCopy.chipDeclined
                  : ChallengeCopy.chipPending,
              color: RuniacColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosesIn extends StatelessWidget {
  const _ClosesIn({required this.controller});

  final ChallengeCountdownController? controller;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final label = ChallengeCountdown.formatHms(controller.value.remaining);
        return Text(
          ChallengeCopy.lobbyClosesIn(label),
          style: const TextStyle(
            color: RuniacColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }
}

class _CapacityLine extends StatelessWidget {
  const _CapacityLine({required this.invited, required this.cap});

  final int invited;
  final int cap;

  @override
  Widget build(BuildContext context) {
    return Text(
      ChallengeCopy.invitedOf(invited, cap),
      style: const TextStyle(
        color: RuniacColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
