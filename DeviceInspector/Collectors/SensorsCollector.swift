import AVFoundation
import CoreMotion
import os.log

struct SensorsCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "SensorsCollector")

    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting sensors data")
        var items: [DeviceInfoItem] = []

        let motion = CMMotionManager()

        items.append(DeviceInfoItem(
            key: "Accelerometer Available",
            value: motion.isAccelerometerAvailable ? "Yes" : "No",
            notes: "Measures acceleration forces along three axes."
        ))

        items.append(DeviceInfoItem(
            key: "Gyroscope Available",
            value: motion.isGyroAvailable ? "Yes" : "No",
            notes: "Measures rotation rate around three axes."
        ))

        items.append(DeviceInfoItem(
            key: "Magnetometer Available",
            value: motion.isMagnetometerAvailable ? "Yes" : "No",
            notes: "Measures ambient magnetic field (compass)."
        ))

        items.append(DeviceInfoItem(
            key: "Device Motion Available",
            value: motion.isDeviceMotionAvailable ? "Yes" : "No",
            notes: "Fused sensor data combining accelerometer, gyroscope, and magnetometer."
        ))

        items.append(DeviceInfoItem(
            key: "Barometer (Relative Altitude)",
            value: CMAltimeter.isRelativeAltitudeAvailable() ? "Yes" : "No",
            notes: "Barometric pressure sensor for measuring relative altitude changes."
        ))

        items.append(DeviceInfoItem(
            key: "Step Counting",
            value: CMPedometer.isStepCountingAvailable() ? "Yes" : "No",
            notes: "Hardware step counter availability."
        ))

        items.append(DeviceInfoItem(
            key: "Distance Estimation",
            value: CMPedometer.isDistanceAvailable() ? "Yes" : "No",
            notes: "Walking/running distance estimation from pedometer."
        ))

        items.append(DeviceInfoItem(
            key: "Floor Counting",
            value: CMPedometer.isFloorCountingAvailable() ? "Yes" : "No",
            notes: "Ability to count floors ascended/descended (requires barometer)."
        ))

        items.append(DeviceInfoItem(
            key: "Pace Available",
            value: CMPedometer.isPaceAvailable() ? "Yes" : "No",
            notes: "Walking/running pace estimation."
        ))

        items.append(DeviceInfoItem(
            key: "Cadence Available",
            value: CMPedometer.isCadenceAvailable() ? "Yes" : "No",
            notes: "Steps per second measurement."
        ))

        items.append(DeviceInfoItem(
            key: "Motion Activity Recognition",
            value: CMMotionActivityManager.isActivityAvailable() ? "Yes" : "No",
            availability: CMMotionActivityManager.isActivityAvailable() ? .available : .notAvailable,
            notes: "Recognizes user activity type: walking, running, driving, stationary, cycling."
        ))

        let headphoneMotionMgr = CMHeadphoneMotionManager()
        items.append(DeviceInfoItem(key: "Headphone Motion", value: headphoneMotionMgr.isDeviceMotionAvailable ? "Available" : "Not Available", notes: "AirPods motion sensing for spatial audio"))

        logger.debug("Sensors collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Sensors & Motion",
            icon: "gyroscope",
            items: items,
            explanation: """
            Sensors & Motion shows the availability of hardware sensors on this device. \
            These checks only query whether the hardware exists — no sensor data is actually \
            read or recorded. Uses CoreMotion framework. Accelerometer, gyroscope, and \
            magnetometer are present on all modern iPhones and iPads. Barometer is available \
            on iPhone 6+ and some iPads. Pedometer features (step counting, distance, floors) \
            require the M-series motion coprocessor.
            """
        )
    }

    // MARK: - Speech Voices

    static func collectSpeechVoicesSummary() -> DeviceInfoSection {
        logger.debug("Collecting speech voices summary")
        var items: [DeviceInfoItem] = []

        let voices = AVSpeechSynthesisVoice.speechVoices()

        items.append(DeviceInfoItem(
            key: "Total Voices",
            value: "\(voices.count)",
            notes: "Total number of text-to-speech voices installed on this device."
        ))

        let uniqueLanguages = Set(voices.map { $0.language })
        items.append(DeviceInfoItem(
            key: "Voice Languages",
            value: "\(uniqueLanguages.count)",
            notes: "Number of unique language codes across all installed voices."
        ))

        let premiumCount = voices.filter { $0.quality == .enhanced || $0.quality == .premium }.count
        items.append(DeviceInfoItem(
            key: "Premium Voices",
            value: "\(premiumCount)",
            notes: "Count of Enhanced or Premium quality voices. These are larger, higher-quality downloads."
        ))

        logger.debug("Speech voices summary complete: \(items.count) items")
        return speechVoicesSection(items: items)
    }

    static func collectSpeechVoices() -> DeviceInfoSection {
        logger.debug("Collecting full speech voices list")
        var items: [DeviceInfoItem] = []

        let voices = AVSpeechSynthesisVoice.speechVoices().sorted { $0.language < $1.language }

        for voice in voices {
            let qualityString: String
            switch voice.quality {
            case .enhanced:
                qualityString = "Enhanced"
            case .premium:
                qualityString = "Premium"
            default:
                qualityString = "Compact"
            }

            items.append(DeviceInfoItem(
                key: "Voice — \(voice.name)",
                value: "\(voice.language) (\(qualityString))",
                notes: "Text-to-speech voice. Language: \(voice.language), Quality: \(qualityString)."
            ))
        }

        logger.debug("Speech voices list complete: \(items.count) items")
        return speechVoicesSection(items: items)
    }

    private static func speechVoicesSection(items: [DeviceInfoItem]) -> DeviceInfoSection {
        DeviceInfoSection(
            title: "Speech Voices",
            icon: "waveform.and.person.filled",
            items: items,
            explanation: """
            Available text-to-speech voices differ by device model, storage capacity, \
            and user downloads. The voice list reveals hardware tier and language \
            preferences — a fingerprinting vector most users are unaware of.
            """
        )
    }
}
