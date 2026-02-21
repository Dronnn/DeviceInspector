import Foundation
import os.log

struct StorageCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "StorageCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting storage data")

        var items: [DeviceInfoItem] = []

        let homeURL = URL(fileURLWithPath: NSHomeDirectory())

        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: homeURL.path)

            // Total disk space
            if let totalSpace = attributes[.systemSize] as? UInt64 {
                let totalGB = Double(totalSpace) / (1024 * 1024 * 1024)
                items.append(DeviceInfoItem(
                    key: "Total Disk Space",
                    value: String(format: "%.1f GB (%@)", totalGB, ByteFormatter.format(totalSpace))
                ))

                // Free disk space
                if let freeSpace = attributes[.systemFreeSize] as? UInt64 {
                    let freeGB = Double(freeSpace) / (1024 * 1024 * 1024)
                    items.append(DeviceInfoItem(
                        key: "Free Disk Space",
                        value: String(format: "%.1f GB (%@)", freeGB, ByteFormatter.format(freeSpace))
                    ))

                    // Used disk space
                    let usedSpace = totalSpace - freeSpace
                    let usedGB = Double(usedSpace) / (1024 * 1024 * 1024)
                    items.append(DeviceInfoItem(
                        key: "Used Disk Space",
                        value: String(format: "%.1f GB (%@)", usedGB, ByteFormatter.format(usedSpace))
                    ))

                    // Usage percentage
                    let usagePercent = Double(usedSpace) / Double(totalSpace) * 100
                    items.append(DeviceInfoItem(
                        key: "Disk Usage",
                        value: String(format: "%.1f%%", usagePercent)
                    ))
                }
            }

            // File system nodes
            if let totalNodes = attributes[.systemNodes] as? UInt64 {
                items.append(DeviceInfoItem(
                    key: "Total File System Nodes",
                    value: "\(totalNodes)"
                ))
            }

            if let freeNodes = attributes[.systemFreeNodes] as? UInt64 {
                items.append(DeviceInfoItem(
                    key: "Free File System Nodes",
                    value: "\(freeNodes)"
                ))
            }

        } catch {
            logger.error("Failed to read file system attributes: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "Disk Space",
                value: "Error reading file system: \(error.localizedDescription)",
                availability: .notAvailable
            ))
        }

        // Important capacity via URL resource values (more accurate on iOS)
        do {
            let resourceValues = try homeURL.resourceValues(forKeys: [
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeAvailableCapacityForOpportunisticUsageKey,
                .volumeTotalCapacityKey
            ])

            if let importantCapacity = resourceValues.volumeAvailableCapacityForImportantUsage {
                let capacityGB = Double(importantCapacity) / (1024 * 1024 * 1024)
                items.append(DeviceInfoItem(
                    key: "Available (Important Usage)",
                    value: String(format: "%.1f GB (%@)", capacityGB, ByteFormatter.format(Int64(importantCapacity))),
                    notes: "Capacity available for important data (photos, documents). iOS may purge caches to free space."
                ))
            }

            if let opportunisticCapacity = resourceValues.volumeAvailableCapacityForOpportunisticUsage {
                let capacityGB = Double(opportunisticCapacity) / (1024 * 1024 * 1024)
                items.append(DeviceInfoItem(
                    key: "Available (Opportunistic Usage)",
                    value: String(format: "%.1f GB (%@)", capacityGB, ByteFormatter.format(Int64(opportunisticCapacity))),
                    notes: "Capacity available for non-essential data. More conservative than important usage."
                ))
            }

        } catch {
            logger.debug("Failed to read URL resource values: \(error.localizedDescription)")
        }

        // Physical memory (for context alongside storage)
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let memoryGB = Double(physicalMemory) / (1024 * 1024 * 1024)
        items.append(DeviceInfoItem(
            key: "Physical Memory (RAM)",
            value: String(format: "%.1f GB (%@)", memoryGB, ByteFormatter.format(physicalMemory)),
            notes: "Total RAM, shown here alongside storage for context."
        ))

        logger.debug("Storage collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Storage",
            icon: "internaldrive",
            items: items,
            explanation: """
            Storage information shows the total, used, and available disk space on the device. \
            iOS provides two capacity metrics: "Important Usage" (for photos, documents, etc. — \
            iOS may purge caches to make space) and "Opportunistic Usage" (more conservative, for \
            non-essential data). Physical memory (RAM) is included here for context. File system \
            node counts reflect the internal file system structure.
            """
        )
    }
}
