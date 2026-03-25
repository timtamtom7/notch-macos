import SwiftUI

struct ManualExposureView: View {
    @StateObject private var exposureService = ExposureService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Manual Exposure")
                .font(.headline)

            Toggle("Enable Manual Mode", isOn: $exposureService.manualExposureEnabled)
                .onChange(of: exposureService.manualExposureEnabled) { _ in
                    exposureService.saveSettings()
                }

            if exposureService.manualExposureEnabled {
                // ISO
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("ISO")
                            .font(.subheadline)
                        Spacer()
                        Text("\(exposureService.currentISO)")
                            .font(.system(size: 13, design: .monospaced))
                    }
                    Slider(value: Binding(
                        get: { Double(exposureService.currentISO) },
                        set: { exposureService.currentISO = Int($0) }
                    ), in: 50...12800, step: 1)
                    .disabled(!exposureService.manualExposureEnabled)
                    .onChange(of: exposureService.currentISO) { _ in
                        exposureService.saveSettings()
                    }
                }

                // Shutter Speed
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Shutter Speed")
                            .font(.subheadline)
                        Spacer()
                        Text(exposureService.currentShutterSpeed)
                            .font(.system(size: 13, design: .monospaced))
                    }

                    Picker("Shutter", selection: $exposureService.currentShutterSpeed) {
                        Text("1/4000").tag("1/4000")
                        Text("1/2000").tag("1/2000")
                        Text("1/1000").tag("1/1000")
                        Text("1/500").tag("1/500")
                        Text("1/250").tag("1/250")
                        Text("1/125").tag("1/125")
                        Text("1/60").tag("1/60")
                        Text("1/30").tag("1/30")
                        Text("1/15").tag("1/15")
                        Text("1/8").tag("1/8")
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .onChange(of: exposureService.currentShutterSpeed) { _ in
                        exposureService.saveSettings()
                    }
                }

                // Aperture
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Aperture")
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "f/%.1f", exposureService.currentAperture))
                            .font(.system(size: 13, design: .monospaced))
                    }
                    Slider(value: $exposureService.currentAperture, in: 1.0...16.0, step: 0.1)
                        .disabled(!exposureService.manualExposureEnabled)
                        .onChange(of: exposureService.currentAperture) { _ in
                            exposureService.saveSettings()
                        }
                }

                // White Balance
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("White Balance")
                            .font(.subheadline)
                        Spacer()
                        Text("\(exposureService.currentWhiteBalance)K")
                            .font(.system(size: 13, design: .monospaced))
                    }
                    Slider(value: Binding(
                        get: { Double(exposureService.currentWhiteBalance) },
                        set: { exposureService.currentWhiteBalance = Int($0) }
                    ), in: 2700...7500, step: 100)
                        .disabled(!exposureService.manualExposureEnabled)
                        .onChange(of: exposureService.currentWhiteBalance) { _ in
                            exposureService.saveSettings()
                        }

                    HStack {
                        Text("Warm")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Cool")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Exposure presets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Presets")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ExposurePreset.presets) { preset in
                                Button(action: { exposureService.applyPreset(preset) }) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(preset.name)
                                            .font(.caption2)
                                            .lineLimit(1)
                                        Text(preset.shutterSpeed)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.1))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }

            Divider()

            Button("Reset to Auto") {
                exposureService.resetToAuto()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding()
    }
}
