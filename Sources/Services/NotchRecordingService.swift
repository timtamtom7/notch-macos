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

    func startRecording() {
        state = .recording
        recordingStartTime = Date()
        startTimer()
    }

    func pauseRecording() {
        state = .paused
        stopTimer()
    }

    func resumeRecording() {
        state = .recording
        startTimer()
    }

    func stopRecording() {
        state = .processing
        stopTimer()

        // Create clip
        let clip = NotchRecordingClip(
            id: UUID(),
            filePath: "/tmp/notch_clip_\(UUID().uuidString).mov",
            startTime: 0,
            endTime: elapsedTime,
            tags: []
        )
        clips.append(clip)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state = .idle
            self.elapsedTime = 0
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
            guard let start = self?.recordingStartTime else { return }
            self?.elapsedTime = Date().timeIntervalSince(start)
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
