import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/data/real_foreground_run_location_provider.dart';
import 'package:runiac_app/features/run/domain/services/local_run_tracking_session.dart';

void main() {
  _ForegroundPosition position({
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
  }) {
    return _ForegroundPosition(
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      speed: speed,
    );
  }

  group('RealForegroundRunLocationProvider', () {
    test('maps foreground positions into local run samples', () async {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final adapter = _FakeForegroundAdapter();
      final provider = RealForegroundRunLocationProvider(adapter: adapter);

      await provider.start(startedAt: startedAt);
      adapter.emit(
        position(
          timestamp: startedAt,
          latitude: 1.300000,
          longitude: 103.800000,
          accuracy: 6,
          speed: 2.4,
        ),
      );
      adapter.emit(
        position(
          timestamp: startedAt.add(const Duration(seconds: 60)),
          latitude: 1.300899,
          longitude: 103.800000,
          accuracy: 7,
          speed: 2.5,
        ),
      );

      final samples = provider
          .samplesBetween(
            fromActiveOffset: Duration.zero,
            toActiveOffset: const Duration(seconds: 60),
            startedAt: startedAt,
          )
          .toList();

      expect(samples, hasLength(2));
      expect(samples.first.latitude, 1.300000);
      expect(samples.first.longitude, 103.800000);
      expect(samples.first.horizontalAccuracyMeters, 6);
      expect(samples.first.speedMetersPerSecond, 2.4);
      expect(
        samples.last.recordedAt,
        startedAt.add(const Duration(seconds: 60)),
      );
    });

    test('drains a late sample from an already-passed active window', () async {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final adapter = _FakeForegroundAdapter();
      final provider = RealForegroundRunLocationProvider(adapter: adapter);

      await provider.start(startedAt: startedAt);

      expect(
        provider.samplesBetween(
          fromActiveOffset: Duration.zero,
          toActiveOffset: const Duration(seconds: 10),
          startedAt: startedAt,
        ),
        isEmpty,
      );

      adapter.emit(
        position(
          timestamp: startedAt.add(const Duration(seconds: 5)),
          latitude: 1.300100,
          longitude: 103.800000,
          accuracy: 6,
        ),
      );

      final samples = provider
          .samplesBetween(
            fromActiveOffset: const Duration(seconds: 10),
            toActiveOffset: const Duration(seconds: 11),
            startedAt: startedAt,
          )
          .toList();

      expect(samples, hasLength(1));
      expect(
        samples.single.recordedAt,
        startedAt.add(const Duration(seconds: 5)),
      );
      expect(samples.single.latitude, 1.300100);
    });

    test('drains multiple late samples in order and only once', () async {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final adapter = _FakeForegroundAdapter();
      final provider = RealForegroundRunLocationProvider(adapter: adapter);

      await provider.start(startedAt: startedAt);
      provider
          .samplesBetween(
            fromActiveOffset: Duration.zero,
            toActiveOffset: const Duration(seconds: 10),
            startedAt: startedAt,
          )
          .toList();

      adapter.emit(
        position(
          timestamp: startedAt.add(const Duration(seconds: 8)),
          latitude: 1.300800,
          longitude: 103.800000,
        ),
      );
      adapter.emit(
        position(
          timestamp: startedAt.add(const Duration(seconds: 3)),
          latitude: 1.300300,
          longitude: 103.800000,
        ),
      );

      final firstDrain = provider
          .samplesBetween(
            fromActiveOffset: const Duration(seconds: 10),
            toActiveOffset: const Duration(seconds: 11),
            startedAt: startedAt,
          )
          .toList();
      final secondDrain = provider
          .samplesBetween(
            fromActiveOffset: const Duration(seconds: 11),
            toActiveOffset: const Duration(seconds: 12),
            startedAt: startedAt,
          )
          .toList();

      expect(firstDrain.map((sample) => sample.recordedAt).toList(), [
        startedAt.add(const Duration(seconds: 3)),
        startedAt.add(const Duration(seconds: 8)),
      ]);
      expect(secondDrain, isEmpty);
    });

    test(
      'buffers by active offset and does not emit paused movement',
      () async {
        final startedAt = DateTime.utc(2026, 6, 14, 7);
        final adapter = _FakeForegroundAdapter();
        final provider = RealForegroundRunLocationProvider(adapter: adapter);

        await provider.start(startedAt: startedAt);
        adapter.emit(
          position(timestamp: startedAt, latitude: 1.3, longitude: 103.8),
        );
        adapter.emit(
          position(
            timestamp: startedAt.add(const Duration(seconds: 60)),
            latitude: 1.300899,
            longitude: 103.8,
          ),
        );
        final session = LocalRunTrackingSession(startedAt: startedAt);
        session.advanceBy(
          const Duration(seconds: 60),
          samples: provider.samplesBetween(
            fromActiveOffset: Duration.zero,
            toActiveOffset: const Duration(seconds: 60),
            startedAt: startedAt,
          ),
        );
        await provider.pause();
        session.pause();
        adapter.emit(
          position(
            timestamp: startedAt.add(const Duration(seconds: 120)),
            latitude: 1.400000,
            longitude: 103.8,
          ),
        );
        session.resume();
        await provider.resume(
          resumedAt: startedAt.add(const Duration(seconds: 180)),
          activeOffset: const Duration(seconds: 60),
        );
        adapter.emit(
          position(
            timestamp: startedAt.add(const Duration(seconds: 180)),
            latitude: 1.400000,
            longitude: 103.8,
          ),
        );
        adapter.emit(
          position(
            timestamp: startedAt.add(const Duration(seconds: 240)),
            latitude: 1.400899,
            longitude: 103.8,
          ),
        );

        session.advanceBy(
          const Duration(seconds: 60),
          samples: provider.samplesBetween(
            fromActiveOffset: const Duration(seconds: 60),
            toActiveOffset: const Duration(seconds: 120),
            startedAt: startedAt,
          ),
        );

        expect(session.distanceMeters, closeTo(200, 3));
      },
    );

    test('leaves poor accuracy rejection to LocalRunTrackingSession', () async {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final adapter = _FakeForegroundAdapter();
      final provider = RealForegroundRunLocationProvider(adapter: adapter);
      final session = LocalRunTrackingSession(startedAt: startedAt);

      await provider.start(startedAt: startedAt);
      adapter.emit(
        position(
          timestamp: startedAt,
          latitude: 1.3,
          longitude: 103.8,
          accuracy: 5,
        ),
      );
      adapter.emit(
        position(
          timestamp: startedAt.add(const Duration(seconds: 60)),
          latitude: 1.350000,
          longitude: 103.8,
          accuracy: 250,
        ),
      );
      adapter.emit(
        position(
          timestamp: startedAt.add(const Duration(seconds: 120)),
          latitude: 1.300899,
          longitude: 103.8,
          accuracy: 5,
        ),
      );

      session.advanceBy(
        const Duration(seconds: 120),
        samples: provider.samplesBetween(
          fromActiveOffset: Duration.zero,
          toActiveOffset: const Duration(seconds: 120),
          startedAt: startedAt,
        ),
      );

      expect(session.distanceMeters, closeTo(100, 2));
      expect(session.rejectedSampleCount, 1);
    });

    test('stop cancels safely and clears buffered raw samples', () async {
      final startedAt = DateTime.utc(2026, 6, 14, 7);
      final adapter = _FakeForegroundAdapter();
      final provider = RealForegroundRunLocationProvider(adapter: adapter);

      await provider.start(startedAt: startedAt);
      adapter.emit(
        position(timestamp: startedAt, latitude: 1.3, longitude: 103.8),
      );
      adapter.emit(
        position(
          timestamp: startedAt.add(const Duration(seconds: 60)),
          latitude: 1.300899,
          longitude: 103.8,
        ),
      );

      expect(
        provider.samplesBetween(
          fromActiveOffset: Duration.zero,
          toActiveOffset: const Duration(seconds: 60),
          startedAt: startedAt,
        ),
        hasLength(2),
      );

      await provider.stop();
      await provider.stop();
      adapter.emit(
        position(
          timestamp: startedAt.add(const Duration(seconds: 120)),
          latitude: 1.301798,
          longitude: 103.8,
        ),
      );

      expect(
        provider.samplesBetween(
          fromActiveOffset: Duration.zero,
          toActiveOffset: const Duration(seconds: 120),
          startedAt: startedAt,
        ),
        isEmpty,
      );
    });
  });
}

class _FakeForegroundAdapter implements ForegroundLocationAdapter {
  final _controller = StreamController<ForegroundPosition>.broadcast(
    sync: true,
  );
  LocationSettingsRequest? lastSettings;

  void emit(_ForegroundPosition position) {
    _controller.add(position);
  }

  @override
  Stream<ForegroundPosition> getPositionStream(
    LocationSettingsRequest settings,
  ) {
    lastSettings = settings;
    return _controller.stream;
  }
}

class _ForegroundPosition implements ForegroundPosition {
  const _ForegroundPosition({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
  });

  @override
  final DateTime timestamp;

  @override
  final double latitude;

  @override
  final double longitude;

  @override
  final double? accuracy;

  @override
  final double? speed;
}
