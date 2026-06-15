import 'dart:async';

import 'package:geolocator/geolocator.dart' as geolocator;

import '../domain/models/run_location_sample.dart';
import '../domain/repositories/run_location_provider.dart';

class LocationSettingsRequest {
  const LocationSettingsRequest({
    this.highAccuracy = true,
    this.distanceFilterMeters = 1,
  });

  final bool highAccuracy;
  final int distanceFilterMeters;
}

abstract interface class ForegroundPosition {
  DateTime get timestamp;
  double get latitude;
  double get longitude;
  double? get accuracy;
  double? get speed;
}

abstract interface class ForegroundLocationAdapter {
  Stream<ForegroundPosition> getPositionStream(
    LocationSettingsRequest settings,
  );
}

class GeolocatorForegroundLocationAdapter implements ForegroundLocationAdapter {
  const GeolocatorForegroundLocationAdapter();

  @override
  Stream<ForegroundPosition> getPositionStream(
    LocationSettingsRequest settings,
  ) {
    final locationSettings = geolocator.LocationSettings(
      accuracy: settings.highAccuracy
          ? geolocator.LocationAccuracy.high
          : geolocator.LocationAccuracy.medium,
      distanceFilter: settings.distanceFilterMeters,
    );
    return geolocator.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).map(_GeolocatorForegroundPosition.new);
  }
}

class RealForegroundRunLocationProvider implements RunLocationProvider {
  RealForegroundRunLocationProvider({
    this.adapter = const GeolocatorForegroundLocationAdapter(),
    this.settings = const LocationSettingsRequest(),
  });

  final ForegroundLocationAdapter adapter;
  final LocationSettingsRequest settings;

  final List<RunLocationReplaySample> _samples = <RunLocationReplaySample>[];
  final Set<RunLocationReplaySample> _consumedSamples =
      <RunLocationReplaySample>{};
  StreamSubscription<ForegroundPosition>? _subscription;
  DateTime? _resumedAt;
  Duration _activeOffsetAtResume = Duration.zero;
  bool _isActive = false;

  @override
  Future<void> start({required DateTime startedAt}) async {
    await stop();
    _samples.clear();
    _consumedSamples.clear();
    _resumedAt = startedAt;
    _activeOffsetAtResume = Duration.zero;
    _isActive = true;
    _subscription = adapter.getPositionStream(settings).listen(_handlePosition);
  }

  @override
  Future<void> pause() async {
    _isActive = false;
    _samples.clear();
    _consumedSamples.clear();
  }

  @override
  Future<void> resume({
    required DateTime resumedAt,
    required Duration activeOffset,
  }) async {
    _resumedAt = resumedAt;
    _activeOffsetAtResume = activeOffset;
    _isActive = true;
  }

  @override
  Future<void> stop() async {
    _isActive = false;
    _resumedAt = null;
    await _subscription?.cancel();
    _subscription = null;
    _samples.clear();
    _consumedSamples.clear();
  }

  @override
  Iterable<RunLocationSample> samplesBetween({
    required Duration fromActiveOffset,
    required Duration toActiveOffset,
    required DateTime startedAt,
  }) {
    final entries = <RunLocationReplaySample>[];
    for (final entry in _samples) {
      if (_consumedSamples.contains(entry)) {
        continue;
      }
      if (entry.activeOffset > toActiveOffset) {
        break;
      }

      entries.add(entry);
      _consumedSamples.add(entry);
    }
    return entries.map((entry) => entry.sample).toList();
  }

  void _handlePosition(ForegroundPosition position) {
    final resumedAt = _resumedAt;
    if (!_isActive || resumedAt == null) {
      return;
    }

    final offsetSinceResume = position.timestamp.difference(resumedAt);
    if (offsetSinceResume < Duration.zero) {
      return;
    }

    final entry = RunLocationReplaySample(
      activeOffset: _activeOffsetAtResume + offsetSinceResume,
      sample: RunLocationSample(
        recordedAt: position.timestamp,
        latitude: position.latitude,
        longitude: position.longitude,
        horizontalAccuracyMeters: position.accuracy,
        speedMetersPerSecond: position.speed,
      ),
    );
    final insertIndex = _samples.indexWhere(
      (sample) => sample.activeOffset > entry.activeOffset,
    );
    if (insertIndex == -1) {
      _samples.add(entry);
    } else {
      _samples.insert(insertIndex, entry);
    }
  }
}

class _GeolocatorForegroundPosition implements ForegroundPosition {
  const _GeolocatorForegroundPosition(this._position);

  final geolocator.Position _position;

  @override
  DateTime get timestamp => _position.timestamp;

  @override
  double get latitude => _position.latitude;

  @override
  double get longitude => _position.longitude;

  @override
  double? get accuracy => _position.accuracy;

  @override
  double? get speed => _position.speed;
}
