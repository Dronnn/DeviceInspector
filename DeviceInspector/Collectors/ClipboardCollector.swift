import UIKit
import os.log

struct ClipboardCollector {
    private static let logger = Logger(subsystem: "com.deviceinspector", category: "ClipboardCollector")

    @MainActor
    static func collect() -> DeviceInfoSection {
        logger.debug("Collecting clipboard data")
        var items: [DeviceInfoItem] = []

        let pasteboard = UIPasteboard.general

        items.append(DeviceInfoItem(
            key: "Has Text",
            value: pasteboard.hasStrings ? "Yes" : "No",
            notes: "Whether the clipboard currently contains text content."
        ))

        items.append(DeviceInfoItem(
            key: "Has Images",
            value: pasteboard.hasImages ? "Yes" : "No",
            notes: "Whether the clipboard currently contains image content."
        ))

        items.append(DeviceInfoItem(
            key: "Has URLs",
            value: pasteboard.hasURLs ? "Yes" : "No",
            notes: "Whether the clipboard currently contains URL content."
        ))

        items.append(DeviceInfoItem(
            key: "Clipboard Items Count",
            value: "\(pasteboard.items.count)",
            notes: "Total number of items currently on the clipboard."
        ))

        logger.debug("Clipboard collection complete: \(items.count) items")

        return DeviceInfoSection(
            title: "Clipboard",
            icon: "clipboard",
            items: items,
            explanation: """
            Clipboard shows metadata about the current contents of the system pasteboard \
            (UIPasteboard.general). This includes whether text, images, or URLs are present \
            and the total item count. The actual clipboard content is not read — only its \
            type indicators are checked using hasStrings, hasImages, and hasURLs.
            """
        )
    }
}
