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

final class ChannelValueRepositoryMock: BaseRepositoryMock<SAChannelValue>, ChannelValueRepository {
    
    var channelValueObservable: Observable<SAChannelValue> = Observable.empty()
    func getChannelValue(for profile: AuthProfileItem, with remoteId: Int32) -> Observable<SAChannelValue> {
        channelValueObservable
    }
    
    var deleteAllObservable: Observable<Void> = Observable.empty()
    var deleteAllCounter = 0
    func deleteAll(for profile: AuthProfileItem) -> Observable<Void> {
        deleteAllCounter += 1
        return deleteAllObservable
    }
    
    func deleteSync(_ remoteId: Int32, _ profile: AuthProfileItem) {
    }
}
