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

final class ChannelConfigRepositoryMock: BaseRepositoryMock<SAChannelConfig>, ChannelConfigRepository {
    
    var deleteAllParameters: [(SAChannel, AuthProfileItem)] = []
    var deleteAllReturns: Observable<Void> = .empty()
    func deleteAllFor(channel: SAChannel, profile: AuthProfileItem) -> Observable<Void> {
        deleteAllParameters.append((channel, profile))
        return deleteAllReturns
    }
    
    var deleteAllForProfileParameters: [AuthProfileItem] = []
    var deleteAllForProfileReturns: Observable<Void> = .empty()
    func deleteAllFor(profile: AuthProfileItem) -> Observable<Void> {
        deleteAllForProfileParameters.append(profile)
        return deleteAllForProfileReturns
    }
    
    var getConfigParameters: [Int32] = []
    var getConfigReturns: Observable<SAChannelConfig?> = .empty()
    var getConfigReturnsMap: [Int32: Observable<SAChannelConfig?>] = [:]
    func getConfig(channelRemoteId: Int32) -> Observable<SAChannelConfig?> {
        getConfigParameters.append(channelRemoteId)
        
        if (getConfigReturnsMap.isEmpty) {
            return getConfigReturns
        }
        
        return getConfigReturnsMap[channelRemoteId]!
    }
    
}
