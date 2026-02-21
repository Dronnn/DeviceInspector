import SwiftUI
import UIKit

struct ItemDetailSheet: View {
    let item: DeviceInfoItem
    var privacyMode: Bool = false

    @Environment(\.dismiss) private var dismiss
    @State private var updatedValue: String?

    private var displayValue: String {
        if privacyMode && item.isSensitive {
            return String(repeating: "\u{2022}", count: 8)
        }
        return updatedValue ?? item.value
    }

    private var availabilityExplanation: String {
        switch item.availability {
        case .available:
            return "This data is freely accessible without any permissions."
        case .requiresPermission:
            return "This data requires user permission to access. Grant the relevant permission in Settings."
        case .notAvailable:
            return "This data cannot be accessed on iOS using public APIs."
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Value block
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Value")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(displayValue)
                            .font(.body.monospaced())
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // What is this? section
                    if let explanation = ItemExplanations.explanation(for: item.key) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What is this?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(explanation)
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    // Availability section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Availability")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            AvailabilityBadge(availability: item.availability)
                            Spacer()
                        }

                        Text(availabilityExplanation)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    // Details section
                    if let details = item.details, !details.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Details (\(details.count))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(spacing: 0) {
                                ForEach(details.keys.sorted(), id: \.self) { key in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(key)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(privacyMode && item.isSensitive
                                            ? String(repeating: "\u{2022}", count: 8)
                                            : (details[key] ?? ""))
                                            .font(.caption.monospaced())
                                            .textSelection(.enabled)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)

                                    if key != details.keys.sorted().last {
                                        Divider()
                                            .padding(.horizontal, 10)
                                    }
                                }
                            }
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    // Notes section
                    if let notes = item.notes {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(notes)
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    // Permission action
                    if PermissionRequester.isPermissionItem(item.key),
                       PermissionRequester.isRequestable(displayValue) {
                        Button {
                            Task {
                                let newValue = await PermissionRequester.request(for: item.key)
                                updatedValue = newValue
                            }
                        } label: {
                            Label("Request Permission", systemImage: "hand.raised")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .controlSize(.large)
                    }

                    if PermissionRequester.isPermissionItem(item.key)
                        || item.availability == .requiresPermission {
                        Button {
                            PermissionRequester.openSettings()
                        } label: {
                            Label("Open Settings", systemImage: "gear")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(.systemGray))
                        .controlSize(.large)
                    }

                    // Copy button
                    Button {
                        UIPasteboard.general.string = displayValue
                    } label: {
                        Label("Copy Value", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
            }
            .navigationTitle(item.key)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
