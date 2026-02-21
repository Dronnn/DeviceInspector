import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Group {
                    Text("Last Updated: February 21, 2026")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("Contact: Andreas Maier")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                sectionBlock(
                    title: "Overview",
                    content: """
                    Device Inspector is a privacy-first iOS application designed to display detailed \
                    information about your device. This Privacy Policy explains how the app handles \
                    your data and what information it accesses.

                    Our commitment: Device Inspector does not collect personal data, does not require \
                    user accounts, and does not track or profile users.
                    """
                )

                sectionBlock(
                    title: "Data Collection and Storage",
                    subtitle: "On-Device Processing Only",
                    content: """
                    All device information displayed by Device Inspector is processed locally on your device. \
                    This includes:
                    """,
                    bullets: [
                        "Device model, iOS version, and hardware specifications",
                        "Storage and memory information",
                        "Active network interfaces and configurations",
                        "Running processes and system status",
                        "Battery and thermal status"
                    ],
                    footer: "This data is never stored, transmitted, or logged by the app."
                )

                sectionBlock(
                    title: "Network Requests",
                    subtitle: "Public IP Address Lookup",
                    content: """
                    The app makes a single, anonymous request to ipify.org to retrieve your public IP \
                    address when you explicitly tap "Determine Public IP". The purposes and terms are:
                    """,
                    bullets: [
                        "What is sent: Only a standard HTTP GET request to identify your public IP",
                        "What is displayed: Your public IP address is shown on the app screen only",
                        "What is NOT done: The IP address is not stored, cached, or transmitted to any server controlled by the developer",
                        "Privacy note: This request is subject to ipify.org's privacy policy"
                    ]
                )

                sectionBlock(
                    title: "Local Network Discovery",
                    content: """
                    Device Inspector scans your local network using Bonjour (mDNS) to discover available \
                    services and devices. All discovery activities remain on your local network and are \
                    not transmitted outside your device.
                    """
                )

                sectionBlock(
                    title: "Bluetooth Scanning",
                    content: """
                    The app scans for nearby Bluetooth Low Energy (BLE) devices to display available \
                    Bluetooth peripherals. This scan data remains on your device and is not transmitted elsewhere.
                    """
                )

                sectionBlock(
                    title: "System APIs and Required Reason APIs",
                    content: """
                    Device Inspector uses the following system APIs for legitimate on-device functionality:
                    """,
                    bullets: [
                        "System Boot Time API: Displays device uptime",
                        "Disk Space API: Shows available and used storage",
                        "Active Keyboard API: Displays information about active input methods"
                    ],
                    footer: """
                    The app includes a Privacy Manifest (PrivacyInfo.xcprivacy) that declares all required \
                    APIs in accordance with Apple's privacy requirements.
                    """
                )

                sectionBlock(
                    title: "What the App Does NOT Do",
                    bullets: [
                        "Does not collect personal data (names, emails, phone numbers, etc.)",
                        "Does not require user accounts or registration",
                        "Does not use analytics or tracking SDKs",
                        "Does not display advertisements",
                        "Does not use cookies",
                        "Does not transmit device information to any server controlled by the developer",
                        "Does not log system information",
                        "Does not profile or build user behavior models"
                    ]
                )

                sectionBlock(
                    title: "Data Export",
                    content: """
                    Device Inspector allows you to export device information in JSON format or copy it \
                    to your clipboard. These export operations are initiated only when you manually select \
                    the export option, processed entirely on your device, and not automatically transmitted \
                    or shared. You control what happens with exported data after you initiate the export.
                    """
                )

                sectionBlock(
                    title: "Third-Party Services",
                    content: """
                    The only third-party service used by Device Inspector is ipify.org for public IP \
                    address lookup. No other third-party services, analytics providers, or advertising \
                    networks are integrated into this app.
                    """
                )

                sectionBlock(
                    title: "Children's Privacy",
                    content: """
                    Device Inspector is not directed toward children under 13. The app does not knowingly \
                    collect any information from children.
                    """
                )

                sectionBlock(
                    title: "Changes to This Privacy Policy",
                    content: """
                    This Privacy Policy may be updated periodically to reflect changes in the app's \
                    functionality or evolving privacy practices. The "Last Updated" date at the top of \
                    this page will indicate when changes were made.
                    """
                )

                sectionBlock(
                    title: "Contact",
                    content: """
                    If you have questions or concerns about this Privacy Policy or how Device Inspector \
                    handles your data, please contact Andreas Maier.
                    """
                )

                Divider()

                Text("""
                Device Inspector is built with privacy as the foundation. Your device information stays \
                on your device. The app collects no personal data, requires no accounts, and includes no \
                tracking mechanisms.
                """)
                .font(.callout)
                .foregroundStyle(.secondary)
                .italic()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func sectionBlock(
        title: String,
        subtitle: String? = nil,
        content: String? = nil,
        bullets: [String]? = nil,
        footer: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            if let content = content {
                Text(content)
                    .font(.callout)
            }

            if let bullets = bullets {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\u{2022}")
                                .font(.callout)
                            Text(bullet)
                                .font(.callout)
                        }
                    }
                }
                .padding(.leading, 4)
            }

            if let footer = footer {
                Text(footer)
                    .font(.callout)
                    .fontWeight(.medium)
            }
        }
    }
}
