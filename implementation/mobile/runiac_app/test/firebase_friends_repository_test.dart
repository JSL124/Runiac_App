import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/friends/data/firebase_friends_repository.dart';

void main() {
  test('owner-list reads keep the Rules-required bounded query', () {
    final repositorySource = File(
      'lib/features/friends/data/firebase_friends_repository.dart',
    ).readAsStringSync();
    final readerSource = File(
      'lib/features/friends/data/friends_owner_list_reader.dart',
    ).readAsStringSync();

    expect(
      readerSource,
      contains(
        ".orderBy('listSortTieBreaker')\n      .limit(30)\n      .get()",
      ),
    );
    expect(repositorySource, contains("user.collection('friends')"));
    expect(repositorySource, contains("user.collection('friendRequests')"));
    expect(repositorySource, contains("user.collection('blockedUsers')"));
  });

  test('maps the finalized root-level owner-list document shape', () {
    final user = mapFriendIdentityDocument(<String, Object?>{
      'uid': 'runner-b',
      'nickname': 'grace-teo',
      'displayName': 'Grace Teo',
      'avatarInitials': 'GT',
      'listSortKey': 'grace-teo',
      'listSortTieBreaker': 'runner-b',
    });

    expect(user?.userId, 'runner-b');
    expect(user?.nickname, 'grace-teo');
    expect(user?.displayName, 'Grace Teo');
    expect(user?.avatarInitials, 'GT');
  });

  test('does not read an obsolete nested identity map', () {
    final user = mapFriendIdentityDocument(<String, Object?>{
      'identity': <String, Object?>{
        'uid': 'runner-b',
        'nickname': 'grace-teo',
        'displayName': 'Grace Teo',
        'avatarInitials': 'GT',
      },
    }, fallbackUid: 'runner-b');

    expect(user, isNull);
  });

  test('maps exact backend authentication and argument reasons', () {
    expect(
      mapFriendsCallableError(
        transportCode: 'internal',
        details: const <String, Object?>{'reason': 'UNAUTHENTICATED'},
      ).code,
      FriendsRepositoryErrorCode.authRequired,
    );
    expect(
      mapFriendsCallableError(
        transportCode: 'internal',
        details: const <String, Object?>{'reason': 'INVALID_ARGUMENT'},
      ).code,
      FriendsRepositoryErrorCode.invalidRequest,
    );
  });

  test('unknown backend reason falls back to the transport code', () {
    expect(
      mapFriendsCallableError(
        transportCode: 'unauthenticated',
        details: const <String, Object?>{'reason': 'UNKNOWN_REASON'},
      ).code,
      FriendsRepositoryErrorCode.authRequired,
    );
    expect(
      mapFriendsCallableError(
        transportCode: 'invalid-argument',
        details: const <String, Object?>{'reason': 'UNKNOWN_REASON'},
      ).code,
      FriendsRepositoryErrorCode.invalidRequest,
    );
  });

  test('signed-in Firestore permission failures stay privacy-safe', () {
    expect(
      mapFriendsFirestoreError('permission-denied').code,
      FriendsRepositoryErrorCode.unavailable,
    );
  });
}
