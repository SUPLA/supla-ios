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
import RxRelay
import RxSwift

/**
    Protocol created to avoid using static instances in code. Instance of it is created when the app starts and everything there will behave like a static content.
 */
protocol RuntimeConfig {
    
    var activeProfileId: ProfileID? { get set }
    
    func preferencesObservable() -> Observable<RuntimePreferences>
    func emitPreferenceChange(scaleFactor: Float, showChannelInfo: Bool)
}

class RuntimeConfigImpl: RuntimeConfig {
    var activeProfileId: ProfileID?
    
    let configRelay: BehaviorRelay<RuntimePreferences>
    
    init() {
        let config = Config()
        configRelay = BehaviorRelay(value: RuntimePreferences(
            scaleFactor: config.channelHeightFactor,
            showChannelInfo: config.showChannelInfo
        ))
    }
    
    func preferencesObservable() -> Observable<RuntimePreferences> {
        return configRelay.asObservable()
    }
    
    func emitPreferenceChange(scaleFactor: Float, showChannelInfo: Bool) {
        configRelay.accept(RuntimePreferences(scaleFactor: scaleFactor, showChannelInfo: showChannelInfo))
    }
}

struct RuntimePreferences {
    let scaleFactor: Float
    let showChannelInfo: Bool
}
