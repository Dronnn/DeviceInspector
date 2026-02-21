# Privacy Policy — Device Inspector

**Last Updated:** February 21, 2026
**Contact:** Andreas Maier

---

## Overview

Device Inspector is a privacy-first iOS application designed to display detailed information about your device. This Privacy Policy explains how the app handles your data and what information it accesses.

**Our commitment:** Device Inspector does not collect personal data, does not require user accounts, and does not track or profile users.

---

## Data Collection and Storage

### On-Device Processing Only

All device information displayed by Device Inspector is processed locally on your device. This includes:
- Device model, iOS version, and hardware specifications
- Storage and memory information
- Active network interfaces and configurations
- Running processes and system status
- Battery and thermal status

**This data is never stored, transmitted, or logged by the app.**

---

## Network Requests

### Public IP Address Lookup

The app makes a single, anonymous request to **ipify.org** to retrieve your public IP address. The purposes and terms are:

- **What is sent:** Only a standard HTTP GET request to identify your public IP
- **What is displayed:** Your public IP address is shown on the app screen only
- **What is NOT done:** The IP address is not stored, cached, or transmitted to any server controlled by the developer
- **Privacy note:** This request is subject to ipify.org's privacy policy; the developer has no control over or visibility into this external service

For details on ipify.org's data handling, visit: https://www.ipify.org/

### Local Network Discovery

Device Inspector scans your local network using Bonjour (mDNS) to discover available services and devices. All discovery activities remain on your local network and are not transmitted outside your device.

### Bluetooth Scanning

The app scans for nearby Bluetooth Low Energy (BLE) devices to display available Bluetooth peripherals. This scan data remains on your device and is not transmitted elsewhere.

---

## System APIs and Required Reason APIs

Device Inspector uses the following system APIs for legitimate on-device functionality:

- **System Boot Time API:** Displays device uptime
- **Disk Space API:** Shows available and used storage
- **Active Keyboard API:** Displays information about active input methods

The app includes a Privacy Manifest (`PrivacyInfo.xcprivacy`) that declares all required APIs in accordance with Apple's privacy requirements. These APIs are used only for displaying system information within the app; no data is transmitted to external servers.

---

## What the App Does NOT Do

- ✓ Does not collect personal data (names, emails, phone numbers, etc.)
- ✓ Does not require user accounts or registration
- ✓ Does not use analytics or tracking SDKs
- ✓ Does not display advertisements
- ✓ Does not use cookies
- ✓ Does not transmit device information to any server controlled by the developer
- ✓ Does not log system information
- ✓ Does not profile or build user behavior models

---

## Data Export

Device Inspector allows you to export device information in JSON format or copy it to your clipboard. These export operations are:

- Initiated only when you manually select the export option
- Processed entirely on your device
- Not automatically transmitted or shared

You control what happens with exported data after you initiate the export.

---

## Third-Party Services

The only third-party service used by Device Inspector is:

- **ipify.org** – for public IP address lookup (as described above)

No other third-party services, analytics providers, or advertising networks are integrated into this app.

---

## Open Source

Device Inspector is fully open source. The entire source code is publicly available on GitHub, so you can review exactly how the app works and verify that it does what this policy describes — nothing more, nothing less.

**Source Code:** [github.com/Dronnn/DeviceInspector](https://github.com/Dronnn/DeviceInspector)

---

## Children's Privacy

Device Inspector is not directed toward children under 13. The app does not knowingly collect any information from children. If you believe a child under 13 has used this app, please contact the developer.

---

## Changes to This Privacy Policy

This Privacy Policy may be updated periodically to reflect changes in the app's functionality or evolving privacy practices. The "Last Updated" date at the top of this page will indicate when changes were made. We encourage you to review this policy regularly.

---

## Contact

If you have questions or concerns about this Privacy Policy or how Device Inspector handles your data, please contact:

**Andreas Maier**
GitHub Repository: [Device Inspector on GitHub](https://github.com/Dronnn/DeviceInspector)

---

## Summary

Device Inspector is built with privacy as the foundation. Your device information stays on your device. The app collects no personal data, requires no accounts, and includes no tracking mechanisms. The only external request (ipify.org for public IP) is clearly documented and does not involve data storage or transmission by the developer.
