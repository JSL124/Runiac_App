import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../auth/domain/runiac_auth_service.dart';
import '../domain/models/friends_read_model.dart';
import '../domain/repositories/friends_repository.dart';
import 'friend_identity_mapper.dart';
import 'friends_owner_list_reader.dart';
import 'friends_repository_errors.dart';

export 'friend_identity_mapper.dart' show mapFriendIdentityDocument;
export 'friends_repository_errors.dart';

class FirebaseFriendsRepository implements FriendsRepository {
  FirebaseFriendsRepository({
    required this.authRepository,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  final RuniacAuthRepository authRepository;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  @override
  Future<FriendsOverviewReadModel> loadFriendsOverview({
    required String ownerUid,
  }) async {
    _requireAuthenticatedOwner(ownerUid);
    try {
      final user = _firestore.collection('users').doc(ownerUid);
      final snapshots = await Future.wait([
        readFriendsOwnerList(user.collection('friends')),
        readFriendsOwnerList(
          user.collection('friendRequests'),
          direction: 'incoming',
        ),
        readFriendsOwnerList(
          user.collection('friendRequests'),
          direction: 'outgoing',
        ),
        readFriendsOwnerList(user.collection('blockedUsers')),
      ]);
      return FriendsOverviewReadModel(
        friends: snapshots[0],
        incomingRequests: snapshots[1],
        outgoingRequests: snapshots[2],
        blockedUsers: snapshots[3],
      );
    } on FriendsRepositoryException {
      rethrow;
    } on FirebaseException catch (error) {
      throw _mapFirebaseError(error);
    } catch (_) {
      throw const FriendsRepositoryException(
        FriendsRepositoryErrorCode.unavailable,
      );
    }
  }

  @override
  Stream<FriendsOverviewReadModel> watchFriendsOverview({
    required String ownerUid,
  }) {
    _requireAuthenticatedOwner(ownerUid);
    final user = _firestore.collection('users').doc(ownerUid);
    late final StreamController<FriendsOverviewReadModel> controller;
    final subscriptions = <StreamSubscription<void>>[];

    List<FriendUserReadModel>? friends;
    List<FriendUserReadModel>? incomingRequests;
    List<FriendUserReadModel>? outgoingRequests;
    List<FriendUserReadModel>? blockedUsers;

    void emitIfReady() {
      final currentFriends = friends;
      final currentIncoming = incomingRequests;
      final currentOutgoing = outgoingRequests;
      final currentBlocked = blockedUsers;
      if (currentFriends == null ||
          currentIncoming == null ||
          currentOutgoing == null ||
          currentBlocked == null) {
        return;
      }
      controller.add(
        FriendsOverviewReadModel(
          friends: currentFriends,
          incomingRequests: currentIncoming,
          outgoingRequests: currentOutgoing,
          blockedUsers: currentBlocked,
        ),
      );
    }

    void handleError(Object error) {
      if (error is FirebaseException) {
        controller.addError(_mapFirebaseError(error));
      } else {
        controller.addError(
          const FriendsRepositoryException(
            FriendsRepositoryErrorCode.unavailable,
          ),
        );
      }
    }

    controller = StreamController<FriendsOverviewReadModel>(
      onListen: () {
        subscriptions.addAll([
          watchFriendsOwnerList(user.collection('friends')).listen((value) {
            friends = value;
            emitIfReady();
          }, onError: handleError),
          watchFriendsOwnerList(
            user.collection('friendRequests'),
            direction: 'incoming',
          ).listen((value) {
            incomingRequests = value;
            emitIfReady();
          }, onError: handleError),
          watchFriendsOwnerList(
            user.collection('friendRequests'),
            direction: 'outgoing',
          ).listen((value) {
            outgoingRequests = value;
            emitIfReady();
          }, onError: handleError),
          watchFriendsOwnerList(user.collection('blockedUsers')).listen((
            value,
          ) {
            blockedUsers = value;
            emitIfReady();
          }, onError: handleError),
        ]);
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        subscriptions.clear();
      },
    );
    return controller.stream;
  }

  @override
  Future<List<FriendUserReadModel>> searchFriends({
    required String ownerUid,
    required String nickname,
  }) async {
    _requireAuthenticatedOwner(ownerUid);
    try {
      final data = await _call('searchFriends', <String, Object?>{
        'nickname': nickname,
      });
      final rawResults = data['results'];
      if (rawResults is! List<Object?>) {
        throw const FriendsRepositoryException(
          FriendsRepositoryErrorCode.unavailable,
        );
      }
      return rawResults
          .map(_mapIdentity)
          .whereType<FriendUserReadModel>()
          .take(1)
          .toList(growable: false);
    } on FriendsRepositoryException {
      rethrow;
    } on FirebaseFunctionsException catch (error) {
      throw _mapCallableError(error);
    } catch (_) {
      throw const FriendsRepositoryException(
        FriendsRepositoryErrorCode.unavailable,
      );
    }
  }

  @override
  Future<FriendsMutationResult> sendFriendRequest({
    required String ownerUid,
    required String targetUid,
  }) async {
    _requireAuthenticatedOwner(ownerUid);
    final data = await _callSafely('sendFriendRequest', <String, Object?>{
      'targetUid': targetUid,
    });
    return FriendsMutationResult(
      changed: data['created'] == true,
      status: friendStringValue(data['status']),
    );
  }

  @override
  Future<FriendsMutationResult> cancelFriendRequest({
    required String ownerUid,
    required String targetUid,
  }) async {
    _requireAuthenticatedOwner(ownerUid);
    final data = await _callSafely('cancelFriendRequest', <String, Object?>{
      'targetUid': targetUid,
    });
    return FriendsMutationResult(changed: data['cancelled'] == true);
  }

  @override
  Future<FriendsMutationResult> respondToFriendRequest({
    required String ownerUid,
    required String senderUid,
    required FriendRequestResponseAction action,
  }) async {
    _requireAuthenticatedOwner(ownerUid);
    final data = await _callSafely('respondToFriendRequest', <String, Object?>{
      'senderUid': senderUid,
      'action': action.name,
    });
    return FriendsMutationResult(
      changed: data['status'] is String,
      status: friendStringValue(data['status']),
    );
  }

  @override
  Future<FriendsMutationResult> removeFriend({
    required String ownerUid,
    required String friendUid,
  }) async {
    _requireAuthenticatedOwner(ownerUid);
    final data = await _callSafely('removeFriend', <String, Object?>{
      'friendUid': friendUid,
    });
    return FriendsMutationResult(changed: data['removed'] == true);
  }

  @override
  Future<FriendsMutationResult> blockUser({
    required String ownerUid,
    required String targetUid,
  }) async {
    _requireAuthenticatedOwner(ownerUid);
    final data = await _callSafely('blockUser', <String, Object?>{
      'targetUid': targetUid,
    });
    return FriendsMutationResult(changed: data['blocked'] == true);
  }

  @override
  Future<FriendsMutationResult> unblockUser({
    required String ownerUid,
    required String targetUid,
  }) async {
    _requireAuthenticatedOwner(ownerUid);
    final data = await _callSafely('unblockUser', <String, Object?>{
      'targetUid': targetUid,
    });
    return FriendsMutationResult(changed: data['unblocked'] == true);
  }

  Future<Map<String, Object?>> _call(
    String name,
    Map<String, Object?> payload,
  ) async {
    final result = await _functions.httpsCallable(name).call(payload);
    final data = result.data;
    if (data is! Map<Object?, Object?>) {
      throw const FriendsRepositoryException(
        FriendsRepositoryErrorCode.unavailable,
      );
    }
    return <String, Object?>{
      for (final entry in data.entries)
        if (entry.key is String) entry.key! as String: entry.value,
    };
  }

  Future<Map<String, Object?>> _callSafely(
    String name,
    Map<String, Object?> payload,
  ) async {
    try {
      return await _call(name, payload);
    } on FriendsRepositoryException {
      rethrow;
    } on FirebaseFunctionsException catch (error) {
      throw _mapCallableError(error);
    } catch (_) {
      throw const FriendsRepositoryException(
        FriendsRepositoryErrorCode.unavailable,
      );
    }
  }

  void _requireAuthenticatedOwner(String ownerUid) {
    if (authRepository.currentUser?.uid != ownerUid) {
      throw const FriendsRepositoryException(
        FriendsRepositoryErrorCode.authRequired,
      );
    }
  }

  FriendUserReadModel? _mapIdentity(Object? raw, {String? fallbackUid}) {
    if (raw is! Map<Object?, Object?>) return null;
    return mapFriendIdentityDocument(<String, Object?>{
      for (final entry in raw.entries)
        if (entry.key is String) entry.key! as String: entry.value,
    }, fallbackUid: fallbackUid);
  }

  FriendsRepositoryException _mapCallableError(
    FirebaseFunctionsException error,
  ) {
    return mapFriendsCallableError(
      transportCode: error.code,
      details: error.details,
    );
  }

  FriendsRepositoryException _mapFirebaseError(FirebaseException error) {
    return mapFriendsFirestoreError(error.code);
  }
}
