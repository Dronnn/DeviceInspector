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
            Extended Network shows proxy settings (HTTP, HTTPS, SOCKS, PAC, WPAD) from the system \
            configuration, VPN connection status detected via active network interfaces (utun/ipsec), \
            and network path information from NWPathMonitor including connection status, \
            whether the connection is expensive (cellular/hotspot) or constrained (Low Data Mode), \
            DNS and IP version support, and detailed available interface information. \
            Uses CFNetwork, Network framework, and POSIX getifaddrs.
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

        // HTTPS Proxy
        let httpsProxyEnabled = proxySettings["HTTPSEnable"] as? Int == 1
        items.append(DeviceInfoItem(
            key: "HTTPS Proxy Enabled",
            value: httpsProxyEnabled ? "Yes" : "No"
        ))

        if httpsProxyEnabled {
            let httpsHost = proxySettings["HTTPSProxy"] as? String ?? "Unknown"
            let httpsPort = proxySettings["HTTPSPort"] as? Int ?? 0
            items.append(DeviceInfoItem(
                key: "HTTPS Proxy Host",
                value: httpsHost,
                isSensitive: true
            ))
            items.append(DeviceInfoItem(
                key: "HTTPS Proxy Port",
                value: "\(httpsPort)"
            ))
        }

        // SOCKS Proxy
        let socksProxyEnabled = proxySettings["SOCKSEnable"] as? Int == 1
        items.append(DeviceInfoItem(
            key: "SOCKS Proxy Enabled",
            value: socksProxyEnabled ? "Yes" : "No"
        ))

        if socksProxyEnabled {
            let socksHost = proxySettings["SOCKSProxy"] as? String ?? "Unknown"
            let socksPort = proxySettings["SOCKSPort"] as? Int ?? 0
            items.append(DeviceInfoItem(
                key: "SOCKS Proxy Host",
                value: socksHost,
                isSensitive: true
            ))
            items.append(DeviceInfoItem(
                key: "SOCKS Proxy Port",
                value: "\(socksPort)"
            ))
        }

        // PAC URL
        if let pacURL = proxySettings["ProxyAutoConfigURLString"] as? String {
            items.append(DeviceInfoItem(
                key: "PAC URL",
                value: pacURL,
                isSensitive: true
            ))
        } else {
            items.append(DeviceInfoItem(
                key: "PAC URL",
                value: "Not Configured"
            ))
        }

        // Auto-Discovery (WPAD)
        let wpadEnabled = proxySettings["ProxyAutoDiscoveryEnable"] as? Int == 1
        items.append(DeviceInfoItem(
            key: "Auto-Discovery (WPAD)",
            value: wpadEnabled ? "Enabled" : "Disabled",
            notes: "Web Proxy Auto-Discovery protocol for automatic proxy configuration."
        ))

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

        items.append(DeviceInfoItem(
            key: "Supports DNS",
            value: path.supportsDNS ? "Yes" : "No",
            notes: "Whether the path can resolve DNS queries."
        ))

        items.append(DeviceInfoItem(
            key: "Supports IPv4",
            value: path.supportsIPv4 ? "Yes" : "No",
            notes: "Whether the path supports IPv4 connectivity."
        ))

        items.append(DeviceInfoItem(
            key: "Supports IPv6",
            value: path.supportsIPv6 ? "Yes" : "No",
            notes: "Whether the path supports IPv6 connectivity."
        ))

        for iface in path.availableInterfaces {
            let typeString: String
            switch iface.type {
            case .wifi: typeString = "WiFi"
            case .cellular: typeString = "Cellular"
            case .wiredEthernet: typeString = "Wired Ethernet"
            case .loopback: typeString = "Loopback"
            case .other: typeString = "Other"
            @unknown default: typeString = "Unknown"
            }

            items.append(DeviceInfoItem(
                key: "Interface: \(iface.name)",
                value: typeString,
                details: [
                    "Name": iface.name,
                    "Type": typeString,
                    "Index": "\(iface.index)"
                ]
            ))
        }

        return items
    }

    // MARK: - DNS Servers

    static func collectDNSServers() -> DeviceInfoSection {
        logger.debug("Collecting DNS server information")
        var items: [DeviceInfoItem] = []

        // Read DNS servers from /etc/resolv.conf (accessible on iOS in most cases)
        if let contents = try? String(contentsOfFile: "/etc/resolv.conf", encoding: .utf8) {
            let lines = contents.components(separatedBy: "\n")
            var serverIndex = 1
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("nameserver") {
                    let parts = trimmed.split(separator: " ")
                    if parts.count >= 2 {
                        let server = String(parts[1])
                        items.append(DeviceInfoItem(
                            key: "DNS Server \(serverIndex)",
                            value: server,
                            notes: "From system resolver configuration"
                        ))
                        serverIndex += 1
                    }
                }
            }
        }

        if items.isEmpty {
            items.append(DeviceInfoItem(
                key: "DNS Servers",
                value: "Not Available",
                availability: .notAvailable,
                notes: "DNS server enumeration requires C interop (resolv.h) which is not available in pure Swift. DNS resolution is working if network is connected."
            ))
        }

        logger.debug("DNS server collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "DNS Servers",
            icon: "server.rack",
            items: items,
            explanation: """
            DNS Servers lists the configured Domain Name System resolvers on this device. \
            DNS servers translate human-readable domain names (like example.com) into IP addresses \
            that devices use to communicate. These are typically provided by your network (router/ISP) \
            or manually configured (e.g. 8.8.8.8 for Google DNS, 1.1.1.1 for Cloudflare). \
            Retrieved from the system resolver configuration.
            """
        )
    }

    // MARK: - Public IP Address

    static func collectPublicIP() async -> DeviceInfoSection {
        logger.debug("Collecting public IP address")
        var items: [DeviceInfoItem] = []

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        let session = URLSession(configuration: configuration)

        // IPv4
        let ipv4Value: String
        do {
            let (data, _) = try await session.data(from: URL(string: "https://api.ipify.org?format=json")!)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: String],
               let ip = json["ip"] {
                ipv4Value = ip
            } else {
                ipv4Value = "Unavailable"
            }
        } catch {
            logger.error("Failed to fetch public IPv4: \(error.localizedDescription)")
            ipv4Value = "Unavailable"
        }

        items.append(DeviceInfoItem(
            key: "Public IPv4",
            value: ipv4Value,
            notes: ipv4Value == "Unavailable" ? "Requires an active internet connection to determine public IP." : nil,
            isSensitive: true
        ))

        // IPv6
        let ipv6Value: String
        do {
            let (data, _) = try await session.data(from: URL(string: "https://api6.ipify.org?format=json")!)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: String],
               let ip = json["ip"] {
                ipv6Value = ip
            } else {
                ipv6Value = "Unavailable"
            }
        } catch {
            logger.error("Failed to fetch public IPv6: \(error.localizedDescription)")
            ipv6Value = "Unavailable"
        }

        items.append(DeviceInfoItem(
            key: "Public IPv6",
            value: ipv6Value,
            notes: ipv6Value == "Unavailable" ? "Your network may not support IPv6, or requires an active internet connection." : nil,
            isSensitive: true
        ))

        logger.debug("Public IP collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Public IP",
            icon: "globe",
            items: items,
            explanation: """
            Public IP shows the external IP addresses visible to the internet for this device. \
            The IPv4 and IPv6 addresses are obtained by querying the ipify.org API, which returns \
            the IP address as seen by their server. This is the address that websites and services \
            see when you connect. Marked as sensitive because it can reveal your approximate location \
            and ISP. Requires an active internet connection.
            """
        )
    }
}
