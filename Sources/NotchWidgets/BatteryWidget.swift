import WidgetKit
import SwiftUI

struct BatteryWidget: Widget {
    let kind: String = "BatteryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryProvider()) { entry in
            BatteryWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Battery Status")
        .description("Shows battery level and charging status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct BatteryEntry: TimelineEntry {
    let date: Date
    let batteryLevel: Int
    let isCharging: Bool
}

struct BatteryProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryEntry {
        BatteryEntry(date: Date(), batteryLevel: 85, isCharging: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BatteryEntry) -> Void) {
        let entry = BatteryEntry(date: Date(), batteryLevel: 85, isCharging: false)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryEntry>) -> Void) {
        let entry = BatteryEntry(date: Date(), batteryLevel: 85, isCharging: false)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct BatteryWidgetView: View {
    var entry: BatteryProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularBatteryView(entry: entry)
        case .accessoryRectangular:
            RectangularBatteryView(entry: entry)
        default:
            CircularBatteryView(entry: entry)
        }
    }
}

struct CircularBatteryView: View {
    let entry: BatteryEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: entry.isCharging ? "battery.100.bolt" : batteryIcon(entry.batteryLevel))
                    .font(.caption)
                Text("\(entry.batteryLevel)%")
                    .font(.system(.caption2, design: .monospaced))
            }
        }
    }
    
    private func batteryIcon(_ level: Int) -> String {
        if level > 75 { return "battery.100" }
        else if level > 50 { return "battery.75" }
        else if level > 25 { return "battery.50" }
        else { return "battery.25" }
    }
}

struct RectangularBatteryView: View {
    let entry: BatteryEntry
    
    var body: some View {
        HStack {
            Image(systemName: entry.isCharging ? "battery.100.bolt" : batteryIcon(entry.batteryLevel))
                .font(.body)
            VStack(alignment: .leading) {
                Text("Battery")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(entry.batteryLevel)%")
                    .font(.headline)
            }
        }
    }
    
    private func batteryIcon(_ level: Int) -> String {
        if level > 75 { return "battery.100" }
        else if level > 50 { return "battery.75" }
        else if level > 25 { return "battery.50" }
        else { return "battery.25" }
    }
}
