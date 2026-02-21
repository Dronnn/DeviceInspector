import Darwin
import Foundation
import os.log

struct ProcessInfoCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "ProcessInfoCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting ProcessInfo data")

        let info = ProcessInfo.processInfo
        var items: [DeviceInfoItem] = []

        // Process name
        items.append(DeviceInfoItem(
            key: "Process Name",
            value: info.processName
        ))

        // Process identifier (PID)
        items.append(DeviceInfoItem(
            key: "Process Identifier (PID)",
            value: "\(info.processIdentifier)"
        ))

        // System uptime formatted
        let uptime = info.systemUptime
        let days = Int(uptime) / 86400
        let hours = (Int(uptime) % 86400) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        let seconds = Int(uptime) % 60
        let uptimeString = "\(days)d \(hours)h \(minutes)m \(seconds)s"
        items.append(DeviceInfoItem(
            key: "System Uptime",
            value: uptimeString,
            notes: "Time since last device reboot"
        ))

        // Operating system version string
        items.append(DeviceInfoItem(
            key: "OS Version String",
            value: info.operatingSystemVersionString
        ))

        // Operating system version components
        let osVersion = info.operatingSystemVersion
        items.append(DeviceInfoItem(
            key: "OS Version (Parsed)",
            value: "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        ))

        // isOperatingSystemAtLeast checks
        let atLeast16 = info.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 16, minorVersion: 0, patchVersion: 0))
        items.append(DeviceInfoItem(
            key: "Is At Least iOS 16",
            value: atLeast16 ? "Yes" : "No"
        ))

        let atLeast17 = info.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 17, minorVersion: 0, patchVersion: 0))
        items.append(DeviceInfoItem(
            key: "Is At Least iOS 17",
            value: atLeast17 ? "Yes" : "No"
        ))

        let atLeast18 = info.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 18, minorVersion: 0, patchVersion: 0))
        items.append(DeviceInfoItem(
            key: "Is At Least iOS 18",
            value: atLeast18 ? "Yes" : "No"
        ))

        // Processor count
        items.append(DeviceInfoItem(
            key: "Processor Count",
            value: "\(info.processorCount)"
        ))

        // Active processor count
        items.append(DeviceInfoItem(
            key: "Active Processor Count",
            value: "\(info.activeProcessorCount)"
        ))

        // Physical memory
        let memoryGB = Double(info.physicalMemory) / (1024 * 1024 * 1024)
        items.append(DeviceInfoItem(
            key: "Physical Memory",
            value: String(format: "%.1f GB (%@)", memoryGB, ByteFormatter.format(info.physicalMemory))
        ))

        // Low power mode
        items.append(DeviceInfoItem(
            key: "Low Power Mode",
            value: info.isLowPowerModeEnabled ? "Enabled" : "Disabled"
        ))

        // Thermal state
        let thermalStateString: String
        switch info.thermalState {
        case .nominal:
            thermalStateString = "Nominal"
        case .fair:
            thermalStateString = "Fair"
        case .serious:
            thermalStateString = "Serious"
        case .critical:
            thermalStateString = "Critical"
        @unknown default:
            thermalStateString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Thermal State",
            value: thermalStateString
        ))

        // Environment variables
        let envVars = info.environment
        let envCount = envVars.count
        items.append(DeviceInfoItem(
            key: "Environment Variables",
            value: "\(envCount) variables",
            notes: "Environment variables passed to this process. May contain paths and internal config.",
            isSensitive: true,
            details: envVars
        ))

        // Arguments
        let args = info.arguments
        let argsPreview = args.prefix(3).joined(separator: ", ")
        items.append(DeviceInfoItem(
            key: "Launch Arguments",
            value: "\(args.count) arguments" + (argsPreview.isEmpty ? "" : " (\(argsPreview))"),
            notes: "Arguments passed when the process was launched.",
            isSensitive: true
        ))

        // Host name
        items.append(DeviceInfoItem(
            key: "Host Name",
            value: info.hostName,
            isSensitive: true
        ))

        // Globally unique string
        items.append(DeviceInfoItem(
            key: "Globally Unique String",
            value: info.globallyUniqueString,
            notes: "Temporary unique string generated at call time. Not a stable device identifier."
        ))

        // App Memory
        let availableMemory = os_proc_available_memory()
        items.append(DeviceInfoItem(
            key: "Available Memory",
            value: ByteFormatter.format(UInt64(availableMemory)),
            notes: "Memory currently available for the app before the system starts terminating background apps."
        ))

        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &taskInfo) { taskInfoPtr in
            taskInfoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rawPtr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), rawPtr, &count)
            }
        }
        if result == KERN_SUCCESS {
            items.append(DeviceInfoItem(
                key: "App Memory Usage",
                value: ByteFormatter.format(UInt64(taskInfo.resident_size)),
                notes: "Current resident memory (RAM) used by this app process."
            ))
        } else {
            items.append(DeviceInfoItem(
                key: "App Memory Usage",
                value: "Not available",
                availability: .notAvailable,
                notes: "Could not query task_info for memory usage."
            ))
        }

        logger.debug("ProcessInfo collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Process Info",
            icon: "gearshape.2",
            items: items,
            explanation: """
            ProcessInfo provides information about the current process and the system environment. \
            This includes the OS version, processor count, physical memory, thermal state, and system \
            uptime. The environment variables and arguments reflect what was passed when the app was \
            launched. The globally unique string is generated fresh each time it is accessed and should \
            not be used as a persistent device identifier.
            """
        )
    }
}
