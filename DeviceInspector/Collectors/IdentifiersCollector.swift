import UIKit
import AdSupport
import AppTrackingTransparency
import os.log

struct IdentifiersCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "IdentifiersCollector")

    @MainActor
    static func collect(attAuthorized: Bool) -> DeviceInfoSection {
        logger.debug("Collecting identifier data (attAuthorized: \(attAuthorized))")

        var items: [DeviceInfoItem] = []

        // MARK: - Identifier For Vendor (IDFV)

        let idfv = UIDevice.current.identifierForVendor?.uuidString ?? "Not available"
        items.append(DeviceInfoItem(
            key: "Identifier For Vendor (IDFV)",
            value: idfv,
            notes: """
            Unique per vendor (developer account). Resets if all apps from this vendor are \
            uninstalled. Same across all apps from the same vendor on the same device.
            """,
            isSensitive: true
        ))

        // MARK: - Advertising Identifier (IDFA)

        if attAuthorized {
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            let isAllZeros = idfa == "00000000-0000-0000-0000-000000000000"
            items.append(DeviceInfoItem(
                key: "Advertising Identifier (IDFA)",
                value: isAllZeros ? "Zeroed out (tracking limited)" : idfa,
                availability: .available,
                notes: """
                Advertising identifier for cross-app attribution. ATT permission is granted. \
                If zeroed out, the user has globally disabled ad tracking in Settings.
                """,
                isSensitive: true
            ))
        } else {
            let currentStatus = ATTrackingManager.trackingAuthorizationStatus
            let statusDescription: String
            switch currentStatus {
            case .notDetermined:
                statusDescription = "Not yet requested"
            case .restricted:
                statusDescription = "Restricted (parental controls or MDM)"
            case .denied:
                statusDescription = "Denied by user"
            case .authorized:
                statusDescription = "Authorized"
            @unknown default:
                statusDescription = "Unknown"
            }

            items.append(DeviceInfoItem(
                key: "Advertising Identifier (IDFA)",
                value: "Not authorized (\(statusDescription))",
                availability: .requiresPermission,
                notes: """
                Requires App Tracking Transparency (ATT) permission. The user must explicitly \
                grant tracking authorization via the ATT prompt before the IDFA can be read.
                """,
                isSensitive: true
            ))
        }

        // MARK: - ATT Status

        let attStatus = ATTrackingManager.trackingAuthorizationStatus
        let attStatusString: String
        switch attStatus {
        case .notDetermined:
            attStatusString = "Not Determined"
        case .restricted:
            attStatusString = "Restricted"
        case .denied:
            attStatusString = "Denied"
        case .authorized:
            attStatusString = "Authorized"
        @unknown default:
            attStatusString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "ATT Authorization Status",
            value: attStatusString,
            notes: "Current App Tracking Transparency status. Controls access to IDFA."
        ))

        // MARK: - Globally Unique String

        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        items.append(DeviceInfoItem(
            key: "Globally Unique String",
            value: uniqueString,
            notes: """
            Temporary unique string, changes every call. Not a stable device ID. \
            Generated using a combination of host name, process ID, and timestamp.
            """
        ))

        logger.debug("Identifiers collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Identifiers",
            icon: "person.badge.key",
            items: items,
            explanation: """
            iOS provides several types of identifiers, each with different privacy implications. \
            The Identifier For Vendor (IDFV) is unique per developer and resets when all apps from \
            that developer are removed. The Advertising Identifier (IDFA) is a cross-app identifier \
            that requires explicit App Tracking Transparency (ATT) permission. The globally unique \
            string is a one-time value that changes on every access and is not suitable as a \
            persistent identifier. iOS intentionally limits access to stable device identifiers \
            to protect user privacy.
            """
        )
    }
}
