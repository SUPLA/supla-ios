//
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
    
enum SuplaAppState: Equatable {
    case initialization
    case locked
    case firstProfileCreation
    case connecting(reason: Reason? = nil)
    case connected
    case disconnecting
    case locking
    case finished(reason: Reason? = nil)
    
    enum Reason: Equatable {
        case connectionError(code: Int32)
        case registerError(code: Int32)
        case versionError
        case noNetwork
        case appInBackground
        
        var shouldAuthorize: Bool {
            switch (self) {
            case .registerError(let code):
                code == SUPLA_RESULTCODE_REGISTRATION_DISABLED || code == SUPLA_RESULTCODE_ACCESSID_NOT_ASSIGNED
            default: false
            }
        }
    }
    
    func nextState(event: SuplaAppEvent) -> SuplaAppState? {
        switch (self) {
        case .initialization: initializationNextState(for: event)
        case .locked: lockedNextState(for: event)
        case .firstProfileCreation: firstProfileCreationNextState(for: event)
        case .connecting(let reason): connectingNextState(for: event, previousReason: reason)
        case .connected: connectedNextState(for: event)
        case .disconnecting: disconnectingNextState(for: event)
        case .locking: lockingNextState(for: event)
        case .finished(let reason): finishedNextState(for: event, previousReason: reason)
        }
    }
    
    private func initializationNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .networkConnected: nil
        case .lock: .locked
        case .initialized: .connecting()
        case .noAccount: .firstProfileCreation
        default: fatalError("Unexpected event in Initialization: \(event)")
        }
    }
    
    private func lockedNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .lock, .onStart, .networkConnected, .finish: nil
        case .unlock: .connecting()
        case .noAccount: .firstProfileCreation
        default: fatalError("Unexpected event in Locked: \(event)")
        }
    }
    
    private func firstProfileCreationNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .networkConnected: nil
        case .connecting: .connecting()
        default: fatalError("Unexpected event in FirstProfileCreation: \(event)")
        }
    }
    
    private func connectingNextState(for event: SuplaAppEvent, previousReason: Reason?) -> SuplaAppState? {
        switch (event) {
        case .connecting, .initialized, .onStart: nil
        case .connected: .connected
        case .lock: .locked
        case .cancel: .disconnecting
        case .networkConnected: .connecting()
        case .error(let reason): .connecting(reason: reason)
        case .finish(let reason): .finished(reason: reason == nil ? previousReason : reason)
        default: fatalError("Unexpected event in Connecting: \(event)")
        }
    }
    
    private func connectedNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .networkConnected: nil
        case .connecting: .connecting()
        case .lock: .locked
        case .cancel: .disconnecting
        case .finish(let reason): .finished(reason: reason)
        case .error(let reason): .finished(reason: reason)
        default: fatalError("Unexpected event in Connected: \(event)")
        }
    }
    
    private func disconnectingNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .cancel, .networkConnected, .connecting, .connected: nil
        case .lock: .locking
        case .finish(let reason): .finished(reason: reason)
        case .error(let reason): .finished(reason: reason)
        default: fatalError("Unexpected event in Disconnecting: \(event)")
        }
    }
    
    private func lockingNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .lock, .cancel, .networkConnected: nil
        case .finish(_): .locked
        default: fatalError("Unexpected event in Locking: \(event)")
        }
    }
    
    private func finishedNextState(for event: SuplaAppEvent, previousReason: Reason?) -> SuplaAppState? {
        switch (event) {
        case .cancel, .networkConnected: nil
        case .initialized, .connecting: .connecting()
        case .lock: .locked
        case .onStart: previousReason == .noNetwork ? .connecting(reason: previousReason) : .connecting()
        case .noAccount: .firstProfileCreation
        case .error(let reason): reason != previousReason ? .finished(reason: reason) : nil
        case .finish(let reason): reason != previousReason ? .finished(reason: reason ?? previousReason) : nil
        default: fatalError("Unexpected event in Finished: \(event)")
        }
    }
}
