import Foundation

// MARK: - Notch R12-R15 Models

struct NotchProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var isActive: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        isActive: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

struct NotchSession: Identifiable, Codable {
    let id: UUID
    var startTime: Date
    var endTime: Date?
    var focusDuration: TimeInterval
    var breaksTaken: Int

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        focusDuration: TimeInterval = 0,
        breaksTaken: Int = 0
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.focusDuration = focusDuration
        self.breaksTaken = breaksTaken
    }
}

struct FocusStatistics: Codable {
    var totalSessions: Int
    var totalFocusTime: TimeInterval
    var averageSessionDuration: TimeInterval
    var streakDays: Int
    var bestDay: Date?
}

struct NotchTeam: Identifiable, Codable {
    let id: UUID
    var name: String
    var members: [NotchMember]
    var sharedProfiles: [SharedProfile]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        members: [NotchMember] = [],
        sharedProfiles: [SharedProfile] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.members = members
        self.sharedProfiles = sharedProfiles
        self.createdAt = createdAt
    }
}

struct NotchMember: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String

    init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

struct SharedProfile: Identifiable, Codable {
    let id: UUID
    var profileId: UUID
    var shareCode: String
    var expiresAt: Date?

    init(
        id: UUID = UUID(),
        profileId: UUID,
        shareCode: String = String(UUID().uuidString.prefix(8)).uppercased(),
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.profileId = profileId
        self.shareCode = shareCode
        self.expiresAt = expiresAt
    }
}
