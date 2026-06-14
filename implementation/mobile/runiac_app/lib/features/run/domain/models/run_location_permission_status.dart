enum RunLocationPermissionStatus {
  checking,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  unavailable,
}

extension RunLocationPermissionStatusCopy on RunLocationPermissionStatus {
  String get message {
    return switch (this) {
      RunLocationPermissionStatus.checking =>
        'Checking GPS permission for your run.',
      RunLocationPermissionStatus.granted => 'GPS is ready for your run.',
      RunLocationPermissionStatus.denied =>
        'GPS helps Runiac measure distance and pace. Try again when you are ready.',
      RunLocationPermissionStatus.deniedForever =>
        'Location is blocked. Open settings to allow location while using Runiac.',
      RunLocationPermissionStatus.serviceDisabled =>
        'Turn on GPS to track distance and pace during your run.',
      RunLocationPermissionStatus.unavailable =>
        'GPS tracking is not available on this device right now.',
    };
  }

  bool get canStartRun => this == RunLocationPermissionStatus.granted;
}
