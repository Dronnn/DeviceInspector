import CoreLocation
import os.log

struct LocationCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "LocationCollector")

    static func collect(authorizationStatus: CLAuthorizationStatus, accuracyAuthorization: CLAccuracyAuthorization?, location: CLLocation?, locationServicesEnabled: Bool) -> DeviceInfoSection {
        logger.debug("Collecting location data")
        var items: [DeviceInfoItem] = []

        // MARK: - Free info (no permission needed)
        items.append(DeviceInfoItem(
            key: "Location Services Enabled",
            value: locationServicesEnabled ? "Yes" : "No",
            notes: "Whether location services are enabled globally in Settings."
        ))

        let headingAvailable = CLLocationManager.headingAvailable()
        items.append(DeviceInfoItem(
            key: "Heading Available",
            value: headingAvailable ? "Yes" : "No",
            notes: "Whether the device has a magnetometer for compass heading."
        ))

        let significantLocationAvailable = CLLocationManager.significantLocationChangeMonitoringAvailable()
        items.append(DeviceInfoItem(
            key: "Significant Location Monitoring",
            value: significantLocationAvailable ? "Available" : "Not Available",
            notes: "Whether the device supports significant location change monitoring."
        ))

        let rangingAvailable = CLLocationManager.isRangingAvailable()
        items.append(DeviceInfoItem(
            key: "Ranging Available",
            value: rangingAvailable ? "Yes" : "No",
            notes: "Whether the device supports ranging for iBeacon detection."
        ))

        let authStatusString: String
        switch authorizationStatus {
        case .notDetermined: authStatusString = "Not Determined"
        case .restricted: authStatusString = "Restricted"
        case .denied: authStatusString = "Denied"
        case .authorizedAlways: authStatusString = "Authorized Always"
        case .authorizedWhenInUse: authStatusString = "Authorized When In Use"
        @unknown default: authStatusString = "Unknown"
        }
        items.append(DeviceInfoItem(
            key: "Authorization Status",
            value: authStatusString,
            notes: "Current location permission level granted by the user."
        ))

        let accuracyString: String
        if let accuracyAuthorization {
            switch accuracyAuthorization {
            case .fullAccuracy: accuracyString = "Full Accuracy"
            case .reducedAccuracy: accuracyString = "Reduced Accuracy"
            @unknown default: accuracyString = "Unknown"
            }
        } else {
            accuracyString = "Not Available"
        }
        items.append(DeviceInfoItem(
            key: "Accuracy Authorization",
            value: accuracyString,
            notes: "Whether the app has full or reduced location accuracy."
        ))

        // MARK: - Actual location data (requires permission)

        if let location {
            items.append(DeviceInfoItem(
                key: "Latitude",
                value: String(format: "%.6f", location.coordinate.latitude),
                isSensitive: true
            ))

            items.append(DeviceInfoItem(
                key: "Longitude",
                value: String(format: "%.6f", location.coordinate.longitude),
                isSensitive: true
            ))

            items.append(DeviceInfoItem(
                key: "Altitude",
                value: String(format: "%.1f m", location.altitude)
            ))

            items.append(DeviceInfoItem(
                key: "Horizontal Accuracy",
                value: String(format: "%.1f m", location.horizontalAccuracy)
            ))

            items.append(DeviceInfoItem(
                key: "Vertical Accuracy",
                value: String(format: "%.1f m", location.verticalAccuracy)
            ))

            items.append(DeviceInfoItem(
                key: "Speed",
                value: location.speed >= 0 ? String(format: "%.1f m/s", location.speed) : "Not available"
            ))

            items.append(DeviceInfoItem(
                key: "Speed Accuracy",
                value: location.speedAccuracy >= 0 ? String(format: "%.1f m/s", location.speedAccuracy) : "Not available"
            ))

            items.append(DeviceInfoItem(
                key: "Course",
                value: location.course >= 0 ? String(format: "%.1f\u{00B0}", location.course) : "Not available"
            ))

            items.append(DeviceInfoItem(
                key: "Course Accuracy",
                value: location.courseAccuracy >= 0 ? String(format: "%.1f\u{00B0}", location.courseAccuracy) : "Not available"
            ))

            items.append(DeviceInfoItem(
                key: "Floor Level",
                value: location.floor != nil ? "\(location.floor!.level)" : "Not available"
            ))

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            items.append(DeviceInfoItem(
                key: "Location Timestamp",
                value: formatter.string(from: location.timestamp)
            ))
        } else {
            let locationKeys = [
                "Latitude", "Longitude", "Altitude",
                "Horizontal Accuracy", "Vertical Accuracy",
                "Speed", "Speed Accuracy",
                "Course", "Course Accuracy",
                "Floor Level", "Location Timestamp"
            ]
            for key in locationKeys {
                let isSensitive = key == "Latitude" || key == "Longitude"
                items.append(DeviceInfoItem(
                    key: key,
                    value: "Requires Location Permission",
                    availability: .requiresPermission,
                    isSensitive: isSensitive
                ))
            }
        }

        logger.debug("Location collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Location",
            icon: "location",
            items: items,
            explanation: """
            Location data available through CoreLocation framework. Some capabilities can be \
            queried without permission. Actual coordinates require user authorization.
            """
        )
    }
}
