import 'dart:async';

import 'package:geolocator/geolocator.dart' as geolocator;

import '../domain/models/run_location_sample.dart';
import '../domain/models/run_tracking_diagnostics.dart';
import '../domain/repositories/run_location_preview_provider.dart';
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
  Future<ForegroundPosition> getCurrentPosition(
    LocationSettingsRequest settings,
  );

  Stream<ForegroundPosition> getPositionStream(
    LocationSettingsRequest settings,
  );

  Future<RunTrackingLocationAccuracyStatus> getLocationAccuracyStatus();
}

class GeolocatorForegroundLocationAdapter implements ForegroundLocationAdapter {
  const GeolocatorForegroundLocationAdapter();

  @override
  Future<ForegroundPosition> getCurrentPosition(
    LocationSettingsRequest settings,
  ) async {
    final position = await geolocator.Geolocator.getCurrentPosition(
      locationSettings: _locationSettingsFor(settings),
    );
    return _GeolocatorForegroundPosition(position);
  }

  @override
  Stream<ForegroundPosition> getPositionStream(
    LocationSettingsRequest settings,
  ) {
    return geolocator.Geolocator.getPositionStream(
      locationSettings: _locationSettingsFor(settings),
    ).map(_GeolocatorForegroundPosition.new);
  }

  @override
  Future<RunTrackingLocationAccuracyStatus> getLocationAccuracyStatus() async {
    final status = await geolocator.Geolocator.getLocationAccuracy();
    return switch (status) {
      geolocator.LocationAccuracyStatus.precise =>
        RunTrackingLocationAccuracyStatus.precise,
      geolocator.LocationAccuracyStatus.reduced =>
        RunTrackingLocationAccuracyStatus.reduced,
      geolocator.LocationAccuracyStatus.unknown =>
        RunTrackingLocationAccuracyStatus.unknown,
    };
  }

  geolocator.LocationSettings _locationSettingsFor(
    LocationSettingsRequest settings,
  ) {
    return geolocator.LocationSettings(
      accuracy: settings.highAccuracy
          ? geolocator.LocationAccuracy.high
          : geolocator.LocationAccuracy.medium,
      distanceFilter: settings.distanceFilterMeters,
    );
  }
}

class RealForegroundRunLocationPreviewProvider
    implements RunLocationPreviewProvider {
  const RealForegroundRunLocationPreviewProvider({
    this.adapter = const GeolocatorForegroundLocationAdapter(),
    this.settings = const LocationSettingsRequest(),
  });

  final ForegroundLocationAdapter adapter;
  final LocationSettingsRequest settings;

  @override
  Future<RunLocationSample> currentLocation() async {
    final position = await adapter.getCurrentPosition(settings);
    return RunLocationSample(
      recordedAt: position.timestamp,
      latitude: position.latitude,
      longitude: position.longitude,
      horizontalAccuracyMeters: position.accuracy,
      speedMetersPerSecond: position.speed,
    );
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
  RunTrackingLocationAccuracyStatus _locationAccuracyStatus =
      RunTrackingLocationAccuracyStatus.notChecked;

  @override
  RunTrackingLocationAccuracyStatus get locationAccuracyStatus =>
      _locationAccuracyStatus;

  @override
  Future<void> start({required DateTime startedAt}) async {
    await stop();
    _samples.clear();
    _consumedSamples.clear();
    _resumedAt = startedAt;
    _activeOffsetAtResume = Duration.zero;
    _isActive = true;
    _locationAccuracyStatus = await _readLocationAccuracyStatus();
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
    _locationAccuracyStatus = RunTrackingLocationAccuracyStatus.notChecked;
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

  Future<RunTrackingLocationAccuracyStatus>
  _readLocationAccuracyStatus() async {
    try {
      return await adapter.getLocationAccuracyStatus();
    } on Object {
      return RunTrackingLocationAccuracyStatus.unknown;
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
