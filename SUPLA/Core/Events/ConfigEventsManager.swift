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
import RxRelay

@objc protocol ConfigEventsManagerEmitter {
    func emitConfig(result: UInt8, config: TSCS_ChannelConfig)
}

protocol ConfigEventsManager: ConfigEventsManagerEmitter {
    func observeConfig(remoteId: Int32) -> Observable<ConfigEvent>
}

final class ConfigEventsManagerImpl: ConfigEventsManager {
    
    private var subjects: [Int32: PublishRelay<ConfigEvent>] = [:]
    private let syncedQueue = DispatchQueue(label: "ConfigEventsPrivateQueue", attributes: .concurrent)
    
    func emitConfig(result: UInt8, config: TSCS_ChannelConfig) {
        let convertedConfig = SuplaChannelConfig.from(suplaConfig: config)
        let convertedResult = ChannelConfigResult.from(value: result)
        
        let subject = getSubject(remoteId: convertedConfig.remoteId)
        subject.accept(ConfigEvent(result: convertedResult, config: convertedConfig))
    }
    
    func observeConfig(remoteId: Int32) -> Observable<ConfigEvent> {
        getSubject(remoteId: remoteId).asObservable()
    }
    
    private func getSubject(remoteId: Int32) -> PublishRelay<ConfigEvent> {
        return syncedQueue.sync(execute: {
            if let subject = subjects[remoteId] {
                return subject
            }
            
            let subject = PublishRelay<ConfigEvent>()
            subjects[remoteId] = subject
            return subject
        })
    }
}

struct ConfigEvent {
    let result: ChannelConfigResult
    let config: SuplaChannelConfig
}
