import SwiftUI

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
        .onChange(of: collapseAllSignal) { _ in
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
        }
        .onChange(of: expandAllSignal) { _ in
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
        }
        .onChange(of: expandSectionID) { newID in
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
    @State private var isExpanded = true
    @State private var showDevicesSheet = false

    var body: some View {
        Section {
            if isExpanded {
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
                            Text("Show \(detailItems.count) devices")
                                .foregroundStyle(Color.accentColor)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
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
        .onChange(of: collapseAllSignal) { _ in
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = false }
        }
        .onChange(of: expandAllSignal) { _ in
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
        }
        .onChange(of: expandSectionID) { newID in
            if newID == section.id {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded = true }
            }
        }
        .sheet(isPresented: $showDevicesSheet) {
            DiscoveredDevicesSheet(title: detailTitle, items: detailItems)
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
