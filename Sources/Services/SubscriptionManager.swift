import Foundation
import StoreKit

/// R16: Subscription management for Notch
@available(macOS 13.0, *)
public final class NotchSubscriptionManager: ObservableObject {
    public static let shared = NotchSubscriptionManager()
    @Published public private(set) var subscription: NotchSubscription?
    @Published public private(set) var products: [Product] = []
    
    private init() {}
    
    public func loadProducts() async {
        do {
            products = try await Product.products(for: [
                "com.notch.macos.pro.monthly",
                "com.notch.macos.pro.yearly",
                "com.notch.macos.household.monthly",
                "com.notch.macos.household.yearly"
            ])
        } catch { print("Failed to load products") }
    }
    
    public func canAccess(_ feature: NotchFeature) -> Bool {
        guard let sub = subscription else { return false }
        switch feature {
        case .advancedWeather: return sub.tier != .free
        case .widgets: return sub.tier != .free
        case .shortcuts: return sub.tier != .free
        }
    }
    
    public func updateStatus() async {
        var found: NotchSubscription = NotchSubscription(tier: .free)
        for await result in Transaction.currentEntitlements {
            do {
                let t = try checkVerified(result)
                if t.productID.contains("household") {
                    found = NotchSubscription(tier: .household, status: t.revocationDate == nil ? "active" : "expired")
                } else if t.productID.contains("pro") {
                    found = NotchSubscription(tier: .pro, status: t.revocationDate == nil ? "active" : "expired")
                }
            } catch { continue }
        }
        await MainActor.run { self.subscription = found }
    }
    
    public func restore() async throws {
        try await AppStore.sync()
        await updateStatus()
    }
    
    private func checkVerified<T>(_ r: VerificationResult<T>) throws -> T {
        switch r { case .unverified: throw NSError(domain: "Notch", code: -1); case .verified(let s): return s }
    }
}

public enum NotchFeature { case advancedWeather, widgets, shortcuts }
