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
            let mainTask = Task {
                let result = try await checkNetworkConnection()
                let hasConnectivity = await checkInternetConnection()
                
                try Task.checkCancellation()
                
                if (result == .success && hasConnectivity) {
                    return result
                } else {
                    return .timeout
                }
            }
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: TIMEOUT_SECS * NSEC_PER_SEC)
                SALog.debug("Timeout reached - canceling main task")
                mainTask.cancel()
            }
            
            do {
                let result = try await withTaskCancellationHandler {
                    try await mainTask.value
                } onCancel: {
                    SALog.debug("Reconnect task canceled")
                    mainTask.cancel()
                    timeoutTask.cancel()
                }
                timeoutTask.cancel()
                return result
            } catch {
                SALog.error("Reconnect timeout")
                return .timeout
            }
        }
        
        private func checkNetworkConnection() async throws -> Result {
            let monitor = NWPathMonitor()
            let continuationContainer = ObjectContainer<CheckedContinuation<AwaitConnectivity.Result, any Error>>()
            
            return try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
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
                continuationContainer.object?.resume(throwing: CancellationError())
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
