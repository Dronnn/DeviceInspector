import SwiftUI
import CoreLocation
import AppTrackingTransparency
import CoreBluetooth

struct ContentView: View {
    @StateObject private var viewModel = DeviceInspectorViewModel()
    @StateObject private var locationManager = LocationManagerDelegate()
    @StateObject private var bluetoothManager = BluetoothManagerDelegate()
    @StateObject private var networkDiscoveryManager = NetworkDiscoveryManager()
    @State private var jsonExportURL: URL?
    @State private var collapseAllSignal = 0
    @State private var expandAllSignal = 0
    @State private var expandSectionID: String?
    @State private var allExpanded = true
    @State private var showSectionMenu = false
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var showAbout = false
    @Environment(\.scenePhase) private var scenePhase

    private var locationStatusText: String {
        switch viewModel.locationStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When In Use"
        @unknown default: return "Unknown"
        }
    }

    private var locationStatusColor: Color {
        switch viewModel.locationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        @unknown default: return .secondary
        }
    }

    private var trackingStatusText: String {
        switch viewModel.attStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        @unknown default: return "Unknown"
        }
    }

    private var trackingStatusColor: Color {
        switch viewModel.attStatus {
        case .authorized: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        @unknown default: return .secondary
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        Section {
            Toggle("Privacy Mode", isOn: $viewModel.privacyMode)
                .tint(.orange)
        }
    }

    private var filteredSections: [DeviceInfoSection] {
        guard !searchText.isEmpty else {
            return viewModel.sections
        }
        let query = searchText.lowercased()
        return viewModel.sections.compactMap { section in
            let matchingItems = section.items.filter { item in
                item.key.lowercased().contains(query) ||
                item.value.lowercased().contains(query)
            }
            guard !matchingItems.isEmpty else { return nil }
            var filtered = section
            filtered.items = matchingItems
            return filtered
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    List {
                        headerSection

                        // MARK: - Device Info Sections
                        ForEach(filteredSections) { section in
                            if section.title == "Public IP" {
                                PublicIPSectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID,
                                    isFetching: viewModel.isFetchingPublicIP,
                                    hasFetched: viewModel.publicIPAddress != nil,
                                    onFetch: { viewModel.fetchPublicIP() }
                                )
                            } else if section.title == "Clipboard" {
                                ClipboardSectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID,
                                    isFetching: viewModel.isFetchingClipboard,
                                    hasFetched: viewModel.clipboardFetched,
                                    onFetch: { viewModel.fetchClipboard() }
                                )
                            } else if section.title == "Bluetooth Devices" {
                                ScanSectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID,
                                    isScanning: viewModel.isScanningBluetooth,
                                    onScan: { viewModel.scanBluetoothDevices() },
                                    detailItems: viewModel.bluetoothDetailItems,
                                    detailTitle: "Bluetooth Devices",
                                    deviceCount: viewModel.bluetoothDeviceCount,
                                    permissionStatus: bluetoothManager.authorizationStatus,
                                    onRequestPermission: { bluetoothManager.requestAuthorization() }
                                )
                            } else if section.title == "Network Devices" {
                                ScanSectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID,
                                    isScanning: viewModel.isScanningNetwork,
                                    onScan: { viewModel.scanNetworkDevices() },
                                    detailItems: viewModel.networkDetailItems,
                                    detailTitle: "Network Devices",
                                    deviceCount: viewModel.networkServiceCount
                                )
                            } else if section.title == "Location" {
                                PermissionSectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID,
                                    permissionIcon: "location",
                                    permissionLabel: "Location",
                                    permissionStatusText: locationStatusText,
                                    permissionStatusColor: locationStatusColor,
                                    isRequestable: viewModel.locationStatus == .notDetermined,
                                    isDenied: viewModel.locationStatus == .denied || viewModel.locationStatus == .restricted,
                                    onRequestPermission: { locationManager.requestWhenInUseAuthorization() }
                                )
                            } else if section.title == "Tracking" {
                                PermissionSectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID,
                                    permissionIcon: "hand.raised",
                                    permissionLabel: "Tracking",
                                    permissionStatusText: trackingStatusText,
                                    permissionStatusColor: trackingStatusColor,
                                    isRequestable: viewModel.attStatus == .notDetermined,
                                    isDenied: viewModel.attStatus == .denied || viewModel.attStatus == .restricted,
                                    onRequestPermission: { Task { await viewModel.requestATTPermission() } }
                                )
                            } else if section.title == "System Fonts" {
                                DetailListSectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID,
                                    detailItems: viewModel.fontDetailItems,
                                    detailTitle: "System Fonts",
                                    detailCount: viewModel.fontCount,
                                    detailCountLabel: "fonts"
                                )
                            } else if section.title == "Speech Voices" {
                                DetailListSectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID,
                                    detailItems: viewModel.speechVoiceDetailItems,
                                    detailTitle: "Speech Voices",
                                    detailCount: viewModel.speechVoiceCount,
                                    detailCountLabel: "voices"
                                )
                            } else {
                                SectionView(
                                    section: section,
                                    privacyMode: viewModel.privacyMode,
                                    collapseAllSignal: collapseAllSignal,
                                    expandAllSignal: expandAllSignal,
                                    expandSectionID: expandSectionID
                                )
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("Device Inspector")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                showAbout = true
                            } label: {
                                Image(systemName: "info.circle")
                            }
                        }

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
                                isSearching = true
                            } label: {
                                Label("Search", systemImage: "magnifyingglass")
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
                    .searchable(text: $searchText, isPresented: $isSearching)
                    .refreshable {
                        await viewModel.refresh()
                    }
                    .task {
                        viewModel.locationStatus = locationManager.authorizationStatus
                        viewModel.attStatus = ATTrackingManager.trackingAuthorizationStatus
                        viewModel.accuracyAuthorization = locationManager.accuracyAuthorization
                        viewModel.currentLocation = locationManager.currentLocation
                        viewModel.bluetoothManager = bluetoothManager
                        viewModel.networkDiscoveryManager = networkDiscoveryManager
                        await viewModel.refresh()
                    }
                    .onChange(of: locationManager.authorizationStatus) { _, newStatus in
                        viewModel.locationStatus = newStatus
                        viewModel.accuracyAuthorization = locationManager.accuracyAuthorization
                        viewModel.currentLocation = locationManager.currentLocation
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .onChange(of: bluetoothManager.authorizationStatus) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .onChange(of: viewModel.attStatus) {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            viewModel.attStatus = ATTrackingManager.trackingAuthorizationStatus
                            viewModel.locationStatus = locationManager.authorizationStatus
                            viewModel.accuracyAuthorization = locationManager.accuracyAuthorization
                            viewModel.currentLocation = locationManager.currentLocation
                            Task {
                                await viewModel.refresh()
                            }
                        }
                    }
                    .onReceive(locationManager.$currentLocation) { newLocation in
                        guard newLocation != nil else { return }
                        viewModel.currentLocation = newLocation
                        viewModel.accuracyAuthorization = locationManager.accuracyAuthorization
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
                                Section("Sections") {
                                    ForEach(filteredSections) { section in
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

                                Section {
                                    NavigationLink {
                                        PrivacyPolicyView()
                                    } label: {
                                        Label("Privacy Policy", systemImage: "hand.raised")
                                    }

                                    Link(destination: URL(string: "mailto:app@andreasmaier.dev")!) {
                                        Label("Contact", systemImage: "envelope")
                                    }

                                    Link(destination: URL(string: "https://andreasmaier.dev")!) {
                                        Label("Website", systemImage: "globe")
                                    }
                                } header: {
                                    Text("About")
                                } footer: {
                                    Text("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0") (\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1")) \u{00B7} \u{00A9} 2025 Andreas Maier")
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 8)
                                }
                            }
                            .navigationTitle("Menu")
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
                    .sheet(isPresented: $showAbout) {
                        AboutView()
                            .presentationDetents([.large])
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
