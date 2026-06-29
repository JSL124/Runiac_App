import CoreMotion
import Flutter
import UIKit

final class RuniacPhoneMotionCadenceChannel: NSObject, FlutterStreamHandler {
  private static let methodChannelName = "runiac/phone_motion_cadence"
  private static let eventChannelName = "runiac/phone_motion_cadence_events"
  private static let cadenceWindowSeconds: TimeInterval = 15
  private static let minimumWindowSteps = 6
  private static let minimumCadenceSpm = 120
  private static let maximumCadenceSpm = 220

  private let pedometer: CMPedometer
  private var eventSink: FlutterEventSink?
  private var baselineSteps: Int?
  private var baselineDate: Date?
  private var acceptedCadenceCount = 0
  private var filteredCadenceCount = 0
  private var nativeErrorCount = 0

  init(pedometer: CMPedometer = CMPedometer()) {
    self.pedometer = pedometer
  }

  static func register(with messenger: FlutterBinaryMessenger) {
    let methodChannel = FlutterMethodChannel(
      name: methodChannelName,
      binaryMessenger: messenger
    )
    let eventChannel = FlutterEventChannel(
      name: eventChannelName,
      binaryMessenger: messenger
    )
    let handler = RuniacPhoneMotionCadenceChannel()
    methodChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "isAvailable":
        result(CMPedometer.isStepCountingAvailable())
      case "requestPermission":
        result(Self.permissionStatus())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    eventChannel.setStreamHandler(handler)
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    guard CMPedometer.isStepCountingAvailable() else {
      events(Self.diagnosticEvent(
        reason: "unavailable",
        availabilityStatus: "unavailable"
      ))
      events(FlutterEndOfEventStream)
      return nil
    }

    baselineSteps = nil
    baselineDate = nil
    acceptedCadenceCount = 0
    filteredCadenceCount = 0
    nativeErrorCount = 0
    eventSink = events
    pedometer.startUpdates(from: Date()) { [weak self] data, error in
      guard let self = self else { return }
      if let error = error {
        self.nativeErrorCount += 1
        self.emitDiagnostic(
          reason: "nativeError",
          errorCode: String(describing: type(of: error)),
          errorMessage: error.localizedDescription
        )
        return
      }
      guard let data = data else {
        self.emitDiagnostic(reason: "nilData")
        return
      }
      guard let cadence = self.cadence(from: data) else { return }
      self.acceptedCadenceCount += 1
      DispatchQueue.main.async {
        events([
          "type": "sample",
          "recordedAtMillis": self.millisecondsSinceEpoch(Date()),
          "stepsPerMinute": cadence,
          "confidence": "estimated",
          "acceptedCadenceCount": self.acceptedCadenceCount,
          "filteredCadenceCount": self.filteredCadenceCount,
        ])
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    pedometer.stopUpdates()
    baselineSteps = nil
    baselineDate = nil
    eventSink = nil
    return nil
  }

  private func cadence(from data: CMPedometerData) -> Int? {
    if #available(iOS 10.0, *), let currentCadence = data.currentCadence {
      let cadence = Int((currentCadence.doubleValue * 60).rounded())
      return validCadence(cadence)
    }

    let steps = data.numberOfSteps.intValue
    if baselineSteps == nil || baselineDate == nil {
      baselineSteps = steps
      baselineDate = data.startDate
      return nil
    }

    guard let baselineSteps = baselineSteps, let baselineDate = baselineDate else {
      return nil
    }
    let stepDelta = steps - baselineSteps
    let elapsedSeconds = data.endDate.timeIntervalSince(baselineDate)
    guard stepDelta >= Self.minimumWindowSteps,
          elapsedSeconds >= Self.cadenceWindowSeconds
    else {
      return nil
    }

    self.baselineSteps = steps
    self.baselineDate = data.endDate
    let cadence = Int((Double(stepDelta) / elapsedSeconds * 60).rounded())
    return validCadence(cadence)
  }

  private func validCadence(_ cadence: Int) -> Int? {
    guard cadence >= Self.minimumCadenceSpm,
          cadence <= Self.maximumCadenceSpm
    else {
      filteredCadenceCount += 1
      emitDiagnostic(reason: "filteredOutOfRange", cadence: cadence)
      return nil
    }
    return cadence
  }

  private static func permissionStatus() -> String {
    if #available(iOS 11.0, *) {
      switch CMPedometer.authorizationStatus() {
      case .authorized:
        return "granted"
      case .denied:
        return "denied"
      case .restricted:
        return "restricted"
      case .notDetermined:
        return "unknown"
      @unknown default:
        return "unknown"
      }
    }
    return "unknown"
  }

  private func emitDiagnostic(
    reason: String,
    cadence: Int? = nil,
    errorCode: String? = nil,
    errorMessage: String? = nil
  ) {
    let event = Self.diagnosticEvent(
      reason: reason,
      availabilityStatus: "available",
      cadence: cadence,
      acceptedCadenceCount: acceptedCadenceCount,
      filteredCadenceCount: filteredCadenceCount,
      nativeErrorCount: nativeErrorCount,
      errorCode: errorCode,
      errorMessage: errorMessage
    )
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(event)
    }
  }

  private static func diagnosticEvent(
    reason: String,
    availabilityStatus: String? = nil,
    cadence: Int? = nil,
    acceptedCadenceCount: Int? = nil,
    filteredCadenceCount: Int? = nil,
    nativeErrorCount: Int? = nil,
    errorCode: String? = nil,
    errorMessage: String? = nil
  ) -> [String: Any] {
    var event: [String: Any] = [
      "type": "diagnostic",
      "reason": reason,
    ]
    if let availabilityStatus = availabilityStatus {
      event["availabilityStatus"] = availabilityStatus
    }
    if let cadence = cadence {
      event["stepsPerMinute"] = cadence
    }
    if let acceptedCadenceCount = acceptedCadenceCount {
      event["acceptedCadenceCount"] = acceptedCadenceCount
    }
    if let filteredCadenceCount = filteredCadenceCount {
      event["filteredCadenceCount"] = filteredCadenceCount
    }
    if let nativeErrorCount = nativeErrorCount {
      event["nativeErrorCount"] = nativeErrorCount
    }
    if let errorCode = errorCode {
      event["errorCode"] = errorCode
    }
    if let errorMessage = errorMessage {
      event["errorMessage"] = errorMessage
    }
    return event
  }

  private func millisecondsSinceEpoch(_ date: Date) -> Int64 {
    return Int64((date.timeIntervalSince1970 * 1000).rounded())
  }
}
