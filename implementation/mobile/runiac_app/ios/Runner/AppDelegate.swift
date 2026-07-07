import Flutter
import GoogleSignIn
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }

    return super.application(application, open: url, options: options)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "RuniacLiveActivityChannel"
    ) else { return }
    RuniacLiveActivityChannel.register(with: registrar.messenger())
    RuniacHealthKitImportChannel.register(with: registrar.messenger())
    RuniacPhoneMotionCadenceChannel.register(with: registrar.messenger())
    RuniacPlanNotificationChannel.register(with: registrar.messenger())
  }
}
