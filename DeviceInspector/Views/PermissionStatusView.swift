import SwiftUI
import UIKit
import CoreLocation
import AppTrackingTransparency
import CoreBluetooth

struct PermissionStatusView: View {
    let locationStatus: CLAuthorizationStatus
    let attStatus: ATTrackingManager.AuthorizationStatus
    let bluetoothStatus: CBManagerAuthorization
    let onRequestLocation: () -> Void
    let onRequestATT: () async -> Void
    let onRequestBluetooth: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Permissions")
                .font(.headline)

            HStack {
                Image(systemName: "location")
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                Text("Location")
                Spacer()
                Text(locationStatusText)
                    .font(.caption)
                    .foregroundStyle(locationStatusColor)
                if locationStatus == .notDetermined {
                    Button("Request") {
                        onRequestLocation()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                } else if locationStatus == .denied || locationStatus == .restricted {
                    Button("Settings") {
                        openSettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            HStack {
                Image(systemName: "hand.raised")
                    .foregroundStyle(.purple)
                    .frame(width: 20)
                Text("Tracking")
                Spacer()
                Text(attStatusText)
                    .font(.caption)
                    .foregroundStyle(attStatusColor)
                if attStatus == .notDetermined {
                    Button("Request") {
                        Task { await onRequestATT() }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                } else if attStatus == .denied || attStatus == .restricted {
                    Button("Settings") {
                        openSettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                Text("Bluetooth")
                Spacer()
                Text(bluetoothStatusText)
                    .font(.caption)
                    .foregroundStyle(bluetoothStatusColor)
                if bluetoothStatus == .notDetermined {
                    Button("Request") {
                        onRequestBluetooth()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                } else if bluetoothStatus == .denied || bluetoothStatus == .restricted {
                    Button("Settings") {
                        openSettings()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Open Settings

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Location Status

    private var locationStatusText: String {
        switch locationStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Always"
        case .authorizedWhenInUse:
            return "When In Use"
        @unknown default:
            return "Unknown"
        }
    }

    private var locationStatusColor: Color {
        switch locationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .secondary
        }
    }

    // MARK: - ATT Status

    private var attStatusText: String {
        switch attStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        @unknown default:
            return "Unknown"
        }
    }

    private var attStatusColor: Color {
        switch attStatus {
        case .authorized:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .secondary
        }
    }

    // MARK: - Bluetooth Status

    private var bluetoothStatusText: String {
        switch bluetoothStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .allowedAlways:
            return "Allowed"
        @unknown default:
            return "Unknown"
        }
    }

    private var bluetoothStatusColor: Color {
        switch bluetoothStatus {
        case .allowedAlways:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .secondary
        }
    }
}
