import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  if call.method == "getUptimeMillis" {
    let uptime = ProcessInfo.processInfo.systemUptime * 1000 // ✅ monotonic
    result(Int(uptime))
  }
}
