import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models/friends_read_model.dart';
import 'friend_identity_mapper.dart';

Future<List<FriendUserReadModel>> readFriendsOwnerList(
  CollectionReference<Map<String, Object?>> collection, {
  String? direction,
}) async {
  Query<Map<String, Object?>> query = collection;
  if (direction != null) {
    query = query
        .where('status', isEqualTo: 'PENDING')
        .where('direction', isEqualTo: direction);
  }
  final snapshot = await query
      .orderBy('listSortKey')
      .orderBy('listSortTieBreaker')
      .limit(30)
      .get();
  return snapshot.docs
      .map(
        (document) => mapFriendIdentityDocument(
          document.data(),
          fallbackUid: document.id,
        ),
      )
      .whereType<FriendUserReadModel>()
      .toList(growable: false);
}
