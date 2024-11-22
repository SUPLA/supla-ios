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

final class ChannelRepositoryMock: BaseRepositoryMock<SAChannel>, ChannelRepository {
    
    var allVisibleChannelsObservable: Observable<[SAChannel]> = Observable.empty()
    func getAllVisibleChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]> {
        return allVisibleChannelsObservable
    }
    
    var allChannelsObservable: Observable<[SAChannel]> = Observable.empty()
    func getAllChannels(forProfile profile: AuthProfileItem) -> Observable<[SAChannel]> {
        return allChannelsObservable
    }
    
    var channelProfiles: [AuthProfileItem] = []
    var channelRemoteIds: [Int32] = []
    var channelObservable: Observable<SAChannel> = Observable.empty()
    func getChannel(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannel> {
        channelProfiles.append(profile)
        channelRemoteIds.append(remoteId)
        return channelObservable
    }
    
    var getChannelNullableMock: FunctionMock<(AuthProfileItem, Int32), Observable<SAChannel?>> = .init()
    func getChannelNullable(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannel?> {
        getChannelNullableMock.handle((profile, remoteId))
    }
    
    var getAllChannelsParameters: [(AuthProfileItem, [Int32])] = []
    var getAllChannelsReturns: Observable<[SAChannel]> = Observable.empty()
    func getAllChannels(forProfile profile: AuthProfileItem, with ids: [Int32]) -> Observable<[SAChannel]> {
        getAllChannelsParameters.append((profile, ids))
        return getAllChannelsReturns
    }
    
    var deleteAllObservable: Observable<Void> = Observable.empty()
    var deleteAllCounter = 0
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAllCounter += 1
        return deleteAllObservable
    }
    
    var allVisibleChannelsInLocationObservable: Observable<[SAChannel]> = Observable.empty()
    var allVisibleChannelsInLocationProfiles: [AuthProfileItem] = []
    var allVisibleChannelsInLocationCaptions: [String] = []
    func getAllVisibleChannels(forProfile profile: AuthProfileItem, inLocation locationCaption: String) -> Observable<[SAChannel]> {
        allVisibleChannelsInLocationProfiles.append(profile)
        allVisibleChannelsInLocationCaptions.append(locationCaption)
        return allVisibleChannelsInLocationObservable
    }
    
    func getAllIconIds(for profile: AuthProfileItem) -> Observable<[Int32]> {
        Observable.empty()
    }
}
