import AVFoundation
import Photos
import Contacts
import EventKit
import CoreLocation
import CoreMotion
import Speech
import UserNotifications
import CoreBluetooth
import AppTrackingTransparency
import Intents
import UIKit

struct PermissionRequester {
    static let permissionDidChange = Notification.Name("PermissionRequesterDidChange")

    static func isPermissionItem(_ key: String) -> Bool {
        permissionKeys.contains(key)
    }

    static func isRequestable(_ value: String) -> Bool {
        value == "Not Determined"
    }

    private static let permissionKeys: Set<String> = [
        "Camera", "Microphone", "Photos", "Contacts", "Calendar",
        "Reminders", "Location", "Motion & Fitness", "Speech Recognition",
        "Notifications", "Bluetooth", "App Tracking (ATT)", "Siri"
    ]

    @MainActor
    static func request(for key: String) async -> String {
        let result = await performRequest(for: key)
        if result != "Not Determined" && result != "Unknown" {
            NotificationCenter.default.post(name: permissionDidChange, object: nil)
        }
        return result
    }

    @MainActor
    private static func performRequest(for key: String) async -> String {
        switch key {
        case "Camera":
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            return granted ? "Authorized" : "Denied"

        case "Microphone":
            let granted = await AVCaptureDevice.requestAccess(for: .audio)
            return granted ? "Authorized" : "Denied"

        case "Photos":
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            switch status {
            case .authorized: return "Full Access"
            case .limited: return "Limited Access"
            case .denied: return "Denied"
            case .restricted: return "Restricted"
            default: return "Unknown"
            }

        case "Contacts":
            let store = CNContactStore()
            do {
                let granted = try await store.requestAccess(for: .contacts)
                return granted ? "Authorized" : "Denied"
            } catch {
                return "Denied"
            }

        case "Calendar":
            let store = EKEventStore()
            do {
                let granted = try await store.requestFullAccessToEvents()
                return granted ? "Full Access" : "Denied"
            } catch {
                return "Denied"
            }

        case "Reminders":
            let store = EKEventStore()
            do {
                let granted = try await store.requestFullAccessToReminders()
                return granted ? "Full Access" : "Denied"
            } catch {
                return "Denied"
            }

        case "Location":
            return "Not Determined"

        case "Motion & Fitness":
            let manager = CMMotionActivityManager()
            return await withCheckedContinuation { continuation in
                manager.startActivityUpdates(to: .main) { _ in
                    manager.stopActivityUpdates()
                    let status = CMMotionActivityManager.authorizationStatus()
                    switch status {
                    case .authorized: continuation.resume(returning: "Authorized")
                    case .denied: continuation.resume(returning: "Denied")
                    case .restricted: continuation.resume(returning: "Restricted")
                    default: continuation.resume(returning: "Not Determined")
                    }
                }
            }

        case "Speech Recognition":
            return await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    switch status {
                    case .authorized: continuation.resume(returning: "Authorized")
                    case .denied: continuation.resume(returning: "Denied")
                    case .restricted: continuation.resume(returning: "Restricted")
                    default: continuation.resume(returning: "Not Determined")
                    }
                }
            }

        case "Notifications":
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
                return granted ? "Authorized" : "Denied"
            } catch {
                return "Denied"
            }

        case "Bluetooth":
            return "Not Determined"

        case "App Tracking (ATT)":
            let status = await ATTrackingManager.requestTrackingAuthorization()
            switch status {
            case .authorized: return "Authorized"
            case .denied: return "Denied"
            case .restricted: return "Restricted"
            default: return "Not Determined"
            }

        case "Siri":
            return await withCheckedContinuation { continuation in
                INPreferences.requestSiriAuthorization { status in
                    switch status {
                    case .authorized: continuation.resume(returning: "Authorized")
                    case .denied: continuation.resume(returning: "Denied")
                    case .restricted: continuation.resume(returning: "Restricted")
                    default: continuation.resume(returning: "Not Determined")
                    }
                }
            }

        default:
            return "Unknown"
        }
    }

    @MainActor
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
