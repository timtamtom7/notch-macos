import AppKit
import Foundation

class NotchService {

    static let shared = NotchService()

    private init() {}

    // MARK: - Notch Detection

    struct NotchInfo {
        let frame: NSRect        // The notch frame in screen coordinates
        let safeAreaTop: CGFloat // Top of usable area (below notch)
        let hasNotch: Bool
    }

    func detectNotch() -> NotchInfo {
        guard let screen = NSScreen.main else {
            return NotchInfo(frame: .zero, safeAreaTop: 0, hasNotch: false)
        }

        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame

        // Notch is the difference between screen top and visible frame top
        let notchTop = screenFrame.maxY
        let notchBottom = visibleFrame.maxY
        let notchHeight = notchTop - notchBottom

        // Typical notch dimensions on MacBook Pro: ~311pt wide, ~53pt tall
        // Only consider it a notch if the height is significant (between 30-100pt)
        let hasNotch = notchHeight > 30 && notchHeight < 100

        if hasNotch {
            let notchWidth = visibleFrame.width
            let notchX = visibleFrame.minX + (screenFrame.width - notchWidth) / 2

            let notchFrame = NSRect(
                x: notchX,
                y: notchBottom,
                width: notchWidth,
                height: notchHeight
            )

            return NotchInfo(frame: notchFrame, safeAreaTop: notchBottom, hasNotch: true)
        } else {
            // No notch: use a thin bar at the top of the screen
            let barHeight: CGFloat = 28
            let barFrame = NSRect(
                x: 0,
                y: screenFrame.height - barHeight,
                width: screenFrame.width,
                height: barHeight
            )
            return NotchInfo(frame: barFrame, safeAreaTop: screenFrame.height - barHeight, hasNotch: false)
        }
    }

    func hasNotch() -> Bool {
        return detectNotch().hasNotch
    }
}

// MARK: - Notch Window Controller

class NotchWindowController: NSWindowController {

    private var notchView: NotchContentView!

    init() {
        let notchInfo = NotchService.shared.detectNotch()
        let window = NSWindow(
            contentRect: notchInfo.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.ignoresMouseEvents = false

        // Position at notch location
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let notchFrame = NotchService.shared.detectNotch().frame

            // Convert to screen coordinates (origin at bottom-left)
            let windowOrigin = NSPoint(
                x: notchFrame.origin.x,
                y: screenFrame.maxY - notchFrame.maxY
            )
            window.setFrameOrigin(windowOrigin)
        }

        super.init(window: window)

        notchView = NotchContentView(frame: notchInfo.frame)
        window.contentView = notchView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.orderFront(nil)
    }

    override func close() {
        window?.orderOut(nil)
    }
}

// MARK: - Notch Content View

class NotchContentView: NSView {

    private let visualEffectView: NSVisualEffectView
    private let contentHostingView: NSHostingView<NotchWidgetView>
    private let settings = SettingsStore.shared

    override init(frame: NSRect) {
        visualEffectView = NSVisualEffectView(frame: frame)
        contentHostingView = NSHostingView(rootView: NotchWidgetView())

        super.init(frame: frame)

        setupViews()
        setupNotifications()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        visualEffectView.material = .popover
        visualEffectView.state = .active
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 0
        visualEffectView.layer?.masksToBounds = true

        addSubview(visualEffectView)
        visualEffectView.frame = bounds
        visualEffectView.autoresizingMask = [.width, .height]

        contentHostingView.frame = bounds
        contentHostingView.autoresizingMask = [.width, .height]
        addSubview(contentHostingView)

        updateOpacity()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: .settingsDidChange,
            object: nil
        )
    }

    @objc private func settingsChanged() {
        updateOpacity()
    }

    private func updateOpacity() {
        visualEffectView.alphaValue = CGFloat(settings.notchBarOpacity)
    }

    override func updateLayer() {
        visualEffectView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notch Widget View (SwiftUI)

import SwiftUI

struct NotchWidgetView: View {
    @StateObject private var dateManager = DateManager()
    @StateObject private var batteryManager = BatteryManager()
    @StateObject private var weatherManager = WeatherManager()
    private let settings = SettingsStore.shared

    var body: some View {
        HStack(spacing: 20) {
            if settings.showDate {
                DateWidgetView(dateManager: dateManager)
            }
            if settings.showBattery {
                BatteryWidgetView(batteryManager: batteryManager)
            }
            if settings.showWeather {
                WeatherWidgetView(weatherManager: weatherManager)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct DateWidgetView: View {
    @ObservedObject var dateManager: DateManager

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)

            Text(dateManager.formattedTime)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.primary)

            Text(dateManager.formattedDay)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
}

struct BatteryWidgetView: View {
    @ObservedObject var batteryManager: BatteryManager

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: batteryManager.iconName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(batteryManager.isCharging ? .green : .primary)

            Text(batteryManager.formattedPercentage)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}

struct WeatherWidgetView: View {
    @ObservedObject var weatherManager: WeatherManager

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: weatherManager.iconName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.yellow)

            Text(weatherManager.formattedTemp)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Date Manager

class DateManager: ObservableObject {
    @Published var currentDate = Date()
    private var timer: Timer?

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: currentDate)
    }

    var formattedDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: currentDate)
    }

    init() {
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.currentDate = Date()
            }
        }
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Battery Manager

class BatteryManager: ObservableObject {
    @Published var percentage: Int = 0
    @Published var isCharging: Bool = false

    var iconName: String {
        if isCharging {
            return "battery.100.bolt"
        } else if percentage > 75 {
            return "battery.100"
        } else if percentage > 50 {
            return "battery.75"
        } else if percentage > 25 {
            return "battery.50"
        } else {
            return "battery.25"
        }
    }

    var formattedPercentage: String {
        return "\(percentage)%"
    }

    init() {
        updateBatteryInfo()
        startTimer()
    }

    private func updateBatteryInfo() {
        // Use IOKit to get battery info
        let task = Process()
        task.launchPath = "/usr/sbin/pmset"
        task.arguments = ["-g", "batt"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                parseBatteryInfo(output)
            }
        } catch {
            // Default values on failure
            percentage = 0
            isCharging = false
        }
    }

    private func parseBatteryInfo(_ output: String) {
        // Sample output: "Now drawing from 'Battery Power'\n -InternalBattery-0\t95%; discharging; 4:11 remaining"
        let lines = output.components(separatedBy: "\n")
        for line in lines {
            if line.contains("%") {
                // Extract percentage
                if let percentRange = line.range(of: "\\d+%", options: .regularExpression) {
                    let percentStr = line[percentRange]
                    percentage = Int(percentStr.dropLast()) ?? 0
                }

                // Check charging state
                isCharging = line.contains("charging")
                break
            }
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateBatteryInfo()
            }
        }
    }
}

// MARK: - Weather Manager

class WeatherManager: ObservableObject {
    @Published var temperature: Int = 0
    @Published var condition: String = ""
    @Published var iconName: String = "cloud.sun"

    private let settings = SettingsStore.shared
    private var refreshTimer: Timer?
    private let weatherService = WeatherService.shared

    var formattedTemp: String {
        if settings.temperatureUnit == "F" {
            return "\(temperature)°F"
        } else {
            let celsius = (temperature - 32) * 5 / 9
            return "\(celsius)°C"
        }
    }

    init() {
        fetchWeather()
        startTimer()
    }

    private func startTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.fetchWeather()
        }
    }

    func fetchWeather() {
        weatherService.fetchWeather { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self?.temperature = weather.temperature
                    self?.condition = weather.condition
                    self?.iconName = WeatherService.weatherIcon(for: weather.code)
                case .failure:
                    self?.temperature = 0
                    self?.condition = "Unknown"
                    self?.iconName = "cloud"
                }
            }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}
