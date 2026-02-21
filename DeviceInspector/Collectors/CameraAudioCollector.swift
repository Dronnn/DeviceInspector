import AVFoundation
import CoreHaptics
import os.log

struct CameraAudioCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "CameraAudioCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting camera & audio data")
        var items: [DeviceInfoItem] = []

        items.append(contentsOf: collectCameras())
        items.append(contentsOf: collectAudioSession())
        items.append(contentsOf: collectHaptics())

        logger.debug("Camera & Audio collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Camera & Audio",
            icon: "camera",
            items: items,
            explanation: """
            Camera & Audio enumerates all available camera devices using AVCaptureDevice.DiscoverySession, \
            including their type (wide angle, telephoto, ultra wide, TrueDepth), position (front/back), \
            flash and torch support. Audio session details come from AVAudioSession.sharedInstance() \
            including sample rate, buffer duration, latency, input/output routes, and channel counts. \
            Haptic engine capabilities are checked via CoreHaptics. No camera feed or audio is captured.
            """
        )
    }

    private static func collectCameras() -> [DeviceInfoItem] {
        var items: [DeviceInfoItem] = []

        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .builtInTelephotoCamera,
            .builtInUltraWideCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,
            .builtInTripleCamera,
            .builtInTrueDepthCamera,
            .builtInLiDARDepthCamera
        ]

        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )

        if session.devices.isEmpty {
            items.append(DeviceInfoItem(
                key: "Cameras",
                value: "No cameras found",
                availability: .notAvailable
            ))
        } else {
            items.append(DeviceInfoItem(
                key: "Camera Count",
                value: "\(session.devices.count)"
            ))

            for (index, device) in session.devices.enumerated() {
                let position: String
                switch device.position {
                case .front: position = "Front"
                case .back: position = "Back"
                case .unspecified: position = "Unspecified"
                @unknown default: position = "Unknown"
                }

                let prefix = "Camera \(index + 1)"
                items.append(DeviceInfoItem(
                    key: "\(prefix) — Name",
                    value: device.localizedName
                ))
                items.append(DeviceInfoItem(
                    key: "\(prefix) — Type",
                    value: deviceTypeName(device.deviceType)
                ))
                items.append(DeviceInfoItem(
                    key: "\(prefix) — Position",
                    value: position
                ))
                items.append(DeviceInfoItem(
                    key: "\(prefix) — Flash",
                    value: device.hasFlash ? "Yes" : "No"
                ))
                items.append(DeviceInfoItem(
                    key: "\(prefix) — Torch",
                    value: device.hasTorch ? "Yes" : "No"
                ))
            }
        }

        return items
    }

    private static func deviceTypeName(_ type: AVCaptureDevice.DeviceType) -> String {
        switch type {
        case .builtInWideAngleCamera: return "Wide Angle"
        case .builtInTelephotoCamera: return "Telephoto"
        case .builtInUltraWideCamera: return "Ultra Wide"
        case .builtInDualCamera: return "Dual Camera"
        case .builtInDualWideCamera: return "Dual Wide Camera"
        case .builtInTripleCamera: return "Triple Camera"
        case .builtInTrueDepthCamera: return "TrueDepth"
        case .builtInLiDARDepthCamera: return "LiDAR Depth"
        default: return "Unknown"
        }
    }

    private static func collectAudioSession() -> [DeviceInfoItem] {
        var items: [DeviceInfoItem] = []
        let session = AVAudioSession.sharedInstance()

        items.append(DeviceInfoItem(
            key: "Audio Category",
            value: session.category.rawValue
        ))
        items.append(DeviceInfoItem(
            key: "Audio Mode",
            value: session.mode.rawValue
        ))
        items.append(DeviceInfoItem(
            key: "Sample Rate",
            value: String(format: "%.0f Hz", session.sampleRate)
        ))
        items.append(DeviceInfoItem(
            key: "I/O Buffer Duration",
            value: String(format: "%.1f ms", session.ioBufferDuration * 1000)
        ))
        items.append(DeviceInfoItem(
            key: "Output Latency",
            value: String(format: "%.1f ms", session.outputLatency * 1000)
        ))
        items.append(DeviceInfoItem(
            key: "Input Latency",
            value: String(format: "%.1f ms", session.inputLatency * 1000)
        ))

        // Input routes
        for input in session.currentRoute.inputs {
            items.append(DeviceInfoItem(
                key: "Audio Input — \(input.portName)",
                value: "Type: \(input.portType.rawValue)",
                notes: "UID: \(input.uid)"
            ))
        }

        // Output routes
        for output in session.currentRoute.outputs {
            items.append(DeviceInfoItem(
                key: "Audio Output — \(output.portName)",
                value: "Type: \(output.portType.rawValue)",
                notes: "UID: \(output.uid)"
            ))
        }

        items.append(DeviceInfoItem(
            key: "Max Input Channels",
            value: "\(session.maximumInputNumberOfChannels)"
        ))
        items.append(DeviceInfoItem(
            key: "Max Output Channels",
            value: "\(session.maximumOutputNumberOfChannels)"
        ))
        items.append(DeviceInfoItem(
            key: "Other Audio Playing",
            value: session.isOtherAudioPlaying ? "Yes" : "No",
            notes: "Whether another app is currently playing audio."
        ))

        return items
    }

    private static func collectHaptics() -> [DeviceInfoItem] {
        var items: [DeviceInfoItem] = []
        let capabilities = CHHapticEngine.capabilitiesForHardware()

        items.append(DeviceInfoItem(
            key: "Haptics Supported",
            value: capabilities.supportsHaptics ? "Yes" : "No",
            notes: "Whether the device has a Taptic Engine for haptic feedback."
        ))
        items.append(DeviceInfoItem(
            key: "Haptic Audio Supported",
            value: capabilities.supportsAudio ? "Yes" : "No",
            notes: "Whether the haptic engine can play synchronized audio."
        ))

        return items
    }
}
