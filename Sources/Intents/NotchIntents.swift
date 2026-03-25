import Foundation
import AppIntents

// MARK: - Get Notch Info Intent

struct GetNotchInfoIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Notch Info"
    static var description = IntentDescription("Returns current notch bar information")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get notch info")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let battery = getBatteryLevel()
        let weather = getWeatherInfo()
        return .result(value: "Battery: \(battery)%, Weather: \(weather)")
    }
    
    private func getBatteryLevel() -> Int {
        return 85 // Would get from system
    }
    
    private func getWeatherInfo() -> String {
        return "72°F Sunny"
    }
}

// MARK: - Set Notch Mode Intent

struct SetNotchModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Notch Mode"
    static var description = IntentDescription("Changes the notch bar mode")
    
    @Parameter(title: "Mode")
    var mode: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Set notch mode to \(\.$mode)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        UserDefaults.standard.set(mode, forKey: "currentNotchMode")
        return .result(dialog: "Notch mode set to \(mode)")
    }
}

// MARK: - Toggle Notch Item Intent

struct ToggleNotchItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Notch Item"
    static var description = IntentDescription("Toggles an item in the notch bar")
    
    @Parameter(title: "Item Type")
    var itemType: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Toggle \(\.$itemType) in notch bar")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: "Toggled \(itemType) in notch bar")
    }
}

// MARK: - App Shortcuts Provider

struct NotchShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetNotchInfoIntent(),
            phrases: [
                "Get notch info in \(.applicationName)",
                "Show notch status in \(.applicationName)"
            ],
            shortTitle: "Get Notch Info",
            systemImageName: "rectangle.inset.filled"
        )
        
        AppShortcut(
            intent: SetNotchModeIntent(),
            phrases: [
                "Set notch mode in \(.applicationName)",
                "Change notch bar in \(.applicationName)"
            ],
            shortTitle: "Set Notch Mode",
            systemImageName: "slider.horizontal.3"
        )
    }
}
