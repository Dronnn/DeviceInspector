import UIKit
import os.log

struct DisplayCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "DisplayCollector")

    @MainActor
    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting display and locale data")

        var items: [DeviceInfoItem] = []

        // MARK: - Screen Information

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

        // MARK: - User Interface

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

        // MARK: - Locale

        let locale = Locale.current

        items.append(DeviceInfoItem(
            key: "Locale Identifier",
            value: locale.identifier
        ))

        let languageCode = locale.language.languageCode?.identifier ?? "Unknown"
        items.append(DeviceInfoItem(
            key: "Language Code",
            value: languageCode
        ))

        let regionCode = locale.region?.identifier ?? "Unknown"
        items.append(DeviceInfoItem(
            key: "Region Code",
            value: regionCode
        ))

        // MARK: - TimeZone

        let timeZone = TimeZone.current

        items.append(DeviceInfoItem(
            key: "Time Zone Identifier",
            value: timeZone.identifier
        ))

        items.append(DeviceInfoItem(
            key: "Time Zone Abbreviation",
            value: timeZone.abbreviation() ?? "Unknown"
        ))

        let gmtOffset = timeZone.secondsFromGMT()
        let gmtHours = gmtOffset / 3600
        let gmtMinutes = abs(gmtOffset % 3600) / 60
        let gmtString = String(format: "UTC%+d:%02d (%d seconds)", gmtHours, gmtMinutes, gmtOffset)
        items.append(DeviceInfoItem(
            key: "GMT Offset",
            value: gmtString
        ))

        // MARK: - Calendar

        let calendar = Calendar.current
        items.append(DeviceInfoItem(
            key: "Calendar Identifier",
            value: calendar.identifier.debugDescription
        ))

        logger.debug("Display collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Display & Locale",
            icon: "display",
            items: items,
            explanation: """
            Display information includes the screen resolution in both logical points and physical \
            pixels, the scale factor (2x for Retina, 3x for Super Retina), and current brightness. \
            Locale information reflects the user's language, region, time zone, and calendar settings. \
            Dynamic Type shows the preferred text size set by the user in Accessibility settings. \
            Screen brightness is a live value and changes as the user adjusts it.
            """
        )
    }
}
