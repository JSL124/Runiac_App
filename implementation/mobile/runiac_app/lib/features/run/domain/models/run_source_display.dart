enum RunSourceType {
  runiacGps,
  appleHealth,
  healthConnect,
  garminViaHealth,
  demoImport,
}

extension RunSourceTypeDisplay on RunSourceType {
  String get label {
    return switch (this) {
      RunSourceType.runiacGps => 'Runiac GPS',
      RunSourceType.appleHealth => 'Apple Health',
      RunSourceType.healthConnect => 'Health Connect',
      RunSourceType.garminViaHealth => 'Garmin via Health',
      RunSourceType.demoImport => 'Demo import',
    };
  }
}

enum HeartRateAvailability {
  available,
  unavailableNoSensor,
  unavailableNotShared,
}

extension HeartRateAvailabilityDisplay on HeartRateAvailability {
  bool get isAvailable => this == HeartRateAvailability.available;

  String? get helperText {
    return switch (this) {
      HeartRateAvailability.available => null,
      HeartRateAvailability.unavailableNoSensor =>
        'Heart rate unavailable for Runiac GPS runs.',
      HeartRateAvailability.unavailableNotShared =>
        'Heart rate was not shared by this source.',
    };
  }
}
