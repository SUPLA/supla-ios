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

struct AwaitConnectivity {
    protocol UseCase {
        func invoke() async -> Result
    }
    
    class Implementation: UseCase {
        func invoke() async -> Result {
            let mainTask = Task {
                let result: Result = await withCheckedContinuation { continuation in
                    let monitor = NWPathMonitor()
                    monitor.pathUpdateHandler = { path in
                        switch path.status {
                        case .satisfied:
                            SALog.debug("Got connection")
                            monitor.cancel()
                            continuation.resume(returning: .success)
                        default:
                            SALog.debug("Awaiting connection (status: \(path.status))")
                        }
                    }
                    monitor.start(queue: DispatchQueue(label: "InternetConnectionMonitor"))
                }
                try Task.checkCancellation()
                return result
            }
            
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: TIMEOUT_SECS * NSEC_PER_SEC)
                mainTask.cancel()
            }
            
            do {
                let result = try await mainTask.value
                timeoutTask.cancel()
                return result
            } catch {
                SALog.error("Reconnect timeout")
                return .timeout
            }
        }
    }
    
    enum Result {
        case success
        case timeout
    }
}
