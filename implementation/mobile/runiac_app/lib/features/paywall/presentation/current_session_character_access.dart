import 'package:flutter/widgets.dart';

import '../domain/models/character_access_read_model.dart';
import '../domain/repositories/character_access_repository.dart';

/// App-level store for the admin-published premium-character list
/// (`config/characterAccess`).
///
/// [characterAccess] is never null: it starts as the built-in defaults so the
/// picker renders instantly, and swaps in the Firestore document once
/// [ensureLoaded] resolves. One-shot and session-cached — character tiers
/// change rarely, so no live listener is held.
///
/// This store only relays display data. The character is cosmetic, device-local
/// personalization, so the lock it drives is presentation only; it never writes
/// XP, level, rank, streak, or leaderboard values.
class CurrentSessionCharacterAccess extends ChangeNotifier {
  CurrentSessionCharacterAccess({
    this._repository = const StaticCharacterAccessRepository(),
  });

  final CharacterAccessRepository _repository;
  CharacterAccessReadModel _characterAccess = CharacterAccessReadModel.defaults;
  Future<void>? _load;
  var _disposed = false;

  /// Current premium-character list — defaults until the read resolves.
  CharacterAccessReadModel get characterAccess => _characterAccess;

  /// Kicks off the one-shot `config/characterAccess` read. Idempotent:
  /// repeated calls share the first in-flight load. Errors keep the defaults
  /// in place.
  Future<void> ensureLoaded() {
    return _load ??= _loadOnce();
  }

  Future<void> _loadOnce() async {
    try {
      final loaded = await _repository.loadCharacterAccess();
      if (_disposed || loaded == _characterAccess) {
        return;
      }
      _characterAccess = loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'runiac current session character access',
          context: ErrorDescription('loading premium character list'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class CharacterAccessScope
    extends InheritedNotifier<CurrentSessionCharacterAccess> {
  const CharacterAccessScope({
    required CurrentSessionCharacterAccess store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static CurrentSessionCharacterAccess? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CharacterAccessScope>()
        ?.notifier;
  }

  static CurrentSessionCharacterAccess? maybeRead(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<CharacterAccessScope>()
        ?.notifier;
  }
}
