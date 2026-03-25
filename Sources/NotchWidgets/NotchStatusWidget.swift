import WidgetKit
import SwiftUI

struct NotchStatusEntry: TimelineEntry {
    let date: Date
    let batteryLevel: Int
    let weatherTemp: Int
    let weatherCondition: String
    let currentMode: String
}

struct NotchStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> NotchStatusEntry {
        NotchStatusEntry(
            date: Date(),
            batteryLevel: 85,
            weatherTemp: 72,
            weatherCondition: "Sunny",
            currentMode: "default"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NotchStatusEntry) -> Void) {
        let entry = loadNotchStatus()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NotchStatusEntry>) -> Void) {
        let entry = loadNotchStatus()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadNotchStatus() -> NotchStatusEntry {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bou.notch"),
              let data = try? Data(contentsOf: containerURL.appendingPathComponent("notch_status.json")),
              let status = try? JSONDecoder().decode(NotchStatusData.self, from: data) else {
            return NotchStatusEntry(
                date: Date(),
                batteryLevel: 85,
                weatherTemp: 72,
                weatherCondition: "Sunny",
                currentMode: "default"
            )
        }
        
        return NotchStatusEntry(
            date: Date(),
            batteryLevel: status.batteryLevel,
            weatherTemp: status.weatherTemp,
            weatherCondition: status.weatherCondition,
            currentMode: status.currentMode
        )
    }
}

struct NotchStatusData: Codable {
    let batteryLevel: Int
    let weatherTemp: Int
    let weatherCondition: String
    let currentMode: String
}

struct NotchStatusWidget: Widget {
    let kind: String = "NotchStatusWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NotchStatusProvider()) { entry in
            NotchStatusWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Notch Status")
        .description("Shows battery, weather, and mode in your notch.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct NotchStatusWidgetView: View {
    var entry: NotchStatusProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallNotchStatusView(entry: entry)
        case .systemMedium:
            MediumNotchStatusView(entry: entry)
        default:
            SmallNotchStatusView(entry: entry)
        }
    }
}

struct SmallNotchStatusView: View {
    let entry: NotchStatusEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "rectangle.inset.filled")
                    .foregroundColor(.blue)
                Text("NOTCH")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading) {
                    Image(systemName: batteryIcon(entry.batteryLevel))
                        .foregroundColor(batteryColor(entry.batteryLevel))
                    Text("\(entry.batteryLevel)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Text("\(entry.weatherTemp)")
                            .font(.headline)
                        Text("°F")
                            .font(.caption2)
                    }
                    Text(entry.weatherCondition)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(entry.currentMode.uppercased())
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(4)
        }
        .padding(10)
    }
    
    private func batteryIcon(_ level: Int) -> String {
        if level > 75 { return "battery.100" }
        else if level > 50 { return "battery.75" }
        else if level > 25 { return "battery.50" }
        else { return "battery.25" }
    }
    
    private func batteryColor(_ level: Int) -> Color {
        if level > 50 { return .green }
        else if level > 20 { return .orange }
        else { return .red }
    }
}

struct MediumNotchStatusView: View {
    let entry: NotchStatusEntry
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "rectangle.inset.filled")
                        .foregroundColor(.blue)
                    Text("NOTCH")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Text(entry.currentMode.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: batteryIcon(entry.batteryLevel))
                        .foregroundColor(batteryColor(entry.batteryLevel))
                    Text("\(entry.batteryLevel)%")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Text("Battery")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 2) {
                    Text("\(entry.weatherTemp)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("°F")
                        .font(.caption)
                }
                Text(entry.weatherCondition)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
    }
    
    private func batteryIcon(_ level: Int) -> String {
        if level > 75 { return "battery.100" }
        else if level > 50 { return "battery.75" }
        else if level > 25 { return "battery.50" }
        else { return "battery.25" }
    }
    
    private func batteryColor(_ level: Int) -> Color {
        if level > 50 { return .green }
        else if level > 20 { return .orange }
        else { return .red }
    }
}
