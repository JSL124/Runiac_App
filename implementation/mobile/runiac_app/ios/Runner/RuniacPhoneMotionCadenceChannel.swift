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
        result("granted")
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
      events(FlutterEndOfEventStream)
      return nil
    }

    baselineSteps = nil
    baselineDate = nil
    eventSink = events
    pedometer.startUpdates(from: Date()) { [weak self] data, error in
      guard let self = self, error == nil, let data = data else { return }
      guard let cadence = self.cadence(from: data) else { return }
      DispatchQueue.main.async {
        events([
          "recordedAtMillis": self.millisecondsSinceEpoch(Date()),
          "stepsPerMinute": cadence,
          "confidence": "estimated",
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
      return nil
    }
    return cadence
  }

  private func millisecondsSinceEpoch(_ date: Date) -> Int64 {
    return Int64((date.timeIntervalSince1970 * 1000).rounded())
  }
}
