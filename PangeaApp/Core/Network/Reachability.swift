import Foundation
import Network

final class Reachability {
    static let shared = Reachability()
    static let didChange = Notification.Name("NetworkReachabilityDidChange")

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ReachabilityQueue")

    private(set) var isOnline: Bool = true
    private(set) var isExpensive: Bool = false   // datos móviles
    private(set) var isConstrained: Bool = false // Low Data Mode

    private init() {}

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = (path.status == .satisfied)
            let expensive = path.isExpensive
            let constrained = path.isConstrained
            DispatchQueue.main.async {
                self?.isOnline = online
                self?.isExpensive = expensive
                self?.isConstrained = constrained
                NotificationCenter.default.post(
                    name: Self.didChange,
                    object: nil,
                    userInfo: ["isOnline": online]
                )
            }
        }
        monitor.start(queue: queue)
    }

    func stop() { monitor.cancel() }
}
