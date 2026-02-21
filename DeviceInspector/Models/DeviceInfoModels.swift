import Foundation

enum InfoAvailability: String, Codable {
    case available = "Available"
    case requiresPermission = "Requires Permission"
    case notAvailable = "Not Available on iOS"
}

struct DeviceInfoItem: Identifiable, Codable {
    let id: String
    let key: String
    var value: String
    let availability: InfoAvailability
    let notes: String?
    let isSensitive: Bool
    let details: [String: String]?

    init(key: String, value: String, availability: InfoAvailability = .available, notes: String? = nil, isSensitive: Bool = false, details: [String: String]? = nil) {
        self.id = key
        self.key = key
        self.value = value
        self.availability = availability
        self.notes = notes
        self.isSensitive = isSensitive
        self.details = details
    }
}

struct DeviceInfoSection: Identifiable, Codable {
    let id: String
    let title: String
    let icon: String
    var items: [DeviceInfoItem]
    let explanation: String

    init(title: String, icon: String, items: [DeviceInfoItem], explanation: String) {
        self.id = "\(title)-\(UUID().uuidString)"
        self.title = title
        self.icon = icon
        self.items = items
        self.explanation = explanation
    }
}
