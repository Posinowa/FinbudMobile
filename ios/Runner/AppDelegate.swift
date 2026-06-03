import Flutter
import UIKit
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Tüm URL scheme çağrılarını işler (Google Sign-In + finbud:// deep link)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Önce Google Sign-In'e ver, Google'a aitse o işler
    if GIDSignIn.sharedInstance.handle(url) { return true }
    // Google'a ait değilse (örn: finbud://) Flutter plugin sistemine devret
    // app_links paketi buradan URL'i alır ve main.dart'taki _handleDeepLink'i tetikler
    return super.application(app, open: url, options: options)
  }
}
