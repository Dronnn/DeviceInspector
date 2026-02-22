import UIKit
import os.log

struct FontCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "FontCollector")

    private static let sectionExplanation = """
        Font enumeration is a classic browser and app fingerprinting technique. Different iOS versions \
        ship different sets of system fonts, so the exact list of font families and faces can reveal \
        the OS version, region, and even whether the device is managed by an enterprise (which may \
        install custom fonts). Custom or enterprise-provisioned fonts are particularly unique \
        identifiers because they narrow the device population to a specific organization.
        """

    // MARK: - Summary (for main list)

    static func collectSummary() -> DeviceInfoSection {
        logger.debug("Collecting font summary")

        var items: [DeviceInfoItem] = []

        let families = UIFont.familyNames
        items.append(DeviceInfoItem(
            key: "Font Families",
            value: "\(families.count)"
        ))

        let totalFonts = families.reduce(0) { $0 + UIFont.fontNames(forFamilyName: $1).count }
        items.append(DeviceInfoItem(
            key: "Total Fonts",
            value: "\(totalFonts)"
        ))

        logger.debug("Font summary complete: \(items.count) items")

        return DeviceInfoSection(
            title: "System Fonts",
            icon: "textformat",
            items: items,
            explanation: sectionExplanation
        )
    }

    // MARK: - Full Detail (for detail sheet)

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting full font list")

        var items: [DeviceInfoItem] = []

        let families = UIFont.familyNames.sorted()
        for family in families {
            let fontNames = UIFont.fontNames(forFamilyName: family)
            items.append(DeviceInfoItem(
                key: "Family — \(family)",
                value: fontNames.joined(separator: ", ")
            ))
        }

        logger.debug("Font collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "System Fonts",
            icon: "textformat",
            items: items,
            explanation: sectionExplanation
        )
    }
}
