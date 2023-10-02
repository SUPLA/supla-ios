//
//  ChannelRelationRepositoryMock.swift
//  SUPLATests
//
//  Created by Michał Polański on 19/09/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import RxSwift

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
    
    
}
