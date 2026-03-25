import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var notchWindowController: NotchWindowController?
    private let settings = SettingsStore.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        setupStatusItem()
        setupNotchWindow()

        if !NotchService.shared.hasNotch() {
            showNoNotchAlert()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        notchWindowController?.close()
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "menubar.star.fill", accessibilityDescription: "Notch")
        }

        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Toggle Notch Bar", action: #selector(toggleNotchBar), keyEquivalent: "t")
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let widgetsSubmenu = NSMenu()
        let dateItem = NSMenuItem(title: "Date", action: #selector(toggleDateWidget), keyEquivalent: "")
        dateItem.state = settings.showDate ? .on : .off
        widgetsSubmenu.addItem(dateItem)

        let batteryItem = NSMenuItem(title: "Battery", action: #selector(toggleBatteryWidget), keyEquivalent: "")
        batteryItem.state = settings.showBattery ? .on : .off
        widgetsSubmenu.addItem(batteryItem)

        let weatherItem = NSMenuItem(title: "Weather", action: #selector(toggleWeatherWidget), keyEquivalent: "")
        weatherItem.state = settings.showWeather ? .on : .off
        widgetsSubmenu.addItem(weatherItem)

        let widgetsMenuItem = NSMenuItem(title: "Widgets", action: nil, keyEquivalent: "")
        widgetsMenuItem.submenu = widgetsSubmenu
        menu.addItem(widgetsMenuItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "About Notch", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Notch", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    // MARK: - Notch Window

    private func setupNotchWindow() {
        notchWindowController = NotchWindowController()
        if settings.isVisible {
            notchWindowController?.showWindow(nil)
        }
    }

    private func showNoNotchAlert() {
        let alert = NSAlert()
        alert.messageText = "No Notch Detected"
        alert.informativeText = "No notch was detected on your Mac. Would you like to use Notch as a top bar widget instead?"
        alert.addButton(withTitle: "Use as Top Bar Widget")
        alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            settings.isVisible = true
            notchWindowController?.showWindow(nil)
        }
    }

    // MARK: - Actions

    @objc private func toggleNotchBar() {
        settings.isVisible.toggle()
        if settings.isVisible {
            notchWindowController?.showWindow(nil)
        } else {
            notchWindowController?.close()
        }
    }

    @objc private func toggleDateWidget() {
        settings.showDate.toggle()
        updateWidgetMenuItems()
        NotificationCenter.default.post(name: .widgetsDidChange, object: nil)
    }

    @objc private func toggleBatteryWidget() {
        settings.showBattery.toggle()
        updateWidgetMenuItems()
        NotificationCenter.default.post(name: .widgetsDidChange, object: nil)
    }

    @objc private func toggleWeatherWidget() {
        settings.showWeather.toggle()
        updateWidgetMenuItems()
        NotificationCenter.default.post(name: .widgetsDidChange, object: nil)
    }

    private func updateWidgetMenuItems() {
        guard let menu = statusItem.menu else { return }
        if let widgetsItem = menu.items.first(where: { $0.title == "Widgets" }),
           let submenu = widgetsItem.submenu {
            submenu.item(withTitle: "Date")?.state = settings.showDate ? .on : .off
            submenu.item(withTitle: "Battery")?.state = settings.showBattery ? .on : .off
            submenu.item(withTitle: "Weather")?.state = settings.showWeather ? .on : .off
        }
    }

    @objc private func showPreferences() {
        let preferencesWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        preferencesWindow.title = "Notch Preferences"
        preferencesWindow.contentView = NSHostingView(rootView: PreferencesView())
        preferencesWindow.center()
        preferencesWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Notch"
        alert.informativeText = "Version 1.0.0\n\nNotch makes your MacBook notch useful by displaying widgets in the notch area."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let widgetsDidChange = Notification.Name("widgetsDidChange")
    static let settingsDidChange = Notification.Name("settingsDidChange")
}
