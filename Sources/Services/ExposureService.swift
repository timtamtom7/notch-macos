import Foundation

struct ExposurePreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var iso: Int
    var shutterSpeed: String
    var aperture: Float
    var whiteBalance: Int
    var focusDistance: Float?

    init(id: UUID = UUID(), name: String, iso: Int, shutterSpeed: String, aperture: Float, whiteBalance: Int, focusDistance: Float? = nil) {
        self.id = id
        self.name = name
        self.iso = iso
        self.shutterSpeed = shutterSpeed
        self.aperture = aperture
        self.whiteBalance = whiteBalance
        self.focusDistance = focusDistance
    }

    static let presets: [ExposurePreset] = [
        ExposurePreset(name: "Sunny Day (f/8)", iso: 100, shutterSpeed: "1/250", aperture: 8.0, whiteBalance: 5500),
        ExposurePreset(name: "Cloudy (f/5.6)", iso: 200, shutterSpeed: "1/250", aperture: 5.6, whiteBalance: 6500),
        ExposurePreset(name: "Shade (f/4)", iso: 200, shutterSpeed: "1/500", aperture: 4.0, whiteBalance: 7500),
        ExposurePreset(name: "Indoor (f/2.8)", iso: 800, shutterSpeed: "1/60", aperture: 2.8, whiteBalance: 3200),
        ExposurePreset(name: "Night (f/1.8)", iso: 3200, shutterSpeed: "1/30", aperture: 1.8, whiteBalance: 2700),
        ExposurePreset(name: "Sports (f/2.8)", iso: 1600, shutterSpeed: "1/1000", aperture: 2.8, whiteBalance: 5500),
    ]
}

final class ExposureService: ObservableObject {
    static let shared = ExposureService()

    @Published var manualExposureEnabled = false
    @Published var currentISO: Int = 100
    @Published var currentShutterSpeed: String = "1/60"
    @Published var currentAperture: Float = 2.8
    @Published var currentWhiteBalance: Int = 5500
    @Published var exposureCompensation: Float = 0

    private let key = "exposureSettings"

    init() {
        loadSettings()
    }

    func applyPreset(_ preset: ExposurePreset) {
        currentISO = preset.iso
        currentShutterSpeed = preset.shutterSpeed
        currentAperture = preset.aperture
        currentWhiteBalance = preset.whiteBalance
        saveSettings()
    }

    func resetToAuto() {
        manualExposureEnabled = false
        currentISO = 100
        currentShutterSpeed = "1/60"
        currentAperture = 2.8
        currentWhiteBalance = 5500
        exposureCompensation = 0
        saveSettings()
    }

    func saveSettings() {
        let settings: [String: Any] = [
            "manualExposureEnabled": manualExposureEnabled,
            "currentISO": currentISO,
            "currentShutterSpeed": currentShutterSpeed,
            "currentAperture": currentAperture,
            "currentWhiteBalance": currentWhiteBalance,
            "exposureCompensation": exposureCompensation
        ]
        UserDefaults.standard.set(settings, forKey: key)
    }

    private func loadSettings() {
        guard let settings = UserDefaults.standard.dictionary(forKey: key) else { return }
        manualExposureEnabled = settings["manualExposureEnabled"] as? Bool ?? false
        currentISO = settings["currentISO"] as? Int ?? 100
        currentShutterSpeed = settings["currentShutterSpeed"] as? String ?? "1/60"
        currentAperture = settings["currentAperture"] as? Float ?? 2.8
        currentWhiteBalance = settings["currentWhiteBalance"] as? Int ?? 5500
        exposureCompensation = settings["exposureCompensation"] as? Float ?? 0
    }
}
