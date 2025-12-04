//
//  NetworkReachability.swift
//  Last
//
//  Created by Claude Code on 04.12.2025.
//

import Foundation
import Network

protocol NetworkReachabilityProtocol: Sendable {
    func isNetworkAvailable() async -> Bool
}

final class NetworkReachability: NetworkReachabilityProtocol, @unchecked Sendable {
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkReachability")
    private var isConnected = false

    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }

    func isNetworkAvailable() async -> Bool {
        return await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                continuation.resume(returning: self?.isConnected ?? false)
            }
        }
    }

    deinit {
        monitor.cancel()
    }
}
