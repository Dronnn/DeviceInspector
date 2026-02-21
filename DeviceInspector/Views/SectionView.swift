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
