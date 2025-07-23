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

enum ConnectToEsp {
    protocol UseCase {
        func invoke() async -> Result
    }

    class Implementation: UseCase {
        @Singleton<DisconnectUseCase> private var disconnectUseCase

        func invoke() async -> Result {
            disconnectUseCase.invokeSynchronous(reason: .addWizardStarted)

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
                        }
                    }
                }
            }

            return .failure
        }
    }

    enum Result {
        case success, failure
    }
}

private extension Error {
    var isUserDenied: Bool {
        return (self as NSError).domain == NEHotspotConfigurationErrorDomain
            && (self as NSError).code == NEHotspotConfigurationError.userDenied.rawValue
    }
}
