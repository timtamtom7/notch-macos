import Foundation

class SettingsStore {

    static let shared = SettingsStore()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let showDate = "showDate"
        static let showBattery = "showBattery"
        static let showWeather = "showWeather"
        static let weatherLocation = "weatherLocation"
        static let temperatureUnit = "temperatureUnit"
        static let notchBarOpacity = "notchBarOpacity"
        static let isVisible = "isVisible"
        static let cachedWeather = "cachedWeather"
        static let cachedWeatherTimestamp = "cachedWeatherTimestamp"
    }

    private init() {
        registerDefaults()
    }

    private func registerDefaults() {
        defaults.register(defaults: [
            Keys.showDate: true,
            Keys.showBattery: true,
            Keys.showWeather: true,
            Keys.weatherLocation: "Auto",
            Keys.temperatureUnit: "C",
            Keys.notchBarOpacity: 0.95,
            Keys.isVisible: true
        ])
    }

    // MARK: - Widget Visibility

    var showDate: Bool {
        get { defaults.bool(forKey: Keys.showDate) }
        set {
            defaults.set(newValue, forKey: Keys.showDate)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var showBattery: Bool {
        get { defaults.bool(forKey: Keys.showBattery) }
        set {
            defaults.set(newValue, forKey: Keys.showBattery)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var showWeather: Bool {
        get { defaults.bool(forKey: Keys.showWeather) }
        set {
            defaults.set(newValue, forKey: Keys.showWeather)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    // MARK: - Weather Settings

    var weatherLocation: String {
        get { defaults.string(forKey: Keys.weatherLocation) ?? "Auto" }
        set {
            defaults.set(newValue, forKey: Keys.weatherLocation)
            clearWeatherCache()
        }
    }

    var temperatureUnit: String {
        get { defaults.string(forKey: Keys.temperatureUnit) ?? "C" }
        set {
            defaults.set(newValue, forKey: Keys.temperatureUnit)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    // MARK: - Notch Bar Settings

    var notchBarOpacity: Double {
        get { defaults.double(forKey: Keys.notchBarOpacity) }
        set {
            defaults.set(newValue, forKey: Keys.notchBarOpacity)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var isVisible: Bool {
        get { defaults.bool(forKey: Keys.isVisible) }
        set { defaults.set(newValue, forKey: Keys.isVisible) }
    }

    // MARK: - Weather Cache

    var cachedWeatherData: Data? {
        get { defaults.data(forKey: Keys.cachedWeather) }
        set { defaults.set(newValue, forKey: Keys.cachedWeather) }
    }

    var cachedWeatherTimestamp: Date? {
        get { defaults.object(forKey: Keys.cachedWeatherTimestamp) as? Date }
        set { defaults.set(newValue, forKey: Keys.cachedWeatherTimestamp) }
    }

    func isWeatherCacheValid() -> Bool {
        guard let timestamp = cachedWeatherTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < 900 // 15 minutes
    }

    func clearWeatherCache() {
        defaults.removeObject(forKey: Keys.cachedWeather)
        defaults.removeObject(forKey: Keys.cachedWeatherTimestamp)
    }
}
