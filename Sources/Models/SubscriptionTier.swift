import Foundation

/// R16: Subscription tiers for Notch
public enum NotchSubscriptionTier: String, Codable, CaseIterable {
    case free = "free"
    case pro = "pro"
    case household = "household"
    
    public var displayName: String {
        switch self { case .free: return "Free"; case .pro: return "Notch Pro"; case .household: return "Notch Household" }
    }
    public var monthlyPrice: Decimal? {
        switch self { case .free: return nil; case .pro: return 2.99; case .household: return 4.99 }
    }
    public var maxDevices: Int {
        switch self { case .free: return 1; case .pro: return 3; case .household: return 10 }
    }
    public var supportsAdvancedWeather: Bool { self != .free }
    public var supportsWidgets: Bool { self != .free }
    public var supportsShortcuts: Bool { self != .free }
    public var trialDays: Int { self == .free ? 0 : 14 }
}

public struct NotchSubscription: Codable {
    public let tier: NotchSubscriptionTier
    public let status: String
    public let expiresAt: Date?
    public init(tier: NotchSubscriptionTier, status: String = "active", expiresAt: Date? = nil) {
        self.tier = tier; self.status = status; self.expiresAt = expiresAt
    }
}
