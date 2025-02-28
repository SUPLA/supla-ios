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

import RxRelay
import RxSwift

protocol DownloadEventsManager {
    func emitProgressState(remoteId: Int32, state: DownloadEventsManagerState)
    func observeProgress(remoteId: Int32) -> Observable<DownloadEventsManagerState>
    
    func emitProgressState(remoteId: Int32, dataType: DownloadEventsManagerDataType, state: DownloadEventsManagerState)
    func observeProgress(remoteId: Int32, dataType: DownloadEventsManagerDataType) -> Observable<DownloadEventsManagerState>
}

final class DownloadEventsManagerImpl: DownloadEventsManager {
    private var subjects: [Id: BehaviorRelay<DownloadEventsManagerState>] = [:]
    private let syncedQueue = DispatchQueue(label: "DownloadEventsPrivateQueue", attributes: .concurrent)
    
    func emitProgressState(remoteId: Int32, state: DownloadEventsManagerState) {
        getSubject(remoteId: remoteId, dataType: .default).accept(state)
    }

    func observeProgress(remoteId: Int32) -> Observable<DownloadEventsManagerState> {
        return getSubject(remoteId: remoteId, dataType: .default).asObservable()
    }

    func emitProgressState(remoteId: Int32, dataType: DownloadEventsManagerDataType, state: DownloadEventsManagerState) {
        getSubject(remoteId: remoteId, dataType: dataType).accept(state)
    }

    func observeProgress(remoteId: Int32, dataType: DownloadEventsManagerDataType) -> Observable<DownloadEventsManagerState> {
        return getSubject(remoteId: remoteId, dataType: dataType).asObservable()
    }

    private func getSubject(remoteId: Int32, dataType: DownloadEventsManagerDataType) -> BehaviorRelay<DownloadEventsManagerState> {
        let id = Id(id: remoteId, dataType: dataType)
        return syncedQueue.sync {
            if let subject = subjects[id] {
                return subject
            }

            let subject = BehaviorRelay(value: DownloadEventsManagerState.idle)
            subjects[id] = subject
            return subject
        }
    }
}

enum DownloadEventsManagerState: Equatable {
    case idle
    case started
    case inProgress(progress: Float)
    case failed
    case finished
    case refresh

    var order: Int {
        switch (self) {
        case .idle: 1
        case .started: 2
        case .inProgress: 3
        case .failed: 4
        case .finished: 5
        case .refresh: 6
        }
    }

    func isInProgress() -> Bool {
        switch (self) {
        case .inProgress: true
        default: false
        }
    }

    func getProgress() -> Float {
        switch (self) {
        case .inProgress(let progress): progress
        default: -1
        }
    }
}

enum DownloadEventsManagerDataType {
    case `default`
    case electricityCurrent
    case electricityVoltage
    case electricityPowerActive
}

private struct Id: Hashable {
    let id: Int32
    let dataType: DownloadEventsManagerDataType
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(dataType)
    }
}
