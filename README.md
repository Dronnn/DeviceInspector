# Device Inspector

A privacy-focused iOS app that collects and displays all publicly available device information. No network requests, no analytics, no tracking. Data is shown locally and can be exported to JSON or copied to clipboard.

**Author:** Andreas Maier

## Features

- Collects device information across 21 categories
- Privacy mode (sensitive data hidden by default)
- Export to JSON via share sheet
- Copy all data to clipboard
- Pull-to-refresh
- Expandable sections with explanations
- Per-item context menu for copying
- Search and filter items by keyword in real time
- Permission management UI (Location, App Tracking Transparency)

## Categories

### 1. Process Info
- Process name, PID, uptime
- OS version, processors, active processors
- Physical memory, thermal state
- System uptime, low-power mode
- Available memory, app memory usage (Mach task_info)

### 2. Device Info
- Device name, model, localized model
- System name, system version
- Identifier for Vendor (IDFV)
- Battery level, battery state
- Device orientation

### 3. Hardware
- Machine identifier (e.g. `iPhone15,2`)
- Mapped model name (e.g. "iPhone 14 Pro")
- Total RAM
- OS build number
- CPU architecture, core count

### 4. Display
- Screen bounds, native bounds, scale, native scale
- Screen brightness
- Dynamic Type content size category
- Display gamut (P3/sRGB), EDR headroom
- Max refresh rate (ProMotion)
- Interface style (Dark/Light mode)
- Display Zoom detection

### 5. Storage
- Total disk space
- Free disk space
- Used disk space
- Volume capacity information

### 6. Network
- IP addresses by interface (en0, pdp_ip0, etc.) with subnet masks and flags
- WiFi SSID, BSSID (requires Location permission)
- WiFi security type, signal strength (RSSI)
- Carrier name, mobile country code, mobile network code
- Radio access technology (LTE, 5G, etc.)

### 7. Identifiers
- Identifier for Vendor (IDFV)
- Advertising Identifier (IDFA, requires ATT permission)
- Globally unique string (UUID)

### 8. Biometrics & Security
- Biometry type (Face ID / Touch ID / none)
- Biometrics enrollment status
- Screen capture/mirroring detection

### 9. Sensors & Motion
- Accelerometer, gyroscope, magnetometer availability
- Device motion, barometer availability
- Pedometer features (steps, distance, floors, pace, cadence)
- Motion activity recognition

### 10. Camera & Audio
- All camera devices (type, position, flash, torch)
- Audio session (sample rate, latency, routes, channels)
- Output volume, silent mode detection (heuristic)
- Haptic engine capabilities

### 11. Wireless Technologies
- NFC reading availability
- Bluetooth authorization status
- Ultra Wideband (UWB/U1 chip) support

### 12. GPU & AR
- Metal GPU name, buffer limits, threadgroup parameters
- GPU family support level
- ARKit configurations (world, face, body, image tracking)

### 13. Permission Statuses
- Read-only status for 13 permissions (Camera, Microphone, Photos, Contacts, Calendar, Reminders, Location, Motion, Speech, Notifications, Bluetooth, ATT, Siri)

### 14. Accessibility
- 21 UIAccessibility flags (VoiceOver, Switch Control, Reduce Motion, Bold Text, Grayscale, etc.)
- Hearing device pairing status

### 15. App & Bundle
- Bundle identifier, version, build number
- Simulator vs physical device detection
- File system paths (Documents, Caches, Temp)

### 16. Extended Network
- HTTP/HTTPS/SOCKS proxy settings
- Proxy auto-configuration (PAC URL, WPAD)
- VPN detection (utun/ipsec interfaces)
- NWPathMonitor (status, expensive, constrained, interface types)
- DNS support, IPv4/IPv6 support
- Available interfaces detail
- DNS servers (/etc/resolv.conf)
- Public IP (IPv4/IPv6 via ipify.org)

### 17. Locale & Languages
- Currency code/symbol, decimal/grouping separators
- Metric system preference
- Preferred languages list
- Timezone DST status, calendar identifier

### 18. System Settings
- 24-hour time format detection
- First day of week
- Temperature unit (Celsius/Fahrenheit)
- Active keyboard input modes

### 19. Clipboard
- Clipboard content type detection (text, images, URLs)
- Item count (no actual content is read)

### 20. Environment Security
- TestFlight build detection
- Debug/Release build configuration
- Jailbreak indicator checks

### 21. WiFi Extras
- WiFi security type (WPA2/WPA3/Open/WEP)
- Signal strength (RSSI in dBm)

## iOS Limitations & What's NOT Available

iOS enforces strict privacy boundaries. The following data **cannot** be accessed by any app using public APIs:

| Data | Reason |
|------|--------|
| **IMEI** | Not available via public API since iOS 7 |
| **Serial number** | Not available via public API since iOS 7 |
| **MAC address** | Returns fixed `02:00:00:00:00:00` since iOS 7 |
| **UDID** | Not available to apps |
| **Phone number** | Not available to apps |
| **SIM card number (ICCID)** | Not available via public API |
| **Cellular signal strength (dBm)** | Not available via public API (WiFi RSSI is available) |
| **Neighboring WiFi networks** | Only the currently connected network is accessible |
| **Installed apps list** | Not available since iOS 9 |
| **Hardware serial number** | Not available via public API |
| **Baseband version** | Not available via public API |

## Required Permissions

### Location (When In Use)

- **Purpose**: Required to read WiFi SSID and BSSID via `CNCopyCurrentNetworkInfo`
- **iOS Requirements**:
  1. "Access WiFi Information" entitlement in the app
  2. Location permission (When In Use) granted by user
  3. `NSLocationWhenInUseUsageDescription` in Info.plist
- **If denied**: WiFi SSID/BSSID show "Not available"
- **No location data is collected** -- the permission is only used for the WiFi info API

### App Tracking Transparency

- **Purpose**: Required to read the Advertising Identifier (IDFA)
- **iOS Requirements**:
  1. `NSUserTrackingUsageDescription` in Info.plist
  2. User grants permission via `ATTrackingManager`
- **If denied**: IDFA shows "Not authorized"

## Info.plist Keys

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<key>NSUserTrackingUsageDescription</key>
<key>NSBluetoothAlwaysUsageDescription</key>
<key>NSBluetoothPeripheralUsageDescription</key>
<key>NSSpeechRecognitionUsageDescription</key>
<key>NSContactsUsageDescription</key>
<key>NSCalendarsUsageDescription</key>
<key>NSRemindersUsageDescription</key>
<key>NSMicrophoneUsageDescription</key>
<key>NSPhotoLibraryUsageDescription</key>
<key>NSCameraUsageDescription</key>
<key>NFCReaderUsageDescription</key>
<key>NSSiriUsageDescription</key>
```

## Entitlements

- `com.apple.developer.networking.wifi-info` -- Access WiFi Information

## Frameworks Used

- **Always available**: Foundation, UIKit, SwiftUI
- **Device/System**: CoreLocation, CoreTelephony, SystemConfiguration, Darwin
- **Privacy**: AppTrackingTransparency, AdSupport
- **Sensors**: CoreMotion
- **Media**: AVFoundation, CoreHaptics
- **Wireless**: CoreNFC, CoreBluetooth, NearbyInteraction
- **Graphics/AR**: Metal, ARKit
- **Permissions**: Photos, Contacts, EventKit, Speech, UserNotifications, Intents
- **Network**: Network (NWPathMonitor), NetworkExtension (NEHotspotNetwork), CFNetwork

## Architecture

- **Pattern**: MVVM
- **UI**: SwiftUI
- **Minimum**: iOS 16.0
- **Language**: Swift 5.9+
- **Async**: async/await (no GCD)

### Project Structure

```
DeviceInspector/
├── DeviceInspectorApp.swift          # App entry point
├── Info.plist                         # App configuration
├── DeviceInspector.entitlements       # WiFi info entitlement
├── Assets.xcassets/                   # App icon, accent color
├── Models/
│   ├── DeviceInfoModels.swift         # Core data models
│   └── DeviceModelMapping.swift       # Machine ID → name mapping
├── Collectors/
│   ├── ProcessInfoCollector.swift     # ProcessInfo data
│   ├── UIDeviceCollector.swift        # UIDevice data
│   ├── HardwareCollector.swift        # sysctl hardware info
│   ├── DisplayCollector.swift         # Screen, gamut, refresh rate
│   ├── StorageCollector.swift         # Disk space
│   ├── NetworkCollector.swift         # IP, WiFi, carrier
│   ├── IdentifiersCollector.swift     # IDFV, IDFA
│   ├── BiometricsCollector.swift     # Face ID/Touch ID, screen capture
│   ├── SensorsCollector.swift        # CoreMotion sensors
│   ├── CameraAudioCollector.swift    # Cameras, audio session, haptics
│   ├── WirelessCollector.swift       # NFC, Bluetooth, UWB
│   ├── GPUARCollector.swift          # Metal GPU, ARKit
│   ├── PermissionsCollector.swift    # All permission statuses
│   ├── AccessibilityCollector.swift  # UIAccessibility flags
│   ├── AppBundleCollector.swift      # Bundle info, paths
│   ├── ExtendedNetworkCollector.swift # Proxy, VPN, NWPathMonitor
│   ├── LocaleCollector.swift         # Locale, currency, DST
│   ├── ClipboardCollector.swift    # Clipboard metadata
│   └── EnvironmentSecurityCollector.swift # Build/security environment
├── ViewModels/
│   └── DeviceInspectorViewModel.swift # Main view model
├── Views/
│   ├── ContentView.swift              # Main screen
│   ├── SectionView.swift              # Expandable section
│   ├── ItemRowView.swift              # Single info item
│   ├── ItemDetailSheet.swift          # Item detail half-sheet
│   ├── AvailabilityBadge.swift        # Status badge
│   ├── ExplanationSheet.swift         # Section explanation
│   ├── PermissionStatusView.swift     # Permission UI
│   └── ActivityViewControllerRepresentable.swift  # Share sheet
└── Helpers/
    ├── LocationManagerDelegate.swift  # CLLocationManager wrapper
    ├── BluetoothManagerDelegate.swift # CBCentralManager wrapper
    ├── ByteFormatter.swift            # Byte formatting
    ├── ItemExplanations.swift         # Per-item explanation dictionary
    └── PermissionRequester.swift      # Permission request helpers
```

## Privacy

- All data is collected and displayed locally only
- No network requests are made
- No analytics or tracking SDKs
- Sensitive data (device name, SSID, identifiers) hidden by default in Privacy Mode
- User must explicitly tap Refresh to collect data
- Console logging uses `os.log` with no personal data in debug logs

## Building

1. Open `DeviceInspector.xcodeproj` in Xcode 15+
2. Select your development team in Signing & Capabilities
3. Verify "Access WiFi Information" entitlement is enabled
4. Build and run on a physical device (some data only available on real hardware)

## Notes

- Simulator will show limited data (no battery, no carrier, no WiFi SSID)
- Some APIs (`CTCarrier`) are deprecated in iOS 16+ but still functional
- Model identifier mapping may not include the very latest devices -- update `DeviceModelMapping.swift` as needed

## License

This project is licensed under the [MIT License](LICENSE).
