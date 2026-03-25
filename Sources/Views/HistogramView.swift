import SwiftUI

struct HistogramView: View {
    let histogramData: HistogramService.HistogramData
    let mode: DisplayMode

    enum DisplayMode {
        case rgb
        case luminance
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.opacity(0.8)

                if mode == .luminance {
                    luminanceHistogram(in: geometry.size)
                } else {
                    rgbHistogram(in: geometry.size)
                }

                // Clipping warning
                if isClipping(histogramData.luminance) {
                    VStack {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Clipping!")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            .cornerRadius(4)
        }
    }

    @ViewBuilder
    private func luminanceHistogram(in size: CGSize) -> some View {
        Path { path in
            drawPath(for: histogramData.luminance, in: size, path: &path)
        }
        .fill(Color.gray.opacity(0.7))
    }

    @ViewBuilder
    private func rgbHistogram(in size: CGSize) -> some View {
        ZStack {
            // Red channel
            Path { path in
                drawPath(for: histogramData.red, in: size, path: &path)
            }
            .fill(Color.red.opacity(0.5))

            // Green channel
            Path { path in
                drawPath(for: histogramData.green, in: size, path: &path)
            }
            .fill(Color.green.opacity(0.5))

            // Blue channel
            Path { path in
                drawPath(for: histogramData.blue, in: size, path: &path)
            }
            .fill(Color.blue.opacity(0.5))
        }
    }

    private func drawPath(for data: [Float], in size: CGSize, path: inout Path) {
        guard !data.isEmpty else { return }

        let stepX = size.width / CGFloat(data.count - 1)

        path.move(to: CGPoint(x: 0, y: size.height))

        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let y = size.height - CGFloat(value) * size.height
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.closeSubpath()
    }

    private func isClipping(_ data: [Float]) -> Bool {
        guard data.count >= 2 else { return false }
        return data[0] > 0.95 || data[data.count - 1] > 0.95
    }
}
