import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "RuniacLiveActivityChannel"
    ) else { return }
    RuniacLiveActivityChannel.register(with: registrar.messenger())
    RuniacHealthKitImportChannel.register(with: registrar.messenger())
    RuniacPhoneMotionCadenceChannel.register(with: registrar.messenger())
  }
}
