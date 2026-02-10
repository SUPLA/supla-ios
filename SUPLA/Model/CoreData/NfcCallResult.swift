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
    
enum NfcCallResult: Int32 {
    case success = 1
    case failure = 2
    case actionMissing = 3
    case tagAdded = 4
    
    var iconText: String {
        switch (self) {
        case .success: "✓"
        case .failure,
             .actionMissing: "✕"
        case .tagAdded: "✦"
        }
    }

    var iconColor: Color {
        switch (self) {
        case .success: .Supla.primary
        case .failure,
             .actionMissing: .Supla.error
        case .tagAdded: .Supla.secondary
        }
    }

    var text: String {
        switch (self) {
        case .success: Strings.Nfc.Detail.actionCompleted
        case .failure: Strings.Nfc.Detail.actionFailure
        case .actionMissing: Strings.Nfc.Detail.actionMissing
        case .tagAdded: Strings.Nfc.Detail.actionAdded
        }
    }
    
    static func from(value: Int32) -> NfcCallResult {
        switch(value) {
        case 1: .success
        case 3: .actionMissing
        case 4: .tagAdded
        default: .failure
        }
    }
}
