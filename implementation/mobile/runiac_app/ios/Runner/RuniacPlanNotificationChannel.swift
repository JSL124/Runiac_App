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
        scheduler.requestPermission(result: result)
      case "syncPlanNotifications":
        scheduler.syncPlanNotifications(arguments: call.arguments, result: result)
      case "cancelPlanNotifications":
        scheduler.cancelPlanNotifications()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func requestPermission(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      granted, _ in
      DispatchQueue.main.async {
        result(granted ? "granted" : "denied")
      }
    }
  }

  private func syncPlanNotifications(arguments: Any?, result: @escaping FlutterResult) {
    let notifications = notificationsFromArguments(arguments)
    cancelPlanNotifications()
    saveScheduledIds(notifications.map(\.id))
    let center = UNUserNotificationCenter.current()
    for notification in notifications where notification.scheduledAt > Date() {
      let content = UNMutableNotificationContent()
      content.title = notification.title
      content.body = notification.body
      content.sound = .default

      let components = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute],
        from: notification.scheduledAt
      )
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      let request = UNNotificationRequest(
        identifier: notification.id,
        content: content,
        trigger: trigger
      )
      center.add(request)
    }
    result(nil)
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
    return items.compactMap { item in
      guard let id = item["id"] as? String,
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
  }

  private func scheduledIds() -> [String] {
    UserDefaults.standard.stringArray(forKey: Self.scheduledIdsKey) ?? []
  }

  private func saveScheduledIds(_ ids: [String]) {
    UserDefaults.standard.set(ids, forKey: Self.scheduledIdsKey)
  }
}

private struct PlanNotificationPayload {
  let id: String
  let title: String
  let body: String
  let scheduledAt: Date
}
