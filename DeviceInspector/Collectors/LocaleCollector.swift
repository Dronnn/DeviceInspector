import Foundation
import UIKit
import os.log

struct LocaleCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "LocaleCollector")

    // MARK: - Locale & Region

    static func collectLocale() -> DeviceInfoSection {
        logger.debug("Collecting locale data")
        var items: [DeviceInfoItem] = []

        let locale = Locale.current

        items.append(DeviceInfoItem(
            key: "Locale Identifier",
            value: locale.identifier
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

        let measurementValue: String
        switch locale.measurementSystem {
        case .metric: measurementValue = "Metric"
        case .us: measurementValue = "US"
        case .uk: measurementValue = "UK"
        default: measurementValue = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Measurement System",
            value: measurementValue
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

        // Locale script and variant (fingerprinting vectors)
        if let script = locale.language.script {
            items.append(DeviceInfoItem(key: "Locale Script", value: script.identifier,
                notes: "Writing script variant (e.g., Hans vs Hant for Chinese). Adds fingerprint entropy."))
        }

        if let variant = locale.variant {
            items.append(DeviceInfoItem(key: "Locale Variant", value: variant.identifier,
                notes: "Regional variant of the locale. Narrows user identity when combined with region."))
        }

        let collation = Locale.current.collation
        items.append(DeviceInfoItem(key: "Collation", value: collation.identifier.isEmpty ? "Default" : collation.identifier,
            notes: "String sorting order. Most users have 'Default' but custom values add fingerprint entropy."))

        logger.debug("Locale collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Locale & Region",
            icon: "globe.europe.africa",
            items: items,
            explanation: """
            Locale & Region shows the user's regional settings including locale identifier, \
            region, currency, number formatting, and measurement system preferences. Also includes \
            timezone details (identifier, abbreviation, GMT offset, daylight saving time status) \
            and the calendar type. All data comes from Locale.current, TimeZone.current, and \
            Calendar.current.
            """
        )
    }

    // MARK: - Languages

    static func collectLanguages() -> DeviceInfoSection {
        logger.debug("Collecting languages data")
        var items: [DeviceInfoItem] = []

        let locale = Locale.current

        items.append(DeviceInfoItem(
            key: "Language Code",
            value: locale.language.languageCode?.identifier ?? "Unknown"
        ))

        let preferredLanguages = Locale.preferredLanguages.prefix(10)
        items.append(DeviceInfoItem(
            key: "Preferred Languages",
            value: preferredLanguages.joined(separator: ", "),
            notes: "Ordered list of user's preferred languages (up to 10)."
        ))

        logger.debug("Languages collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Languages",
            icon: "character.book.closed",
            items: items,
            explanation: """
            Language settings show the device's current language code and the user's preferred \
            languages in priority order. The language code comes from Locale.current, while \
            preferred languages come from Locale.preferredLanguages — the ordered list configured \
            in Settings > General > Language & Region.
            """
        )
    }

    // MARK: - System Settings

    @MainActor
    static func collectSystemSettings() -> DeviceInfoSection {
        logger.debug("Collecting system settings data")
        var items: [DeviceInfoItem] = []

        // 24-Hour Time
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeString = formatter.string(from: Date())
        let uses24Hour = !timeString.contains(formatter.amSymbol) && !timeString.contains(formatter.pmSymbol)
        items.append(DeviceInfoItem(
            key: "24-Hour Time",
            value: uses24Hour ? "Yes" : "No",
            notes: "Whether the device uses 24-hour time format vs. 12-hour AM/PM."
        ))

        // First Day of Week
        let firstWeekday = Calendar.current.firstWeekday
        let weekdayName: String
        switch firstWeekday {
        case 1: weekdayName = "Sunday"
        case 2: weekdayName = "Monday"
        case 3: weekdayName = "Tuesday"
        case 4: weekdayName = "Wednesday"
        case 5: weekdayName = "Thursday"
        case 6: weekdayName = "Friday"
        case 7: weekdayName = "Saturday"
        default: weekdayName = "Unknown (\(firstWeekday))"
        }
        items.append(DeviceInfoItem(
            key: "First Day of Week",
            value: weekdayName,
            notes: "Which day is considered the first day of the week in the user's calendar settings."
        ))

        // Temperature Unit
        let tempFormatter = MeasurementFormatter()
        tempFormatter.locale = Locale.current
        tempFormatter.unitOptions = .naturalScale
        let celsius = Measurement(value: 25, unit: UnitTemperature.celsius)
        let formatted = tempFormatter.string(from: celsius)
        let usesF = formatted.contains("F") || formatted.contains("\u{00B0}F")
        items.append(DeviceInfoItem(
            key: "Temperature Unit",
            value: usesF ? "Fahrenheit" : "Celsius",
            notes: "Temperature unit preference inferred from locale formatting of 25\u{00B0}C."
        ))

        // Active Keyboards
        let inputModes = UITextInputMode.activeInputModes
        let keyboards = inputModes.compactMap { $0.primaryLanguage }
        items.append(DeviceInfoItem(
            key: "Active Keyboards",
            value: keyboards.isEmpty ? "None detected" : keyboards.joined(separator: ", "),
            notes: "Languages/identifiers of the currently active keyboard input modes."
        ))

        // Individual keyboard languages
        items.append(DeviceInfoItem(
            key: "Keyboard Count",
            value: "\(inputModes.count)",
            notes: "Number of installed keyboard languages. A user with English + Russian + Arabic keyboards is highly distinguishable."))

        for (index, mode) in inputModes.enumerated() {
            items.append(DeviceInfoItem(
                key: "Keyboard \(index + 1)",
                value: mode.primaryLanguage ?? "Unknown",
                notes: "Language identifier for this installed keyboard input mode."))
        }

        logger.debug("System settings collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "System Settings",
            icon: "gearshape",
            items: items,
            explanation: """
            System Settings shows user preferences that affect app behavior: time format \
            (12h vs 24h), first day of the week, temperature unit, and active keyboard \
            input modes. These are derived from Locale, Calendar, MeasurementFormatter, \
            and UITextInputMode APIs.
            """
        )
    }
}
