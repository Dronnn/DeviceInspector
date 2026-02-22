import AppTrackingTransparency
import AdSupport
import AdServices
import os.log

struct TrackingCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "TrackingCollector")

    static func collect(attStatus: ATTrackingManager.AuthorizationStatus) -> DeviceInfoSection {
        logger.debug("Collecting tracking data")
        var items: [DeviceInfoItem] = []

        // 1. Tracking Authorization Status
        let statusText: String
        switch attStatus {
        case .notDetermined: statusText = "Not Determined"
        case .restricted: statusText = "Restricted"
        case .denied: statusText = "Denied"
        case .authorized: statusText = "Authorized"
        @unknown default: statusText = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Tracking Authorization Status",
            value: statusText,
            notes: "Current App Tracking Transparency permission level."
        ))

        // 2. Device Tracking Restriction
        items.append(DeviceInfoItem(
            key: "Device Tracking Restriction",
            value: attStatus == .restricted ? "Restricted" : "Not Restricted",
            notes: attStatus == .restricted
                ? "Tracking is restricted at the device level (parental controls or MDM)."
                : "No device-level restriction on tracking."
        ))

        // 3. IDFA (Advertising Identifier) — ALWAYS show the value
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        items.append(DeviceInfoItem(
            key: "IDFA (Advertising Identifier)",
            value: idfa,
            notes: attStatus == .authorized
                ? "Unique device identifier for targeted advertising."
                : "Returns all zeros when tracking is not authorized.",
            isSensitive: true
        ))

        // 4. IDFA Is Zeroed
        let isZeroed = ASIdentifierManager.shared().advertisingIdentifier == UUID(uuidString: "00000000-0000-0000-0000-000000000000")
        items.append(DeviceInfoItem(
            key: "IDFA Is Zeroed",
            value: isZeroed ? "Yes" : "No",
            notes: isZeroed
                ? "IDFA is all zeros — tracking is not authorized or disabled."
                : "IDFA contains a real identifier — tracking is authorized."
        ))

        // 5. AdServices Attribution Available
        var attributionAvailable = false
        do {
            let _ = try AAAttribution.attributionToken()
            attributionAvailable = true
        } catch {
            attributionAvailable = false
        }
        items.append(DeviceInfoItem(
            key: "AdServices Attribution",
            value: attributionAvailable ? "Available" : "Not Available",
            notes: "Whether Apple AdServices can provide an attribution token for Apple Search Ads measurement."
        ))

        logger.debug("Tracking collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Tracking",
            icon: "hand.raised",
            items: items,
            explanation: """
            App Tracking Transparency (ATT) controls whether apps can track your activity across \
            other companies' apps and websites. When authorized, apps can access the Identifier for \
            Advertisers (IDFA), a unique device-level ID used for targeted advertising. Without \
            permission, the IDFA returns all zeros.
            """
        )
    }
}
