import 'dart:async';

import 'package:flutter/services.dart';

/// Central seam for haptic feedback across the app.
///
/// Feature code should trigger haptics through this abstraction (reached via
/// `RuniacHapticsScope`) instead of calling `HapticFeedback` directly, so a
/// single place governs whether haptics are enabled (mirroring the user's
/// Settings > App comfort > Haptic feedback preference) and so tests can
/// substitute a recording fake.
abstract class RuniacHaptics {
  /// A subtle "selection changed" haptic (e.g. toggles, segmented controls).
  void selection();

  /// A light impact haptic (e.g. minor taps and confirmations).
  void impactLight();

  /// A medium impact haptic (e.g. standard confirmations).
  void impactMedium();

  /// A heavy impact haptic (e.g. significant milestones).
  void impactHeavy();

  /// An error haptic (e.g. failed actions, invalid input).
  void error();

  /// Enables or disables all haptic feedback dispatched through this
  /// instance.
  void setEnabled(bool enabled);
}

/// [RuniacHaptics] implementation backed by the platform's [HapticFeedback]
/// channel.
///
/// Haptics are a non-critical comfort feature, so every call here is
/// fail-safe: platform channel failures (missing plugin implementation,
/// unsupported platform, no binary messenger registered in a test) are
/// swallowed rather than allowed to propagate to the caller.
class SystemRuniacHaptics implements RuniacHaptics {
  // The public parameter is `enabled` while the backing field is private
  // (`_enabled`) behind a getter/setter, so an initializing formal cannot apply.
  // ignore: prefer_initializing_formals
  SystemRuniacHaptics({bool enabled = true}) : _enabled = enabled;

  bool _enabled;

  /// Whether haptic feedback is currently enabled.
  bool get enabled => _enabled;

  @override
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  @override
  void selection() {
    if (!_enabled) {
      return;
    }
    _fire(() => HapticFeedback.selectionClick());
  }

  @override
  void impactLight() {
    if (!_enabled) {
      return;
    }
    _fire(() => HapticFeedback.lightImpact());
  }

  @override
  void impactMedium() {
    if (!_enabled) {
      return;
    }
    _fire(() => HapticFeedback.mediumImpact());
  }

  @override
  void impactHeavy() {
    if (!_enabled) {
      return;
    }
    _fire(() => HapticFeedback.heavyImpact());
  }

  @override
  void error() {
    if (!_enabled) {
      return;
    }
    _fire(() => HapticFeedback.vibrate());
  }

  /// Fires a platform haptic call, guarding both the synchronous call site
  /// and the returned future so a platform failure never surfaces to the
  /// caller.
  void _fire(Future<void> Function() call) {
    try {
      unawaited(call().catchError((_) {}));
    } catch (_) {
      // Never let a haptic failure affect the calling feature flow.
    }
  }
}
