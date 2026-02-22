import LocalAuthentication
import UIKit
import CryptoKit
import DeviceCheck
import os.log

struct BiometricsCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "BiometricsCollector")

    @MainActor
    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting biometrics data")
        var items: [DeviceInfoItem] = []

        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        // Biometry type
        let biometryType: String
        switch context.biometryType {
        case .faceID: biometryType = "Face ID"
        case .touchID: biometryType = "Touch ID"
        case .opticID: biometryType = "Optic ID"
        case .none: biometryType = "None"
        @unknown default: biometryType = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Biometry Type",
            value: biometryType,
            notes: "Type of biometric authentication supported by this device."
        ))

        // Can evaluate biometrics
        items.append(DeviceInfoItem(
            key: "Biometrics Enrolled",
            value: canEvaluate ? "Yes" : "No",
            notes: canEvaluate ? "Biometric data (face/fingerprint) is registered." : "Error: \(error?.localizedDescription ?? "No biometrics enrolled")"
        ))

        // Screen captured
        let isCaptured = UIScreen.main.isCaptured
        items.append(DeviceInfoItem(
            key: "Screen Captured",
            value: isCaptured ? "Yes" : "No",
            notes: "Whether the screen is currently being recorded or mirrored via AirPlay."
        ))

        items.append(DeviceInfoItem(
            key: "Secure Enclave Available",
            value: SecureEnclave.isAvailable ? "Yes" : "No"
        ))

        items.append(DeviceInfoItem(
            key: "App Attest Supported",
            value: DCAppAttestService.shared.isSupported ? "Yes" : "No"
        ))

        logger.debug("Biometrics collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Biometrics & Security",
            icon: "faceid",
            items: items,
            explanation: """
            Biometrics & Security shows the type of biometric authentication available \
            on this device (Face ID, Touch ID, or none), whether biometric data is enrolled, \
            and whether the screen is currently being captured (screen recording or AirPlay mirroring). \
            Uses LocalAuthentication framework. No biometric data is collected or stored — only \
            capability checks are performed.
            """
        )
    }
}
