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
}

final class DownloadEventsManagerImpl: DownloadEventsManager {
    
    private var subjects: [Int32: BehaviorRelay<DownloadEventsManagerState>] = [:]
    private let syncedQueue = DispatchQueue(label: "DownloadEventsPrivateQueue", attributes: .concurrent)
    
    func emitProgressState(remoteId: Int32, state: DownloadEventsManagerState) {
        getSubject(id: remoteId).accept(state)
    }
    
    func observeProgress(remoteId: Int32) -> Observable<DownloadEventsManagerState> {
        return getSubject(id: remoteId).asObservable()
    }
    
    private func getSubject(id: Int32) -> BehaviorRelay<DownloadEventsManagerState> {
        return syncedQueue.sync(execute: {
            if let subject = subjects[id] {
                return subject
            }
            
            let subject = BehaviorRelay(value: DownloadEventsManagerState.idle)
            subjects[id] = subject
            return subject
        })
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
        get {
            switch(self) {
            case .idle: 1
            case .started: 2
            case .inProgress(_): 3
            case .failed: 4
            case .finished: 5
            case .refresh: 6
            }
        }
    }
    
    func isInProgress() -> Bool {
        switch (self) {
        case .inProgress(_): true
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
