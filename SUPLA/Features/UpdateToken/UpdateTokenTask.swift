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

@objc
class UpdateTokenTask: NSObject {
    
    let updatePauseInSecs = 7 * 24 * 60 * 60.0
    
    @Singleton<ProfileRepository> private var profileRepository
    @Singleton<SingleCall> private var singleCall
    @Singleton<GlobalSettings> private var settings
    @Singleton<DateProvider> private var dateProvider
    
    @objc
    func update(token: Data, completionHandler: @escaping () -> Void) {
        DispatchQueue.global(qos: .default).async {
            self.doUpdate(token: token)
            completionHandler()
        }
    }
    
    private func doUpdate(token: Data) {
        if (settings.pushToken == token && tokenUpdateNotNeeded()) {
            SALog.info("Token update skipped. Tokens are equal")
            return
        }
        
        do {
            let profiles = try profileRepository.getAllProfiles().subscribeSynchronous()
            if (profiles == nil || profiles?.count == 0) {
                SALog.info("Skipping token update - no profiles found")
                return
            }
            
            var allProfilesUpdated = true
            profiles?.forEach { profile in
                let name = profile.name ?? "<<>>"
                
                SALog.info("Updating token for profile `\(name)`")
                if (!updateToken(token: token, forProfile: profile)) {
                    allProfilesUpdated = false
                }
            }
            
            if (allProfilesUpdated) {
                settings.pushTokenLastUpdate = dateProvider.currentTimestamp()
            }
        } catch {
            SALog.warning("Token update task failed with error \(error)")
        }
    }
    
    private func updateToken(token: Data, forProfile profile: AuthProfileItem) -> Bool {
        let name = profile.name ?? "<<>>"
        do {
            let tokenDetails = profile.token(token)
            
            if (profile.isAuthDataComplete) {
                try singleCall.registerPushToken(profile.authorizationEntity, profile.preferredProtocolVersion, tokenDetails)
            } else {
                SALog.debug("Token update skipped for profile with incomplete data \(name)")
            }
            return true
        } catch {
            SALog.warning("Token update for porfile `\(name)` failed with error \(error)")
            return false
        }
    }
    
    private func tokenUpdateNotNeeded() -> Bool {
        return settings.pushTokenLastUpdate + updatePauseInSecs > dateProvider.currentTimestamp()
    }
}
