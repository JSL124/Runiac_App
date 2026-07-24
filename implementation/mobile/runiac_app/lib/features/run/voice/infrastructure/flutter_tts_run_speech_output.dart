import 'package:flutter_tts/flutter_tts.dart';

import '../domain/ports/run_speech_output.dart';
import 'flutter_tts_port.dart';

/// Production [RunSpeechOutput] backed by the `flutter_tts` plugin, reached
/// only through [FlutterTtsPort].
///
/// The underlying [FlutterTtsPort] is created lazily on first
/// [initialize]/[speak] call so merely constructing this adapter (and any
/// coordinator that holds it) never touches a platform channel. This keeps
/// it safe to construct unconditionally even when voice coaching is
/// disabled.
class FlutterTtsRunSpeechOutput implements RunSpeechOutput {
  FlutterTtsRunSpeechOutput({FlutterTtsPort Function()? portFactory})
    : _portFactory = portFactory ?? (() => PluginFlutterTtsPort(FlutterTts()));

  final FlutterTtsPort Function() _portFactory;

  FlutterTtsPort? _port;
  bool _initialized = false;
  String? _currentLanguageTag;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _port ??= _portFactory();
    await _port!.awaitSpeakCompletion(true);
    await _port!.setSpeechRate(0.48);
    await _port!.setVolume(1.0);
    await _port!.configureIosAudioDucking();
    _initialized = true;
  }

  @override
  Future<void> speak(String message, {String? languageTag}) async {
    await initialize();
    if (languageTag != null && languageTag != _currentLanguageTag) {
      final available = await _port!.isLanguageAvailable(languageTag);
      final effective = available ? languageTag : 'en-US';
      await _port!.setLanguage(effective);
      _currentLanguageTag = languageTag;
    }
    await _port!.speak(message);
  }

  @override
  Future<void> stop() async {
    if (_port == null) {
      return;
    }
    await _port!.stop();
  }
}
