# Device Inspector

An open-source, privacy-focused iOS app that shows users how much data any app can collect about their device — using only public APIs. The goal is transparency: helping people understand their digital fingerprint and make informed decisions about privacy.

No analytics, no tracking SDKs, no data leaves your device. Everything is collected and displayed locally. Data can be exported to JSON or copied to clipboard.

**Author:** Andreas Maier
**Source Code:** [github.com/Dronnn/DeviceInspector](https://github.com/Dronnn/DeviceInspector)

## Features

- Collects device information across 27 categories
- **Bluetooth device scanning** — discover nearby BLE peripherals with RSSI, advertisement data
- **Local network discovery** — find devices via Bonjour (AirPlay, HomeKit, printers, SSH, etc.)
- **"About This App" screen** — accessible via the info button (circle-i) in the toolbar; explains the app's purpose, data transparency philosophy, and links to the source code
- **About section in burger menu** — includes Privacy Policy link, Contact, Website, and version info
- Privacy mode (sensitive data masked everywhere: UI, JSON export, copy to clipboard, and detail sheets)
- Export to JSON via share sheet
- Copy all data to clipboard
- Pull-to-refresh
- Expandable sections with explanations
- Per-item context menu for copying
- Native `.searchable` search bar with real-time keyword filtering
- Permission management UI (Location, App Tracking Transparency, Bluetooth)

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
- Safe area insets (top/bottom/left/right)
- Device shape inference (notch/Dynamic Island/home button)

### 5. Storage
- Total disk space
- Free disk space
- Used disk space
- Volume capacity information

### 6. Network
- IP addresses by interface (en0, pdp_ip0, etc.) with subnet masks and flags
- MTU per network interface
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

### 12. Bluetooth Devices (Interactive Scan)
- Scan for nearby BLE peripherals (5-second scan)
- Device name, Core Bluetooth UUID, RSSI signal strength with quality label
- Advertisement data: connectable status, TX power level, manufacturer data (hex), service UUIDs
- Results shown in a dedicated detail sheet

### 13. Network Devices (Interactive Scan)
- Bonjour/mDNS service discovery across 12 service types
- AirPlay, HomeKit, printers (IPP), SSH, HTTP, SMB file sharing, Chromecast, Spotify Connect, Apple Companion, Sleep Proxy
- Service name, type, domain, endpoint
- Results shown in a dedicated detail sheet

### 14. GPU & AR
- Metal GPU name, buffer limits, threadgroup parameters
- GPU family support level
- ARKit configurations (world, face, body, image tracking)

### 15. Permission Statuses
- Read-only status for 13 permissions (Camera, Microphone, Photos, Contacts, Calendar, Reminders, Location, Motion, Speech, Notifications, Bluetooth, ATT, Siri)

### 16. Accessibility
- 21 UIAccessibility flags (VoiceOver, Switch Control, Reduce Motion, Bold Text, Grayscale, etc.)
- Hearing device pairing status

### 17. App & Bundle
- Bundle identifier, version, build number
- Simulator vs physical device detection
- File system paths (Documents, Caches, Temp)

### 18. Extended Network
- HTTP/HTTPS/SOCKS proxy settings
- Proxy auto-configuration (PAC URL, WPAD)
- VPN detection (utun/ipsec interfaces)
- NWPathMonitor (status, expensive, constrained, interface types)
- DNS support, IPv4/IPv6 support
- Available interfaces detail
- DNS servers (/etc/resolv.conf)
- Public IP (IPv4/IPv6 via ipify.org) — **user-initiated only**, not fetched automatically

### 19. Locale & Languages
- Currency code/symbol, decimal/grouping separators
- Metric system preference
- Preferred languages list
- Timezone DST status, calendar identifier
- Locale script, variant, collation identifier
- Individual keyboard enumeration (UITextInputMode)

### 20. System Settings
- 24-hour time format detection
- First day of week
- Temperature unit (Celsius/Fahrenheit)
- Active keyboard input modes

### 21. Clipboard (User-Initiated)
- Clipboard content type detection (text, images, URLs) — **user-initiated only**, not read automatically
- Item count (no actual content is read)

### 22. Environment Security
- TestFlight build detection
- Debug/Release build configuration
- Jailbreak indicator checks

### 23. WiFi Extras
- WiFi security type (WPA2/WPA3/Open/WEP)
- Signal strength (RSSI in dBm)

### 24. System Fonts
- Font family enumeration (all installed font families)
- Total font count across all families
- Per-family font listing (detail sheet)
- Classic fingerprinting vector (~5-8 bits of entropy)

### 25. WebView Fingerprint
- User-Agent string
- navigator.platform, navigator.vendor
- navigator.language, navigator.languages
- hardwareConcurrency (logical CPU cores)
- maxTouchPoints, cookieEnabled
- The #1 web tracking vector — reveals browser-level device identity

### 26. Speech Voices
- Total installed TTS voices
- Language count across all voices
- Premium voice ratio (premium vs. standard)
- Varies by device model and user downloads

### 27. Media Codecs
- Supported export presets (AVAssetExportSession)
- HEVC/H.265 hardware support
- ProRes codec support
- Reveals hardware generation and media capabilities

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

### Bluetooth

- **Purpose**: Required to scan for nearby BLE devices
- **iOS Requirements**:
  1. `NSBluetoothAlwaysUsageDescription` in Info.plist
  2. User grants Bluetooth permission
- **If denied**: Bluetooth scan button is disabled, authorization shows "Denied"

### Local Network

- **Purpose**: Required to discover devices and services on the local network via Bonjour
- **iOS Requirements**:
  1. `NSLocalNetworkUsageDescription` in Info.plist
  2. `NSBonjourServices` listing discovered service types
  3. User grants local network permission (system prompt on first scan)
- **If denied**: Network device discovery returns no results

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
<key>NSLocalNetworkUsageDescription</key>
<key>NSBonjourServices</key> <!-- 12 service types -->
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
- **Web**: WebKit (WKWebView navigator fingerprint)
- **Network**: Network (NWPathMonitor), NetworkExtension (NEHotspotNetwork), CFNetwork

## Architecture

- **Pattern**: MVVM
- **UI**: SwiftUI
- **Minimum**: iOS 17.0
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
│   ├── BluetoothDevicesCollector.swift # BLE device scan results
│   ├── NetworkDevicesCollector.swift  # Bonjour service discovery results
│   ├── GPUARCollector.swift          # Metal GPU, ARKit
│   ├── PermissionsCollector.swift    # All permission statuses
│   ├── AccessibilityCollector.swift  # UIAccessibility flags
│   ├── AppBundleCollector.swift      # Bundle info, paths
│   ├── ExtendedNetworkCollector.swift # Proxy, VPN, NWPathMonitor
│   ├── LocaleCollector.swift         # Locale, currency, DST
│   ├── ClipboardCollector.swift    # Clipboard metadata
│   ├── FontCollector.swift              # System font enumeration
│   ├── WebViewFingerprintCollector.swift # WebView/navigator fingerprint
│   └── EnvironmentSecurityCollector.swift # Build/security environment
├── ViewModels/
│   └── DeviceInspectorViewModel.swift # Main view model
├── Views/
│   ├── ContentView.swift              # Main screen
│   ├── SectionView.swift              # Expandable section
│   ├── ItemRowView.swift              # Single info item
│   ├── ItemDetailSheet.swift          # Item detail half-sheet
│   ├── DiscoveredDevicesSheet.swift   # BT/Network scan results sheet
│   ├── AboutView.swift                # About This App screen
│   ├── AvailabilityBadge.swift        # Status badge
│   ├── ExplanationSheet.swift         # Section explanation
│   ├── PermissionStatusView.swift     # Permission UI
│   ├── PrivacyPolicyView.swift        # In-app Privacy Policy
│   └── ActivityViewControllerRepresentable.swift  # Share sheet
└── Helpers/
    ├── LocationManagerDelegate.swift  # CLLocationManager wrapper
    ├── BluetoothManagerDelegate.swift # CBCentralManager wrapper + BLE scanning
    ├── NetworkDiscoveryManager.swift  # NWBrowser Bonjour service discovery
    ├── ByteFormatter.swift            # Byte formatting
    ├── ItemExplanations.swift         # Per-item explanation dictionary
    └── PermissionRequester.swift      # Permission request helpers
```

## Privacy

- All data is collected and displayed locally only
- **Sensitive data is not collected automatically** — Public IP (via ipify.org) and Clipboard contents require the user to explicitly tap a button to fetch
- Bonjour discovery is local network only (no internet requests)
- No analytics or tracking SDKs
- **Privacy Mode** masks sensitive data (device name, SSID, identifiers) everywhere: in the UI, JSON export, copy to clipboard, and detail sheets
- User must explicitly tap Refresh to collect data
- Console logging uses `os.log` with no personal data in debug logs
- **Privacy Policy** is accessible in-app (burger menu → About → Privacy Policy) and hosted online at [dronnn.github.io/DeviceInspector](https://dronnn.github.io/DeviceInspector/)
- [Privacy Policy (source)](docs/privacy-policy.md)

## Building

1. Open `DeviceInspector.xcodeproj` in Xcode 15+
2. Select your development team in Signing & Capabilities
3. Verify "Access WiFi Information" entitlement is enabled
4. Build and run on a physical device (some data only available on real hardware)

## Notes

- Simulator will show limited data (no battery, no carrier, no WiFi SSID)
- Some APIs (`CTCarrier`) are deprecated but still functional
- Model identifier mapping may not include the very latest devices -- update `DeviceModelMapping.swift` as needed

## License

This project is licensed under the [MIT License](LICENSE).
