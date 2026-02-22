import SwiftUI
import CoreBluetooth
import UIKit

struct SectionView: View {
    let section: DeviceInfoSection
    let privacyMode: Bool
    let collapseAllSignal: Int
    let expandAllSignal: Int
    let expandSectionID: String?
    @State private var isExpanded = true

    var body: some View {
        Section {
            if isExpanded {
                ForEach(section.items) { item in
                    ItemRowView(item: item, privacyMode: privacyMode)
                }

                ExplainRowView(title: section.title, explanation: section.explanation)
            }
        } header: {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: section.icon)
                        .foregroundStyle(Color.accentColor)
                    Text(section.title)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .id(section.id)
        .onChange(of: collapseAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
        }
        .onChange(of: expandAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
        }
        .onChange(of: expandSectionID) { _, newID in
            if newID == section.id {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }
        }
    }
}

struct ScanSectionView: View {
    let section: DeviceInfoSection
    let privacyMode: Bool
    let collapseAllSignal: Int
    let expandAllSignal: Int
    let expandSectionID: String?
    let isScanning: Bool
    let onScan: () -> Void
    let detailItems: [DeviceInfoItem]
    let detailTitle: String
    let deviceCount: Int
    var permissionStatus: CBManagerAuthorization? = nil
    var onRequestPermission: (() -> Void)? = nil
    @State private var isExpanded = true
    @State private var showDevicesSheet = false

    var body: some View {
        Section {
            if isExpanded {
                // Bluetooth permission request row (only for BT section)
                if let status = permissionStatus {
                    if status == .notDetermined {
                        Button {
                            onRequestPermission?()
                        } label: {
                            HStack {
                                Image(systemName: "bluetooth")
                                    .foregroundStyle(.blue)
                                Text("Request Bluetooth Access")
                                    .foregroundStyle(Color.accentColor)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    } else if status == .denied || status == .restricted {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "bluetooth")
                                    .foregroundStyle(.red)
                                Text("Bluetooth")
                                Spacer()
                                Text(status == .denied ? "Denied" : "Restricted")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                Text("Settings")
                                    .foregroundStyle(Color.accentColor)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    } else if status == .allowedAlways {
                        HStack {
                            Image(systemName: "bluetooth")
                                .foregroundStyle(.green)
                            Text("Bluetooth")
                            Spacer()
                            Text("Allowed")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                }

                // Scan button row
                Button {
                    onScan()
                } label: {
                    HStack {
                        if isScanning {
                            ProgressView()
                                .controlSize(.small)
                            Text("Scanning...")
                                .foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundStyle(Color.accentColor)
                            Text("Scan")
                                .foregroundStyle(Color.accentColor)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isScanning)

                ForEach(section.items) { item in
                    ItemRowView(item: item, privacyMode: privacyMode)
                }

                // Show Devices button (only when there are results)
                if !detailItems.isEmpty {
                    Button {
                        showDevicesSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundStyle(Color.accentColor)
                            Text("Show \(deviceCount) devices")
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showDevicesSheet) {
                        DiscoveredDevicesSheet(title: detailTitle, items: detailItems)
                    }
                }

                ExplainRowView(title: section.title, explanation: section.explanation)
            }
        } header: {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: section.icon)
                        .foregroundStyle(Color.accentColor)
                    Text(section.title)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .id(section.id)
        .onChange(of: collapseAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
        }
        .onChange(of: expandAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
        }
        .onChange(of: expandSectionID) { _, newID in
            if newID == section.id {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }
        }
    }
}

struct PublicIPSectionView: View {
    let section: DeviceInfoSection
    let privacyMode: Bool
    let collapseAllSignal: Int
    let expandAllSignal: Int
    let expandSectionID: String?
    let isFetching: Bool
    let hasFetched: Bool
    let onFetch: () -> Void
    @State private var isExpanded = true

    var body: some View {
        Section {
            if isExpanded {
                if !hasFetched {
                    Button {
                        onFetch()
                    } label: {
                        HStack {
                            if isFetching {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Determining Public IP...")
                                    .foregroundStyle(.secondary)
                            } else {
                                Image(systemName: "globe")
                                    .foregroundStyle(Color.accentColor)
                                Text("Determine Public IP")
                                    .foregroundStyle(Color.accentColor)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isFetching)
                } else {
                    ForEach(section.items) { item in
                        ItemRowView(item: item, privacyMode: privacyMode)
                    }
                }

                ExplainRowView(title: section.title, explanation: section.explanation)
            }
        } header: {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: section.icon)
                        .foregroundStyle(Color.accentColor)
                    Text(section.title)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .id(section.id)
        .onChange(of: collapseAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
        }
        .onChange(of: expandAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
        }
        .onChange(of: expandSectionID) { _, newID in
            if newID == section.id {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }
        }
    }
}

struct ClipboardSectionView: View {
    let section: DeviceInfoSection
    let privacyMode: Bool
    let collapseAllSignal: Int
    let expandAllSignal: Int
    let expandSectionID: String?
    let isFetching: Bool
    let hasFetched: Bool
    let onFetch: () -> Void
    @State private var isExpanded = true

    var body: some View {
        Section {
            if isExpanded {
                if !hasFetched {
                    Button {
                        onFetch()
                    } label: {
                        HStack {
                            if isFetching {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Inspecting Clipboard...")
                                    .foregroundStyle(.secondary)
                            } else {
                                Image(systemName: "clipboard")
                                    .foregroundStyle(Color.accentColor)
                                Text("Inspect Clipboard")
                                    .foregroundStyle(Color.accentColor)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isFetching)
                } else {
                    ForEach(section.items) { item in
                        ItemRowView(item: item, privacyMode: privacyMode)
                    }
                }

                ExplainRowView(title: section.title, explanation: section.explanation)
            }
        } header: {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: section.icon)
                        .foregroundStyle(Color.accentColor)
                    Text(section.title)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .id(section.id)
        .onChange(of: collapseAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
        }
        .onChange(of: expandAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
        }
        .onChange(of: expandSectionID) { _, newID in
            if newID == section.id {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }
        }
    }
}

struct PermissionSectionView: View {
    let section: DeviceInfoSection
    let privacyMode: Bool
    let collapseAllSignal: Int
    let expandAllSignal: Int
    let expandSectionID: String?
    let permissionIcon: String
    let permissionLabel: String
    let permissionStatusText: String
    let permissionStatusColor: Color
    let isRequestable: Bool
    let isDenied: Bool
    let onRequestPermission: () -> Void
    @State private var isExpanded = true

    var body: some View {
        Section {
            if isExpanded {
                // Permission request row
                if isRequestable {
                    Button {
                        onRequestPermission()
                    } label: {
                        HStack {
                            Image(systemName: permissionIcon)
                                .foregroundStyle(.blue)
                            Text("Request \(permissionLabel) Access")
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else if isDenied {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: permissionIcon)
                                .foregroundStyle(.red)
                            Text(permissionLabel)
                            Spacer()
                            Text(permissionStatusText)
                                .font(.caption)
                                .foregroundStyle(.red)
                            Text("Settings")
                                .foregroundStyle(Color.accentColor)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack {
                        Image(systemName: permissionIcon)
                            .foregroundStyle(permissionStatusColor)
                        Text(permissionLabel)
                        Spacer()
                        Text(permissionStatusText)
                            .font(.caption)
                            .foregroundStyle(permissionStatusColor)
                    }
                }

                ForEach(section.items) { item in
                    ItemRowView(item: item, privacyMode: privacyMode)
                }

                ExplainRowView(title: section.title, explanation: section.explanation)
            }
        } header: {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: section.icon)
                        .foregroundStyle(Color.accentColor)
                    Text(section.title)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .id(section.id)
        .onChange(of: collapseAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
        }
        .onChange(of: expandAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
        }
        .onChange(of: expandSectionID) { _, newID in
            if newID == section.id {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }
        }
    }
}

struct DetailListSectionView: View {
    let section: DeviceInfoSection
    let privacyMode: Bool
    let collapseAllSignal: Int
    let expandAllSignal: Int
    let expandSectionID: String?
    let detailItems: [DeviceInfoItem]
    let detailTitle: String
    let detailCount: Int
    let detailCountLabel: String
    @State private var isExpanded = true
    @State private var showDetailSheet = false

    var body: some View {
        Section {
            if isExpanded {
                ForEach(section.items) { item in
                    ItemRowView(item: item, privacyMode: privacyMode)
                }

                if !detailItems.isEmpty {
                    Button {
                        showDetailSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundStyle(Color.accentColor)
                            Text("Show \(detailCount) \(detailCountLabel)")
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showDetailSheet) {
                        DiscoveredDevicesSheet(title: detailTitle, items: detailItems)
                    }
                }

                ExplainRowView(title: section.title, explanation: section.explanation)
            }
        } header: {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: section.icon)
                        .foregroundStyle(Color.accentColor)
                    Text(section.title)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .id(section.id)
        .onChange(of: collapseAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
        }
        .onChange(of: expandAllSignal) {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
        }
        .onChange(of: expandSectionID) { _, newID in
            if newID == section.id {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }
        }
    }
}

private struct ExplainRowView: View {
    let title: String
    let explanation: String
    @State private var showExplanation = false

    var body: some View {
        Button {
            showExplanation = true
        } label: {
            HStack {
                Label("Explain", systemImage: "questionmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showExplanation) {
            ExplanationSheet(title: title, explanation: explanation)
        }
    }
}
