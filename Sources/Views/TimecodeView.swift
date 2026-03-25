import SwiftUI

struct TimecodeView: View {
    @StateObject private var timecodeService = TimecodeService.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("Timecode")
                .font(.headline)

            // Timecode display
            Text(timecodeService.currentTimecode.formatted)
                .font(.system(size: 32, weight: .medium, design: .monospaced))
                .padding()
                .background(Color.black)
                .foregroundColor(.green)
                .cornerRadius(8)

            // Frame rate
            Picker("Frame Rate", selection: $timecodeService.frameRate) {
                Text("23.976").tag(24)
                Text("24").tag(24)
                Text("25").tag(25)
                Text("29.97").tag(30)
                Text("30").tag(30)
                Text("50").tag(50)
                Text("59.94").tag(60)
                Text("60").tag(60)
            }
            .pickerStyle(.segmented)

            // Controls
            HStack(spacing: 16) {
                Button(action: { timecodeService.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)

                Button(action: {
                    if timecodeService.isRunning {
                        timecodeService.stop()
                    } else {
                        timecodeService.start()
                    }
                }) {
                    Image(systemName: timecodeService.isRunning ? "stop.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .tint(timecodeService.isRunning ? .red : .green)
            }

            // Start timecode
            VStack(alignment: .leading, spacing: 4) {
                Text("Start Timecode")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(timecodeService.startTimecode.formatted)
                    .font(.system(size: 13, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(4)
            }
        }
        .padding()
    }
}
