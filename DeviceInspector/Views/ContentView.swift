import SwiftUI
import CoreLocation
import AppTrackingTransparency
import CoreBluetooth

struct ContentView: View {
    @StateObject private var viewModel = DeviceInspectorViewModel()
    @StateObject private var locationManager = LocationManagerDelegate()
    @StateObject private var bluetoothManager = BluetoothManagerDelegate()
    @State private var jsonExportURL: URL?
    @State private var collapseAllSignal = 0
    @State private var expandAllSignal = 0
    @State private var expandSectionID: String?
    @State private var allExpanded = true
    @State private var showSectionMenu = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    List {
                        // MARK: - Header Section
                        Section {
                            HStack {
                                Image(systemName: "cpu")
                                    .font(.title2)
                                    .foregroundStyle(Color.accentColor)
                                Text("Device Inspector")
                                    .font(.title2.bold())
                                Spacer()
                            }

                            Toggle("Privacy Mode", isOn: $viewModel.privacyMode)
                                .tint(.orange)

                            PermissionStatusView(
                                locationStatus: viewModel.locationStatus,
                                attStatus: viewModel.attStatus,
                                bluetoothStatus: bluetoothManager.authorizationStatus,
                                onRequestLocation: {
                                    locationManager.requestWhenInUseAuthorization()
                                },
                                onRequestATT: {
                                    await viewModel.requestATTPermission()
                                },
                                onRequestBluetooth: {
                                    bluetoothManager.requestAuthorization()
                                }
                            )
                        }

                        // MARK: - Device Info Sections
                        ForEach(viewModel.sections) { section in
                            SectionView(
                                section: section,
                                privacyMode: viewModel.privacyMode,
                                collapseAllSignal: collapseAllSignal,
                                expandAllSignal: expandAllSignal,
                                expandSectionID: expandSectionID
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Device Inspector")
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            Button {
                                if allExpanded {
                                    collapseAllSignal += 1
                                } else {
                                    expandAllSignal += 1
                                }
                                allExpanded.toggle()
                            } label: {
                                Image(systemName: allExpanded
                                    ? "arrow.down.right.and.arrow.up.left"
                                    : "arrow.up.left.and.arrow.down.right")
                            }

                            Button {
                                showSectionMenu = true
                            } label: {
                                Image(systemName: "line.3.horizontal")
                            }
                        }

                        ToolbarItemGroup(placement: .bottomBar) {
                            Button {
                                Task {
                                    await viewModel.refresh()
                                }
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }

                            Spacer()

                            Button {
                                viewModel.copyAllToClipboard()
                            } label: {
                                Label("Copy All", systemImage: "doc.on.doc")
                            }

                            Spacer()

                            Button {
                                if let data = viewModel.exportJSON() {
                                    let url = FileManager.default.temporaryDirectory
                                        .appendingPathComponent("DeviceInspector.json")
                                    try? data.write(to: url)
                                    jsonExportURL = url
                                }
                            } label: {
                                Label("Export JSON", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                    .task {
                        viewModel.locationStatus = locationManager.authorizationStatus
                        await viewModel.refresh()
                    }
                    .onChange(of: locationManager.authorizationStatus) { newStatus in
                        viewModel.locationStatus = newStatus
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .onChange(of: bluetoothManager.authorizationStatus) { _ in
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: PermissionRequester.permissionDidChange)) { _ in
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .sheet(isPresented: Binding(
                        get: { jsonExportURL != nil },
                        set: { if !$0 { jsonExportURL = nil } }
                    )) {
                        ActivityViewControllerRepresentable(
                            activityItems: [jsonExportURL!]
                        )
                        .presentationDetents([.medium, .large])
                    }
                    .sheet(isPresented: $showSectionMenu) {
                        NavigationStack {
                            List {
                                ForEach(viewModel.sections) { section in
                                    Button {
                                        let targetID = section.id
                                        showSectionMenu = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            expandSectionID = targetID
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation {
                                                    proxy.scrollTo(targetID, anchor: .top)
                                                }
                                            }
                                        }
                                    } label: {
                                        Label(section.title, systemImage: section.icon)
                                    }
                                }
                            }
                            .navigationTitle("Sections")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Done") {
                                        showSectionMenu = false
                                    }
                                }
                            }
                        }
                        .presentationDetents([.medium, .large])
                    }
                }

                // MARK: - Loading Overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                    ProgressView("Collecting device info...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
