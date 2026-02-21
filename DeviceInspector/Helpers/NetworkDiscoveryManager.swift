import Foundation
import Combine
import Network
import os.log

struct DiscoveredNetworkService: Identifiable {
    let id: String
    let name: String
    let serviceType: String
    let domain: String
    let endpoint: String?
}

final class NetworkDiscoveryManager: ObservableObject {
    @Published var discoveredServices: [DiscoveredNetworkService] = []
    @Published var isScanning = false

    private var browsers: [NWBrowser] = []
    private let logger = Logger(subsystem: "com.deviceinspector", category: "NetworkDiscovery")

    private let serviceTypes: [String] = [
        "_http._tcp",
        "_airplay._tcp",
        "_raop._tcp",
        "_homekit._tcp",
        "_printer._tcp",
        "_ipp._tcp",
        "_smb._tcp",
        "_ssh._tcp",
        "_googlecast._tcp",
        "_spotify-connect._tcp",
        "_companion-link._tcp",
        "_sleep-proxy._udp"
    ]

    func startScanning() {
        logger.debug("Starting network discovery")
        discoveredServices = []
        isScanning = true
        browsers = []

        for serviceType in serviceTypes {
            let descriptor = NWBrowser.Descriptor.bonjour(type: serviceType, domain: nil)
            let browser = NWBrowser(for: descriptor, using: .tcp)

            browser.stateUpdateHandler = { [weak self] state in
                self?.logger.debug("Browser for \(serviceType) state: \(String(describing: state))")
            }

            browser.browseResultsChangedHandler = { [weak self] results, _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.processResults(results, serviceType: serviceType)
                }
            }

            browser.start(queue: .main)
            browsers.append(browser)
        }
    }

    func stopScanning() {
        logger.debug("Stopping network discovery, found \(self.discoveredServices.count) services")
        for browser in browsers {
            browser.cancel()
        }
        browsers = []
        isScanning = false
    }

    private func processResults(_ results: Set<NWBrowser.Result>, serviceType: String) {
        for result in results {
            let name: String
            let domain: String
            let endpointStr: String?

            switch result.endpoint {
            case .service(let svcName, let svcType, let svcDomain, _):
                name = svcName
                domain = svcDomain
                endpointStr = "\(svcName).\(svcType).\(svcDomain)"
            case .hostPort(let host, let port):
                name = "\(host)"
                domain = ""
                endpointStr = "\(host):\(port)"
            default:
                name = "Unknown"
                domain = ""
                endpointStr = nil
            }

            let serviceID = "\(serviceType).\(name)"

            // Skip duplicates
            guard !discoveredServices.contains(where: { $0.id == serviceID }) else { continue }

            let service = DiscoveredNetworkService(
                id: serviceID,
                name: name,
                serviceType: serviceType,
                domain: domain.isEmpty ? "local." : domain,
                endpoint: endpointStr
            )

            discoveredServices.append(service)
            logger.debug("Discovered: \(name) (\(serviceType))")
        }
    }
}
