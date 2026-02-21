import Foundation

enum DeviceModelMapping {
    static let modelMap: [String: String] = [
        // MARK: - iPhone 16 Series
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",

        // MARK: - iPhone 15 Series
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",

        // MARK: - iPhone 14 Series
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",

        // MARK: - iPhone 13 Series
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",

        // MARK: - iPhone 12 Series
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",

        // MARK: - iPhone SE
        "iPhone14,6": "iPhone SE (3rd generation)",
        "iPhone12,8": "iPhone SE (2nd generation)",

        // MARK: - iPad Pro (M4) 2024
        "iPad16,3": "iPad Pro 11-inch (M4)",
        "iPad16,4": "iPad Pro 11-inch (M4)",
        "iPad16,5": "iPad Pro 13-inch (M4)",
        "iPad16,6": "iPad Pro 13-inch (M4)",

        // MARK: - iPad Pro (M2) 2022
        "iPad14,3": "iPad Pro 11-inch (4th generation)",
        "iPad14,4": "iPad Pro 11-inch (4th generation)",
        "iPad14,5": "iPad Pro 12.9-inch (6th generation)",
        "iPad14,6": "iPad Pro 12.9-inch (6th generation)",

        // MARK: - iPad Pro (M1) 2021
        "iPad13,4": "iPad Pro 11-inch (3rd generation)",
        "iPad13,5": "iPad Pro 11-inch (3rd generation)",
        "iPad13,6": "iPad Pro 11-inch (3rd generation)",
        "iPad13,7": "iPad Pro 11-inch (3rd generation)",
        "iPad13,8": "iPad Pro 12.9-inch (5th generation)",
        "iPad13,9": "iPad Pro 12.9-inch (5th generation)",
        "iPad13,10": "iPad Pro 12.9-inch (5th generation)",
        "iPad13,11": "iPad Pro 12.9-inch (5th generation)",

        // MARK: - iPad Air (M3) 2025
        "iPad16,7": "iPad Air 11-inch (M3)",
        "iPad16,8": "iPad Air 11-inch (M3)",
        "iPad16,9": "iPad Air 13-inch (M3)",
        "iPad16,10": "iPad Air 13-inch (M3)",

        // MARK: - iPad Air (M2) 2024
        "iPad14,8": "iPad Air 11-inch (M2)",
        "iPad14,9": "iPad Air 11-inch (M2)",
        "iPad14,10": "iPad Air 13-inch (M2)",
        "iPad14,11": "iPad Air 13-inch (M2)",

        // MARK: - iPad Air (5th generation) 2022
        "iPad13,16": "iPad Air (5th generation)",
        "iPad13,17": "iPad Air (5th generation)",

        // MARK: - iPad mini
        "iPad14,1": "iPad mini (6th generation)",
        "iPad14,2": "iPad mini (6th generation)",
        "iPad16,1": "iPad mini (A17 Pro)",
        "iPad16,2": "iPad mini (A17 Pro)",

        // MARK: - iPad (standard)
        "iPad14,12": "iPad (A16)",
        "iPad13,18": "iPad (10th generation)",
        "iPad13,19": "iPad (10th generation)",
        "iPad12,1": "iPad (9th generation)",
        "iPad12,2": "iPad (9th generation)",

        // MARK: - iPod touch
        "iPod9,1": "iPod touch (7th generation)",

        // MARK: - Simulator
        "i386": "Simulator (32-bit)",
        "x86_64": "Simulator (x86_64)",
        "arm64": "Simulator (arm64)",
    ]

    static func humanReadableName(for machineIdentifier: String) -> String {
        return modelMap[machineIdentifier] ?? "Unknown (\(machineIdentifier))"
    }
}
