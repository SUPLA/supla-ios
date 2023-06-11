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

final class GroupRepositoryMock: BaseRepositoryMock<SAChannelGroup>, GroupRepository {
    
    var allVisibleGroupsObservable: Observable<[SAChannelGroup]> = Observable.empty()
    var allVisibleGroupsProfilesArray: [AuthProfileItem] = []
    
    func getAllVisibleGroups(forProfile profile: AuthProfileItem) -> Observable<[SAChannelGroup]> {
        allVisibleGroupsProfilesArray.append(profile)
        return allVisibleGroupsObservable
    }
    
    var allVisibleGroupsInLocationObservable: Observable<[SAChannelGroup]> = Observable.empty()
    var allVisibleGroupsInLocationProfiles: [AuthProfileItem] = []
    var allVisibleGroupsInLocationCaptions: [String] = []
    
    func getAllVisibleGroups(forProfile profile: AuthProfileItem, inLocation locationCaption: String) -> Observable<[SAChannelGroup]> {
        allVisibleGroupsInLocationProfiles.append(profile)
        allVisibleGroupsInLocationCaptions.append(locationCaption)
        return allVisibleGroupsInLocationObservable
    }
    
    var allGroupsObservable: Observable<[SAChannelGroup]> = Observable.empty()
    
    func getAllGroups(forProfile profile: AuthProfileItem) -> Observable<[SAChannelGroup]> {
        allGroupsObservable
    }
    
    var groupObservable: Observable<SAChannelGroup> = Observable.empty()
    
    func getGroup(remoteId: Int) -> Observable<SAChannelGroup> {
        groupObservable
    }
    
    var deleteAllObservable: Observable<Void> = Observable.empty()
    var deleteAllCounter = 0
    
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAllCounter += 1
        return deleteAllObservable
    }
    
}
