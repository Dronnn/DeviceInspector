import Foundation

struct ItemExplanations {

    // MARK: - Public API

    static func explanation(for key: String) -> String? {
        if let exact = explanations[key] {
            return exact
        }
        return patternMatch(for: key)
    }

    // MARK: - Pattern Matching for Dynamic Keys

    private static func patternMatch(for key: String) -> String? {
        // Camera dynamic keys (e.g. "Camera 1 — Name", "Camera 2 — Type")
        if key.contains("Camera") {
            if key.hasSuffix("— Name") {
                return "The system name of this camera module (e.g. \"Back Wide Camera\", \"Front TrueDepth Camera\")."
            }
            if key.hasSuffix("— Type") {
                return "The type of camera lens — wide angle, ultra wide, telephoto, or TrueDepth (for Face ID and selfies)."
            }
            if key.hasSuffix("— Position") {
                return "Whether this camera is on the front or back of the device."
            }
            if key.hasSuffix("— Flash") {
                return "Whether this camera has a flash or LED light available for photos."
            }
            if key.hasSuffix("— Torch") {
                return "Whether this camera can use its flash as a continuous flashlight (torch mode)."
            }
        }

        // DNS Server dynamic keys (e.g. "DNS Server 1", "DNS Server 2")
        if key.hasPrefix("DNS Server") {
            return "A DNS server configured on this device for resolving domain names to IP addresses."
        }

        // Network interface dynamic keys (e.g. "Interface: en0 (WiFi)")
        if key.hasPrefix("Interface:") {
            return "A network interface available on the current network path, showing its type and configuration details."
        }

        // Audio port dynamic keys
        if key.hasPrefix("Audio Input —") {
            return "An audio input source (microphone). The port name indicates which microphone is in use."
        }
        if key.hasPrefix("Audio Output —") {
            return "An audio output destination (speaker or headphones). The port name shows the current output device."
        }

        // Network interface dynamic keys (e.g. "en0 (WiFi) IPv4", "pdp_ip0 (Cellular) IPv6")
        if key.contains("WiFi") && (key.contains("IPv4") || key.contains("IPv6")) {
            return "The IP address assigned to the WiFi network interface. This address identifies the device on the local WiFi network."
        }
        if key.contains("Cellular") && (key.contains("IPv4") || key.contains("IPv6")) {
            return "The IP address assigned to the cellular data interface. This address is provided by the mobile carrier."
        }
        if key.contains("Loopback") {
            return "The loopback address — a virtual network interface used for internal communication within the device itself. It is not visible to other devices."
        }
        if key.contains("VPN Tunnel") {
            return "The IP address assigned to the VPN tunnel interface. This address is used when communicating through the encrypted VPN connection."
        }
        if key.contains("Apple Wireless Direct Link") {
            return "The IP address on the Apple Wireless Direct Link (AWDL) interface. AWDL is used for AirDrop, AirPlay, and other device-to-device Apple features."
        }
        if key.contains("IPv4") {
            return "An IPv4 address on this network interface. IPv4 is the traditional internet addressing format (e.g. 192.168.1.1)."
        }
        if key.contains("IPv6") {
            return "An IPv6 address on this network interface. IPv6 is the newer internet addressing format with longer addresses, designed to replace IPv4."
        }

        // Generic network interface fallback
        if key.contains("(") && (key.contains("Other") || key.contains("Link")) {
            return "An IP address on a network interface. Network interfaces are the device's connections to different networks."
        }

        // Clipboard dynamic keys
        if key == "Has Text" || key == "Has Images" || key == "Has URLs" {
            return "Whether the system clipboard currently contains this type of content. Checked via UIPasteboard.general."
        }

        return nil
    }

    // MARK: - Static Dictionary

    private static let explanations: [String: String] = [

        // MARK: ProcessInfoCollector

        "Process Name":
            "The name of the running app process. On iOS, this is typically the app's executable name.",
        "Process Identifier (PID)":
            "A unique number assigned by the operating system to this running app. Each time the app launches, it gets a new PID.",
        "System Uptime":
            "How long the device has been running since its last restart. A longer uptime means the device hasn't been rebooted recently.",
        "OS Version String":
            "The full version string of the operating system, including build metadata.",
        "OS Version (Parsed)":
            "The iOS version broken down into major.minor.patch components.",
        "Is At Least iOS 16":
            "Whether the device is running iOS 16 or later. Useful for checking feature compatibility.",
        "Is At Least iOS 17":
            "Whether the device is running iOS 17 or later. Useful for checking feature compatibility.",
        "Is At Least iOS 18":
            "Whether the device is running iOS 18 or later. Useful for checking feature compatibility.",
        "Processor Count":
            "The total number of CPU cores on the device's processor.",
        "Active Processor Count":
            "How many CPU cores are currently active. The system may disable some cores to save power.",
        "Physical Memory":
            "The total amount of RAM (working memory) in the device. More RAM allows more apps to stay in memory simultaneously.",
        "Low Power Mode":
            "Whether the user has enabled Low Power Mode, which reduces background activity and visual effects to extend battery life.",
        "Thermal State":
            "The device's current thermal condition. If overheating, the system may throttle CPU performance to cool down.",
        "Environment Variables":
            "System environment variables available to the app process. These contain internal configuration values.",
        "Launch Arguments":
            "Command-line arguments passed when the app was launched. Normally empty in production builds.",
        "Host Name":
            "The local network hostname assigned to this device.",
        "Globally Unique String":
            "A randomly generated unique identifier. Changes every time it is requested — never the same twice.",

        // MARK: UIDeviceCollector

        "Device Name":
            "The name the user has given their device (e.g. \"John's iPhone\"). Set in Settings > General > About > Name.",
        "Model":
            "The general device model type (e.g. \"iPhone\", \"iPad\").",
        "Localized Model":
            "The device model name translated into the user's current language.",
        "System Name":
            "The name of the operating system (e.g. \"iOS\", \"iPadOS\").",
        "System Version":
            "The iOS or iPadOS version number (e.g. \"17.4.1\").",
        "Identifier For Vendor (IDFV)":
            "A unique ID that identifies this device to apps from the same developer. It stays the same across all apps by the same company but resets if all their apps are deleted.",
        "Battery Level":
            "The current battery charge as a percentage from 0% to 100%.",
        "Battery State":
            "Whether the battery is charging, fully charged, unplugged, or unknown.",
        "Orientation":
            "The physical orientation of the device — portrait, landscape left or right, face up or down, etc.",
        "Multitasking Supported":
            "Whether the device supports running multiple apps simultaneously.",
        "User Interface Idiom":
            "The type of user interface the device uses — phone (compact screen), pad (large screen), TV, etc.",

        // MARK: HardwareCollector

        "Machine Identifier":
            "The internal hardware identifier (e.g. \"iPhone15,2\"). Apple uses these codes to distinguish exact hardware revisions.",
        "Device Model (Mapped)":
            "The marketing name of the device (e.g. \"iPhone 14 Pro\") mapped from the machine identifier.",
        "Hardware Model (hw.model)":
            "The low-level hardware board identifier used internally by the system.",
        "Total RAM (hw.memsize)":
            "Total physical RAM reported by the kernel, in bytes. This is the raw memory available for all running processes.",
        "OS Build Number (kern.osversion)":
            "The specific build number of the OS (e.g. \"21E236\"). Different builds of the same iOS version may contain different patches.",
        "OS Type (kern.ostype)":
            "The kernel type — always \"Darwin\" on Apple devices. Darwin is the open-source kernel that powers iOS and macOS.",
        "Kernel Hostname":
            "The hostname as reported by the kernel.",
        "CPU Count (hw.ncpu)":
            "Total number of CPU cores as reported by the kernel.",
        "Physical CPU Count":
            "The number of physical CPU cores in the chip (excludes hyper-threading virtual cores, if any).",
        "Logical CPU Count":
            "The number of logical CPU cores, which may be higher than physical if hyper-threading is supported.",
        "CPU Type":
            "A numeric code identifying the CPU architecture (e.g. ARM64).",
        "CPU Subtype":
            "A numeric code identifying the specific CPU variant within the architecture family.",

        // MARK: DisplayCollector

        "Screen Bounds (Points)":
            "The screen size measured in logical points. Points are a display-independent unit used by iOS for layout.",
        "Native Bounds (Pixels)":
            "The screen's actual pixel dimensions. This is the true hardware resolution of the display.",
        "Scale Factor":
            "How many physical pixels correspond to one logical point. @2x means 2 pixels per point (Retina), @3x means 3 pixels (Super Retina).",
        "Native Scale Factor":
            "The actual physical pixel-to-point ratio of the display hardware, which may differ from the rendering scale.",
        "Screen Brightness":
            "The current screen brightness level from 0.0 (darkest) to 1.0 (maximum).",
        "Preferred Content Size":
            "The user's preferred text size from the Accessibility settings. Apps that support Dynamic Type adjust their fonts accordingly.",
        "Locale Identifier":
            "A code representing the user's language and region preferences (e.g. \"en_US\" for English, United States).",
        "Language Code":
            "The two-letter code for the user's current language (e.g. \"en\" for English, \"de\" for German).",
        "Region Code":
            "The two-letter code for the user's region (e.g. \"US\", \"DE\"). Affects date formats, number formats, and other regional conventions.",
        "Time Zone Identifier":
            "The full name of the user's time zone (e.g. \"Europe/Berlin\", \"America/New_York\").",
        "Time Zone Abbreviation":
            "The short abbreviation for the time zone (e.g. \"CET\", \"EST\", \"PST\").",
        "GMT Offset":
            "The difference in seconds between the local time zone and Greenwich Mean Time (UTC).",
        "Calendar Identifier":
            "Which calendar system is in use (e.g. Gregorian, Buddhist, Japanese).",

        // MARK: StorageCollector

        "Total Disk Space":
            "The total storage capacity of the device.",
        "Free Disk Space":
            "How much storage space is currently available for new data.",
        "Used Disk Space":
            "How much storage is currently occupied by apps, photos, system files, etc.",
        "Disk Usage":
            "The percentage of total storage that is currently in use.",
        "Total File System Nodes":
            "The total number of file system entries (inodes) available. Each file or directory uses one inode.",
        "Free File System Nodes":
            "How many file system entries (inodes) are still available. Running out of inodes prevents creating new files even if disk space remains.",
        "Disk Space":
            "Total disk capacity reported by the iOS Resource Values API, which may differ slightly from the raw file system value.",
        "Available (Important Usage)":
            "Storage space available for critical data like user documents. iOS reserves some space for system functions.",
        "Available (Opportunistic Usage)":
            "Storage space available for non-essential data like caches. This is typically less than the space available for important usage.",
        "Physical Memory (RAM)":
            "Total RAM as reported by the process info API. RAM is the fast working memory used by running apps.",

        // MARK: NetworkCollector

        "IP Addresses":
            "Summary of all IP addresses assigned to this device's network interfaces.",
        "WiFi SSID":
            "The name of the WiFi network the device is currently connected to. Requires location permission to read.",
        "WiFi BSSID":
            "The unique hardware address of the WiFi access point (router) the device is connected to. Requires location permission.",
        "Carrier Name":
            "The name of the cellular carrier (e.g. \"T-Mobile\", \"Vodafone\").",
        "Mobile Country Code (MCC)":
            "A three-digit code identifying the country of the cellular network (e.g. \"262\" for Germany, \"310\" for USA).",
        "Mobile Network Code (MNC)":
            "A code identifying the specific cellular carrier within a country.",
        "ISO Country Code":
            "The two-letter country code of the cellular network (e.g. \"de\", \"us\").",
        "Allows VoIP":
            "Whether the cellular carrier allows Voice over IP calls on its network.",
        "Carrier Info":
            "General information about the device's cellular carrier.",
        "Radio Access Technology":
            "The type of cellular connection currently in use (e.g. LTE, 5G NR, WCDMA, EDGE).",

        // MARK: IdentifiersCollector

        "Advertising Identifier (IDFA)":
            "A unique ID used for advertising tracking across apps. Since iOS 14.5, users must explicitly grant permission for apps to access this.",
        "ATT Authorization Status":
            "Whether the user has granted App Tracking Transparency permission. This controls access to the Advertising Identifier (IDFA).",

        // MARK: BiometricsCollector

        "Biometry Type":
            "The type of biometric authentication available — Face ID (face recognition), Touch ID (fingerprint), or none.",
        "Biometrics Enrolled":
            "Whether the user has set up biometric authentication (Face ID or Touch ID) on this device.",
        "Screen Captured":
            "Whether the screen is currently being recorded, mirrored, or captured by another app.",

        // MARK: SensorsCollector

        "Accelerometer Available":
            "Whether the device has an accelerometer sensor, which measures acceleration and tilt. Used for screen rotation, fitness tracking, and gaming.",
        "Gyroscope Available":
            "Whether the device has a gyroscope, which measures rotation speed. Used for precise motion tracking in AR, gaming, and image stabilization.",
        "Magnetometer Available":
            "Whether the device has a magnetometer (digital compass), which measures the Earth's magnetic field to determine direction.",
        "Device Motion Available":
            "Whether the device can combine accelerometer, gyroscope, and magnetometer data into a unified motion measurement.",
        "Barometer (Relative Altitude)":
            "Whether the device has a barometric pressure sensor that can measure relative changes in altitude (e.g. climbing stairs).",
        "Step Counting":
            "Whether the device can count footsteps using its motion sensors.",
        "Distance Estimation":
            "Whether the device can estimate walking or running distance from step data.",
        "Floor Counting":
            "Whether the device can detect changes in elevation (going up or down floors) using the barometer.",
        "Pace Available":
            "Whether the device can calculate walking or running pace (time per distance unit).",
        "Cadence Available":
            "Whether the device can measure step cadence (steps per second).",
        "Motion Activity Recognition":
            "Whether the device can automatically detect the user's current activity — walking, running, cycling, driving, or stationary.",

        // MARK: CameraAudioCollector

        "Cameras":
            "Summary of how many cameras are available on the device.",
        "Camera Count":
            "The total number of camera modules detected on the device.",
        "Audio Category":
            "The current audio session category, which determines how the app interacts with other audio (e.g. playback, recording, or both).",
        "Audio Mode":
            "The audio session mode, which optimizes audio processing for specific use cases like voice chat, video recording, or measurement.",
        "Sample Rate":
            "The audio sampling rate in Hz. Higher rates capture more audio detail. Standard rates are 44100 Hz (CD quality) or 48000 Hz.",
        "I/O Buffer Duration":
            "The audio input/output buffer size in seconds. Smaller buffers reduce latency but require more CPU power.",
        "Output Latency":
            "The delay in seconds between when audio is sent to the speaker and when it is actually heard.",
        "Input Latency":
            "The delay in seconds between when sound hits the microphone and when it is available for processing.",
        "Max Input Channels":
            "The maximum number of simultaneous audio input channels (microphones).",
        "Max Output Channels":
            "The maximum number of simultaneous audio output channels (speakers or headphones).",
        "Other Audio Playing":
            "Whether another app is currently playing audio in the background.",
        "Haptics Supported":
            "Whether the device has a haptic engine (Taptic Engine) for touch feedback vibrations.",
        "Haptic Audio Supported":
            "Whether the haptic engine can also play audio alongside vibrations for richer tactile feedback.",

        // MARK: WirelessCollector

        "NFC Reading":
            "Whether the device supports Near Field Communication for reading NFC tags (used for contactless payments, transit cards, etc.).",
        "Bluetooth Authorization":
            "The current Bluetooth permission status. Apps need authorization to communicate with Bluetooth accessories.",
        "Ultra Wideband (UWB)":
            "Whether the device has a U1 chip for Ultra Wideband, enabling precise spatial awareness and device location (used by AirTag and Precision Finding).",

        // MARK: GPUARCollector

        "Metal":
            "Whether the device supports Apple's Metal graphics API, which provides direct access to the GPU for high-performance graphics.",
        "GPU Name":
            "The name of the graphics processor (e.g. \"Apple GPU\"). The GPU handles all visual rendering and parallel computations.",
        "Max Buffer Length":
            "The maximum size of a single data buffer that can be allocated on the GPU, in bytes.",
        "Max Threads Per Threadgroup":
            "The maximum number of parallel threads that can work together in a single GPU threadgroup. Higher numbers mean more parallel processing power.",
        "Max Threadgroup Memory":
            "The maximum amount of shared memory available within a GPU threadgroup for inter-thread communication.",
        "Recommended Max Working Set Size":
            "The recommended maximum amount of GPU memory to use for optimal performance.",
        "Highest GPU Family":
            "The most advanced GPU feature set supported by this device. Higher family numbers support more advanced graphics features.",
        "AR World Tracking":
            "Whether the device supports ARKit World Tracking — placing virtual objects in the real world using camera and sensors.",
        "AR Face Tracking":
            "Whether the device supports AR Face Tracking using the TrueDepth camera (for Animoji, face filters, etc.).",
        "AR Body Tracking":
            "Whether the device supports full-body motion tracking in AR.",
        "AR Image Tracking":
            "Whether the device can recognize and track known 2D images in the camera view.",
        "AR Object Scanning":
            "Whether the device can scan and recognize 3D objects for AR experiences.",

        // MARK: PermissionsCollector

        "Camera":
            "Current permission status for the device camera. Required for taking photos and videos.",
        "Microphone":
            "Current permission status for the microphone. Required for audio recording and voice calls.",
        "Photos":
            "Current permission status for the photo library. Required to read or save photos and videos.",
        "Contacts":
            "Current permission status for the contacts database. Required to read or modify contact information.",
        "Calendar":
            "Current permission status for the calendar. Required to read or create calendar events.",
        "Reminders":
            "Current permission status for reminders. Required to read or create reminder items.",
        "Location":
            "Current permission status for location services. Required for GPS, maps, and location-based features.",
        "Motion & Fitness":
            "Current permission status for motion and fitness data from the device's sensors.",
        "Speech Recognition":
            "Current permission status for speech recognition. Required to convert spoken words to text.",
        "Notifications":
            "Current permission status for push notifications. Determines if the app can send alerts.",
        "Bluetooth":
            "Current permission status for Bluetooth. Required to communicate with nearby Bluetooth devices.",
        "App Tracking (ATT)":
            "App Tracking Transparency status. Controls whether the app can track the user's activity across other companies' apps and websites.",
        "Siri":
            "Current permission status for Siri integration. Required for the app to donate shortcuts and intents to Siri.",

        // MARK: AccessibilityCollector

        "VoiceOver Running":
            "Whether VoiceOver (screen reader) is active. VoiceOver reads the screen aloud for visually impaired users.",
        "Switch Control Running":
            "Whether Switch Control is active, allowing users with motor impairments to control the device using external switches.",
        "Guided Access Enabled":
            "Whether Guided Access is enabled, which locks the device to a single app and restricts features. Often used in educational or kiosk settings.",
        "AssistiveTouch Running":
            "Whether AssistiveTouch is active, providing an on-screen menu for gestures that are difficult for some users.",
        "Shake to Undo Enabled":
            "Whether shaking the device triggers an undo action.",
        "Reduce Motion Enabled":
            "Whether the user has enabled Reduce Motion to minimize animations and motion effects, helping with motion sensitivity.",
        "Prefer Cross-Fade Transitions":
            "Whether the user prefers simple fade transitions instead of sliding animations.",
        "Video Autoplay Enabled":
            "Whether videos and animated content should play automatically, or wait for user interaction.",
        "Reduce Transparency Enabled":
            "Whether background blur and transparency effects are reduced for better readability.",
        "Darker System Colors Enabled":
            "Whether the system uses darker, higher-contrast colors for better visibility.",
        "Bold Text Enabled":
            "Whether the user has enabled bold text throughout the system for easier reading.",
        "Grayscale Enabled":
            "Whether the display is set to grayscale (no color), sometimes used for focus or visual accessibility.",
        "Invert Colors Enabled":
            "Whether screen colors are inverted (light becomes dark, dark becomes light). Useful for some visual impairments.",
        "Differentiate Without Color":
            "Whether the user needs visual distinctions beyond just color changes (e.g. shapes, labels) because they have difficulty perceiving color.",
        "On/Off Switch Labels":
            "Whether switches display I/O labels in addition to color to indicate on or off state.",
        "Closed Captioning Enabled":
            "Whether closed captions and subtitles for the deaf and hard of hearing are preferred.",
        "Mono Audio Enabled":
            "Whether stereo audio is combined into a single channel. Helpful for users with hearing loss in one ear.",
        "Speak Selection Enabled":
            "Whether the user can select text and have it spoken aloud.",
        "Speak Screen Enabled":
            "Whether the user can swipe down with two fingers to have the entire screen read aloud.",
        "Button Shapes Enabled":
            "Whether buttons have visible outlines or shapes to make them easier to identify.",
        "Hearing Device Paired Ear":
            "Which ear(s) have a paired Made for iPhone hearing device — left, right, both, or none.",

        // MARK: AppBundleCollector

        "Bundle Identifier":
            "The unique identifier for this app (e.g. \"com.example.app\"). Used by the system to distinguish apps from each other.",
        "App Name":
            "The display name of this app as shown on the home screen.",
        "Version":
            "The app's user-facing version number (e.g. \"1.2.0\"). This is the version shown on the App Store.",
        "Build Number":
            "An internal build number used by developers to track specific builds. Multiple builds can share the same version number.",
        "Executable Name":
            "The name of the compiled binary that the system runs when launching this app.",
        "Preferred Localization":
            "The language the app is currently displaying in, based on the user's preferences and the app's available translations.",
        "Resource Path":
            "The file system path where the app's bundled resources (images, data files, etc.) are stored on disk.",
        "Running Environment":
            "Whether the app is running on a physical device or in the Xcode Simulator (a development tool).",
        "Documents Directory":
            "The file path where the app stores user-created documents and data files that are backed up to iCloud.",
        "Caches Directory":
            "The file path for temporary cached data. The system may delete these files when storage is low.",
        "Temp Directory":
            "The file path for temporary files that are not needed between app launches.",

        // MARK: LocaleCollector

        "Currency Code":
            "The three-letter currency code for the user's region (e.g. \"USD\", \"EUR\", \"GBP\").",
        "Currency Symbol":
            "The symbol used for the local currency (e.g. \"$\", \"\u{20AC}\", \"\u{00A3}\").",
        "Decimal Separator":
            "The character used to separate decimal places in numbers (e.g. \".\" in the US, \",\" in Germany).",
        "Grouping Separator":
            "The character used to group thousands in numbers (e.g. \",\" in the US giving \"1,000\", \".\" in Germany giving \"1.000\").",
        "Measurement System":
            "The measurement system used in the user's region — Metric (meters, kilograms), US (feet, pounds), or UK (miles, stones).",
        "Preferred Languages":
            "The user's ranked list of preferred languages for app content, set in Settings > General > Language & Region.",
        "Timezone Identifier":
            "The full name of the user's time zone (e.g. \"Europe/Berlin\", \"America/New_York\").",
        "Timezone Abbreviation":
            "The short abbreviation for the time zone (e.g. \"CET\", \"EST\", \"PST\").",
        "Daylight Saving Time Active":
            "Whether daylight saving time (summer time) is currently in effect in the user's time zone.",
        "Next DST Transition":
            "The date and time of the next daylight saving time change, when clocks will spring forward or fall back.",

        // MARK: ExtendedNetworkCollector

        "HTTP Proxy":
            "Summary of HTTP proxy configuration. A proxy routes web traffic through an intermediary server.",
        "HTTP Proxy Enabled":
            "Whether an HTTP proxy is configured and active on this device. Proxies are used in corporate networks or for privacy tools.",
        "HTTP Proxy Host":
            "The address of the HTTP proxy server, if configured.",
        "HTTP Proxy Port":
            "The port number used to connect to the HTTP proxy server.",
        "VPN Status":
            "Summary of VPN (Virtual Private Network) connection status.",
        "VPN Active":
            "Whether a VPN connection is currently active. VPNs encrypt internet traffic and can mask the device's real IP address.",
        "Network Path Status":
            "The overall network connectivity status — satisfied (connected), unsatisfied (no connection), or requiresConnection (available but not active).",
        "Is Expensive":
            "Whether the current network connection is metered or costly (e.g. cellular data as opposed to WiFi).",
        "Is Constrained":
            "Whether the system is limiting network usage, typically due to Low Data Mode being enabled by the user.",
        "Active Interface Types":
            "Which types of network connections are currently available (WiFi, Cellular, Wired, Loopback, etc.).",
        "Supports DNS":
            "Indicates whether the current network path supports DNS resolution. If false, the device cannot resolve domain names.",
        "Supports IPv4":
            "Indicates whether the current network path supports IPv4 connectivity.",
        "Supports IPv6":
            "Indicates whether the current network path supports IPv6 connectivity.",

        // MARK: NetworkCollector — WiFi Security

        "Security Type":
            "The Wi-Fi encryption type of the currently connected network (e.g., Open, WPA2/WPA3 Personal, Enterprise). Retrieved via NEHotspotNetwork.",

        // MARK: ExtendedNetworkCollector — Proxy (Extended)

        "HTTPS Proxy Enabled":
            "Whether an HTTPS proxy server is configured for secure web traffic.",
        "HTTPS Proxy Host":
            "The hostname or IP address of the configured HTTPS proxy server.",
        "HTTPS Proxy Port":
            "The port number used by the configured HTTPS proxy server.",
        "SOCKS Proxy Enabled":
            "Whether a SOCKS proxy server is configured. SOCKS proxies can handle any type of network traffic, not just HTTP.",
        "SOCKS Proxy Host":
            "The hostname or IP address of the configured SOCKS proxy server.",
        "SOCKS Proxy Port":
            "The port number used by the configured SOCKS proxy server.",
        "PAC URL":
            "Proxy Auto-Configuration URL. Points to a JavaScript file that determines which proxy to use for each URL request.",
        "Auto-Discovery (WPAD)":
            "Web Proxy Auto-Discovery. When enabled, the device automatically discovers proxy settings via DHCP or DNS.",

        // MARK: ExtendedNetworkCollector — Public IP

        "Public IPv4":
            "Your device's public IPv4 address as seen by external servers. This is assigned by your ISP or network provider.",
        "Public IPv6":
            "Your device's public IPv6 address as seen by external servers. Not all networks support IPv6.",

        // MARK: DisplayCollector — Extended

        "Display Gamut":
            "The color space supported by the display. P3 (Display P3) is a wider color gamut than sRGB, allowing richer and more vivid colors. Most modern iPhones use P3.",
        "EDR Headroom":
            "Extended Dynamic Range headroom — how much brighter than standard white the display can show. Values above 1.0 indicate HDR capability. Higher values mean brighter highlights.",
        "Max Refresh Rate":
            "The maximum refresh rate the display supports. 60 Hz is standard, 120 Hz (ProMotion) provides smoother scrolling and animations by refreshing the screen twice as often.",
        "Interface Style":
            "Whether the device is in Dark Mode or Light Mode, as set in Settings > Display & Brightness.",
        "Display Zoom":
            "Whether Display Zoom is enabled (Settings > Display & Brightness > Display Zoom). Zoomed mode makes everything on screen larger at the cost of fitting less content.",

        // MARK: LocaleCollector — System Settings

        "24-Hour Time":
            "Whether the device uses 24-hour time format (e.g. 14:30) or 12-hour format with AM/PM (e.g. 2:30 PM). Set in Settings > General > Date & Time.",
        "First Day of Week":
            "Which day is considered the start of the week in calendars. Varies by region — Monday in most of Europe, Sunday in the US.",
        "Temperature Unit":
            "Whether temperatures are displayed in Celsius or Fahrenheit, inferred from the device's locale and regional settings.",
        "Active Keyboards":
            "The keyboard input modes currently enabled on the device. Each entry represents a language or input method the user has added in Settings > General > Keyboard.",

        // MARK: ClipboardCollector

        "Clipboard Items Count":
            "The total number of distinct items currently stored on the system clipboard. Multiple items can exist when copying rich content.",

        // MARK: CameraAudioCollector — Extended

        "Output Volume":
            "The current system volume level as a percentage. This reflects the hardware volume buttons and Control Center slider.",
        "Silent Mode":
            "Whether the physical mute switch (ring/silent) is engaged. No reliable public API exists — this uses a heuristic based on audio route analysis.",

        // MARK: ProcessInfoCollector — Memory

        "Available Memory":
            "The amount of RAM currently available for this app to use. When this drops too low, iOS starts terminating background apps to free memory.",
        "App Memory Usage":
            "The resident memory (RAM) currently used by this app process. High usage may trigger iOS to terminate the app when memory is scarce.",

        // MARK: EnvironmentSecurityCollector

        "TestFlight Build":
            "Whether this app was installed via TestFlight (beta testing). Detected by checking if the App Store receipt URL contains 'sandboxReceipt'.",
        "Build Configuration":
            "Whether the app was compiled in Debug mode (for development, with extra logging and assertions) or Release mode (optimized for production).",
        "Jailbreak Indicators":
            "Results of checking for common jailbreak artifacts — Cydia.app, APT directories, writable root filesystem. These are basic heuristic checks and may not detect sophisticated jailbreaks.",

        // MARK: NetworkCollector — WiFi RSSI

        "Signal Strength (RSSI)":
            "Received Signal Strength Indicator for the current WiFi connection. Measured in dBm: -30 is excellent, -50 is good, -70 is fair, -90 is very weak.",
    ]
}
