import Foundation

struct StreamingDestination: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: DestinationType
    var serverURL: String
    var streamKey: String
    var isActive: Bool

    enum DestinationType: String, Codable, CaseIterable {
        case youtube = "YouTube Live"
        case twitch = "Twitch"
        case vimeo = "Vimeo Live"
        case custom = "Custom RTMP"
    }
}

final class StreamingService: ObservableObject {
    static let shared = StreamingService()

    @Published var destinations: [StreamingDestination] = []
    @Published var activeDestination: StreamingDestination?

    private let key = "streamingDestinations"

    init() {
        loadDestinations()
    }

    func addDestination(_ destination: StreamingDestination) {
        destinations.append(destination)
        saveDestinations()
    }

    func removeDestination(id: UUID) {
        destinations.removeAll { $0.id == id }
        if activeDestination?.id == id {
            activeDestination = nil
        }
        saveDestinations()
    }

    func connect(to destination: StreamingDestination) async throws {
        activeDestination = destination

        // Simulate connection
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }

    func disconnect() {
        activeDestination = nil
    }

    private func loadDestinations() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([StreamingDestination].self, from: data) else {
            return
        }
        destinations = decoded
    }

    private func saveDestinations() {
        if let data = try? JSONEncoder().encode(destinations) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
