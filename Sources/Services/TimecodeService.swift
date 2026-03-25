import Foundation

struct Timecode: Codable, Equatable {
    var hours: Int
    var minutes: Int
    var seconds: Int
    var frames: Int
    var frameRate: Int

    init(hours: Int = 0, minutes: Int = 0, seconds: Int = 0, frames: Int = 0, frameRate: Int = 30) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.frames = frames
        self.frameRate = frameRate
    }

    static func from(elapsed: TimeInterval, frameRate: Int = 30) -> Timecode {
        let totalFrames = Int(elapsed * Double(frameRate))
        let frames = totalFrames % frameRate
        let totalSeconds = totalFrames / frameRate
        let seconds = totalSeconds % 60
        let totalMinutes = totalSeconds / 60
        let minutes = totalMinutes % 60
        let hours = totalMinutes / 60

        return Timecode(hours: hours, minutes: minutes, seconds: seconds, frames: frames, frameRate: frameRate)
    }

    var formatted: String {
        String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, frames)
    }

    var formattedDropFrame: String {
        "\(hours):\(minutes):\(seconds);\(frames)"
    }
}

final class TimecodeService: ObservableObject {
    static let shared = TimecodeService()

    @Published var isRunning = false
    @Published var currentTimecode = Timecode()
    @Published var startTimecode = Timecode()
    @Published var frameRate: Int = 30

    private var timer: Timer?

    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(frameRate), repeats: true) { [weak self] _ in
            self?.incrementFrame()
        }
    }

    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        currentTimecode = Timecode(frameRate: frameRate)
    }

    func setStartTimecode(_ tc: Timecode) {
        startTimecode = tc
        currentTimecode = tc
    }

    private func incrementFrame() {
        currentTimecode.frames += 1
        if currentTimecode.frames >= frameRate {
            currentTimecode.frames = 0
            currentTimecode.seconds += 1
            if currentTimecode.seconds >= 60 {
                currentTimecode.seconds = 0
                currentTimecode.minutes += 1
                if currentTimecode.minutes >= 60 {
                    currentTimecode.minutes = 0
                    currentTimecode.hours += 1
                }
            }
        }
    }
}
