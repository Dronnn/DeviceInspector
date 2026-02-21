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
import os.log

struct PermissionsCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "PermissionsCollector")

    static func collect() async -> DeviceInfoSection {
        logger.debug("Collecting permissions data")
        var items: [DeviceInfoItem] = []

        // Camera
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        items.append(DeviceInfoItem(
            key: "Camera",
            value: avAuthString(cameraStatus),
            availability: cameraStatus == .authorized ? .available : .requiresPermission
        ))

        // Microphone
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        items.append(DeviceInfoItem(
            key: "Microphone",
            value: avAuthString(micStatus),
            availability: micStatus == .authorized ? .available : .requiresPermission
        ))

        // Photos
        let photoStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        items.append(DeviceInfoItem(
            key: "Photos",
            value: phAuthString(photoStatus),
            availability: photoStatus == .authorized || photoStatus == .limited ? .available : .requiresPermission
        ))

        // Contacts
        let contactStatus = CNContactStore.authorizationStatus(for: .contacts)
        items.append(DeviceInfoItem(
            key: "Contacts",
            value: cnAuthString(contactStatus),
            availability: contactStatus == .authorized ? .available : .requiresPermission
        ))

        // Calendar
        let calendarStatus = EKEventStore.authorizationStatus(for: .event)
        let calendarGranted: Bool
        if #available(iOS 17.0, *) {
            calendarGranted = calendarStatus == .fullAccess || calendarStatus == .authorized
        } else {
            calendarGranted = calendarStatus == .authorized
        }
        items.append(DeviceInfoItem(
            key: "Calendar",
            value: ekAuthString(calendarStatus),
            availability: calendarGranted ? .available : .requiresPermission
        ))

        // Reminders
        let reminderStatus = EKEventStore.authorizationStatus(for: .reminder)
        let reminderGranted: Bool
        if #available(iOS 17.0, *) {
            reminderGranted = reminderStatus == .fullAccess || reminderStatus == .authorized
        } else {
            reminderGranted = reminderStatus == .authorized
        }
        items.append(DeviceInfoItem(
            key: "Reminders",
            value: ekAuthString(reminderStatus),
            availability: reminderGranted ? .available : .requiresPermission
        ))

        // Location
        let locationStatus = CLLocationManager().authorizationStatus
        let locationString: String
        switch locationStatus {
        case .notDetermined: locationString = "Not Determined"
        case .restricted: locationString = "Restricted"
        case .denied: locationString = "Denied"
        case .authorizedAlways: locationString = "Always"
        case .authorizedWhenInUse: locationString = "When In Use"
        @unknown default: locationString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Location",
            value: locationString,
            availability: locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse ? .available : .requiresPermission
        ))

        // Motion & Fitness
        let motionStatus = CMMotionActivityManager.authorizationStatus()
        let motionString: String
        switch motionStatus {
        case .notDetermined: motionString = "Not Determined"
        case .restricted: motionString = "Restricted"
        case .denied: motionString = "Denied"
        case .authorized: motionString = "Authorized"
        @unknown default: motionString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Motion & Fitness",
            value: motionString,
            availability: motionStatus == .authorized ? .available : .requiresPermission
        ))

        // Speech Recognition
        let speechStatus = SFSpeechRecognizer.authorizationStatus()
        let speechString: String
        switch speechStatus {
        case .notDetermined: speechString = "Not Determined"
        case .denied: speechString = "Denied"
        case .restricted: speechString = "Restricted"
        case .authorized: speechString = "Authorized"
        @unknown default: speechString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Speech Recognition",
            value: speechString,
            availability: speechStatus == .authorized ? .available : .requiresPermission
        ))

        // Notifications (async)
        let notifSettings = await UNUserNotificationCenter.current().notificationSettings()
        let notifString: String
        switch notifSettings.authorizationStatus {
        case .notDetermined: notifString = "Not Determined"
        case .denied: notifString = "Denied"
        case .authorized: notifString = "Authorized"
        case .provisional: notifString = "Provisional"
        case .ephemeral: notifString = "Ephemeral"
        @unknown default: notifString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Notifications",
            value: notifString,
            availability: notifSettings.authorizationStatus == .authorized ? .available : .requiresPermission
        ))

        // Bluetooth
        let btAuth = CBCentralManager.authorization
        let btString: String
        switch btAuth {
        case .notDetermined: btString = "Not Determined"
        case .restricted: btString = "Restricted"
        case .denied: btString = "Denied"
        case .allowedAlways: btString = "Allowed Always"
        @unknown default: btString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Bluetooth",
            value: btString,
            availability: btAuth == .allowedAlways ? .available : .requiresPermission
        ))

        // App Tracking Transparency
        let attStatus = ATTrackingManager.trackingAuthorizationStatus
        let attString: String
        switch attStatus {
        case .notDetermined: attString = "Not Determined"
        case .restricted: attString = "Restricted"
        case .denied: attString = "Denied"
        case .authorized: attString = "Authorized"
        @unknown default: attString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "App Tracking (ATT)",
            value: attString,
            availability: attStatus == .authorized ? .available : .requiresPermission
        ))

        // Siri
        let siriStatus = INPreferences.siriAuthorizationStatus()
        let siriString: String
        switch siriStatus {
        case .notDetermined: siriString = "Not Determined"
        case .restricted: siriString = "Restricted"
        case .denied: siriString = "Denied"
        case .authorized: siriString = "Authorized"
        @unknown default: siriString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Siri",
            value: siriString,
            availability: siriStatus == .authorized ? .available : .requiresPermission
        ))

        logger.debug("Permissions collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Permission Statuses",
            icon: "lock.shield",
            items: items,
            explanation: """
            Permission Statuses shows the current authorization state for all major iOS permissions. \
            No permission requests are triggered — only the current status is read. Statuses include: \
            Not Determined (never asked), Denied (user declined), Restricted (parental controls), \
            and Authorized (user approved). Uses AVFoundation, Photos, Contacts, EventKit, CoreLocation, \
            CoreMotion, Speech, UserNotifications, CoreBluetooth, AppTrackingTransparency, and Intents.
            """
        )
    }

    private static func avAuthString(_ status: AVAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }

    private static func phAuthString(_ status: PHAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Full Access"
        case .limited: return "Limited Access"
        @unknown default: return "Unknown"
        }
    }

    private static func cnAuthString(_ status: CNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }

    private static func ekAuthString(_ status: EKAuthorizationStatus) -> String {
        if #available(iOS 17.0, *) {
            switch status {
            case .notDetermined: return "Not Determined"
            case .restricted: return "Restricted"
            case .denied: return "Denied"
            case .authorized: return "Authorized"
            case .fullAccess: return "Full Access"
            case .writeOnly: return "Write Only"
            @unknown default: return "Unknown"
            }
        } else {
            switch status {
            case .notDetermined: return "Not Determined"
            case .restricted: return "Restricted"
            case .denied: return "Denied"
            case .authorized: return "Authorized"
            @unknown default: return "Unknown"
            }
        }
    }
}
