import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/run/domain/models/run_location_permission_status.dart';
import 'package:runiac_app/features/run/domain/repositories/run_location_permission_service.dart';

class _FakePermissionService implements RunLocationPermissionService {
  _FakePermissionService(this._statuses);

  final List<RunLocationPermissionStatus> _statuses;
  int _index = 0;

  @override
  Future<RunLocationPermissionStatus> checkStatus() async {
    return _statuses[_index.clamp(0, _statuses.length - 1)];
  }

  @override
  Future<RunLocationPermissionStatus> requestPermission() async {
    _index += 1;
    return _statuses[_index.clamp(0, _statuses.length - 1)];
  }
}

void main() {
  group('RunLocationPermissionStatus', () {
    test('models all M4-B foreground permission states', () {
      expect(RunLocationPermissionStatus.values, [
        RunLocationPermissionStatus.checking,
        RunLocationPermissionStatus.granted,
        RunLocationPermissionStatus.denied,
        RunLocationPermissionStatus.deniedForever,
        RunLocationPermissionStatus.serviceDisabled,
        RunLocationPermissionStatus.unavailable,
      ]);
    });

    test('exposes beginner-friendly guidance copy', () {
      expect(RunLocationPermissionStatus.denied.message, contains('Try again'));
      expect(
        RunLocationPermissionStatus.deniedForever.message,
        contains('settings'),
      );
      expect(
        RunLocationPermissionStatus.serviceDisabled.message,
        contains('GPS'),
      );
      expect(
        RunLocationPermissionStatus.unavailable.message,
        contains('not available'),
      );
    });

    test('permission service can be faked without platform APIs', () async {
      final service = _FakePermissionService([
        RunLocationPermissionStatus.denied,
        RunLocationPermissionStatus.granted,
      ]);

      expect(await service.checkStatus(), RunLocationPermissionStatus.denied);
      expect(
        await service.requestPermission(),
        RunLocationPermissionStatus.granted,
      );
    });
  });
}
