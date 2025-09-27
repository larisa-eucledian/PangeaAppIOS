//
//  Reachability.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 27/09/25.
//

import Foundation
import Network

final class Reachability {
    static let shared = Reachability()
    static let didChange = Notification.Name("NetworkReachabilityDidChange")

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ReachabilityQueue")
    private(set) var isOnline: Bool = true

    private init() {}

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = (path.status == .satisfied)
            DispatchQueue.main.async {
                self?.isOnline = online
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
