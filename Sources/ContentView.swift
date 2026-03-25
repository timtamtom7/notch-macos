import SwiftUI

struct PreferencesView: View {
    @State private var showDate: Bool = SettingsStore.shared.showDate
    @State private var showBattery: Bool = SettingsStore.shared.showBattery
    @State private var showWeather: Bool = SettingsStore.shared.showWeather
    @State private var weatherLocation: String = SettingsStore.shared.weatherLocation
    @State private var temperatureUnit: String = SettingsStore.shared.temperatureUnit
    @State private var notchBarOpacity: Double = SettingsStore.shared.notchBarOpacity
    @State private var launchAtLogin: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Preferences")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 8)

            // Widget Toggles
            GroupBox(label: Text("Widgets").fontWeight(.semibold)) {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Date / Time", isOn: $showDate)
                        .onChange(of: showDate) { newValue in
                            SettingsStore.shared.showDate = newValue
                            NotificationCenter.default.post(name: .widgetsDidChange, object: nil)
                        }

                    Toggle("Battery", isOn: $showBattery)
                        .onChange(of: showBattery) { newValue in
                            SettingsStore.shared.showBattery = newValue
                            NotificationCenter.default.post(name: .widgetsDidChange, object: nil)
                        }

                    Toggle("Weather", isOn: $showWeather)
                        .onChange(of: showWeather) { newValue in
                            SettingsStore.shared.showWeather = newValue
                            NotificationCenter.default.post(name: .widgetsDidChange, object: nil)
                        }
                }
                .padding(.vertical, 8)
            }

            // Weather Settings
            GroupBox(label: Text("Weather").fontWeight(.semibold)) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Location:")
                        TextField("City name", text: $weatherLocation)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)
                            .onChange(of: weatherLocation) { newValue in
                                SettingsStore.shared.weatherLocation = newValue
                            }
                    }

                    HStack {
                        Text("Temperature:")
                        Picker("", selection: $temperatureUnit) {
                            Text("Celsius").tag("C")
                            Text("Fahrenheit").tag("F")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                        .onChange(of: temperatureUnit) { newValue in
                            SettingsStore.shared.temperatureUnit = newValue
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            // Appearance
            GroupBox(label: Text("Appearance").fontWeight(.semibold)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Notch Bar Opacity:")
                        Slider(value: $notchBarOpacity, in: 0.5...1.0, step: 0.05)
                            .frame(width: 200)
                            .onChange(of: notchBarOpacity) { newValue in
                                SettingsStore.shared.notchBarOpacity = newValue
                            }
                        Text("\(Int(notchBarOpacity * 100))%")
                            .frame(width: 40)
                    }
                }
                .padding(.vertical, 8)
            }

            // Launch at Login
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _ in
                    // TODO: Implement launch at login using SMAppService (macOS 13+)
                }

            Spacer()
        }
        .padding(24)
        .frame(width: 400, height: 420)
    }
}
