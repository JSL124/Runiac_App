import 'dart:io' show Platform;

import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around the `flutter_tts` plugin so higher layers can be
/// unit-tested without exercising a platform `MethodChannel`.
///
/// `flutter_tts` must be imported ONLY in this file; every other file in the
/// voice feature depends on this abstraction instead.
abstract interface class FlutterTtsPort {
  Future<void> setLanguage(String language);

  Future<void> setSpeechRate(double rate);

  Future<void> setVolume(double volume);

  Future<void> awaitSpeakCompletion(bool awaitCompletion);

  Future<void> configureIosAudioDucking();

  Future<bool> isLanguageAvailable(String language);

  Future<void> speak(String message);

  Future<void> stop();
}

/// Production [FlutterTtsPort] backed by a real `FlutterTts` plugin
/// instance.
///
/// Every plugin call is guarded so a platform that lacks (or misbehaves on)
/// a given API degrades gracefully instead of crashing an in-progress run.
class PluginFlutterTtsPort implements FlutterTtsPort {
  PluginFlutterTtsPort(this._tts);

  final FlutterTts _tts;

  @override
  Future<void> setLanguage(String language) async {
    try {
      await _tts.setLanguage(language);
    } catch (_) {
      // Unsupported/unavailable language on this platform: no-op.
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
    } catch (_) {
      // Rate control unsupported on this platform: no-op.
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await _tts.setVolume(volume);
    } catch (_) {
      // Volume control unsupported on this platform: no-op.
    }
  }

  @override
  Future<void> awaitSpeakCompletion(bool awaitCompletion) async {
    try {
      await _tts.awaitSpeakCompletion(awaitCompletion);
    } catch (_) {
      // Unsupported on this platform: no-op.
    }
  }

  @override
  Future<void> configureIosAudioDucking() async {
    if (!Platform.isIOS) {
      return;
    }
    try {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
      );
    } catch (_) {
      // Audio category configuration is a best-effort convenience: no-op if
      // the installed plugin/platform version doesn't support it.
    }
  }

  @override
  Future<bool> isLanguageAvailable(String language) async {
    try {
      final result = await _tts.isLanguageAvailable(language);
      if (result is bool) {
        return result;
      }
      if (result is num) {
        return result != 0;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<void> speak(String message) async {
    try {
      await _tts.speak(message);
    } catch (_) {
      // Speak failures are handled by the caller; degrade to no-op here so
      // a single bad platform call cannot crash the run session.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing to stop / unsupported: no-op.
    }
  }
}
