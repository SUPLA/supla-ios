/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
    
import Network

private let TIMEOUT_SECS: UInt64 = 15
private let TEST_ENDPOINT = "http://captive.apple.com/hotspot-detect.html"

enum AwaitConnectivity {
    protocol UseCase {
        func invoke() async -> Result
    }
    
    class Implementation: UseCase {
        func invoke() async -> Result {
            SALog.info("Awaiting connectivity task started")
            
            return await cancelableTaskWithTimeout(timeout: TIMEOUT_SECS) { [weak self] in
                let result = await self?.checkNetworkConnection()
                let hasConnectivity = await self?.checkInternetConnection()
                
                if (result == .success && hasConnectivity == true) {
                    return .success
                } else {
                    return .timeout
                }
            } ?? .timeout
        }
        
        private func checkNetworkConnection() async -> Result {
            let monitor = NWPathMonitor()
            let continuationContainer = ObjectContainer<CheckedContinuation<AwaitConnectivity.Result, Never>>()
            
            return await withTaskCancellationHandler {
                await withCheckedContinuation { continuation in
                    continuationContainer.object = continuation
                    monitor.pathUpdateHandler = { path in
                        switch path.status {
                        case .satisfied:
                            SALog.debug("Got connection")
                            monitor.cancel()
                            continuation.resume(returning: .success)
                        default:
                            SALog.debug("Awaiting connection (status: \(path.status), reason: \(path.unsatisfiedReason))")
                        }
                    }
                    monitor.start(queue: DispatchQueue(label: "InternetConnectionMonitor"))
                }
            } onCancel: {
                SALog.debug("Canceling monitor")
                monitor.cancel()
                continuationContainer.object?.resume(returning: .timeout)
            }
        }
        
        private func checkInternetConnection() async -> Bool {
            guard let url = URL(string: TEST_ENDPOINT) else {
                return false
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            request.httpMethod = "GET"
            
            if let (data, response) = try? await URLSession.shared.data(for: request),
               let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let responseString = String(data: data, encoding: .utf8),
               responseString.contains("Success")
            {
                return true
            }
            
            return false
        }
    }
    
    enum Result {
        case success
        case timeout
    }
}
