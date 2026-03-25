import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct GridOverlaySettingsView: View {
    @StateObject private var gridService = GridOverlayService.shared

    private let colors = ["#FFFFFF", "#FFFF00", "#00FFFF", "#FF00FF", "#00FF00"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Grid Overlay")
                .font(.headline)

            Picker("Grid Type", selection: $gridService.settings.gridType) {
                ForEach(GridOverlaySettings.GridType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .labelsHidden()
            .onChange(of: gridService.settings.gridType) { _ in
                gridService.save()
            }

            HStack {
                Text("Color:")
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color) ?? .white)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(gridService.settings.gridColor == color ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            gridService.settings.gridColor = color
                            gridService.save()
                        }
                }
            }

            HStack {
                Text("Opacity:")
                Slider(value: $gridService.settings.gridOpacity, in: 0.1...1.0)
                    .onChange(of: gridService.settings.gridOpacity) { _ in
                        gridService.save()
                    }
                Text("\(Int(gridService.settings.gridOpacity * 100))%")
                    .frame(width: 40)
            }

            Toggle("Show Safe Zones (action/subs)", isOn: $gridService.settings.showSafeZones)
                .onChange(of: gridService.settings.showSafeZones) { _ in
                    gridService.save()
                }

            // Preview
            GridOverlayPreview(settings: gridService.settings)
                .frame(height: 150)
                .cornerRadius(8)
        }
        .padding()
    }
}

struct GridOverlayPreview: View {
    let settings: GridOverlaySettings

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black

                switch settings.gridType {
                case .none:
                    EmptyView()

                case .ruleOfThirds:
                    ruleOfThirds(in: geometry.size)

                case .golden:
                    goldenRatio(in: geometry.size)

                case .fourByFour:
                    grid4x4(in: geometry.size)

                case .sixBySix:
                    grid6x6(in: geometry.size)

                case .diagonal:
                    diagonalLines(in: geometry.size)
                }

                if settings.showSafeZones {
                    safeZones(in: geometry.size)
                }
            }
        }
    }

    private func ruleOfThirds(in size: CGSize) -> some View {
        let color = Color(hex: settings.gridColor) ?? .white
        let opacity = settings.gridOpacity

        return ZStack {
            // Vertical lines
            Path { path in
                path.move(to: CGPoint(x: size.width / 3, y: 0))
                path.addLine(to: CGPoint(x: size.width / 3, y: size.height))
            }
            .stroke(color.opacity(opacity), lineWidth: 1)

            Path { path in
                path.move(to: CGPoint(x: 2 * size.width / 3, y: 0))
                path.addLine(to: CGPoint(x: 2 * size.width / 3, y: size.height))
            }
            .stroke(color.opacity(opacity), lineWidth: 1)

            // Horizontal lines
            Path { path in
                path.move(to: CGPoint(x: 0, y: size.height / 3))
                path.addLine(to: CGPoint(x: size.width, y: size.height / 3))
            }
            .stroke(color.opacity(opacity), lineWidth: 1)

            Path { path in
                path.move(to: CGPoint(x: 0, y: 2 * size.height / 3))
                path.addLine(to: CGPoint(x: size.width, y: 2 * size.height / 3))
            }
            .stroke(color.opacity(opacity), lineWidth: 1)
        }
    }

    private func goldenRatio(in size: CGSize) -> some View {
        let color = Color(hex: settings.gridColor) ?? .white
        let opacity = settings.gridOpacity
        let phi = 1.618

        return ZStack {
            Path { path in
                let x1 = size.width / phi
                path.move(to: CGPoint(x: x1, y: 0))
                path.addLine(to: CGPoint(x: x1, y: size.height))
            }
            .stroke(color.opacity(opacity), lineWidth: 1)

            Path { path in
                let y1 = size.height / phi
                path.move(to: CGPoint(x: 0, y: y1))
                path.addLine(to: CGPoint(x: size.width, y: y1))
            }
            .stroke(color.opacity(opacity), lineWidth: 1)
        }
    }

    private func grid4x4(in size: CGSize) -> some View {
        let color = Color(hex: settings.gridColor) ?? .white
        let opacity = settings.gridOpacity

        return ZStack {
            ForEach(1..<4) { i in
                Path { path in
                    let x = size.width * CGFloat(i) / 4
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                .stroke(color.opacity(opacity), lineWidth: 1)

                Path { path in
                    let y = size.height * CGFloat(i) / 4
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(color.opacity(opacity), lineWidth: 1)
            }
        }
    }

    private func grid6x6(in size: CGSize) -> some View {
        let color = Color(hex: settings.gridColor) ?? .white
        let opacity = settings.gridOpacity

        return ZStack {
            ForEach(1..<6) { i in
                Path { path in
                    let x = size.width * CGFloat(i) / 6
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                .stroke(color.opacity(opacity), lineWidth: 1)

                Path { path in
                    let y = size.height * CGFloat(i) / 6
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(color.opacity(opacity), lineWidth: 1)
            }
        }
    }

    private func diagonalLines(in size: CGSize) -> some View {
        let color = Color(hex: settings.gridColor) ?? .white
        let opacity = settings.gridOpacity

        return ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size.width, y: size.height))
            }
            .stroke(color.opacity(opacity), lineWidth: 1)

            Path { path in
                path.move(to: CGPoint(x: size.width, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size.height))
            }
            .stroke(color.opacity(opacity), lineWidth: 1)
        }
    }

    private func safeZones(in size: CGSize) -> some View {
        let actionMargin = size.width * 0.05
        let subMargin = size.width * 0.1

        return ZStack {
            Rectangle()
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                .frame(width: size.width - 2 * actionMargin, height: size.height - 2 * actionMargin)
                .position(x: size.width / 2, y: size.height / 2)

            Rectangle()
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                .frame(width: size.width - 2 * subMargin, height: size.height - 2 * subMargin)
                .position(x: size.width / 2, y: size.height / 2)
        }
    }
}
