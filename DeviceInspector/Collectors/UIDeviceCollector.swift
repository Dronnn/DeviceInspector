import UIKit
import os.log

struct UIDeviceCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "UIDeviceCollector")

    @MainActor
    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting UIDevice data")

        let device = UIDevice.current
        var items: [DeviceInfoItem] = []

        // Device name (user-assigned, sensitive)
        items.append(DeviceInfoItem(
            key: "Device Name",
            value: device.name,
            notes: "User-assigned device name. Visible to other devices on the network.",
            isSensitive: true
        ))

        // Model
        items.append(DeviceInfoItem(
            key: "Model",
            value: device.model,
            notes: "Generic model type (e.g., iPhone, iPad)"
        ))

        // Localized model
        items.append(DeviceInfoItem(
            key: "Localized Model",
            value: device.localizedModel
        ))

        // System name
        items.append(DeviceInfoItem(
            key: "System Name",
            value: device.systemName
        ))

        // System version
        items.append(DeviceInfoItem(
            key: "System Version",
            value: device.systemVersion
        ))

        // Identifier for vendor (IDFV)
        let idfv = device.identifierForVendor?.uuidString ?? "Not available"
        items.append(DeviceInfoItem(
            key: "Identifier For Vendor (IDFV)",
            value: idfv,
            notes: "Unique to each vendor (developer). Resets if all apps from this vendor are uninstalled.",
            isSensitive: true
        ))

        // Battery monitoring - enable it first
        device.isBatteryMonitoringEnabled = true

        // Battery level
        let batteryLevel = device.batteryLevel
        let batteryLevelString: String
        if batteryLevel < 0 {
            batteryLevelString = "Unknown (battery monitoring may not be supported)"
        } else {
            batteryLevelString = String(format: "%.0f%%", batteryLevel * 100)
        }
        items.append(DeviceInfoItem(
            key: "Battery Level",
            value: batteryLevelString,
            notes: "Ranges from 0% to 100%. Returns unknown on simulators."
        ))

        // Battery state
        let batteryStateString: String
        switch device.batteryState {
        case .unknown:
            batteryStateString = "Unknown"
        case .unplugged:
            batteryStateString = "Unplugged"
        case .charging:
            batteryStateString = "Charging"
        case .full:
            batteryStateString = "Full"
        @unknown default:
            batteryStateString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Battery State",
            value: batteryStateString
        ))

        // Orientation
        let orientationString: String
        switch device.orientation {
        case .unknown:
            orientationString = "Unknown"
        case .portrait:
            orientationString = "Portrait"
        case .portraitUpsideDown:
            orientationString = "Portrait Upside Down"
        case .landscapeLeft:
            orientationString = "Landscape Left"
        case .landscapeRight:
            orientationString = "Landscape Right"
        case .faceUp:
            orientationString = "Face Up"
        case .faceDown:
            orientationString = "Face Down"
        @unknown default:
            orientationString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Orientation",
            value: orientationString,
            notes: "Current physical orientation of the device."
        ))

        // Multitasking support
        items.append(DeviceInfoItem(
            key: "Multitasking Supported",
            value: device.isMultitaskingSupported ? "Yes" : "No"
        ))

        // User interface idiom
        let idiomString: String
        switch device.userInterfaceIdiom {
        case .phone:
            idiomString = "Phone"
        case .pad:
            idiomString = "Pad"
        case .tv:
            idiomString = "TV"
        case .carPlay:
            idiomString = "CarPlay"
        case .mac:
            idiomString = "Mac (Catalyst)"
        case .vision:
            idiomString = "Vision"
        case .unspecified:
            idiomString = "Unspecified"
        @unknown default:
            idiomString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "User Interface Idiom",
            value: idiomString
        ))

        logger.debug("UIDevice collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "UIDevice",
            icon: "iphone",
            items: items,
            explanation: """
            UIDevice provides basic information about the iOS device. The device name is the \
            user-assigned name visible in Settings > General > About. The Identifier For Vendor \
            (IDFV) is unique per developer account and resets when all of that developer's apps \
            are uninstalled. Battery monitoring must be explicitly enabled to read battery level \
            and state. On the Simulator, battery values are always unknown.
            """
        )
    }
}
