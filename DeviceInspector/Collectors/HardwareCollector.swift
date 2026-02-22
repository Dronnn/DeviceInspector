import Foundation
import os.log

struct HardwareCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "HardwareCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting hardware data")

        var items: [DeviceInfoItem] = []

        // Machine identifier via sysctlbyname
        let machineIdentifier = sysctlString(name: "hw.machine") ?? "Unknown"
        items.append(DeviceInfoItem(
            key: "Machine Identifier",
            value: machineIdentifier,
            notes: "Raw hardware model identifier from the kernel."
        ))

        // Human-readable name
        let humanName = DeviceModelMapping.humanReadableName(for: machineIdentifier)
        items.append(DeviceInfoItem(
            key: "Device Model (Mapped)",
            value: humanName,
            notes: "Mapped from the machine identifier to a human-readable device name."
        ))

        // hw.model (if available)
        if let hwModel = sysctlString(name: "hw.model") {
            items.append(DeviceInfoItem(
                key: "Hardware Model (hw.model)",
                value: hwModel
            ))
        }

        // hw.memsize (total RAM)
        if let memsize = sysctlInt64(name: "hw.memsize") {
            let formatted = ByteFormatter.format(UInt64(memsize))
            let memGB = Double(memsize) / (1024 * 1024 * 1024)
            items.append(DeviceInfoItem(
                key: "Total RAM (hw.memsize)",
                value: String(format: "%.1f GB (%@)", memGB, formatted)
            ))
        } else {
            items.append(DeviceInfoItem(
                key: "Total RAM (hw.memsize)",
                value: "Not available"
            ))
        }

        // kern.osversion (build number)
        let buildNumber = sysctlString(name: "kern.osversion") ?? "Unknown"
        items.append(DeviceInfoItem(
            key: "OS Build Number (kern.osversion)",
            value: buildNumber
        ))

        // kern.ostype
        if let osType = sysctlString(name: "kern.ostype") {
            items.append(DeviceInfoItem(
                key: "OS Type (kern.ostype)",
                value: osType
            ))
        }

        // kern.hostname
        if let hostname = sysctlString(name: "kern.hostname") {
            items.append(DeviceInfoItem(
                key: "Kernel Hostname",
                value: hostname,
                isSensitive: true
            ))
        }

        // hw.ncpu (number of CPUs)
        if let ncpu = sysctlInt32(name: "hw.ncpu") {
            items.append(DeviceInfoItem(
                key: "CPU Count (hw.ncpu)",
                value: "\(ncpu)"
            ))
        }

        // hw.physicalcpu
        if let physCPU = sysctlInt32(name: "hw.physicalcpu") {
            items.append(DeviceInfoItem(
                key: "Physical CPU Count",
                value: "\(physCPU)"
            ))
        }

        // hw.logicalcpu
        if let logCPU = sysctlInt32(name: "hw.logicalcpu") {
            items.append(DeviceInfoItem(
                key: "Logical CPU Count",
                value: "\(logCPU)"
            ))
        }

        // hw.cputype
        if let cpuType = sysctlInt32(name: "hw.cputype") {
            items.append(DeviceInfoItem(
                key: "CPU Type",
                value: "\(cpuType)",
                notes: "Raw CPU type identifier from the kernel."
            ))
        }

        // hw.cpusubtype
        if let cpuSubtype = sysctlInt32(name: "hw.cpusubtype") {
            items.append(DeviceInfoItem(
                key: "CPU Subtype",
                value: "\(cpuSubtype)",
                notes: "Raw CPU subtype identifier from the kernel."
            ))
        }

        // Cache sizes
        if let l1d = sysctlInt64(name: "hw.l1dcachesize"), l1d > 0 {
            items.append(DeviceInfoItem(key: "L1 Data Cache", value: ByteCountFormatter.string(fromByteCount: l1d, countStyle: .memory)))
        } else {
            items.append(DeviceInfoItem(key: "L1 Data Cache", value: "Not Available"))
        }

        if let l1i = sysctlInt64(name: "hw.l1icachesize"), l1i > 0 {
            items.append(DeviceInfoItem(key: "L1 Instruction Cache", value: ByteCountFormatter.string(fromByteCount: l1i, countStyle: .memory)))
        } else {
            items.append(DeviceInfoItem(key: "L1 Instruction Cache", value: "Not Available"))
        }

        if let l2 = sysctlInt64(name: "hw.l2cachesize"), l2 > 0 {
            items.append(DeviceInfoItem(key: "L2 Cache", value: ByteCountFormatter.string(fromByteCount: l2, countStyle: .memory)))
        } else {
            items.append(DeviceInfoItem(key: "L2 Cache", value: "Not Available"))
        }

        logger.debug("Hardware collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Hardware",
            icon: "cpu",
            items: items,
            explanation: """
            Hardware information is obtained via the sysctl interface, which provides low-level \
            details about the device's processor, memory, and kernel. The machine identifier \
            (e.g., "iPhone16,1") is mapped to a human-readable name using a built-in lookup table. \
            These values come directly from the Darwin kernel and are always available without any \
            special permissions.
            """
        )
    }

    // MARK: - sysctl Helpers

    private static func sysctlString(name: String) -> String? {
        var size: Int = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else {
            logger.debug("sysctlbyname failed for \(name)")
            return nil
        }
        var result = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &result, &size, nil, 0) == 0 else {
            logger.debug("sysctlbyname read failed for \(name)")
            return nil
        }
        return String(cString: result)
    }

    private static func sysctlInt64(name: String) -> Int64? {
        var value: Int64 = 0
        var size = MemoryLayout<Int64>.size
        guard sysctlbyname(name, &value, &size, nil, 0) == 0 else {
            logger.debug("sysctlbyname int64 failed for \(name)")
            return nil
        }
        return value
    }

    private static func sysctlInt32(name: String) -> Int32? {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        guard sysctlbyname(name, &value, &size, nil, 0) == 0 else {
            logger.debug("sysctlbyname int32 failed for \(name)")
            return nil
        }
        return value
    }
}
