import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var previewOverlay: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    self.showPrivacyOverlay()
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    self.hidePrivacyOverlay()
  }

  private func showPrivacyOverlay() {
    if previewOverlay == nil {
      if let window = UIApplication.shared.windows.first {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewOverlay = blurEffectView
        window.addSubview(previewOverlay!)
      }
    }
  }

  private func hidePrivacyOverlay() {
    previewOverlay?.removeFromSuperview()
    previewOverlay = nil
  }
}
