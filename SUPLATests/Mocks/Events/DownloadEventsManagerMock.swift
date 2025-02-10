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

@testable import SUPLA
import RxSwift

final class DownloadEventsManagerMock: DownloadEventsManager {
    
    var emitProgressStateParameters: [(Int32, DownloadEventsManagerState)] = []
    func emitProgressState(remoteId: Int32, state: DownloadEventsManagerState) {
        emitProgressStateParameters.append((remoteId, state))
    }
    
    var observeProgressParameters: [Int32] = []
    var observeProgressReturns: Observable<DownloadEventsManagerState> = Observable.empty()
    func observeProgress(remoteId: Int32) -> Observable<DownloadEventsManagerState> {
        observeProgressParameters.append(remoteId)
        return observeProgressReturns
    }
    
    var emitProgressStateMock: FunctionMock<(Int32, SUPLA.DownloadEventsManagerDataType, SUPLA.DownloadEventsManagerState), Void> = .init()
    func emitProgressState(remoteId: Int32, dataType: SUPLA.DownloadEventsManagerDataType, state: SUPLA.DownloadEventsManagerState) {
        emitProgressStateMock.set((remoteId, dataType, state))
    }
    
    var observeProgressMock: FunctionMock<(Int32, SUPLA.DownloadEventsManagerDataType), Observable<SUPLA.DownloadEventsManagerState>> = .init()
    func observeProgress(remoteId: Int32, dataType: SUPLA.DownloadEventsManagerDataType) -> Observable<SUPLA.DownloadEventsManagerState> {
        observeProgressMock.handle((remoteId, dataType))
    }
}
