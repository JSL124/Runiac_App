import 'challenge_enums.dart';
import 'challenge_parse.dart';

/// A privacy-safe participant row for lobby and progress surfaces.
///
/// Identity is limited to the backend-authored `displayNameSnapshot` and
/// `avatarInitialsSnapshot`; the raw uid is retained only to resolve
/// [isCurrentUser] and to order the roster (You first). No routes, coordinates,
/// run timestamps, or activity history are ever exposed here. `creditedMeters`
/// is the backend-owned value read back verbatim.
class ChallengeParticipantRow {
  const ChallengeParticipantRow({
    required this.uid,
    required this.displayNameSnapshot,
    required this.avatarInitialsSnapshot,
    required this.role,
    required this.status,
    required this.creditedMeters,
    required this.reward,
    required this.isCurrentUser,
  });

  /// Backend uid. Not for display — used only for self-detection and ordering.
  final String uid;
  final String displayNameSnapshot;
  final String avatarInitialsSnapshot;
  final ChallengeParticipantRole role;
  final ChallengeParticipantStatus status;
  final int creditedMeters;
  final ChallengeRewardStatus reward;
  final bool isCurrentUser;

  bool get hasLeft => status == ChallengeParticipantStatus.left;

  static ChallengeParticipantRow fromMap(
    Map<String, Object?> map, {
    required String? currentUid,
  }) {
    final uid = ChallengeParse.string(map, 'uid');
    return ChallengeParticipantRow(
      uid: uid,
      displayNameSnapshot: ChallengeParse.string(map, 'displayNameSnapshot'),
      avatarInitialsSnapshot:
          ChallengeParse.string(map, 'avatarInitialsSnapshot'),
      role: ChallengeParticipantRole.parse(ChallengeParse.string(map, 'role')),
      status:
          ChallengeParticipantStatus.parse(ChallengeParse.string(map, 'status')),
      creditedMeters: ChallengeParse.integer(map, 'creditedMeters'),
      reward: ChallengeRewardStatus.parse(ChallengeParse.string(map, 'reward')),
      isCurrentUser: currentUid != null && currentUid == uid,
    );
  }
}
