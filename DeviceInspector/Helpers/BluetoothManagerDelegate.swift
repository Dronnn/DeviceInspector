import CoreBluetooth
import os.log

final class BluetoothManagerDelegate: NSObject, CBCentralManagerDelegate, ObservableObject {
    @Published var authorizationStatus: CBManagerAuthorization = .notDetermined
    private var manager: CBCentralManager?
    private let logger = Logger(subsystem: "com.deviceinspector", category: "BluetoothManager")

    override init() {
        super.init()
        authorizationStatus = CBCentralManager.authorization
    }

    func requestAuthorization() {
        logger.debug("Requesting Bluetooth authorization")
        // Creating a CBCentralManager instance triggers the system BT permission dialog
        manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        authorizationStatus = CBCentralManager.authorization
        logger.debug("Bluetooth authorization updated: \(String(describing: self.authorizationStatus.rawValue))")
    }
}
