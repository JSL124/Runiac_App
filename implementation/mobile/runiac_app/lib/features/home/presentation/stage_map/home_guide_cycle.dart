import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/guide/home_guide_agent.dart';

/// Immutable identity for one displayed stage and its plan-display context.
///
/// The value is local-only. It lets the Home surface reuse a single in-memory
/// agent future while a stage/request pair is unchanged; a new controller is
/// intentionally a fresh session and asks the server cache again.
@immutable
class HomeGuideCycleSignature {
  const HomeGuideCycleSignature._({
    required this.stageId,
    required this.request,
    required this._encodedValue,
  });

  factory HomeGuideCycleSignature.forRequest({
    required String stageId,
    required HomeGuideRequest request,
  }) {
    final snapshot = HomeGuideRequest(
      planTitle: request.planTitle,
      weekNumber: request.weekNumber,
      weekFocus: request.weekFocus,
      dayLabel: request.dayLabel,
      workoutTitle: request.workoutTitle,
      durationMinutes: request.durationMinutes,
      intensityLabel: request.intensityLabel,
      description: request.description,
      steps: List<String>.unmodifiable(request.steps),
      supportiveNote: request.supportiveNote,
    );
    return HomeGuideCycleSignature._(
      stageId: stageId,
      request: snapshot,
      encodedValue: jsonEncode(<Object?>[
        stageId,
        snapshot.planTitle,
        snapshot.weekNumber,
        snapshot.weekFocus,
        snapshot.dayLabel,
        snapshot.workoutTitle,
        snapshot.durationMinutes,
        snapshot.intensityLabel,
        snapshot.description,
        snapshot.steps,
        snapshot.supportiveNote,
      ]),
    );
  }

  final String stageId;
  final HomeGuideRequest request;
  final String _encodedValue;

  @override
  bool operator ==(Object other) =>
      other is HomeGuideCycleSignature && _encodedValue == other._encodedValue;

  @override
  int get hashCode => _encodedValue.hashCode;
}

/// Read-only local state for the Home guide's three-message cycle.
@immutable
class HomeGuideCycleState {
  const HomeGuideCycleState({
    required this.isVisible,
    required this.isLoading,
    required this.currentIndex,
    required this.bundle,
  });

  final bool isVisible;
  final bool isLoading;
  final int currentIndex;
  final HomeGuideBundle? bundle;

  HomeGuideMessage? get currentMessage =>
      isLoading ? null : bundle?.messages[currentIndex];
}

/// Owns the local-only presentation cycle for a complete guide bundle.
///
/// It makes no persistence, progression, quota, or network-policy decision.
/// The supplied [HomeGuideAgent] remains the sole source of guide bundles.
class HomeGuideCycleController extends ChangeNotifier {
  HomeGuideCycleController({
    required this.agent,
    required HomeGuideCycleSignature signature,
  }) {
    _activate(signature);
  }

  final HomeGuideAgent agent;
  final Map<HomeGuideCycleSignature, Future<HomeGuideBundle>> _bundleFutures =
      <HomeGuideCycleSignature, Future<HomeGuideBundle>>{};

  late HomeGuideCycleSignature _activeSignature;
  late Future<HomeGuideBundle> _activeBundleFuture;
  late HomeGuideCycleState _state;
  bool _isDisposed = false;

  HomeGuideCycleState get state => _state;

  /// Completes after the active bundle has settled, including a safe error
  /// settlement. It exists for deterministic widget/controller coordination.
  Future<void> get settled => _activeBundleFuture.then<void>(
    (_) {},
    onError: (Object _, StackTrace _) {},
  );

  /// Starts a new local cycle only when the stage/request display signature
  /// changes. Returning false means current visibility and message remain.
  bool updateSignature(HomeGuideCycleSignature signature) {
    if (signature == _activeSignature) {
      return false;
    }
    _activate(signature);
    return true;
  }

  void show() {
    if (_state.isVisible) {
      return;
    }
    _state = HomeGuideCycleState(
      isVisible: true,
      isLoading: _state.isLoading,
      currentIndex: _state.currentIndex,
      bundle: _state.bundle,
    );
    notifyListeners();
  }

  void hide() {
    if (!_state.isVisible) {
      return;
    }
    _state = HomeGuideCycleState(
      isVisible: false,
      isLoading: _state.isLoading,
      currentIndex: _state.currentIndex,
      bundle: _state.bundle,
    );
    notifyListeners();
  }

  /// Advances only after a complete bundle has resolved.
  void advance() {
    if (!_state.isVisible || _state.currentMessage == null) {
      return;
    }
    _state = HomeGuideCycleState(
      isVisible: _state.isVisible,
      isLoading: false,
      currentIndex: (_state.currentIndex + 1) % 3,
      bundle: _state.bundle,
    );
    notifyListeners();
  }

  void _activate(HomeGuideCycleSignature signature) {
    _activeSignature = signature;
    final bundleFuture = _bundleFutures.putIfAbsent(
      signature,
      () => Future<HomeGuideBundle>.sync(
        () => agent.explainTodayPlan(signature.request),
      ),
    );
    _activeBundleFuture = bundleFuture;
    _state = const HomeGuideCycleState(
      isVisible: true,
      isLoading: true,
      currentIndex: 0,
      bundle: null,
    );
    notifyListeners();
    bundleFuture.then(
      (bundle) => _settleBundle(signature, bundleFuture, bundle),
      onError: (Object _, StackTrace _) =>
          _settleFailure(signature, bundleFuture),
    );
  }

  void _settleBundle(
    HomeGuideCycleSignature signature,
    Future<HomeGuideBundle> bundleFuture,
    HomeGuideBundle bundle,
  ) {
    if (!_isActive(signature, bundleFuture)) {
      return;
    }
    _state = HomeGuideCycleState(
      isVisible: _state.isVisible,
      isLoading: false,
      currentIndex: 0,
      bundle: bundle,
    );
    notifyListeners();
  }

  void _settleFailure(
    HomeGuideCycleSignature signature,
    Future<HomeGuideBundle> bundleFuture,
  ) {
    if (!_isActive(signature, bundleFuture)) {
      return;
    }
    _state = HomeGuideCycleState(
      isVisible: _state.isVisible,
      isLoading: false,
      currentIndex: 0,
      bundle: null,
    );
    notifyListeners();
  }

  bool _isActive(
    HomeGuideCycleSignature signature,
    Future<HomeGuideBundle> bundleFuture,
  ) =>
      !_isDisposed &&
      signature == _activeSignature &&
      identical(bundleFuture, _activeBundleFuture);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
