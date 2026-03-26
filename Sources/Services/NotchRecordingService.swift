import Foundation
import AVFoundation

enum NotchRecordingState {
    case idle
    case recording
    case paused
    case processing
}

struct NotchRecordingClip: Identifiable {
    let id: UUID
    let filePath: String
    let startTime: TimeInterval
    let endTime: TimeInterval
    var tags: [String]
}

final class NotchRecordingService: ObservableObject {
    static let shared = NotchRecordingService()

    @Published var state: NotchRecordingState = .idle
    @Published var elapsedTime: TimeInterval = 0
    @Published var clips: [NotchRecordingClip] = []

    private var timer: Timer?
    private var recordingStartTime: Date?
    private var accumulatedTime: TimeInterval = 0

    func startRecording() {
        state = .recording
        recordingStartTime = Date()
        startTimer()
    }

    func pauseRecording() {
        state = .paused
        if let start = recordingStartTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }
        recordingStartTime = nil
        stopTimer()
    }

    func resumeRecording() {
        state = .recording
        recordingStartTime = Date()
        startTimer()
    }

    func stopRecording() {
        state = .processing
        if let start = recordingStartTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }
        recordingStartTime = nil
        stopTimer()

        // Create clip directory if needed
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("NotchClips", isDirectory: true)
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)

        let clip = NotchRecordingClip(
            id: UUID(),
            filePath: tmpDir.appendingPathComponent("\(UUID().uuidString).mov").path,
            startTime: 0,
            endTime: accumulatedTime,
            tags: []
        )
        clips.append(clip)

        accumulatedTime = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state = .idle
        }
    }

    func addClipMark() {
        // Mark current time as a clip boundary
        guard state == .recording, let start = recordingStartTime else { return }
        let markTime = Date().timeIntervalSince(start)
        let clip = NotchRecordingClip(
            id: UUID(),
            filePath: "/tmp/notch_clip_\(UUID().uuidString).mov",
            startTime: markTime,
            endTime: markTime,
            tags: []
        )
        clips.append(clip)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            var total = self.accumulatedTime
            if let start = self.recordingStartTime {
                total += Date().timeIntervalSince(start)
            }
            self.elapsedTime = total
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formattedElapsed() -> String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
