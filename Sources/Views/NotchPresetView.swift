import SwiftUI

struct NotchPresetView: View {
    @StateObject private var cameraService = CameraSettingsService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recording Presets")
                .font(.headline)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Presets.allCases, id: \.self) { preset in
                        presetCard(preset)
                    }
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func presetCard(_ preset: Presets) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: preset.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text(preset.name)
                    .font(.system(size: 13, weight: .semibold))
            }

            Text(preset.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Text(preset.resolution)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(4)

                Text(preset.frameRate)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
            }

            Button("Apply") {
                applyPreset(preset)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private func applyPreset(_ preset: Presets) {
        cameraService.settings.resolution = preset.resolutionValue
        cameraService.settings.frameRate = preset.frameRateValue
        cameraService.saveSettings()
    }

    enum Presets: String, CaseIterable {
        case vlog = "Vlog"
        case interview = "Interview"
        case tutorial = "Tutorial"
        case cinematic = "Cinematic"
        case action = "Action Cam"
        case lowLight = "Low Light"

        var icon: String {
            switch self {
            case .vlog: return "person.fill"
            case .interview: return "mic.fill"
            case .tutorial: return "laptopcomputer"
            case .cinematic: return "film"
            case .action: return "figure.run"
            case .lowLight: return "moon.fill"
            }
        }

        var description: String {
            switch self {
            case .vlog: return "1080p 30fps, auto settings"
            case .interview: return "1080p 60fps, locked focus"
            case .tutorial: return "1080p 30fps, locked exposure"
            case .cinematic: return "4K 24fps, manual everything"
            case .action: return "1080p 120fps, wide angle"
            case .lowLight: return "1080p 30fps, high exposure"
            }
        }

        var resolution: String { "1080p" }
        var frameRate: String { "30fps" }

        var resolutionValue: CameraSettings.Resolution {
            switch self {
            case .cinematic: return .p4k
            default: return .p1080
            }
        }

        var frameRateValue: Int {
            switch self {
            case .interview, .action: return 60
            case .cinematic: return 24
            default: return 30
            }
        }
    }
}
