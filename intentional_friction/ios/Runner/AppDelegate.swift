import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var methodChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController

        // Setup method channel for communication with Flutter
        methodChannel = FlutterMethodChannel(
            name: "com.intentionalfriction/shortcuts",
            binaryMessenger: controller.binaryMessenger
        )

        // Listen for App Intent notifications
        if #available(iOS 16.0, *) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleFrictionIntent(_:)),
                name: NSNotification.Name("ShowFrictionMoment"),
                object: nil
            )
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Handle URL schemes (intentionalfriction://trigger)
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if url.scheme == "intentionalfriction" {
            if url.host == "trigger" {
                // Extract app name from query parameters if present
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let appName = components?.queryItems?.first(where: { $0.name == "app" })?.value ?? "manual_trigger"

                // Notify Flutter to show friction moment
                methodChannel?.invokeMethod("showFriction", arguments: ["appName": appName])
                return true
            }
        }
        return super.application(app, open: url, options: options)
    }

    // Handle App Intent notification (iOS 16+)
    @available(iOS 16.0, *)
    @objc private func handleFrictionIntent(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let appName = userInfo["appName"] as? String {
            methodChannel?.invokeMethod("showFriction", arguments: ["appName": appName])
        }
    }
}
