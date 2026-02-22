import Foundation
import os.log

struct EnvironmentSecurityCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "EnvironmentSecurityCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting environment security data")
        var items: [DeviceInfoItem] = []

        // TestFlight Build
        let isTestFlight: Bool
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            isTestFlight = receiptURL.path.contains("sandboxReceipt")
        } else {
            isTestFlight = false
        }
        items.append(DeviceInfoItem(
            key: "TestFlight Build",
            value: isTestFlight ? "Yes" : "No",
            notes: "Detected by checking if the App Store receipt URL contains 'sandboxReceipt'."
        ))

        // Debug Build
        #if DEBUG
        let buildConfig = "Debug"
        #else
        let buildConfig = "Release"
        #endif
        items.append(DeviceInfoItem(
            key: "Build Configuration",
            value: buildConfig,
            notes: "Whether the app was compiled in Debug or Release mode."
        ))

        // Jailbreak Indicators
        var indicators: [String] = []
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/private/var/lib/apt",
            "/private/var/lib/cydia",
            "/private/var/stash",
            "/usr/sbin/sshd",
            "/usr/bin/ssh"
        ]
        for path in suspiciousPaths {
            if FileManager.default.fileExists(atPath: path) {
                indicators.append(path)
            }
        }
        if FileManager.default.isWritableFile(atPath: "/") {
            indicators.append("Root filesystem writable")
        }

        items.append(DeviceInfoItem(
            key: "Jailbreak Indicators",
            value: indicators.isEmpty ? "None Detected" : "\(indicators.count) found",
            notes: indicators.isEmpty
                ? "No common jailbreak artifacts were found."
                : "Found: \(indicators.joined(separator: ", "))"
        ))

        // Data Protection Class
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let url = documentsURL {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                if let protection = attributes[.protectionKey] as? FileProtectionType {
                    let protectionStr: String
                    switch protection {
                    case .complete: protectionStr = "Complete"
                    case .completeUnlessOpen: protectionStr = "Complete Unless Open"
                    case .completeUntilFirstUserAuthentication: protectionStr = "Until First Unlock"
                    case .none: protectionStr = "None"
                    default: protectionStr = protection.rawValue
                    }
                    items.append(DeviceInfoItem(key: "Data Protection", value: protectionStr))
                } else {
                    items.append(DeviceInfoItem(key: "Data Protection", value: "Not Set"))
                }
            } catch {
                items.append(DeviceInfoItem(key: "Data Protection", value: "Unable to Determine"))
            }
        }

        logger.debug("Environment security collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Environment Security",
            icon: "shield.lefthalf.filled",
            items: items,
            explanation: """
            Environment Security checks for indicators about the app's runtime environment: \
            whether it's a TestFlight (sandbox) build, the compilation configuration (Debug \
            vs Release), and common jailbreak artifacts. These are heuristic checks — a \
            sophisticated jailbreak may evade detection, and the sandbox check is not \
            definitive on all iOS versions.
            """
        )
    }
}
