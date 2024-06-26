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

final class ChannelConfigEventsManagerMock: ChannelConfigEventsManager {
    
    var observeConfigParameters: [Int32] = []
    var observeConfigReturns: [Observable<ChannelConfigEvent>] = [Observable.empty()]
    var observeConfigReturnsIdx = 0
    func observeConfig(id: Int32) -> Observable<ChannelConfigEvent> {
        observeConfigParameters.append(id)
        
        if (observeConfigReturnsIdx >= observeConfigReturns.count) {
            return .empty()
        }
        
        let toReturn = observeConfigReturns[observeConfigReturnsIdx]
        observeConfigReturnsIdx += 1
        return toReturn
    }
    
    var emitConfigParameters: [(UInt8, TSCS_ChannelConfig, Int64)] = []
    func emitConfig(result: UInt8, config: TSCS_ChannelConfig, crc32: Int64) {
        emitConfigParameters.append((result, config, crc32))
    }
}
