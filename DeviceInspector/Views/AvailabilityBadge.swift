import SwiftUI

struct AvailabilityBadge: View {
    let availability: InfoAvailability

    private var color: Color {
        switch availability {
        case .available:
            return .green
        case .requiresPermission:
            return .orange
        case .notAvailable:
            return .red
        }
    }

    var body: some View {
        Text(availability.rawValue)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
