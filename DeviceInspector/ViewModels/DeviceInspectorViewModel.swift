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

    @Published var publicIPAddress: String?
    @Published var isFetchingPublicIP = false
    @Published var isFetchingClipboard = false
    @Published var clipboardFetched = false

    @Published var isScanningBluetooth = false
    @Published var isScanningNetwork = false
    @Published var bluetoothDevicesSection: DeviceInfoSection?
    @Published var networkDevicesSection: DeviceInfoSection?
    @Published var bluetoothDetailItems: [DeviceInfoItem] = []
    @Published var networkDetailItems: [DeviceInfoItem] = []
    @Published var bluetoothDeviceCount = 0
    @Published var networkServiceCount = 0

    private let logger = Logger(subsystem: "com.deviceinspector", category: "ViewModel")

    var bluetoothManager: BluetoothManagerDelegate?
    var networkDiscoveryManager: NetworkDiscoveryManager?

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
        // Public IP (user-initiated only — not auto-fetched)
        allSections.append(publicIPSection())

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

        // Bluetooth Devices (summary only — full results in bluetoothDetailItems)
        allSections.append(bluetoothDevicesSection ?? BluetoothDevicesCollector.collectSummary(devices: []))

        // Network Devices (summary only — full results in networkDetailItems)
        allSections.append(networkDevicesSection ?? NetworkDevicesCollector.collectSummary(services: []))

        // L: GPU & AR
        allSections.append(GPUARCollector.collect())
        // M: Permission Statuses (async)
        allSections.append(await PermissionsCollector.collect())
        // N: Accessibility
        allSections.append(AccessibilityCollector.collect())
        // O: App & Bundle
        allSections.append(AppBundleCollector.collect())
        allSections.append(clipboardSection())
        allSections.append(EnvironmentSecurityCollector.collect())
        sections = allSections
        logger.debug("Collection complete: \(allSections.count) sections")
    }

    func scanBluetoothDevices() {
        guard let btManager = bluetoothManager, !isScanningBluetooth else { return }
        logger.debug("Starting Bluetooth scan")
        isScanningBluetooth = true
        btManager.startScanning()

        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            btManager.stopScanning()
            let devices = btManager.discoveredPeripherals
            bluetoothDeviceCount = devices.count
            bluetoothDetailItems = BluetoothDevicesCollector.collect(devices: devices).items
            bluetoothDevicesSection = BluetoothDevicesCollector.collectSummary(devices: devices)
            isScanningBluetooth = false
            // Update the matching section in-place with summary
            if let btSection = bluetoothDevicesSection,
               let index = sections.firstIndex(where: { $0.title == "Bluetooth Devices" }) {
                sections[index] = btSection
            }
            logger.debug("Bluetooth scan complete: \(devices.count) devices")
        }
    }

    func scanNetworkDevices() {
        guard let netManager = networkDiscoveryManager, !isScanningNetwork else { return }
        logger.debug("Starting network discovery")
        isScanningNetwork = true
        netManager.startScanning()

        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            netManager.stopScanning()
            let services = netManager.discoveredServices
            networkServiceCount = services.count
            networkDetailItems = NetworkDevicesCollector.collect(services: services).items
            networkDevicesSection = NetworkDevicesCollector.collectSummary(services: services)
            isScanningNetwork = false
            // Update the matching section in-place with summary
            if let netSection = networkDevicesSection,
               let index = sections.firstIndex(where: { $0.title == "Network Devices" }) {
                sections[index] = netSection
            }
            logger.debug("Network scan complete: \(services.count) services")
        }
    }

    private func publicIPSection() -> DeviceInfoSection {
        if let ip = publicIPAddress {
            return DeviceInfoSection(
                title: "Public IP",
                icon: "globe",
                items: [
                    DeviceInfoItem(
                        key: "Public IP",
                        value: ip,
                        isSensitive: true
                    )
                ],
                explanation: """
                Public IP shows the external IP address visible to the internet for this device. \
                Obtained by querying the ipify.org API. Marked as sensitive because it can reveal \
                your approximate location and ISP. Requires an active internet connection. \
                This request is only made when you tap "Determine Public IP".
                """
            )
        } else {
            return DeviceInfoSection(
                title: "Public IP",
                icon: "globe",
                items: [
                    DeviceInfoItem(
                        key: "Public IP",
                        value: "Not yet determined",
                        notes: "Tap \"Determine Public IP\" to fetch your public IP address from ipify.org."
                    )
                ],
                explanation: """
                Public IP shows the external IP address visible to the internet for this device. \
                Obtained by querying the ipify.org API. Marked as sensitive because it can reveal \
                your approximate location and ISP. Requires an active internet connection. \
                This request is only made when you tap "Determine Public IP".
                """
            )
        }
    }

    func fetchPublicIP() {
        guard !isFetchingPublicIP else { return }
        isFetchingPublicIP = true
        Task {
            let section = await ExtendedNetworkCollector.collectPublicIP()
            let ipValues = section.items.compactMap { item -> String? in
                item.value != "Unavailable" ? "\(item.key): \(item.value)" : nil
            }
            publicIPAddress = ipValues.isEmpty ? "Unavailable" : ipValues.joined(separator: "\n")
            if let index = sections.firstIndex(where: { $0.title == "Public IP" }) {
                sections[index] = section
            }
            isFetchingPublicIP = false
            logger.debug("Public IP fetched on user request")
        }
    }

    private func clipboardSection() -> DeviceInfoSection {
        if clipboardFetched {
            return ClipboardCollector.collect()
        } else {
            return DeviceInfoSection(
                title: "Clipboard",
                icon: "clipboard",
                items: [
                    DeviceInfoItem(
                        key: "Clipboard",
                        value: "Not yet inspected",
                        notes: "Tap \"Inspect Clipboard\" to check current clipboard metadata."
                    )
                ],
                explanation: """
                Clipboard shows metadata about the current contents of the system pasteboard \
                (UIPasteboard.general). This includes whether text, images, or URLs are present \
                and the total item count. The actual clipboard content is not read — only its \
                type indicators are checked using hasStrings, hasImages, and hasURLs. \
                This check is only performed when you tap "Inspect Clipboard".
                """
            )
        }
    }

    func fetchClipboard() {
        guard !isFetchingClipboard else { return }
        isFetchingClipboard = true
        let section = ClipboardCollector.collect()
        clipboardFetched = true
        if let index = sections.firstIndex(where: { $0.title == "Clipboard" }) {
            sections[index] = section
        }
        isFetchingClipboard = false
        logger.debug("Clipboard inspected on user request")
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
        let exportSections: [DeviceInfoSection]
        if privacyMode {
            exportSections = sections.map { section in
                var masked = section
                masked.items = section.items.map { item in
                    guard item.isSensitive else { return item }
                    var maskedItem = item
                    maskedItem.value = String(repeating: "\u{2022}", count: 8)
                    return maskedItem
                }
                return masked
            }
        } else {
            exportSections = sections
        }
        do {
            let data = try encoder.encode(exportSections)
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
