import Foundation
import os.log

struct BluetoothDevicesCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "BluetoothDevicesCollector")

    static func collect(devices: [DiscoveredPeripheral]) -> DeviceInfoSection {
        logger.debug("Collecting BLE device data for \(devices.count) devices")
        var items: [DeviceInfoItem] = []

        if devices.isEmpty {
            items.append(DeviceInfoItem(
                key: "No Bluetooth Devices",
                value: "Tap Scan to discover nearby BLE devices",
                notes: "Scanning requires Bluetooth permission and Bluetooth to be turned on."
            ))
        } else {
            for (index, device) in devices.enumerated() {
                let prefix = "BT Device \(index + 1)"

                items.append(DeviceInfoItem(
                    key: "\(prefix) — Name",
                    value: device.name,
                    notes: device.name == "Unknown"
                        ? "This device does not broadcast a local name."
                        : "The advertised local name of this BLE peripheral."
                ))

                items.append(DeviceInfoItem(
                    key: "\(prefix) — UUID",
                    value: device.uuid,
                    notes: "Core Bluetooth peripheral identifier. Unique per device-app pair, not the hardware MAC address."
                ))

                items.append(DeviceInfoItem(
                    key: "\(prefix) — RSSI",
                    value: "\(device.rssi) dBm (\(device.rssiQuality))",
                    notes: "Received Signal Strength Indicator. Closer to 0 means stronger signal."
                ))

                items.append(DeviceInfoItem(
                    key: "\(prefix) — Connectable",
                    value: device.isConnectable ? "Yes" : "No",
                    notes: "Whether this peripheral advertises as connectable."
                ))

                if let txPower = device.txPowerLevel {
                    items.append(DeviceInfoItem(
                        key: "\(prefix) — TX Power",
                        value: "\(txPower) dBm",
                        notes: "Transmit power level from advertisement data. Used with RSSI to estimate distance."
                    ))
                }

                if let mfgHex = device.manufacturerDataHex {
                    items.append(DeviceInfoItem(
                        key: "\(prefix) — Manufacturer Data",
                        value: mfgHex,
                        notes: "Raw manufacturer-specific data from the advertisement. The first 2 bytes typically identify the company."
                    ))
                }

                if let services = device.serviceUUIDs, !services.isEmpty {
                    let serviceList = services.map { $0.uuidString }.joined(separator: ", ")
                    items.append(DeviceInfoItem(
                        key: "\(prefix) — Service UUIDs",
                        value: serviceList,
                        notes: "GATT service UUIDs advertised by this peripheral."
                    ))
                }
            }
        }

        logger.debug("BLE collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Bluetooth Devices",
            icon: "wave.3.right",
            items: items,
            explanation: """
            Bluetooth Devices shows nearby Bluetooth Low Energy (BLE) peripherals discovered \
            during a scan. Each device displays its advertised name, a Core Bluetooth identifier \
            (not the hardware MAC address), signal strength (RSSI), connectability, and optional \
            advertisement data such as TX power, manufacturer data, and service UUIDs. Tap Scan \
            to start a 5-second discovery. Requires Bluetooth permission.
            """
        )
    }
}
