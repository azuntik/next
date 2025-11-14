import AppIntents
import Foundation

@available(iOS 16.0, *)
struct FrictionIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause & Reflect"
    static var description: IntentDescription = IntentDescription("Take a moment to reflect before opening an app")

    static var openAppWhenRun: Bool = true

    @Parameter(title: "App Name", description: "The app you're about to open", default: "this app")
    var appName: String?

    func perform() async throws -> some IntentResult {
        // Notify Flutter to show friction moment
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowFrictionMoment"),
            object: nil,
            userInfo: ["appName": appName ?? "manual_trigger"]
        )

        return .result()
    }
}

@available(iOS 16.0, *)
struct FrictionShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FrictionIntent(),
            phrases: [
                "Pause and reflect with \(.applicationName)",
                "Take a mindful moment with \(.applicationName)",
                "Check my intentions with \(.applicationName)"
            ],
            shortTitle: "Pause & Reflect",
            systemImageName: "pause.circle"
        )
    }
}
