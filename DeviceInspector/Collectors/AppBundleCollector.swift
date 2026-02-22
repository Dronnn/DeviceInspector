import Foundation
import os.log

struct AppBundleCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "AppBundleCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting app bundle data")
        var items: [DeviceInfoItem] = []
        let bundle = Bundle.main
        let info = bundle.infoDictionary

        items.append(DeviceInfoItem(
            key: "Bundle Identifier",
            value: bundle.bundleIdentifier ?? "Unknown"
        ))

        items.append(DeviceInfoItem(
            key: "App Name",
            value: info?["CFBundleName"] as? String ?? "Unknown"
        ))

        items.append(DeviceInfoItem(
            key: "Version",
            value: info?["CFBundleShortVersionString"] as? String ?? "Unknown",
            notes: "Marketing version (CFBundleShortVersionString)."
        ))

        items.append(DeviceInfoItem(
            key: "Build Number",
            value: info?["CFBundleVersion"] as? String ?? "Unknown",
            notes: "Internal build number (CFBundleVersion)."
        ))

        items.append(DeviceInfoItem(
            key: "Executable Name",
            value: info?["CFBundleExecutable"] as? String ?? "Unknown"
        ))

        items.append(DeviceInfoItem(
            key: "Preferred Localization",
            value: bundle.preferredLocalizations.first ?? "Unknown",
            notes: "Primary language of the app bundle."
        ))

        items.append(DeviceInfoItem(
            key: "Resource Path",
            value: bundle.resourceURL?.path ?? "Unknown"
        ))

        // Simulator detection
        let isSimulator = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
        let simulatorName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]
        items.append(DeviceInfoItem(
            key: "Running Environment",
            value: isSimulator ? "Simulator (\(simulatorName ?? "Unknown"))" : "Physical Device",
            notes: isSimulator ? "Detected via SIMULATOR_DEVICE_NAME environment variable." : "Running on actual hardware."
        ))

        // FileManager paths
        let fm = FileManager.default

        if let documentsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            items.append(DeviceInfoItem(
                key: "Documents Directory",
                value: documentsURL.path
            ))
        }

        if let cachesURL = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
            items.append(DeviceInfoItem(
                key: "Caches Directory",
                value: cachesURL.path
            ))
        }

        items.append(DeviceInfoItem(
            key: "Temp Directory",
            value: NSTemporaryDirectory()
        ))

        // Minimum OS Version
        let minOS = Bundle.main.infoDictionary?["MinimumOSVersion"] as? String ?? "Unknown"
        items.append(DeviceInfoItem(key: "Minimum OS Version", value: minOS))

        logger.debug("App bundle collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "App & Bundle",
            icon: "shippingbox",
            items: items,
            explanation: """
            App & Bundle shows information about this application's bundle — its identifier, \
            version, build number, executable name, and preferred localization. Also shows \
            whether the app is running on a physical device or in the iOS Simulator, and \
            the file system paths for Documents, Caches, and Temp directories. All data comes \
            from Bundle.main, ProcessInfo, and FileManager.
            """
        )
    }
}
