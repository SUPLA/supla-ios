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

import RxSwift

@testable import SUPLA

class RuntimeConfigMock: RuntimeConfig {
    var activeProfileIdReturns: ProfileID? = nil
    var activeProfileIdValues: [ProfileID?] = []
    var activeProfileId: ProfileID? {
        get {
            activeProfileIdReturns
        }
        set {
            activeProfileIdValues.append(newValue)
        }
    }
    
    var runtimePreferences: RuntimePreferences? = nil
    
    func preferencesObservable() -> Observable<RuntimePreferences> {
        if let toEmit = runtimePreferences {
            return Observable.just(toEmit)
        } else {
            return Observable.empty()
        }
    }
    
    func emitPreferenceChange(scaleFactor: Float, showChannelInfo: Bool) {
        runtimePreferences = RuntimePreferences(scaleFactor: scaleFactor, showChannelInfo: showChannelInfo)
    }
}
