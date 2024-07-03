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

import SwiftUI

extension StatusFeature {
    class ViewState: ObservableObject {
        @Published var stateText: StateText = .initializing
        @Published var viewType: viewType = .connecting
        @Published var errorDescription: String? = nil
    }

    enum StateText {
        case initializing, connecting, disconnecting, awaitingNetwork

        var text: String {
            switch (self) {
            case .initializing: Strings.Status.initializing
            case .connecting: Strings.Status.connecting
            case .disconnecting: Strings.Status.disconnecting
            case .awaitingNetwork: Strings.Status.awaitingNetwork
            }
        }

        var showAccountButton: Bool {
            switch (self) {
            case .initializing, .disconnecting: false
            case .connecting, .awaitingNetwork: true
            }
        }
    }
    
    enum viewType {
        case connecting
        case error
    }
}
