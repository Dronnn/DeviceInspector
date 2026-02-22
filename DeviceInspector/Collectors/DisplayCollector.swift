import UIKit
import os.log

struct DisplayCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "DisplayCollector")

    // MARK: - Display

    @MainActor
    static func collectDisplay() -> DeviceInfoSection {
        logger.debug("Collecting display data")

        var items: [DeviceInfoItem] = []

        let screen = UIScreen.main
        let bounds = screen.bounds
        let nativeBounds = screen.nativeBounds

        items.append(DeviceInfoItem(
            key: "Screen Bounds (Points)",
            value: "\(Int(bounds.width)) x \(Int(bounds.height))",
            notes: "Logical screen size in points."
        ))

        items.append(DeviceInfoItem(
            key: "Native Bounds (Pixels)",
            value: "\(Int(nativeBounds.width)) x \(Int(nativeBounds.height))",
            notes: "Physical screen size in pixels."
        ))

        items.append(DeviceInfoItem(
            key: "Scale Factor",
            value: "\(screen.scale)x",
            notes: "Points to pixels multiplier. 2x = Retina, 3x = Super Retina."
        ))

        items.append(DeviceInfoItem(
            key: "Native Scale Factor",
            value: "\(screen.nativeScale)x",
            notes: "Native physical pixels scale. May differ from scale if display zoomed."
        ))

        let brightness = screen.brightness
        items.append(DeviceInfoItem(
            key: "Screen Brightness",
            value: String(format: "%.0f%%", brightness * 100),
            notes: "Current brightness level. Changes in real-time as user adjusts."
        ))

        // User Interface

        let device = UIDevice.current
        let idiomString: String
        switch device.userInterfaceIdiom {
        case .phone:
            idiomString = "Phone"
        case .pad:
            idiomString = "Pad"
        case .tv:
            idiomString = "TV"
        case .carPlay:
            idiomString = "CarPlay"
        case .mac:
            idiomString = "Mac (Catalyst)"
        case .vision:
            idiomString = "Vision"
        case .unspecified:
            idiomString = "Unspecified"
        @unknown default:
            idiomString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "User Interface Idiom",
            value: idiomString
        ))

        // Dynamic Type
        let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        items.append(DeviceInfoItem(
            key: "Preferred Content Size",
            value: contentSizeCategory.rawValue,
            notes: "Dynamic Type setting chosen by the user in Settings > Accessibility."
        ))

        // Display Gamut
        let gamutString: String
        switch screen.traitCollection.displayGamut {
        case .P3: gamutString = "P3 (Wide Color)"
        case .SRGB: gamutString = "sRGB"
        case .unspecified: gamutString = "Unspecified"
        @unknown default: gamutString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Display Gamut",
            value: gamutString,
            notes: "Color space supported by the display. P3 is a wider gamut than sRGB."
        ))

        // EDR Headroom
        let edrHeadroom = screen.currentEDRHeadroom
        items.append(DeviceInfoItem(
            key: "EDR Headroom",
            value: String(format: "%.1fx", edrHeadroom),
            notes: "Extended Dynamic Range headroom. Values above 1.0 indicate HDR capability."
        ))

        // Max Refresh Rate
        items.append(DeviceInfoItem(
            key: "Max Refresh Rate",
            value: "\(screen.maximumFramesPerSecond) Hz",
            notes: "Maximum display refresh rate. 120 Hz = ProMotion adaptive refresh."
        ))

        // Interface Style
        let styleString: String
        switch UITraitCollection.current.userInterfaceStyle {
        case .dark: styleString = "Dark"
        case .light: styleString = "Light"
        case .unspecified: styleString = "Unspecified"
        @unknown default: styleString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Interface Style",
            value: styleString,
            notes: "Current appearance mode (Dark or Light) set in Settings > Display."
        ))

        // Display Zoom
        let isZoomed = screen.nativeScale != screen.scale
        items.append(DeviceInfoItem(
            key: "Display Zoom",
            value: isZoomed ? "Zoomed" : "Standard",
            notes: "Whether Display Zoom is enabled in Settings > Display. Zoomed mode makes UI elements larger."
        ))

        // Native Resolution
        if let mode = UIScreen.main.currentMode {
            items.append(DeviceInfoItem(key: "Native Resolution", value: "\(Int(mode.size.width)) × \(Int(mode.size.height)) px"))
        } else {
            items.append(DeviceInfoItem(key: "Native Resolution", value: "Unknown"))
        }

        // Available Display Modes
        let modeCount = UIScreen.main.availableModes.count
        items.append(DeviceInfoItem(key: "Available Display Modes", value: "\(modeCount)"))

        // Safe Area Insets
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let insets = window.safeAreaInsets
            items.append(DeviceInfoItem(key: "Safe Area Top", value: String(format: "%.1f pt", insets.top)))
            items.append(DeviceInfoItem(key: "Safe Area Bottom", value: String(format: "%.1f pt", insets.bottom)))
            items.append(DeviceInfoItem(key: "Safe Area Left", value: String(format: "%.1f pt", insets.left)))
            items.append(DeviceInfoItem(key: "Safe Area Right", value: String(format: "%.1f pt", insets.right)))

            // Device shape description based on insets
            let shape: String
            if insets.top > 47 {
                shape = "Dynamic Island"
            } else if insets.top > 20 {
                shape = "Notch"
            } else {
                shape = "Classic (no notch)"
            }
            items.append(DeviceInfoItem(key: "Device Shape", value: shape,
                notes: "Inferred from safe area insets. Reveals exact device generation."))
        }

        logger.debug("Display collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Display",
            icon: "display",
            items: items,
            explanation: """
            Display information includes the screen resolution in both logical points and physical \
            pixels, the scale factor (2x for Retina, 3x for Super Retina), current brightness, \
            color gamut, EDR headroom for HDR content, maximum refresh rate, appearance mode, \
            and Display Zoom status. Dynamic Type shows the preferred text size set by the user \
            in Accessibility settings.
            """
        )
    }

}
