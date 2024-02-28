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

@objc protocol ChannelConfigEventsManagerEmitter {
    func emitConfig(result: UInt8, config: TSCS_ChannelConfig, crc32: Int64)
}

protocol ChannelConfigEventsManager: ChannelConfigEventsManagerEmitter {
    func observeConfig(id: Int32) -> Observable<ChannelConfigEvent>
}

final class ChannelConfigEventsManagerImpl: BaseConfigEventsManager<ChannelConfigEvent>, ChannelConfigEventsManager {
    
    init() {
        super.init(queueLabel: "ChannelConfigEventsPrivateQueue")
    }
    
    func emitConfig(result: UInt8, config: TSCS_ChannelConfig, crc32: Int64) {
        let convertedConfig = SuplaChannelConfig.from(suplaConfig: config, crc32: crc32)
        let convertedResult = SuplaConfigResult.from(value: result)
        
        let subject = getSubject(id: convertedConfig.remoteId)
        subject.accept(ChannelConfigEvent(result: convertedResult, config: convertedConfig))
    }
}

struct ChannelConfigEvent {
    let result: SuplaConfigResult
    let config: SuplaChannelConfig
}
