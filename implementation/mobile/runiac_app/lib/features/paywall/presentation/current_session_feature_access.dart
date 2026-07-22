import 'dart:async';

import 'package:flutter/widgets.dart';

import '../domain/models/feature_access_read_model.dart';
import '../domain/repositories/feature_access_repository.dart';

/// App-level store for the admin-published premium feature checklist
/// (`config/featureAccess`).
///
/// [featureAccess] is never null: it starts as the built-in defaults so the
/// upsell renders instantly, and swaps in the merged Firestore document once
/// [ensureLoaded] resolves. One-shot and session-cached — feature tiers
/// change rarely, so no live listener is held.
///
/// This store only relays display data. It never decides feature access;
/// enforcement stays server-side.
class CurrentSessionFeatureAccess extends ChangeNotifier {
  CurrentSessionFeatureAccess({
    this._repository = const StaticFeatureAccessRepository(),
  });

  final FeatureAccessRepository _repository;
  FeatureAccessReadModel _featureAccess = FeatureAccessReadModel.defaults;
  Future<void>? _load;
  var _disposed = false;

  /// Current premium feature checklist — defaults until the read resolves.
  FeatureAccessReadModel get featureAccess => _featureAccess;

  /// Kicks off the one-shot `config/featureAccess` read. Idempotent:
  /// repeated calls share the first in-flight load. Errors keep the
  /// defaults in place.
  Future<void> ensureLoaded() {
    return _load ??= _loadOnce();
  }

  Future<void> _loadOnce() async {
    try {
      final loaded = await _repository.loadFeatureAccess();
      if (_disposed || loaded == _featureAccess) {
        return;
      }
      _featureAccess = loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'runiac current session feature access',
          context: ErrorDescription('loading premium feature checklist'),
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

class FeatureAccessScope
    extends InheritedNotifier<CurrentSessionFeatureAccess> {
  const FeatureAccessScope({
    required CurrentSessionFeatureAccess store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static CurrentSessionFeatureAccess? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FeatureAccessScope>()
        ?.notifier;
  }

  static CurrentSessionFeatureAccess? maybeRead(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<FeatureAccessScope>()
        ?.notifier;
  }
}
