import Flutter
import HealthKit
import UIKit

final class RuniacHealthKitImportChannel {
  private static let channelName = "runiac/healthkit_import"
  private static let defaultLookbackDays = 30
  private static let defaultLimit = 20

  private let healthStore: HKHealthStore

  init(healthStore: HKHealthStore = HKHealthStore()) {
    self.healthStore = healthStore
  }

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    let handler = RuniacHealthKitImportChannel()
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "listRunningWorkouts":
        handler.listRunningWorkouts(arguments: call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func listRunningWorkouts(arguments: Any?, result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable() else {
      result(response(status: "unavailable"))
      return
    }

    guard UIApplication.shared.isProtectedDataAvailable else {
      result(response(status: "protectedDataUnavailable"))
      return
    }

    guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
      result(response(status: "unavailable"))
      return
    }

    let readTypes: Set<HKObjectType> = [
      HKObjectType.workoutType(),
      heartRateType,
    ]

    healthStore.requestAuthorization(toShare: [], read: readTypes) { [weak self] success, _ in
      guard let self = self else { return }
      guard success else {
        result(self.response(status: "permissionDenied"))
        return
      }

      self.queryRunningWorkouts(
        arguments: arguments,
        heartRateType: heartRateType,
        result: result
      )
    }
  }

  private func queryRunningWorkouts(
    arguments: Any?,
    heartRateType: HKQuantityType,
    result: @escaping FlutterResult
  ) {
    let queryBounds = bounds(from: arguments)
    let endDate = Date()
    let startDate = Calendar.current.date(
      byAdding: .day,
      value: -queryBounds.lookbackDays,
      to: endDate
    ) ?? endDate.addingTimeInterval(TimeInterval(-queryBounds.lookbackDays * 24 * 60 * 60))

    let datePredicate = HKQuery.predicateForSamples(
      withStart: startDate,
      end: endDate,
      options: [.strictStartDate]
    )
    let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
      datePredicate,
      runningPredicate,
    ])
    let sortDescriptor = NSSortDescriptor(
      key: HKSampleSortIdentifierStartDate,
      ascending: false
    )

    let query = HKSampleQuery(
      sampleType: HKObjectType.workoutType(),
      predicate: predicate,
      limit: queryBounds.limit,
      sortDescriptors: [sortDescriptor]
    ) { [weak self] _, samples, error in
      guard let self = self else { return }
      guard error == nil else {
        result(self.response(status: "unavailable"))
        return
      }

      let workouts = (samples as? [HKWorkout] ?? []).filter { workout in
        workout.workoutActivityType == .running
      }

      guard !workouts.isEmpty else {
        result(self.response(status: "noData"))
        return
      }

      self.payloads(
        for: workouts,
        heartRateType: heartRateType
      ) { workoutPayloads in
        result(
          self.response(
            status: workoutPayloads.isEmpty ? "noData" : "available",
            workouts: workoutPayloads
          )
        )
      }
    }

    healthStore.execute(query)
  }

  private func payloads(
    for workouts: [HKWorkout],
    heartRateType: HKQuantityType,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    var payloads: [[String: Any]] = []

    func appendPayload(at index: Int) {
      guard index < workouts.count else {
        completion(payloads)
        return
      }

      let workout = workouts[index]
      heartRateAggregate(for: workout, heartRateType: heartRateType) { aggregate in
        if let payload = self.payload(for: workout, heartRate: aggregate) {
          payloads.append(payload)
        }
        appendPayload(at: index + 1)
      }
    }

    appendPayload(at: 0)
  }

  private func heartRateAggregate(
    for workout: HKWorkout,
    heartRateType: HKQuantityType,
    completion: @escaping (HeartRateAggregate?) -> Void
  ) {
    let predicate = HKQuery.predicateForSamples(
      withStart: workout.startDate,
      end: workout.endDate,
      options: []
    )
    let query = HKSampleQuery(
      sampleType: heartRateType,
      predicate: predicate,
      limit: HKObjectQueryNoLimit,
      sortDescriptors: nil
    ) { _, samples, _ in
      let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
      let heartRates = (samples as? [HKQuantitySample] ?? [])
        .map { $0.quantity.doubleValue(for: unit) }
        .filter { $0.isFinite && $0 > 0 }

      guard !heartRates.isEmpty else {
        completion(nil)
        return
      }

      let total = heartRates.reduce(0, +)
      completion(
        HeartRateAggregate(
          averageBpm: total / Double(heartRates.count),
          maxBpm: heartRates.max()
        )
      )
    }

    healthStore.execute(query)
  }

  private func payload(
    for workout: HKWorkout,
    heartRate: HeartRateAggregate?
  ) -> [String: Any]? {
    guard workout.workoutActivityType == .running,
          workout.endDate > workout.startDate,
          workout.duration > 0
    else {
      return nil
    }

    let distanceMeters = workout.totalDistance?.doubleValue(for: HKUnit.meter())
    guard let distanceMeters = distanceMeters, distanceMeters.isFinite, distanceMeters > 0 else {
      return nil
    }

    return [
      "uuid": workout.uuid.uuidString,
      "activityType": "running",
      "sourceName": workout.sourceRevision.source.name,
      "startDateMillis": milliseconds(since1970: workout.startDate),
      "endDateMillis": milliseconds(since1970: workout.endDate),
      "durationSeconds": Int(workout.duration.rounded()),
      "distanceMeters": distanceMeters,
      "activeEnergyKcal": nullable(
        workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie())
      ),
      "averageHeartRateBpm": nullable(heartRate?.averageBpm),
      "maxHeartRateBpm": nullable(heartRate?.maxBpm),
    ]
  }

  private func bounds(from arguments: Any?) -> QueryBounds {
    guard let arguments = arguments as? [String: Any] else {
      return QueryBounds(lookbackDays: Self.defaultLookbackDays, limit: Self.defaultLimit)
    }

    let lookbackDays = clampedPositiveInt(
      arguments["lookbackDays"],
      fallback: Self.defaultLookbackDays,
      max: 30
    )
    let limit = clampedPositiveInt(
      arguments["limit"],
      fallback: Self.defaultLimit,
      max: 20
    )

    return QueryBounds(lookbackDays: lookbackDays, limit: limit)
  }

  private func clampedPositiveInt(_ value: Any?, fallback: Int, max: Int) -> Int {
    guard let number = value as? NSNumber else {
      return fallback
    }

    let intValue = number.intValue
    guard intValue > 0 else {
      return fallback
    }

    return min(intValue, max)
  }

  private func response(
    status: String,
    workouts: [[String: Any]] = []
  ) -> [String: Any] {
    [
      "status": status,
      "workouts": workouts,
    ]
  }

  private func nullable(_ value: Double?) -> Any {
    guard let value = value, value.isFinite else {
      return NSNull()
    }
    return value
  }

  private func milliseconds(since1970 date: Date) -> Int {
    Int((date.timeIntervalSince1970 * 1000).rounded())
  }
}

private struct QueryBounds {
  let lookbackDays: Int
  let limit: Int
}

private struct HeartRateAggregate {
  let averageBpm: Double
  let maxBpm: Double?
}
