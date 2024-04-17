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

final class ChannelGroupRelationRepositoryMock: BaseRepositoryMock<SAChannelGroupRelation>, ChannelGroupRelationRepository {
    
    var getAllRelationsParameters: [AuthProfileItem] = []
    var getAllRelationsReturns: Observable<[SAChannelGroupRelation]> = .empty()
    func getAllRelations(for profile: AuthProfileItem) -> Observable<[SAChannelGroupRelation]> {
        getAllRelationsParameters.append(profile)
        return getAllRelationsReturns
    }
    
    var getRelationParameters: [(AuthProfileItem, Int32, Int32)] = []
    var getRelationReturns: Observable<SAChannelGroupRelation> = .empty()
    func getRelation(for profile: AuthProfileItem, groupId: Int32, channelId: Int32) -> Observable<SAChannelGroupRelation> {
        getRelationParameters.append((profile, groupId, channelId))
        return getRelationReturns
    }
    
    var getRelationsParameters: [(AuthProfileItem, Int32)] = []
    var getRelationsReturns: Observable<[SAChannelGroupRelation]> = .empty()
    func getRelations(for profile: AuthProfileItem, andGroup id: Int32) -> Observable<[SAChannelGroupRelation]> {
        getRelationsParameters.append((profile, id))
        return getRelationsReturns
    }
    
    var getAllVisibleRelationsForActiveProfileCalls = 0
    var getAllVisibleRelationsForActiveProfileReturns: Observable<[SAChannelGroupRelation]> = .empty()
    func getAllVisibleRelationsForActiveProfile() -> Observable<[SAChannelGroupRelation]> {
        getAllVisibleRelationsForActiveProfileCalls += 1
        return getAllVisibleRelationsForActiveProfileReturns
    }
}
