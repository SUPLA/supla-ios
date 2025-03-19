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
import SharedCore

@testable import SUPLA

final class ChannelRelationRepositoryMock: BaseRepositoryMock<SAChannelRelation>, ChannelRelationRepository {
    
    var getRelationParameters: [(AuthProfileItem, Int32, Int32, ChannelRelationType)] = []
    var getRelationReturns: Observable<SAChannelRelation> = Observable.empty()
    func getRelation(for profile: AuthProfileItem, with channelId: Int32, with parentId: Int32, and relationType: ChannelRelationType) -> Observable<SAChannelRelation> {
        getRelationParameters.append((profile, channelId, parentId, relationType))
        return getRelationReturns
    }
    
    var getAllRelationsParameters: [(AuthProfileItem)] = []
    var getAllRelationsReturns: Observable<[SAChannelRelation]> = Observable.empty()
    func getAllRelations(for profile: AuthProfileItem) -> Observable<[SAChannelRelation]> {
        getAllRelationsParameters.append(profile)
        return getAllRelationsReturns
    }
    
    var getAllRelationsWithParentParameters: [(AuthProfileItem, Int32)] = []
    var getAllRelationsWithParentReturns: Observable<[SAChannelRelation]> = Observable.empty()
    func getAllRelations(for profile: AuthProfileItem, with parentId: Int32) -> Observable<[SAChannelRelation]> {
        getAllRelationsWithParentParameters.append((profile, parentId))
        return getAllRelationsWithParentReturns
    }
    
    var deleteRemovableRelationsParameters: [(AuthProfileItem)] = []
    var deleteRemovableRelationsReturns: Observable<Void> = Observable.empty()
    func deleteRemovableRelations(for profile: AuthProfileItem) -> RxSwift.Observable<Void> {
        deleteRemovableRelationsParameters.append(profile)
        return deleteRemovableRelationsReturns
    }
    
    var getParentsMapParameters: [(AuthProfileItem)] = []
    var getParentsMapReturns: Observable<[Int32 : [SAChannelRelation]]> = Observable.empty()
    func getParentsMap(for profile: AuthProfileItem) -> Observable<[Int32 : [SAChannelRelation]]> {
        getParentsMapParameters.append(profile)
        return getParentsMapReturns
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
    }
}
