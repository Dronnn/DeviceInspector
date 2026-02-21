import CoreNFC
import CoreBluetooth
import NearbyInteraction
import os.log

struct WirelessCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "WirelessCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting wireless data")
        var items: [DeviceInfoItem] = []

        // NFC
        let nfcAvailable = NFCReaderSession.readingAvailable
        items.append(DeviceInfoItem(
            key: "NFC Reading",
            value: nfcAvailable ? "Supported" : "Not Supported",
            notes: nfcAvailable
                ? "Device supports reading NFC tags (NDEF, ISO 7816, etc.)."
                : "NFC reading not available. Requires iPhone 7 or later."
        ))

        // Bluetooth authorization (type property, no prompt)
        let btAuth = CBCentralManager.authorization
        let btStatus: String
        switch btAuth {
        case .notDetermined: btStatus = "Not Determined"
        case .restricted: btStatus = "Restricted"
        case .denied: btStatus = "Denied"
        case .allowedAlways: btStatus = "Allowed Always"
        @unknown default: btStatus = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Bluetooth Authorization",
            value: btStatus,
            availability: btAuth == .allowedAlways ? .available : .requiresPermission,
            notes: "Current Bluetooth authorization status. Reading this does not trigger a permission prompt."
        ))

        // UWB (Ultra Wideband)
        if #available(iOS 16.0, *) {
            let supportsUWB = NISession.deviceCapabilities.supportsPreciseDistanceMeasurement
            items.append(DeviceInfoItem(
                key: "Ultra Wideband (UWB)",
                value: supportsUWB ? "Supported" : "Not Supported",
                notes: supportsUWB
                    ? "Device has U1 chip for precise spatial awareness and distance measurement."
                    : "UWB not available. Requires iPhone 11 or later with U1/U2 chip."
            ))
        } else {
            items.append(DeviceInfoItem(
                key: "Ultra Wideband (UWB)",
                value: "Check requires iOS 16+",
                availability: .notAvailable,
                notes: "NISession.deviceCapabilities requires iOS 16.0 or later."
            ))
        }

        logger.debug("Wireless collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Wireless Technologies",
            icon: "antenna.radiowaves.left.and.right",
            items: items,
            explanation: """
            Wireless Technologies shows the availability of NFC, Bluetooth, and Ultra Wideband (UWB) \
            on this device. NFC reading requires iPhone 7 or later. Bluetooth authorization status \
            is read without triggering a permission prompt. UWB (U1 chip) enables precise distance \
            measurement and is available on iPhone 11 and later. Uses CoreNFC, CoreBluetooth, and \
            NearbyInteraction frameworks.
            """
        )
    }
}
