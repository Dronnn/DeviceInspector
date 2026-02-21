import CoreBluetooth
import os.log

struct DiscoveredPeripheral: Identifiable {
    let id: String
    let name: String
    let uuid: String
    let rssi: Int
    let isConnectable: Bool
    let txPowerLevel: Int?
    let manufacturerData: Data?
    let serviceUUIDs: [CBUUID]?

    var rssiQuality: String {
        switch rssi {
        case -30...0: return "Excellent"
        case -50 ..< -30: return "Very Good"
        case -60 ..< -50: return "Good"
        case -70 ..< -60: return "Fair"
        case -80 ..< -70: return "Weak"
        default: return "Very Weak"
        }
    }

    var manufacturerDataHex: String? {
        guard let data = manufacturerData else { return nil }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}

final class BluetoothManagerDelegate: NSObject, CBCentralManagerDelegate, ObservableObject {
    @Published var authorizationStatus: CBManagerAuthorization = .notDetermined
    @Published var discoveredPeripherals: [DiscoveredPeripheral] = []
    @Published var isScanning = false
    private var manager: CBCentralManager?
    private let logger = Logger(subsystem: "com.deviceinspector", category: "BluetoothManager")
    private var scanRequestPending = false

    override init() {
        super.init()
        authorizationStatus = CBCentralManager.authorization
    }

    func requestAuthorization() {
        logger.debug("Requesting Bluetooth authorization")
        // Creating a CBCentralManager instance triggers the system BT permission dialog
        manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }

    func startScanning() {
        logger.debug("Scan requested")
        discoveredPeripherals = []
        isScanning = true

        if manager == nil {
            scanRequestPending = true
            manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        } else if manager?.state == .poweredOn {
            beginScan()
        } else {
            scanRequestPending = true
        }
    }

    func stopScanning() {
        logger.debug("Stopping scan, found \(self.discoveredPeripherals.count) devices")
        manager?.stopScan()
        isScanning = false
        scanRequestPending = false
    }

    private func beginScan() {
        logger.debug("Beginning BLE scan")
        manager?.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        authorizationStatus = CBCentralManager.authorization
        logger.debug("Bluetooth state updated: \(String(describing: central.state.rawValue))")

        if central.state == .poweredOn && scanRequestPending {
            scanRequestPending = false
            beginScan()
        } else if central.state != .poweredOn && isScanning {
            isScanning = false
            scanRequestPending = false
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let uuid = peripheral.identifier.uuidString

        // Skip duplicates (update RSSI if already discovered)
        if let index = discoveredPeripherals.firstIndex(where: { $0.uuid == uuid }) {
            let existing = discoveredPeripherals[index]
            discoveredPeripherals[index] = DiscoveredPeripheral(
                id: existing.id,
                name: peripheral.name ?? existing.name,
                uuid: uuid,
                rssi: RSSI.intValue,
                isConnectable: existing.isConnectable,
                txPowerLevel: existing.txPowerLevel,
                manufacturerData: existing.manufacturerData,
                serviceUUIDs: existing.serviceUUIDs
            )
            return
        }

        let isConnectable = (advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue ?? false
        let txPower = (advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber)?.intValue
        let mfgData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]

        let device = DiscoveredPeripheral(
            id: uuid,
            name: peripheral.name ?? "Unknown",
            uuid: uuid,
            rssi: RSSI.intValue,
            isConnectable: isConnectable,
            txPowerLevel: txPower,
            manufacturerData: mfgData,
            serviceUUIDs: serviceUUIDs
        )

        discoveredPeripherals.append(device)
        logger.debug("Discovered: \(device.name) RSSI=\(RSSI.intValue)")
    }
}
