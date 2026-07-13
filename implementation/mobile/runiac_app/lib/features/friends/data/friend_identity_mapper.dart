import '../domain/models/friends_read_model.dart';

FriendUserReadModel? mapFriendIdentityDocument(
  Map<String, Object?> data, {
  String? fallbackUid,
}) {
  final uid = friendStringValue(data['uid']) ?? fallbackUid;
  final nickname = friendStringValue(data['nickname']);
  final displayName = friendStringValue(data['displayName']);
  final avatarInitials = friendStringValue(data['avatarInitials']);
  if (uid == null ||
      uid.isEmpty ||
      nickname == null ||
      displayName == null ||
      avatarInitials == null ||
      displayName.isEmpty ||
      avatarInitials.isEmpty) {
    return null;
  }
  return FriendUserReadModel(
    userId: uid,
    nickname: nickname,
    displayName: displayName,
    avatarInitials: avatarInitials,
  );
}

String? friendStringValue(Object? value) => value is String ? value : null;
