import Foundation
import Darwin
import SystemConfiguration.CaptiveNetwork
import CoreTelephony
import os.log

struct NetworkCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "NetworkCollector")

    // MARK: - IP Addresses

    static func collectIPAddresses() -> DeviceInfoSection {
        logger.debug("Collecting IP address data")
        var items: [DeviceInfoItem] = []

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            logger.debug("getifaddrs failed")
            items.append(DeviceInfoItem(
                key: "IP Addresses",
                value: "Failed to enumerate network interfaces",
                availability: .notAvailable
            ))
            return DeviceInfoSection(
                title: "IP Addresses",
                icon: "network",
                items: items,
                explanation: """
                IP addresses from all active network interfaces. The POSIX getifaddrs API enumerates \
                every interface: en0 is typically WiFi, pdp_ip0 is cellular, lo0 is loopback, utun \
                interfaces are VPN tunnels, and awdl0 is Apple Wireless Direct Link (AirDrop/AirPlay).
                """
            )
        }
        defer { freeifaddrs(ifaddr) }

        var interfaceAddresses: [(name: String, family: String, address: String)] = []

        var currentAddr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = currentAddr {
            let interface = addr.pointee
            let family = interface.ifa_addr.pointee.sa_family

            if family == UInt8(AF_INET) || family == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                let familyName = family == UInt8(AF_INET) ? "IPv4" : "IPv6"

                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let result = getnameinfo(
                    interface.ifa_addr,
                    socklen_t(interface.ifa_addr.pointee.sa_len),
                    &hostname,
                    socklen_t(hostname.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                )

                if result == 0 {
                    let address = String(cString: hostname)
                    interfaceAddresses.append((name: name, family: familyName, address: address))
                }
            }

            currentAddr = interface.ifa_next
        }

        if interfaceAddresses.isEmpty {
            items.append(DeviceInfoItem(
                key: "IP Addresses",
                value: "No active network interfaces found"
            ))
        } else {
            // Group and label known interfaces
            for entry in interfaceAddresses {
                let label = interfaceLabel(for: entry.name)
                items.append(DeviceInfoItem(
                    key: "\(entry.name) (\(label)) \(entry.family)",
                    value: entry.address,
                    notes: "Network interface \(entry.name) - \(label)"
                ))
            }
        }

        logger.debug("IP address collection complete: \(items.count) items")
        return DeviceInfoSection(
            title: "IP Addresses",
            icon: "network",
            items: items,
            explanation: """
            IP addresses from all active network interfaces. The POSIX getifaddrs API enumerates \
            every interface: en0 is typically WiFi, pdp_ip0 is cellular, lo0 is loopback, utun \
            interfaces are VPN tunnels, and awdl0 is Apple Wireless Direct Link (AirDrop/AirPlay).
            """
        )
    }

    private static func interfaceLabel(for name: String) -> String {
        switch name {
        case "en0": return "WiFi"
        case "en1": return "WiFi (secondary)"
        case "en2": return "Ethernet/USB"
        case "pdp_ip0": return "Cellular"
        case "pdp_ip1": return "Cellular (secondary)"
        case "pdp_ip2": return "Cellular (tertiary)"
        case "pdp_ip3": return "Cellular (quaternary)"
        case "lo0": return "Loopback"
        case "awdl0": return "Apple Wireless Direct Link"
        case "utun0": return "VPN Tunnel"
        case "utun1": return "VPN Tunnel (secondary)"
        case "utun2": return "VPN Tunnel (tertiary)"
        case "ipsec0": return "IPSec VPN"
        default:
            if name.hasPrefix("en") { return "Ethernet" }
            if name.hasPrefix("pdp_ip") { return "Cellular" }
            if name.hasPrefix("utun") { return "VPN Tunnel" }
            return "Other"
        }
    }

    // MARK: - WiFi Info

    static func collectWiFiInfo(locationAuthorized: Bool) -> DeviceInfoSection {
        logger.debug("Collecting WiFi data (locationAuthorized: \(locationAuthorized))")
        var items: [DeviceInfoItem] = []

        let wifiRequirements = """
        Requires: 1) "Access WiFi Information" entitlement, \
        2) Location permission (When In Use), \
        3) NSLocationWhenInUseUsageDescription in Info.plist.
        """

        guard locationAuthorized else {
            items.append(DeviceInfoItem(
                key: "WiFi SSID",
                value: "Location not authorized",
                availability: .requiresPermission,
                notes: wifiRequirements,
                isSensitive: true
            ))
            items.append(DeviceInfoItem(
                key: "WiFi BSSID",
                value: "Location not authorized",
                availability: .requiresPermission,
                notes: wifiRequirements,
                isSensitive: true
            ))
            logger.debug("WiFi collection complete: \(items.count) items (location not authorized)")
            return wifiSection(items: items)
        }

        var ssid: String?
        var bssid: String?

        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let networkInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                    ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String
                    bssid = networkInfo[kCNNetworkInfoKeyBSSID as String] as? String
                    break
                }
            }
        }

        items.append(DeviceInfoItem(
            key: "WiFi SSID",
            value: ssid ?? "Not available",
            availability: ssid != nil ? .available : .requiresPermission,
            notes: ssid == nil ? wifiRequirements : "Name of the currently connected WiFi network.",
            isSensitive: true
        ))

        items.append(DeviceInfoItem(
            key: "WiFi BSSID",
            value: bssid ?? "Not available",
            availability: bssid != nil ? .available : .requiresPermission,
            notes: bssid == nil ? wifiRequirements : "MAC address of the WiFi access point.",
            isSensitive: true
        ))

        logger.debug("WiFi collection complete: \(items.count) items")
        return wifiSection(items: items)
    }

    private static func wifiSection(items: [DeviceInfoItem]) -> DeviceInfoSection {
        DeviceInfoSection(
            title: "WiFi",
            icon: "wifi",
            items: items,
            explanation: """
            WiFi network details obtained via CNCopyCurrentNetworkInfo. Requires the \
            "Access WiFi Information" entitlement, location permission (When In Use), \
            and NSLocationWhenInUseUsageDescription in Info.plist.
            """
        )
    }

    // MARK: - Cellular Info

    private static func isDeprecatedPlaceholder(_ value: String?) -> Bool {
        guard let value = value else { return true }
        return value.isEmpty || value == "--" || value == "65535"
    }

    @available(iOS, deprecated: 16.0, message: "CTCarrier is deprecated but still functional")
    static func collectCellularInfo() -> [DeviceInfoSection] {
        logger.debug("Collecting cellular data")

        let networkInfo = CTTelephonyNetworkInfo()
        let carriers = networkInfo.serviceSubscriberCellularProviders
        let radioTechs = networkInfo.serviceCurrentRadioAccessTechnology

        let cellularExplanation = """
        Carrier information for this SIM via CoreTelephony. Includes carrier name, country codes, \
        and the current radio access technology (e.g. LTE, 5G). Note: CTCarrier is deprecated \
        in iOS 16+ but remains functional.
        """

        guard let carriers = carriers, !carriers.isEmpty else {
            // No SIMs available
            let items = [
                DeviceInfoItem(
                    key: "Carrier Info",
                    value: "Not available",
                    notes: "No carrier data available. Device may not have a SIM card or may be WiFi-only."
                ),
                DeviceInfoItem(
                    key: "Radio Access Technology",
                    value: "Not available",
                    notes: "No active cellular connection or WiFi-only device."
                )
            ]
            logger.debug("Cellular collection complete: no SIMs, \(items.count) items")
            return [DeviceInfoSection(
                title: "Cellular",
                icon: "antenna.radiowaves.left.and.right",
                items: items,
                explanation: cellularExplanation
            )]
        }

        let sortedCarriers = carriers.sorted { $0.key < $1.key }
        var sections: [DeviceInfoSection] = []

        for (index, (serviceID, carrier)) in sortedCarriers.enumerated() {
            var items: [DeviceInfoItem] = []

            let carrierName = carrier.carrierName
            if isDeprecatedPlaceholder(carrierName) {
                items.append(DeviceInfoItem(
                    key: "Carrier Name",
                    value: "Not available",
                    availability: .notAvailable,
                    notes: "CTCarrier is deprecated in iOS 16+. Apple no longer provides carrier name data to third-party apps."
                ))
            } else {
                items.append(DeviceInfoItem(
                    key: "Carrier Name",
                    value: carrierName!
                ))
            }

            let mcc = carrier.mobileCountryCode
            if isDeprecatedPlaceholder(mcc) {
                items.append(DeviceInfoItem(
                    key: "Mobile Country Code (MCC)",
                    value: "Not available",
                    availability: .notAvailable,
                    notes: "CTCarrier is deprecated in iOS 16+. Mobile Country Code is no longer accessible."
                ))
            } else {
                items.append(DeviceInfoItem(
                    key: "Mobile Country Code (MCC)",
                    value: mcc!,
                    notes: "ISO country code of the carrier's home network."
                ))
            }

            let mnc = carrier.mobileNetworkCode
            if isDeprecatedPlaceholder(mnc) {
                items.append(DeviceInfoItem(
                    key: "Mobile Network Code (MNC)",
                    value: "Not available",
                    availability: .notAvailable,
                    notes: "CTCarrier is deprecated in iOS 16+. Mobile Network Code is no longer accessible."
                ))
            } else {
                items.append(DeviceInfoItem(
                    key: "Mobile Network Code (MNC)",
                    value: mnc!,
                    notes: "Network code identifying the carrier within the country."
                ))
            }

            let isoCode = carrier.isoCountryCode
            if isDeprecatedPlaceholder(isoCode) {
                items.append(DeviceInfoItem(
                    key: "ISO Country Code",
                    value: "Not available",
                    availability: .notAvailable,
                    notes: "CTCarrier is deprecated in iOS 16+. ISO Country Code is no longer accessible."
                ))
            } else {
                items.append(DeviceInfoItem(
                    key: "ISO Country Code",
                    value: isoCode!
                ))
            }

            items.append(DeviceInfoItem(
                key: "Allows VoIP",
                value: carrier.allowsVOIP ? "Yes" : "No"
            ))

            // Radio access technology matched by serviceID
            if let tech = radioTechs?[serviceID] {
                let humanTech = humanReadableRadioTech(tech)
                items.append(DeviceInfoItem(
                    key: "Radio Access Technology",
                    value: humanTech,
                    notes: "Current cellular connection technology."
                ))
            } else {
                items.append(DeviceInfoItem(
                    key: "Radio Access Technology",
                    value: "Not available",
                    notes: "No active cellular connection for this SIM."
                ))
            }

            let title: String
            if carriers.count == 1 {
                title = "Cellular"
            } else {
                title = "Cellular — SIM \(index + 1)"
            }

            sections.append(DeviceInfoSection(
                title: title,
                icon: "antenna.radiowaves.left.and.right",
                items: items,
                explanation: cellularExplanation
            ))
        }

        logger.debug("Cellular collection complete: \(sections.count) sections")
        return sections
    }

    private static func humanReadableRadioTech(_ tech: String) -> String {
        switch tech {
        case CTRadioAccessTechnologyGPRS: return "GPRS (2G)"
        case CTRadioAccessTechnologyEdge: return "EDGE (2G)"
        case CTRadioAccessTechnologyWCDMA: return "WCDMA (3G)"
        case CTRadioAccessTechnologyHSDPA: return "HSDPA (3G)"
        case CTRadioAccessTechnologyHSUPA: return "HSUPA (3G)"
        case CTRadioAccessTechnologyCDMA1x: return "CDMA 1x (2G)"
        case CTRadioAccessTechnologyCDMAEVDORev0: return "CDMA EVDO Rev. 0 (3G)"
        case CTRadioAccessTechnologyCDMAEVDORevA: return "CDMA EVDO Rev. A (3G)"
        case CTRadioAccessTechnologyCDMAEVDORevB: return "CDMA EVDO Rev. B (3G)"
        case CTRadioAccessTechnologyeHRPD: return "eHRPD (3G)"
        case CTRadioAccessTechnologyLTE: return "LTE (4G)"
        default:
            if #available(iOS 14.1, *) {
                if tech == CTRadioAccessTechnologyNRNSA { return "5G NR NSA" }
                if tech == CTRadioAccessTechnologyNR { return "5G NR" }
            }
            return tech
        }
    }
}
