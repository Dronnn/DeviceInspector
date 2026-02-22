import UIKit
import os.log

struct AccessibilityCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "AccessibilityCollector")

    @MainActor
    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting accessibility data")
        var items: [DeviceInfoItem] = []

        items.append(DeviceInfoItem(
            key: "VoiceOver Running",
            value: UIAccessibility.isVoiceOverRunning ? "Yes" : "No",
            notes: "Screen reader for visually impaired users."
        ))

        items.append(DeviceInfoItem(
            key: "Switch Control Running",
            value: UIAccessibility.isSwitchControlRunning ? "Yes" : "No",
            notes: "Assistive technology for users with limited motor skills."
        ))

        items.append(DeviceInfoItem(
            key: "Guided Access Enabled",
            value: UIAccessibility.isGuidedAccessEnabled ? "Yes" : "No",
            notes: "Restricts device to a single app (kiosk mode)."
        ))

        items.append(DeviceInfoItem(
            key: "AssistiveTouch Running",
            value: UIAccessibility.isAssistiveTouchRunning ? "Yes" : "No",
            notes: "On-screen virtual button for device controls."
        ))

        items.append(DeviceInfoItem(
            key: "Shake to Undo Enabled",
            value: UIAccessibility.isShakeToUndoEnabled ? "Yes" : "No"
        ))

        items.append(DeviceInfoItem(
            key: "Reduce Motion Enabled",
            value: UIAccessibility.isReduceMotionEnabled ? "Yes" : "No",
            notes: "Reduces UI animations and parallax effects."
        ))

        items.append(DeviceInfoItem(
            key: "Prefer Cross-Fade Transitions",
            value: UIAccessibility.prefersCrossFadeTransitions ? "Yes" : "No",
            notes: "Prefers cross-fade transitions over sliding animations."
        ))

        items.append(DeviceInfoItem(
            key: "Video Autoplay Enabled",
            value: UIAccessibility.isVideoAutoplayEnabled ? "Yes" : "No"
        ))

        items.append(DeviceInfoItem(
            key: "Reduce Transparency Enabled",
            value: UIAccessibility.isReduceTransparencyEnabled ? "Yes" : "No",
            notes: "Reduces transparency and blur effects for readability."
        ))

        items.append(DeviceInfoItem(
            key: "Darker System Colors Enabled",
            value: UIAccessibility.isDarkerSystemColorsEnabled ? "Yes" : "No",
            notes: "Increases contrast of UI elements."
        ))

        items.append(DeviceInfoItem(
            key: "Bold Text Enabled",
            value: UIAccessibility.isBoldTextEnabled ? "Yes" : "No"
        ))

        items.append(DeviceInfoItem(
            key: "Grayscale Enabled",
            value: UIAccessibility.isGrayscaleEnabled ? "Yes" : "No",
            notes: "Removes color from the display."
        ))

        items.append(DeviceInfoItem(
            key: "Invert Colors Enabled",
            value: UIAccessibility.isInvertColorsEnabled ? "Yes" : "No",
            notes: "Smart or Classic invert is active."
        ))

        items.append(DeviceInfoItem(
            key: "Differentiate Without Color",
            value: UIAccessibility.shouldDifferentiateWithoutColor ? "Yes" : "No",
            notes: "Apps should not rely on color alone to convey information."
        ))

        items.append(DeviceInfoItem(
            key: "On/Off Switch Labels",
            value: UIAccessibility.isOnOffSwitchLabelsEnabled ? "Yes" : "No",
            notes: "Shows I/O labels on toggle switches."
        ))

        items.append(DeviceInfoItem(
            key: "Closed Captioning Enabled",
            value: UIAccessibility.isClosedCaptioningEnabled ? "Yes" : "No"
        ))

        items.append(DeviceInfoItem(
            key: "Mono Audio Enabled",
            value: UIAccessibility.isMonoAudioEnabled ? "Yes" : "No",
            notes: "Combines stereo channels into mono for hearing-impaired users."
        ))

        items.append(DeviceInfoItem(
            key: "Speak Selection Enabled",
            value: UIAccessibility.isSpeakSelectionEnabled ? "Yes" : "No",
            notes: "User can select text and have it spoken aloud."
        ))

        items.append(DeviceInfoItem(
            key: "Speak Screen Enabled",
            value: UIAccessibility.isSpeakScreenEnabled ? "Yes" : "No",
            notes: "Two-finger swipe down from top reads entire screen."
        ))

        items.append(DeviceInfoItem(
            key: "Button Shapes Enabled",
            value: UIAccessibility.buttonShapesEnabled ? "Yes" : "No",
            notes: "Buttons display underlines or outlines for visibility."
        ))

        // Hearing device
        let ear = UIAccessibility.hearingDevicePairedEar
        let earString: String
        if ear.contains(.both) {
            earString = "Both"
        } else if ear.contains(.left) {
            earString = "Left"
        } else if ear.contains(.right) {
            earString = "Right"
        } else {
            earString = "None"
        }
        items.append(DeviceInfoItem(
            key: "Hearing Device Paired Ear",
            value: earString,
            notes: "Which ear(s) have a paired MFi hearing device."
        ))

        let contentSize = UIApplication.shared.preferredContentSizeCategory
        items.append(DeviceInfoItem(key: "Preferred Content Size", value: contentSize.rawValue))

        logger.debug("Accessibility collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Accessibility",
            icon: "accessibility",
            items: items,
            explanation: """
            Accessibility shows the state of all publicly queryable iOS accessibility settings. \
            These flags are read-only and do not require any permissions. Apps should respect \
            these settings to provide an inclusive user experience. All values come from \
            UIAccessibility static properties and are updated in real-time by the system.
            """
        )
    }
}
