import SwiftUI
import CoreLocation
import AppTrackingTransparency
import os.log

@MainActor
final class DeviceInspectorViewModel: ObservableObject {
    @Published var sections: [DeviceInfoSection] = []
    @Published var isLoading = false
    @Published var privacyMode = true
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published var attStatus: ATTrackingManager.AuthorizationStatus = .notDetermined

    private let logger = Logger(subsystem: "com.deviceinspector", category: "ViewModel")

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        logger.debug("Starting device info collection")

        var allSections: [DeviceInfoSection] = []

        allSections.append(ProcessInfoCollector.collect())
        allSections.append(UIDeviceCollector.collect())
        allSections.append(HardwareCollector.collect())
        allSections.append(DisplayCollector.collectDisplay())
        allSections.append(LocaleCollector.collectLocale())
        allSections.append(LocaleCollector.collectLanguages())
        allSections.append(LocaleCollector.collectSystemSettings())
        allSections.append(StorageCollector.collect())
        // Network: IP Addresses
        allSections.append(NetworkCollector.collectIPAddresses())
        // Network: WiFi
        allSections.append(
            NetworkCollector.collectWiFiInfo(
                locationAuthorized: locationStatus == .authorizedWhenInUse
                    || locationStatus == .authorizedAlways
            )
        )
        // Network: Cellular (one section per SIM)
        allSections.append(contentsOf: NetworkCollector.collectCellularInfo())
        // WiFi Extras (Security Type + RSSI, inserted into existing WiFi section)
        if #available(iOS 15.0, *) {
            let wifiExtras = await NetworkCollector.collectWiFiExtras()
            if !wifiExtras.isEmpty, let wifiIndex = allSections.firstIndex(where: { $0.title == "WiFi" }) {
                allSections[wifiIndex].items.append(contentsOf: wifiExtras)
            }
        }
        // Extended Network (proxy, VPN, NWPath) — right after WiFi/Cellular
        allSections.append(ExtendedNetworkCollector.collect())
        // DNS Servers
        allSections.append(ExtendedNetworkCollector.collectDNSServers())
        // Public IP
        allSections.append(await ExtendedNetworkCollector.collectPublicIP())

        allSections.append(
            IdentifiersCollector.collect(
                attAuthorized: attStatus == .authorized
            )
        )

        // H: Biometrics & Security
        allSections.append(BiometricsCollector.collect())
        // I: Sensors & Motion
        allSections.append(SensorsCollector.collect())
        // J: Camera & Audio
        allSections.append(CameraAudioCollector.collect())
        // K: Wireless Technologies
        allSections.append(WirelessCollector.collect())
        // L: GPU & AR
        allSections.append(GPUARCollector.collect())
        // M: Permission Statuses (async)
        allSections.append(await PermissionsCollector.collect())
        // N: Accessibility
        allSections.append(AccessibilityCollector.collect())
        // O: App & Bundle
        allSections.append(AppBundleCollector.collect())
        allSections.append(ClipboardCollector.collect())
        allSections.append(EnvironmentSecurityCollector.collect())
        sections = allSections
        logger.debug("Collection complete: \(allSections.count) sections")
    }

    func requestLocationPermission() {
        // Handled by LocationManagerDelegate bound to the view
    }

    func requestATTPermission() async {
        let status = await ATTrackingManager.requestTrackingAuthorization()
        attStatus = status
        logger.debug("ATT status: \(String(describing: status))")
    }

    func exportJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            let data = try encoder.encode(sections)
            logger.debug("JSON export: \(data.count) bytes")
            return data
        } catch {
            logger.error("JSON export failed: \(error.localizedDescription)")
            return nil
        }
    }

    func copyAllToClipboard() {
        var text = ""
        for section in sections {
            text += "=== \(section.title) ===\n"
            for item in section.items {
                let value = (privacyMode && item.isSensitive) ? "[Hidden]" : item.value
                text += "  \(item.key): \(value)\n"
                if let notes = item.notes {
                    text += "    Note: \(notes)\n"
                }
                text += "    Status: \(item.availability.rawValue)\n"
            }
            text += "\n"
        }
        UIPasteboard.general.string = text
        logger.debug("Copied all data to clipboard")
    }
}
