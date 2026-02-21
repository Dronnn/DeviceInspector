import Foundation
import os.log

struct NetworkDevicesCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "NetworkDevicesCollector")

    private static let serviceTypeLabels: [String: String] = [
        "_http._tcp": "Web Server",
        "_airplay._tcp": "AirPlay",
        "_raop._tcp": "AirPlay Audio",
        "_homekit._tcp": "HomeKit",
        "_printer._tcp": "Printer",
        "_ipp._tcp": "IPP Printer",
        "_smb._tcp": "SMB File Sharing",
        "_ssh._tcp": "SSH Server",
        "_googlecast._tcp": "Chromecast",
        "_spotify-connect._tcp": "Spotify Connect",
        "_companion-link._tcp": "Apple Companion",
        "_sleep-proxy._udp": "Sleep Proxy"
    ]

    static func collect(services: [DiscoveredNetworkService]) -> DeviceInfoSection {
        logger.debug("Collecting network device data for \(services.count) services")
        var items: [DeviceInfoItem] = []

        if services.isEmpty {
            items.append(DeviceInfoItem(
                key: "No Network Devices",
                value: "Tap Scan to discover devices on your local network",
                notes: "Discovery uses Bonjour (mDNS) to find services. Requires local network permission."
            ))
        } else {
            for (index, service) in services.enumerated() {
                let prefix = "Net Device \(index + 1)"
                let typeLabel = serviceTypeLabels[service.serviceType] ?? service.serviceType

                items.append(DeviceInfoItem(
                    key: "\(prefix) — Name",
                    value: service.name,
                    notes: "The Bonjour service name advertised by this device on the local network."
                ))

                items.append(DeviceInfoItem(
                    key: "\(prefix) — Type",
                    value: "\(typeLabel) (\(service.serviceType))",
                    notes: "The type of network service this device offers."
                ))

                items.append(DeviceInfoItem(
                    key: "\(prefix) — Domain",
                    value: service.domain,
                    notes: "The Bonjour domain where this service was discovered. Typically \"local.\" for the local network."
                ))

                if let endpoint = service.endpoint {
                    items.append(DeviceInfoItem(
                        key: "\(prefix) — Endpoint",
                        value: endpoint,
                        notes: "The full service endpoint identifier for this Bonjour service."
                    ))
                }
            }
        }

        logger.debug("Network device collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Network Devices",
            icon: "network",
            items: items,
            explanation: """
            Network Devices shows services discovered on your local network using Bonjour \
            (mDNS/DNS-SD). This includes web servers, AirPlay devices, printers, HomeKit \
            accessories, file shares, and more. Each entry shows the service name, type, domain, \
            and endpoint. Tap Scan to start a 5-second discovery. Requires local network permission. \
            Uses the Network framework's NWBrowser.
            """
        )
    }

    static func collectSummary(services: [DiscoveredNetworkService]) -> DeviceInfoSection {
        var items: [DeviceInfoItem] = []

        if services.isEmpty {
            items.append(DeviceInfoItem(
                key: "Network Services Found",
                value: "Tap Scan to discover devices on your local network",
                notes: "Discovery uses Bonjour (mDNS) to find services. Requires local network permission."
            ))
        } else {
            items.append(DeviceInfoItem(
                key: "Network Services Found",
                value: "\(services.count) services",
                notes: "Tap \"Show Devices\" to see the full list."
            ))
        }

        return DeviceInfoSection(
            title: "Network Devices",
            icon: "network",
            items: items,
            explanation: """
            Network Devices shows services discovered on your local network using Bonjour \
            (mDNS/DNS-SD). This includes web servers, AirPlay devices, printers, HomeKit \
            accessories, file shares, and more. Each entry shows the service name, type, domain, \
            and endpoint. Tap Scan to start a 5-second discovery. Requires local network permission. \
            Uses the Network framework's NWBrowser.
            """
        )
    }
}
