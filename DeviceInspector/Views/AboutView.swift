import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Spacer()
                        Image(systemName: "eye.trianglebadge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.top, 8)

                    Text("Why This App Exists")
                        .font(.largeTitle.bold())

                    Text("""
                    Pick up your phone and count the apps on your home screen. Every single one \
                    of them can learn more about you than you probably realize. Your device model, \
                    screen resolution, installed fonts, keyboard languages, thermal state, how much \
                    storage you have left, which accessibility features you use, whether your phone \
                    is jailbroken, what audio route is active, how many SIM cards are inserted — \
                    the list goes on. Hundreds of data points, most of them available without asking \
                    your permission even once.
                    """)
                    .font(.body)

                    Text("""
                    Individually, these signals look harmless. Together, they form a fingerprint \
                    that can identify your device — and by extension, you — with startling precision. \
                    Researchers have shown that combining just a handful of these attributes is often \
                    enough to single out one phone among millions. And unlike cookies, you cannot \
                    clear a hardware fingerprint. It follows your device everywhere.
                    """)
                    .font(.body)

                    Text("""
                    In some parts of the world, this is not an abstract concern. Governments push \
                    citizens toward state-controlled platforms and domestic services where this kind \
                    of silent data collection happens at industrial scale, with no transparency and \
                    no opt-out. But you do not need to live under an authoritarian regime to care. \
                    Any app on any phone in any country can read these signals right now, and most \
                    of them do.
                    """)
                    .font(.body)

                    Text("""
                    Device Inspector collects nothing. It sends nothing. Every piece of data you see \
                    stays on your device and disappears when you close the app. Its only purpose is \
                    to hold up a mirror — to show you, in plain text, exactly what any app could \
                    quietly learn about you behind a friendly interface. Once you see it laid out, \
                    you will think twice about which apps you trust and what permissions you grant. \
                    That awareness is the whole point.
                    """)
                    .font(.body)

                    Text("""
                    Device Inspector is fully open source. The entire codebase is publicly available \
                    on GitHub, so you do not have to take our word for any of the above — you can \
                    review every line yourself.
                    """)
                    .font(.body)

                    Link("View Source Code on GitHub",
                         destination: URL(string: "https://github.com/Dronnn/DeviceInspector")!)
                        .font(.body)

                    Divider()
                        .padding(.vertical, 4)

                    Text("All data stays on your device. No analytics. No tracking. No accounts.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
