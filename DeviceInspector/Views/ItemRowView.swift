import SwiftUI

struct ItemRowView: View {
    let item: DeviceInfoItem
    let privacyMode: Bool

    @State private var showDetail = false

    private var displayValue: String {
        if privacyMode && item.isSensitive {
            return String(repeating: "\u{2022}", count: 8)
        }
        return item.value
    }

    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.key)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    AvailabilityBadge(availability: item.availability)
                }

                Text(displayValue)
                    .font(.body.monospaced())
                    .foregroundStyle(.primary)
                    .blur(radius: (privacyMode && item.isSensitive) ? 4 : 0)

                if let notes = item.notes {
                    Text(notes)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            ItemDetailSheet(item: item)
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = item.value
            } label: {
                Label("Copy Value", systemImage: "doc.on.doc")
            }

            Button {
                UIPasteboard.general.string = "\(item.key): \(item.value)"
            } label: {
                Label("Copy Key & Value", systemImage: "doc.on.clipboard")
            }
        }
    }
}
