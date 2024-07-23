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
    
    enum Error: Swift.Error {
        case illegalEvent(message: String)
    }
    
    func nextState(event: SuplaAppEvent) -> SuplaAppState? {
        switch (self) {
        case .initialization: initializationNextState(for: event)
        case .locked: lockedNextState(for: event)
        case .firstProfileCreation: firstProfileCreationNextState(for: event)
        case .connecting(let reason): connectingNextState(for: event, previousReason: reason)
        case .connected: try! connectedNextState(for: event)
        case .disconnecting: disconnectingNextState(for: event)
        case .locking: lockingNextState(for: event)
        case .finished(let reason): finishedNextState(for: event, previousReason: reason)
        }
    }
    
    private func initializationNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .networkConnected, .finish: nil
        case .lock: .locked
        case .initialized: .connecting()
        case .noAccount: .firstProfileCreation
        case .connecting: try! illegalConnectingEvent()
        case .connected: try! illegalConnectedEvent()
        case .cancel: try! illegalCancelEvent()
        case .unlock: try! illegalUnlockEvent()
        case .error: try! illegalErrorEvent()
        }
    }
    
    private func lockedNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .lock, .onStart, .networkConnected, .finish: nil
        case .unlock: .connecting()
        case .noAccount: .firstProfileCreation
        case .initialized: try! illegalInitializedEvent()
        case .connecting: try! illegalConnectingEvent()
        case .connected: try! illegalConnectedEvent()
        case .cancel: try! illegalCancelEvent()
        case .error: try! illegalErrorEvent()
        }
    }
    
    private func firstProfileCreationNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .networkConnected, .finish: nil
        case .connecting: .connecting()
        case .connected: try! illegalConnectedEvent()
        case .cancel: try! illegalCancelEvent()
        case .unlock: try! illegalUnlockEvent()
        case .error: try! illegalErrorEvent()
        case .initialized: try! illegalInitializedEvent()
        case .noAccount: try! illegalNoAccountEvent()
        case .lock: try! illegalLockEvent()
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
        case .noAccount: try! illegalNoAccountEvent()
        case .unlock: try! illegalUnlockEvent()
        }
    }
    
    private func connectedNextState(for event: SuplaAppEvent) throws -> SuplaAppState? {
        switch (event) {
        case .onStart, .networkConnected: nil
        case .connecting: .connecting()
        case .lock: .locked
        case .cancel: .disconnecting
        case .finish(let reason): .finished(reason: reason)
        case .error(let reason): .finished(reason: reason)
        case .initialized: try! illegalInitializedEvent()
        case .noAccount: try! illegalNoAccountEvent()
        case .connected: try! illegalConnectedEvent()
        case .unlock: try! illegalUnlockEvent()
        }
    }
    
    private func disconnectingNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .cancel, .networkConnected, .connecting, .connected: nil
        case .lock: .locking
        case .finish(let reason): .finished(reason: reason)
        case .error(let reason): .finished(reason: reason)
        case .initialized: try! illegalInitializedEvent()
        case .noAccount: try! illegalNoAccountEvent()
        case .unlock: try! illegalUnlockEvent()
        }
    }
    
    private func lockingNextState(for event: SuplaAppEvent) -> SuplaAppState? {
        switch (event) {
        case .onStart, .lock, .cancel, .networkConnected: nil
        case .finish: .locked
        case .initialized: try! illegalInitializedEvent()
        case .noAccount: try! illegalNoAccountEvent()
        case .connected: try! illegalConnectedEvent()
        case .unlock: try! illegalUnlockEvent()
        case .connecting: try! illegalConnectingEvent()
        case .error(_): try! illegalErrorEvent()
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
        case .connected: try! illegalConnectedEvent()
        case .unlock: try! illegalUnlockEvent()
        }
    }
    
    private func illegalInitializedEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected initialized event!")
    }
    
    private func illegalConnectingEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected connecting event!")
    }
    
    private func illegalConnectedEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected connected event!")
    }
    
    private func illegalCancelEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected cancel event!")
    }
    
    private func illegalErrorEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected error event!")
    }
    
    private func illegalUnlockEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected unlock event!")
    }
    
    private func illegalFinishEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected finish event!")
    }
    
    private func illegalNoAccountEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected no account event!")
    }
    
    private func illegalLockEvent() throws -> SuplaAppState? {
        throw Error.illegalEvent(message: "Unexpected lock event!")
    }
}
