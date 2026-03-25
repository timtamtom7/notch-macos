import Foundation
import CloudKit

final class NotchSyncService: ObservableObject {
    static let shared = NotchSyncService()
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var isEnabled: Bool = true
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    private let container = CKContainer(identifier: "iCloud.com.notch.app")
    private let privateDatabase: CKDatabase
    
    private init() {
        privateDatabase = container.privateCloudDatabase
        loadSettings()
    }
    
    private func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: "notch_iCloudSyncEnabled")
    }
    
    func setSyncEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "notch_iCloudSyncEnabled")
        if enabled { syncAll() }
    }
    
    func syncAll() {
        Task {
            await MainActor.run { syncStatus = .syncing }
            // Sync settings and presets
            do {
                try await syncSettings()
                await MainActor.run {
                    syncStatus = .success
                    lastSyncDate = Date()
                }
            } catch {
                await MainActor.run { syncStatus = .error(error.localizedDescription) }
            }
        }
    }
    
    private func syncSettings() async throws {
        guard isEnabled else { return }
        let record = CKRecord(recordType: "Settings")
        record["mode"] = (UserDefaults.standard.string(forKey: "currentNotchMode") ?? "default") as CKRecordValue
        _ = try await privateDatabase.save(record)
    }
    
    func fetchSettings() async throws -> [String: Any] {
        let query = CKQuery(recordType: "Settings", predicate: NSPredicate(value: true))
        let (results, _) = try await privateDatabase.records(matching: query)
        guard let record = results.first?.1, case .success(let r) = record else { return [:] }
        var settings: [String: Any] = [:]
        for key in r.allKeys() { settings[key] = r[key] }
        return settings
    }
}
