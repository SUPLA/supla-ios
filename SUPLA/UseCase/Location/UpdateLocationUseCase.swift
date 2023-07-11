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

import Foundation
import RxSwift

final class UpdateLocationUseCase {
    
    @Singleton<LocationRepository> private var locationRepository
    @Singleton<ProfileRepository> private var profileRepository
    
    @available(*, deprecated, message: "Only for legacy code")
    func invoke(suplaLocation: TSC_SuplaLocation) -> Bool {
        var changed = false
        
        do {
            changed = try profileRepository.getActiveProfile()
                .flatMapFirst{ profile in
                    self.locationRepository.getLocation(for: profile, with: suplaLocation.Id)
                        .ifEmpty(switchTo: self.createLocation(remoteId: suplaLocation.Id))
                }
                .map { location in self.updateLocation(location: location, suplaLocation: suplaLocation) }
                .flatMapFirst { tuple in
                    if (tuple.0) {
                        return self.locationRepository.save(tuple.1).map { true }
                    }
                    return Observable.just(tuple.0)
                }
                .toBlocking()
                .first() ?? false
            
        } catch {
            changed = false
        }
        
        return changed
    }
    
    private func updateLocation(location: _SALocation, suplaLocation: TSC_SuplaLocation) -> (Bool, _SALocation) {
        var changed = false
        
        let caption = String.fromC(suplaLocation.Caption)
        if (location.caption != caption) {
            location.caption = caption
            changed = true
        }
        
        if (location.visible != 1) {
            location.visible = 1
            changed = true
        }
        
        return (changed, location)
    }
    
    private func createLocation(remoteId: Int32) -> Observable<_SALocation> {
        return locationRepository.create()
            .flatMapFirst { location in
                self.profileRepository.getActiveProfile()
                    .map { profile in
                        location.location_id = NSNumber(value: remoteId)
                        location.profile = profile
                        
                        return location
                    }
            }
    }
}
