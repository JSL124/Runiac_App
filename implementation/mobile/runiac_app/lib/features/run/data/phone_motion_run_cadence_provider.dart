// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/services.dart';

import '../domain/models/run_cadence_sample.dart';
import '../domain/repositories/run_cadence_provider.dart';

class PhoneMotionRunCadenceProvider implements RunCadenceProvider {
  PhoneMotionRunCadenceProvider({
    MethodChannel methodChannel = const MethodChannel(
      'runiac/phone_motion_cadence',
    ),
    EventChannel eventChannel = const EventChannel(
      'runiac/phone_motion_cadence_events',
    ),
    Stream<Object?>? nativeEvents,
  }) : _methodChannel = methodChannel,
       _eventChannel = eventChannel,
       _nativeEvents = nativeEvents;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  final Stream<Object?>? _nativeEvents;
  final StreamController<RunCadenceSample> _controller =
      StreamController<RunCadenceSample>.broadcast();

  StreamSubscription<Object?>? _nativeSubscription;

  @override
  Stream<RunCadenceSample> get cadenceStream => _controller.stream;

  @override
  Future<bool> isAvailable() async {
    try {
      final available = await _methodChannel.invokeMethod<bool>('isAvailable');
      return available ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> start() async {
    final permissionGranted = await _requestPermission();
    if (!permissionGranted || !await isAvailable()) {
      return;
    }
    await _subscribe();
  }

  @override
  Future<void> pause() async {
    await _unsubscribe();
  }

  @override
  Future<void> resume() async {
    if (!await isAvailable()) {
      return;
    }
    await _subscribe();
  }

  @override
  Future<void> stop() async {
    await _unsubscribe();
  }

  Future<void> _subscribe() async {
    if (_nativeSubscription != null) {
      return;
    }
    final events = _nativeEvents ?? _eventChannel.receiveBroadcastStream();
    _nativeSubscription = events.listen((event) {
      final sample = _sampleFromEvent(event);
      if (sample != null && !_controller.isClosed) {
        _controller.add(sample);
      }
    });
  }

  Future<void> _unsubscribe() async {
    await _nativeSubscription?.cancel();
    _nativeSubscription = null;
  }

  Future<bool> _requestPermission() async {
    try {
      final result = await _methodChannel.invokeMethod<Object?>(
        'requestPermission',
      );
      return result == 'granted' || result == 'notRequired';
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> dispose() async {
    await _unsubscribe();
    await _controller.close();
  }

  RunCadenceSample? _sampleFromEvent(Object? event) {
    if (event is! Map) {
      return null;
    }
    final cadence = event['stepsPerMinute'];
    final recordedAtMillis = event['recordedAtMillis'];
    if (cadence is! num || recordedAtMillis is! num || !cadence.isFinite) {
      return null;
    }
    return RunCadenceSample(
      recordedAt: DateTime.fromMillisecondsSinceEpoch(
        recordedAtMillis.round(),
        isUtc: true,
      ),
      stepsPerMinute: cadence.toDouble(),
      source: CadenceSource.phoneMotion,
      confidence: _confidenceFrom(event['confidence']),
    );
  }

  CadenceConfidence _confidenceFrom(Object? value) {
    return switch (value) {
      'high' => CadenceConfidence.high,
      'low' => CadenceConfidence.low,
      'unavailable' => CadenceConfidence.unavailable,
      _ => CadenceConfidence.estimated,
    };
  }
}
