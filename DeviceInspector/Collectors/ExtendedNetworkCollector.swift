import Foundation
import Network
import Darwin
import os.log

struct ExtendedNetworkCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "ExtendedNetworkCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting extended network data")
        var items: [DeviceInfoItem] = []

        items.append(contentsOf: collectProxySettings())
        items.append(contentsOf: collectVPNStatus())
        items.append(contentsOf: collectNetworkPath())

        logger.debug("Extended network collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Extended Network",
            icon: "network",
            items: items,
            explanation: """
            Extended Network shows HTTP proxy settings from the system configuration, \
            VPN connection status detected via active network interfaces (utun/ipsec), \
            and network path information from NWPathMonitor including connection status, \
            whether the connection is expensive (cellular/hotspot) or constrained (Low Data Mode), \
            and available interface types. Uses CFNetwork, Network framework, and POSIX getifaddrs.
            """
        )
    }

    private static func collectProxySettings() -> [DeviceInfoItem] {
        var items: [DeviceInfoItem] = []

        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            items.append(DeviceInfoItem(
                key: "HTTP Proxy",
                value: "Unable to read proxy settings",
                availability: .notAvailable
            ))
            return items
        }

        let proxyEnabled = proxySettings[kCFNetworkProxiesHTTPEnable as String] as? Int == 1
        items.append(DeviceInfoItem(
            key: "HTTP Proxy Enabled",
            value: proxyEnabled ? "Yes" : "No"
        ))

        if proxyEnabled {
            let host = proxySettings[kCFNetworkProxiesHTTPProxy as String] as? String ?? "Unknown"
            let port = proxySettings[kCFNetworkProxiesHTTPPort as String] as? Int ?? 0
            items.append(DeviceInfoItem(
                key: "HTTP Proxy Host",
                value: host,
                isSensitive: true
            ))
            items.append(DeviceInfoItem(
                key: "HTTP Proxy Port",
                value: "\(port)"
            ))
        }

        return items
    }

    private static func collectVPNStatus() -> [DeviceInfoItem] {
        var items: [DeviceInfoItem] = []
        var vpnInterfaces: [String] = []

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            items.append(DeviceInfoItem(
                key: "VPN Status",
                value: "Unable to check",
                availability: .notAvailable
            ))
            return items
        }
        defer { freeifaddrs(ifaddr) }

        var currentAddr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let addr = currentAddr {
            let name = String(cString: addr.pointee.ifa_name)
            if name.hasPrefix("utun") || name.hasPrefix("ipsec") {
                if !vpnInterfaces.contains(name) {
                    vpnInterfaces.append(name)
                }
            }
            currentAddr = addr.pointee.ifa_next
        }

        let vpnActive = !vpnInterfaces.isEmpty
        items.append(DeviceInfoItem(
            key: "VPN Active",
            value: vpnActive ? "Yes" : "No",
            notes: vpnActive ? "VPN interfaces detected: \(vpnInterfaces.joined(separator: ", "))" : "No VPN tunnel interfaces found."
        ))

        return items
    }

    private static func collectNetworkPath() -> [DeviceInfoItem] {
        var items: [DeviceInfoItem] = []

        let monitor = NWPathMonitor()
        let path = monitor.currentPath

        let statusString: String
        switch path.status {
        case .satisfied: statusString = "Satisfied"
        case .unsatisfied: statusString = "Unsatisfied"
        case .requiresConnection: statusString = "Requires Connection"
        @unknown default: statusString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Network Path Status",
            value: statusString,
            notes: "Whether the network path is usable for data transfer."
        ))

        items.append(DeviceInfoItem(
            key: "Is Expensive",
            value: path.isExpensive ? "Yes" : "No",
            notes: "True for cellular data or personal hotspot connections."
        ))

        items.append(DeviceInfoItem(
            key: "Is Constrained",
            value: path.isConstrained ? "Yes" : "No",
            notes: "True when Low Data Mode is enabled by the user."
        ))

        var interfaceTypes: [String] = []
        if path.usesInterfaceType(.wifi) { interfaceTypes.append("WiFi") }
        if path.usesInterfaceType(.cellular) { interfaceTypes.append("Cellular") }
        if path.usesInterfaceType(.wiredEthernet) { interfaceTypes.append("Wired Ethernet") }
        if path.usesInterfaceType(.loopback) { interfaceTypes.append("Loopback") }
        if path.usesInterfaceType(.other) { interfaceTypes.append("Other") }

        items.append(DeviceInfoItem(
            key: "Active Interface Types",
            value: interfaceTypes.isEmpty ? "None" : interfaceTypes.joined(separator: ", "),
            notes: "Network interface types currently in use."
        ))

        return items
    }
}
