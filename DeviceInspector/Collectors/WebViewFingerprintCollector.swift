import WebKit
import os.log

struct WebViewFingerprintCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "WebViewFingerprintCollector")

    @MainActor
    static func collect() async -> DeviceInfoSection {
        logger.debug("Collecting WebView fingerprint data")

        var items: [DeviceInfoItem] = []

        let webView = WKWebView(frame: .zero)
        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)

        // Small delay to let the blank page load
        try? await Task.sleep(for: .milliseconds(100))

        // User-Agent String
        do {
            let result = try await webView.evaluateJavaScript("navigator.userAgent")
            items.append(DeviceInfoItem(
                key: "User-Agent String",
                value: (result as? String) ?? "Not Available",
                isSensitive: true
            ))
        } catch {
            logger.debug("Failed to get navigator.userAgent: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "User-Agent String",
                value: "Not Available",
                availability: .notAvailable
            ))
        }

        // Platform
        do {
            let result = try await webView.evaluateJavaScript("navigator.platform")
            items.append(DeviceInfoItem(
                key: "Platform",
                value: (result as? String) ?? "Not Available"
            ))
        } catch {
            logger.debug("Failed to get navigator.platform: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "Platform",
                value: "Not Available",
                availability: .notAvailable
            ))
        }

        // Language
        do {
            let result = try await webView.evaluateJavaScript("navigator.language")
            items.append(DeviceInfoItem(
                key: "Language",
                value: (result as? String) ?? "Not Available"
            ))
        } catch {
            logger.debug("Failed to get navigator.language: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "Language",
                value: "Not Available",
                availability: .notAvailable
            ))
        }

        // Accept Languages
        do {
            let result = try await webView.evaluateJavaScript("navigator.languages.join(', ')")
            items.append(DeviceInfoItem(
                key: "Accept Languages",
                value: (result as? String) ?? "Not Available"
            ))
        } catch {
            logger.debug("Failed to get navigator.languages: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "Accept Languages",
                value: "Not Available",
                availability: .notAvailable
            ))
        }

        // Hardware Concurrency
        do {
            let result = try await webView.evaluateJavaScript("navigator.hardwareConcurrency")
            items.append(DeviceInfoItem(
                key: "Hardware Concurrency",
                value: String(describing: result ?? "Not Available")
            ))
        } catch {
            logger.debug("Failed to get navigator.hardwareConcurrency: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "Hardware Concurrency",
                value: "Not Available",
                availability: .notAvailable
            ))
        }

        // Max Touch Points
        do {
            let result = try await webView.evaluateJavaScript("navigator.maxTouchPoints")
            items.append(DeviceInfoItem(
                key: "Max Touch Points",
                value: String(describing: result ?? "Not Available")
            ))
        } catch {
            logger.debug("Failed to get navigator.maxTouchPoints: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "Max Touch Points",
                value: "Not Available",
                availability: .notAvailable
            ))
        }

        // Cookies Enabled
        do {
            let result = try await webView.evaluateJavaScript("navigator.cookieEnabled")
            items.append(DeviceInfoItem(
                key: "Cookies Enabled",
                value: String(describing: result ?? "Not Available")
            ))
        } catch {
            logger.debug("Failed to get navigator.cookieEnabled: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "Cookies Enabled",
                value: "Not Available",
                availability: .notAvailable
            ))
        }

        // Vendor
        do {
            let result = try await webView.evaluateJavaScript("navigator.vendor")
            items.append(DeviceInfoItem(
                key: "Vendor",
                value: (result as? String) ?? "Not Available"
            ))
        } catch {
            logger.debug("Failed to get navigator.vendor: \(error.localizedDescription)")
            items.append(DeviceInfoItem(
                key: "Vendor",
                value: "Not Available",
                availability: .notAvailable
            ))
        }

        logger.debug("WebView fingerprint collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "WebView Fingerprint",
            icon: "globe",
            items: items,
            explanation: """
                Every website sees the User-Agent string, which leaks the OS version, device model, \
                and browser engine version — making it the #1 web tracking vector. Combined with \
                navigator properties like language, platform, hardware concurrency, and touch point \
                count, websites can build a surprisingly unique fingerprint without any cookies or \
                storage. Even a "blank" WebView reveals this data to any page it loads.
                """
        )
    }
}
