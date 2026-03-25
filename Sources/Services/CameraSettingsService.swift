import Foundation
import AVFoundation

struct CameraSettings: Codable {
    var deviceId: String
    var resolution: Resolution
    var frameRate: Int
    var position: CameraPosition
    var enableHDR: Bool
    var exposureCompensation: Float
    var whiteBalance: WhiteBalanceMode
    var focusMode: FocusMode
    var zoomFactor: Float
    var torchEnabled: Bool

    enum Resolution: String, Codable, CaseIterable {
        case p720 = "720p"
        case p1080 = "1080p"
        case p4k = "4K"

        var size: (width: Int, height: Int) {
            switch self {
            case .p720: return (1280, 720)
            case .p1080: return (1920, 1080)
            case .p4k: return (3840, 2160)
            }
        }
    }

    enum CameraPosition: String, Codable, CaseIterable {
        case front = "Front"
        case back = "Back"
        case external = "External"
    }

    enum WhiteBalanceMode: String, Codable, CaseIterable {
        case auto = "Auto"
        case daylight = "Daylight"
        case cloudy = "Cloudy"
        case tungsten = "Tungsten"
        case fluorescent = "Fluorescent"
        case manual = "Manual"
    }

    enum FocusMode: String, Codable, CaseIterable {
        case auto = "Auto"
        case locked = "Locked"
        case continuous = "Continuous AF"
    }

    static let `default` = CameraSettings(
        deviceId: "",
        resolution: .p1080,
        frameRate: 30,
        position: .back,
        enableHDR: false,
        exposureCompensation: 0,
        whiteBalance: .auto,
        focusMode: .continuous,
        zoomFactor: 1.0,
        torchEnabled: false
    )
}

final class CameraSettingsService: ObservableObject {
    static let shared = CameraSettingsService()

    @Published var settings: CameraSettings = .default
    @Published var availableCameras: [CameraInfo] = []

    private let key = "cameraSettings"

    struct CameraInfo: Identifiable, Hashable {
        let id: String
        let name: String
        let position: CameraSettings.CameraPosition
        let supports4K: Bool

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: CameraInfo, rhs: CameraInfo) -> Bool {
            lhs.id == rhs.id
        }
    }

    init() {
        loadSettings()
        refreshCameras()
    }

    func refreshCameras() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
            mediaType: .video,
            position: .unspecified
        )

        var cameras: [CameraInfo] = []

        for device in discoverySession.devices {
            let position: CameraSettings.CameraPosition
            switch device.position {
            case .front: position = .front
            case .back: position = .back
            default: position = .external
            }

            cameras.append(CameraInfo(
                id: device.uniqueID,
                name: device.localizedName,
                position: position,
                supports4K: device.formats.contains { format in
                    format.dimensions.width >= 3840
                }
            ))
        }

        DispatchQueue.main.async {
            self.availableCameras = cameras
        }
    }

    func selectCamera(_ cameraId: String) {
        settings.deviceId = cameraId
        saveSettings()
    }

    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(CameraSettings.self, from: data) else {
            return
        }
        settings = decoded
    }
}
