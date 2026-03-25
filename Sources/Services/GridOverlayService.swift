import Foundation

struct GridOverlaySettings: Codable {
    var gridType: GridType
    var gridColor: String
    var gridOpacity: Double
    var showSafeZones: Bool

    enum GridType: String, Codable, CaseIterable {
        case none = "None"
        case ruleOfThirds = "Rule of Thirds"
        case golden = "Golden Ratio"
        case fourByFour = "4×4"
        case sixBySix = "6×6"
        case diagonal = "Diagonal"

        var displayName: String { rawValue }
    }

    static let `default` = GridOverlaySettings(
        gridType: .ruleOfThirds,
        gridColor: "#FFFFFF",
        gridOpacity: 0.5,
        showSafeZones: false
    )
}

final class GridOverlayService: ObservableObject {
    static let shared = GridOverlayService()

    @Published var settings: GridOverlaySettings = .default

    private let key = "gridOverlaySettings"

    init() {
        loadSettings()
    }

    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(GridOverlaySettings.self, from: data) else {
            return
        }
        settings = decoded
    }
}
