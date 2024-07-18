//
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
    
private let INITIALIZATION_MIN_TIME_S: Double = 1

enum InitializationUseCase {
    static func invoke() {
        @Singleton<DateProvider> var dateProvider
        @Singleton<ProfileRepository> var profileRepository
        @Singleton<SuplaAppStateHolder> var stateHolder
        @Singleton<GlobalSettings> var settings
        @Singleton<ThreadHandler> var threadHandler
            
        let initializationStartTime = dateProvider.currentTimestamp()
            
        // Check if there is an active profile
        let profileFound = (try? profileRepository.getActiveProfile().subscribeSynchronous()?.isActive) ?? false
            
        // Check pin
        let pinRequired = settings.lockScreenSettings.pinForAppRequired
            
        // Wait a moment to avoid screen blinking
        let initializationEndTime = dateProvider.currentTimestamp()
        let initializationTime = initializationEndTime - initializationStartTime
        if (initializationTime < INITIALIZATION_MIN_TIME_S) {
            threadHandler.usleepProxy(UInt32((INITIALIZATION_MIN_TIME_S - initializationTime) * 1_000_000))
        }
            
        // Go to next state
        SALog.debug("Active profile found: \(profileFound), pin required \(pinRequired)")
        if (pinRequired) {
            stateHolder.handle(event: .lock)
        } else if (profileFound) {
            stateHolder.handle(event: .initialized)
        } else {
            stateHolder.handle(event: .noAccount)
        }
    }
}
