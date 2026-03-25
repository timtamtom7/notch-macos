import SwiftUI

enum Theme {

    // MARK: - Colors

    enum Colors {
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let accent = Color.accentColor
        static let background = Color(NSColor.windowBackgroundColor)
        static let secondaryBackground = Color(NSColor.controlBackgroundColor)
    }

    // MARK: - Fonts

    enum Fonts {
        static let notchTime = Font.system(size: 13, weight: .medium, design: .monospaced)
        static let notchDay = Font.system(size: 11, weight: .regular)
        static let notchLabel = Font.system(size: 12, weight: .medium)
        static let menuTitle = Font.system(size: 14, weight: .semibold)
        static let menuBody = Font.system(size: 13, weight: .regular)
    }

    // MARK: - Spacing

    enum Spacing {
        static let notchPaddingH: CGFloat = 16
        static let notchPaddingV: CGFloat = 4
        static let widgetSpacing: CGFloat = 20
        static let iconTextSpacing: CGFloat = 6
    }

    // MARK: - Animation

    enum Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.1)
    }
}
