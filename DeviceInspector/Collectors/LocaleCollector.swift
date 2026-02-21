import Foundation
import os.log

struct LocaleCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "LocaleCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting locale data")
        var items: [DeviceInfoItem] = []

        let locale = Locale.current

        items.append(DeviceInfoItem(
            key: "Locale Identifier",
            value: locale.identifier
        ))

        items.append(DeviceInfoItem(
            key: "Language Code",
            value: locale.language.languageCode?.identifier ?? "Unknown"
        ))

        items.append(DeviceInfoItem(
            key: "Region Code",
            value: locale.region?.identifier ?? "Unknown"
        ))

        items.append(DeviceInfoItem(
            key: "Currency Code",
            value: locale.currency?.identifier ?? "Unknown"
        ))

        items.append(DeviceInfoItem(
            key: "Currency Symbol",
            value: locale.currencySymbol ?? "Unknown"
        ))

        items.append(DeviceInfoItem(
            key: "Decimal Separator",
            value: locale.decimalSeparator ?? "Unknown"
        ))

        items.append(DeviceInfoItem(
            key: "Grouping Separator",
            value: locale.groupingSeparator ?? "Unknown",
            notes: "Thousands separator character."
        ))

        items.append(DeviceInfoItem(
            key: "Uses Metric System",
            value: locale.usesMetricSystem ? "Yes" : "No"
        ))

        // Preferred languages (first 10)
        let preferredLanguages = Locale.preferredLanguages.prefix(10)
        items.append(DeviceInfoItem(
            key: "Preferred Languages",
            value: preferredLanguages.joined(separator: ", "),
            notes: "Ordered list of user's preferred languages (up to 10)."
        ))

        // TimeZone
        let tz = TimeZone.current
        items.append(DeviceInfoItem(
            key: "Timezone Identifier",
            value: tz.identifier
        ))

        items.append(DeviceInfoItem(
            key: "Timezone Abbreviation",
            value: tz.abbreviation() ?? "Unknown"
        ))

        let gmtOffset = tz.secondsFromGMT()
        let hours = gmtOffset / 3600
        let minutes = abs(gmtOffset % 3600) / 60
        let offsetString = minutes == 0
            ? "UTC\(hours >= 0 ? "+" : "")\(hours)"
            : "UTC\(hours >= 0 ? "+" : "")\(hours):\(String(format: "%02d", minutes))"
        items.append(DeviceInfoItem(
            key: "GMT Offset",
            value: "\(offsetString) (\(gmtOffset) seconds)",
            notes: "Offset from UTC/GMT in seconds."
        ))

        items.append(DeviceInfoItem(
            key: "Daylight Saving Time Active",
            value: tz.isDaylightSavingTime() ? "Yes" : "No"
        ))

        if let nextDST = tz.nextDaylightSavingTimeTransition {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            items.append(DeviceInfoItem(
                key: "Next DST Transition",
                value: formatter.string(from: nextDST)
            ))
        } else {
            items.append(DeviceInfoItem(
                key: "Next DST Transition",
                value: "None",
                notes: "This timezone does not observe daylight saving time."
            ))
        }

        // Calendar
        items.append(DeviceInfoItem(
            key: "Calendar Identifier",
            value: Calendar.current.identifier.debugDescription
        ))

        logger.debug("Locale collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Locale & Languages",
            icon: "globe",
            items: items,
            explanation: """
            Locale & Languages shows the user's locale settings including language, region, \
            currency, number formatting, and measurement system preferences. Also includes \
            timezone details (identifier, abbreviation, GMT offset, daylight saving time status) \
            and the calendar type. Preferred languages are listed in the user's priority order. \
            All data comes from Locale.current, TimeZone.current, and Calendar.current.
            """
        )
    }
}
