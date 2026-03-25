import Foundation
import AVFoundation

struct MulticameraAngle: Identifiable, Codable {
    let id: UUID
    var name: String
    var cameraDeviceId: String
    var isActive: Bool
    var position: CGPoint
    var size: CGSize
    var isMirrored: Bool
    var opacity: Double

    init(id: UUID = UUID(), name: String, cameraDeviceId: String, isActive: Bool = false, position: CGPoint = .zero, size: CGSize = CGSize(width: 320, height: 180), isMirrored: Bool = false, opacity: Double = 1.0) {
        self.id = id
        self.name = name
        self.cameraDeviceId = cameraDeviceId
        self.isActive = isActive
        self.position = position
        self.size = size
        self.isMirrored = isMirrored
        self.opacity = opacity
    }
}

final class MulticameraService: ObservableObject {
    static let shared = MulticameraService()

    @Published var angles: [MulticameraAngle] = []
    @Published var layout: Layout = .single

    enum Layout: String, Codable, CaseIterable {
        case single = "Single Camera"
        case sideBySide = "Side by Side"
        case pictureInPicture = "Picture in Picture"
        case grid2x1 = "2×1 Grid"
        case grid2x2 = "2×2 Grid"

        var displayName: String { rawValue }
    }

    private let key = "multicameraAngles"

    init() {
        loadAngles()
    }

    func addAngle(_ angle: MulticameraAngle) {
        angles.append(angle)
        saveAngles()
    }

    func removeAngle(id: UUID) {
        angles.removeAll { $0.id == id }
        saveAngles()
    }

    func updateAngle(_ angle: MulticameraAngle) {
        if let index = angles.firstIndex(where: { $0.id == angle.id }) {
            angles[index] = angle
            saveAngles()
        }
    }

    func switchTo(angleId: UUID) {
        for i in angles.indices {
            angles[i].isActive = (angles[i].id == angleId)
        }
    }

    func setLayout(_ layout: Layout) {
        self.layout = layout
        saveAngles()
    }

    private func loadAngles() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([MulticameraAngle].self, from: data) else {
            return
        }
        angles = decoded
    }

    private func saveAngles() {
        if let data = try? JSONEncoder().encode(angles) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}

extension CGSize: Codable {
    enum CodingKeys: String, CodingKey {
        case width, height
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(width: width, height: height)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
}
