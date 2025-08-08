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
    
extension View {
    func onSubmitCompat(_ action: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.onSubmit { action() }
        } else {
            return self
        }
    }
    
    func submitLabelCompat(_ label: SubmitLabelCompat) -> some View {
        if #available(iOS 15.0, *) {
            return self.submitLabel(label.label)
        } else {
            return self
        }
    }
}

enum SubmitLabelCompat : Sendable {

    case done, go, send, join, route, search, `return`, next, `continue`
    
    @available(iOS 15.0, *)
    var label: SubmitLabel {
        switch self {
        case .done: .done
        case .go: .go
        case .send: .send
        case .join: .join
        case .route: .route
        case .search: .search
        case .return: .return
        case .next: .next
        case .continue: .continue
        }
    }
}
