import Metal
import ARKit
import os.log

struct GPUARCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "GPUARCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting GPU & AR data")
        var items: [DeviceInfoItem] = []

        items.append(contentsOf: collectMetal())
        items.append(contentsOf: collectAR())

        logger.debug("GPU & AR collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "GPU & AR",
            icon: "cube.transparent",
            items: items,
            explanation: """
            GPU & AR shows Metal GPU capabilities and ARKit feature support. Metal information \
            includes the GPU name, buffer limits, threadgroup parameters, and supported GPU \
            family levels. ARKit checks show which tracking configurations are supported \
            without requiring camera permission. Uses Metal and ARKit frameworks.
            """
        )
    }

    private static func collectMetal() -> [DeviceInfoItem] {
        var items: [DeviceInfoItem] = []

        guard let device = MTLCreateSystemDefaultDevice() else {
            items.append(DeviceInfoItem(
                key: "Metal",
                value: "Not Available",
                availability: .notAvailable,
                notes: "Metal GPU not available on this device."
            ))
            return items
        }

        items.append(DeviceInfoItem(
            key: "GPU Name",
            value: device.name
        ))

        items.append(DeviceInfoItem(
            key: "Max Buffer Length",
            value: ByteFormatter.format(UInt64(device.maxBufferLength)),
            notes: "Maximum size of a single Metal buffer."
        ))

        let maxThreads = device.maxThreadsPerThreadgroup
        items.append(DeviceInfoItem(
            key: "Max Threads Per Threadgroup",
            value: "\(maxThreads.width) x \(maxThreads.height) x \(maxThreads.depth)"
        ))

        items.append(DeviceInfoItem(
            key: "Max Threadgroup Memory",
            value: ByteFormatter.format(UInt64(device.maxThreadgroupMemoryLength))
        ))

        items.append(DeviceInfoItem(
            key: "Recommended Max Working Set Size",
            value: ByteFormatter.format(device.recommendedMaxWorkingSetSize),
            notes: "Recommended maximum GPU memory working set for this device."
        ))

        // Check GPU family support
        let families: [(MTLGPUFamily, String)] = [
            (.apple1, "Apple 1"), (.apple2, "Apple 2"), (.apple3, "Apple 3"),
            (.apple4, "Apple 4"), (.apple5, "Apple 5"), (.apple6, "Apple 6"),
            (.apple7, "Apple 7"), (.apple8, "Apple 8")
        ]

        var highestFamily = "None"
        for (family, name) in families.reversed() {
            if device.supportsFamily(family) {
                highestFamily = name
                break
            }
        }
        items.append(DeviceInfoItem(
            key: "Highest GPU Family",
            value: highestFamily,
            notes: "Highest Apple GPU family supported. Higher families support more advanced features."
        ))

        items.append(DeviceInfoItem(
            key: "Unified Memory",
            value: device.hasUnifiedMemory ? "Yes" : "No"
        ))

        return items
    }

    private static func collectAR() -> [DeviceInfoItem] {
        var items: [DeviceInfoItem] = []

        items.append(DeviceInfoItem(
            key: "AR World Tracking",
            value: ARWorldTrackingConfiguration.isSupported ? "Supported" : "Not Supported",
            notes: "6DoF world tracking using back camera and motion sensors."
        ))

        items.append(DeviceInfoItem(
            key: "AR Face Tracking",
            value: ARFaceTrackingConfiguration.isSupported ? "Supported" : "Not Supported",
            notes: "TrueDepth camera face tracking. Requires iPhone X or later."
        ))

        items.append(DeviceInfoItem(
            key: "AR Body Tracking",
            value: ARBodyTrackingConfiguration.isSupported ? "Supported" : "Not Supported",
            notes: "Full body pose tracking. Requires A12 chip or later."
        ))

        items.append(DeviceInfoItem(
            key: "AR Image Tracking",
            value: ARImageTrackingConfiguration.isSupported ? "Supported" : "Not Supported",
            notes: "Tracks known 2D images in the environment."
        ))

        items.append(DeviceInfoItem(
            key: "AR Object Scanning",
            value: ARObjectScanningConfiguration.isSupported ? "Supported" : "Not Supported",
            notes: "Scans real-world 3D objects for later detection."
        ))

        items.append(DeviceInfoItem(
            key: "Scene Reconstruction",
            value: ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) ? "Supported" : "Not Supported",
            notes: "Indicates LiDAR scanner presence"
        ))

        items.append(DeviceInfoItem(
            key: "Scene Depth",
            value: ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) ? "Supported" : "Not Supported",
            notes: "LiDAR-based depth sensing"
        ))

        return items
    }
}
