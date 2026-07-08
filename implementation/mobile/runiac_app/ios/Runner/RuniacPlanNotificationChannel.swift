import Flutter
import Foundation
import UserNotifications

final class RuniacPlanNotificationChannel {
  private static let channelName = "runiac/plan_notifications"
  private static let scheduledIdsKey = "runiac.planNotificationIds"

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    let scheduler = RuniacPlanNotificationChannel()
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "requestPermission":
        scheduler.requestPermission(arguments: call.arguments, result: result)
      case "syncPlanNotifications":
        scheduler.syncPlanNotifications(arguments: call.arguments, result: result)
      case "schedulePlanNotification":
        scheduler.schedulePlanNotification(arguments: call.arguments, result: result)
      case "cancelPlanNotifications":
        scheduler.cancelPlanNotifications()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func requestPermission(arguments: Any?, result: @escaping FlutterResult) {
    let debugLogs = debugLogsEnabled(arguments)
    log("requestPermission requested", enabled: debugLogs)
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      granted, error in
      DispatchQueue.main.async {
        if let error = error {
          self.log("requestPermission error=\(error.localizedDescription)", enabled: debugLogs)
        }
        self.log("requestPermission granted=\(granted)", enabled: debugLogs)
        result(granted ? "granted" : "denied")
      }
    }
  }

  private func syncPlanNotifications(arguments: Any?, result: @escaping FlutterResult) {
    let notifications = notificationsFromArguments(arguments)
    let debugLogs = debugLogsEnabled(arguments)
    log("syncPlanNotifications parsedCount=\(notifications.count)", enabled: debugLogs)
    cancelPlanNotifications()
    saveScheduledIds(notifications.map(\.id))
    let center = UNUserNotificationCenter.current()
    for notification in notifications where notification.scheduledAt > Date() {
      add(notification, center: center, debugLogs: debugLogs)
    }
    logPendingRequests(context: "syncPlanNotifications", enabled: debugLogs)
    result(nil)
  }

  private func schedulePlanNotification(arguments: Any?, result: @escaping FlutterResult) {
    let debugLogs = debugLogsEnabled(arguments)
    guard let notification = notificationFromItem(arguments) else {
      log("schedulePlanNotification ignored: invalid arguments", enabled: debugLogs)
      result(nil)
      return
    }
    guard notification.scheduledAt > Date() else {
      log(
        "schedulePlanNotification ignored: past date id=\(notification.id) scheduledAt=\(notification.scheduledAt)",
        enabled: debugLogs
      )
      result(nil)
      return
    }

    let center = UNUserNotificationCenter.current()
    add(notification, center: center, debugLogs: debugLogs)
    logPendingRequests(context: "schedulePlanNotification", enabled: debugLogs)
    result(nil)
  }

  private func add(
    _ notification: PlanNotificationPayload,
    center: UNUserNotificationCenter,
    debugLogs: Bool
  ) {
    let request = requestFor(notification)
    log(
      "add id=\(notification.id) scheduledAt=\(notification.scheduledAt) timeInterval=\(notification.scheduledAt.timeIntervalSinceNow)",
      enabled: debugLogs
    )
    center.add(request) { error in
      if let error = error {
        self.log("add error id=\(notification.id) error=\(error.localizedDescription)", enabled: debugLogs)
        return
      }
      self.log("add success id=\(notification.id)", enabled: debugLogs)
      self.logPendingRequests(context: "add completion", enabled: debugLogs)
    }
  }

  private func requestFor(_ notification: PlanNotificationPayload) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = notification.title
    content.body = notification.body
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: max(1, notification.scheduledAt.timeIntervalSinceNow),
      repeats: false
    )
    return UNNotificationRequest(
      identifier: notification.id,
      content: content,
      trigger: trigger
    )
  }

  private func cancelPlanNotifications() {
    let ids = scheduledIds()
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    UserDefaults.standard.set([], forKey: Self.scheduledIdsKey)
  }

  private func notificationsFromArguments(_ arguments: Any?) -> [PlanNotificationPayload] {
    guard let root = arguments as? [String: Any],
          let items = root["notifications"] as? [[String: Any]]
    else {
      return []
    }
    return items.compactMap(notificationFromItem)
  }

  private func notificationFromItem(_ item: Any?) -> PlanNotificationPayload? {
    guard let item = item as? [String: Any],
          let id = item["id"] as? String,
          let title = item["title"] as? String,
          let body = item["body"] as? String,
          let scheduledAtMillis = item["scheduledAtMillis"] as? NSNumber
    else {
      return nil
    }
    return PlanNotificationPayload(
      id: id,
      title: title,
      body: body,
      scheduledAt: Date(timeIntervalSince1970: scheduledAtMillis.doubleValue / 1000)
    )
  }

  private func scheduledIds() -> [String] {
    UserDefaults.standard.stringArray(forKey: Self.scheduledIdsKey) ?? []
  }

  private func saveScheduledIds(_ ids: [String]) {
    UserDefaults.standard.set(ids, forKey: Self.scheduledIdsKey)
  }

  private func debugLogsEnabled(_ arguments: Any?) -> Bool {
    guard let root = arguments as? [String: Any],
          let debugLogs = root["debugLogs"] as? Bool
    else {
      return false
    }
    return debugLogs
  }

  private func log(_ message: String, enabled: Bool) {
    if enabled {
      NSLog("[RuniacLocalNotifications][iOS] \(message)")
    }
  }

  private func logPendingRequests(context: String, enabled: Bool) {
    guard enabled else {
      return
    }
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
      let identifiers = requests.map(\.identifier).joined(separator: ",")
      self.log("pendingRequests context=\(context) count=\(requests.count) ids=[\(identifiers)]", enabled: true)
    }
  }
}

private struct PlanNotificationPayload {
  let id: String
  let title: String
  let body: String
  let scheduledAt: Date
}
