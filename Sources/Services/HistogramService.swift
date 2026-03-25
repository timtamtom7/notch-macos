import Foundation
import CoreImage

final class HistogramService {
    static let shared = HistogramService()

    struct HistogramData {
        var red: [Float]
        var green: [Float]
        var blue: [Float]
        var luminance: [Float]

        static let empty = HistogramData(
            red: Array(repeating: 0, count: 256),
            green: Array(repeating: 0, count: 256),
            blue: Array(repeating: 0, count: 256),
            luminance: Array(repeating: 0, count: 256)
        )
    }

    func computeHistogram(from pixelBuffer: CVPixelBuffer) -> HistogramData {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)

        guard let data = baseAddress else { return .empty }

        var red = Array(repeating: Float(0), count: 256)
        var green = Array(repeating: Float(0), count: 256)
        var blue = Array(repeating: Float(0), count: 256)
        var luminance = Array(repeating: Float(0), count: 256)

        let pixelCount = width * height

        if let rgbData = data.assumingMemoryBound(to: UInt8.self) {
            for i in 0..<pixelCount {
                let r = Int(rgbData[i * 4])
                let g = Int(rgbData[i * 4 + 1])
                let b = Int(rgbData[i * 4 + 2])

                red[r] += 1
                green[g] += 1
                blue[b] += 1

                let lum = Int(Float(r) * 0.299 + Float(g) * 0.587 + Float(b) * 0.114)
                luminance[min(255, lum)] += 1
            }
        }

        // Normalize
        let maxVal = max(red.max() ?? 1, green.max() ?? 1, blue.max() ?? 1, luminance.max() ?? 1)
        if maxVal > 0 {
            for i in 0..<256 {
                red[i] /= maxVal
                green[i] /= maxVal
                blue[i] /= maxVal
                luminance[i] /= maxVal
            }
        }

        return HistogramData(red: red, green: green, blue: blue, luminance: luminance)
    }
}
