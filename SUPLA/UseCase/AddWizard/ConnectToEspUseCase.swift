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

import NetworkExtension
import SystemConfiguration.CaptiveNetwork

private let ACCEPTED_INTERNAL_ERROR_RETRIES: Int = 3

enum ConnectToEsp {
    protocol UseCase {
        func invoke() async -> Result
    }

    class Implementation: UseCase {
        @Singleton<DisconnectUseCase> private var disconnectUseCase

        func invoke() async -> Result {
            disconnectUseCase.invokeSynchronous(reason: .addWizardStarted)
            var internalErrorRetries = 0

            for _ in 0 ..< 3 {
                for prefix in Esp.prefixes {
                    if (!Task.isCancelled) {
                        do {
                            let config = NEHotspotConfiguration(ssidPrefix: prefix)
                            config.joinOnce = false
                            try await NEHotspotConfigurationManager.shared.apply(config)
                            SALog.info("Connected to prefix \(prefix)")
                            return .success
                        } catch {
                            SALog.error("Connecting to prefix \(prefix) failed: \(error)")
                            
                            if (error.isUserDenied) {
                                return .failure
                            }
                            
                            if (error.isInternal) {
                                // await 2 seconds to give a short time for NEHelper to get his act together
                                try? await Task.sleep(nanoseconds: 2_000_000_000)
                                
                                internalErrorRetries = internalErrorRetries + 1
                                if (internalErrorRetries > ACCEPTED_INTERNAL_ERROR_RETRIES) {
                                    SALog.error("Internal error exceeded the limit, aborting!")
                                    return .fatalError
                                }
                            }
                        }
                    }
                }
                
                // No success after all prefixes - wait short time
                SALog.error("All prefixes scanned, waiting short time!")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }

            return .failure
        }
    }

    enum Result {
        case success, failure, fatalError
    }
}

private extension Error {
    var isUserDenied: Bool {
        return (self as NSError).domain == NEHotspotConfigurationErrorDomain
            && (self as NSError).code == NEHotspotConfigurationError.userDenied.rawValue
    }
    
    var isInternal: Bool {
        return (self as NSError).domain == NEHotspotConfigurationErrorDomain
            && (self as NSError).code == NEHotspotConfigurationError.internal.rawValue
    }
}
