import Foundation
import WidgetKit

// MARK: - Widget Data Service

final class WidgetDataService: ObservableObject {
    static let shared = WidgetDataService()
    
    private let appGroupId = "group.com.bou.notch"
    
    @Published var currentNotchBarItems: [NotchBarItem] = []
    
    private init() {
        loadCurrentItems()
    }
    
    func loadCurrentItems() {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let data = defaults.data(forKey: "notchBarItems"),
              let items = try? JSONDecoder().decode([NotchBarItem].self, from: data) else {
            currentNotchBarItems = [
                NotchBarItem(id: UUID(), type: .battery, isEnabled: true),
                NotchBarItem(id: UUID(), type: .date, isEnabled: true),
                NotchBarItem(id: UUID(), type: .weather, isEnabled: true)
            ]
            return
        }
        currentNotchBarItems = items
    }
    
    func saveItems(_ items: [NotchBarItem]) {
        currentNotchBarItems = items
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let data = try? JSONEncoder().encode(items) else {
            return
        }
        defaults.set(data, forKey: "notchBarItems")
        
        // Trigger widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getWidgetData() -> WidgetData {
        WidgetData(
            batteryLevel: getBatteryLevel(),
            weather: getWeatherData(),
            nextEvent: getNextCalendarEvent(),
            currentMode: getCurrentMode()
        )
    }
    
    private func getBatteryLevel() -> Int {
        return 85 // Would get from IOKit
    }
    
    private func getWeatherData() -> WeatherData? {
        return nil // Would get from WeatherService
    }
    
    private func getNextCalendarEvent() -> String? {
        return nil // Would get from EventKit
    }
    
    private func getCurrentMode() -> String {
        return UserDefaults.standard.string(forKey: "currentNotchMode") ?? "default"
    }
}

// MARK: - Models

struct NotchBarItem: Codable, Identifiable {
    let id: UUID
    var type: NotchBarItemType
    var isEnabled: Bool
    
    enum NotchBarItemType: String, Codable {
        case battery
        case date
        case weather
        case timer
        case calendar
        case worldClock
    }
}

struct WidgetData {
    let batteryLevel: Int
    let weather: WeatherData?
    let nextEvent: String?
    let currentMode: String
}
