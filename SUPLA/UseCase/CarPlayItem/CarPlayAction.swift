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

enum CarPlayAction: CaseIterable, Codable, Sendable {
    case open
    case close
    case shut
    case reveal
    case collapse
    case expand
    case turnOn
    case turnOff
    case openClose
    case stop
    case toggle
    case execute
    case interrupt
    case interruptAndExecute

    var id: Int32 {
        switch (self) {
        case .open: 1
        case .close: 2
        case .shut: 3
        case .reveal: 4
        case .collapse: 5
        case .expand: 6
        case .turnOn: 7
        case .turnOff: 8
        case .openClose: 9
        case .stop: 10
        case .toggle: 11
        case .execute: 12
        case .interrupt: 13
        case .interruptAndExecute: 14
        }
    }

    var name: String {
        switch (self) {
        case .open: Strings.General.open
        case .close: Strings.General.close
        case .shut: Strings.General.shut
        case .reveal: Strings.General.reveal
        case .collapse: Strings.General.collapse
        case .expand: Strings.General.expand
        case .turnOn: Strings.General.turnOn
        case .turnOff: Strings.General.turnOff
        case .openClose: Strings.General.openClose
        case .stop: Strings.General.stop
        case .toggle: Strings.General.toggle
        case .execute: Strings.Scenes.ActionButtons.execute
        case .interrupt: Strings.Scenes.ActionButtons.abort
        case .interruptAndExecute: Strings.Scenes.ActionButtons.abortAndExecute
        }
    }

    var label: String { name }

    var action: Action {
        switch (self) {
        case .open: .open
        case .close: .close
        case .shut: .shut
        case .reveal: .reveal
        case .collapse: .shutPartially
        case .expand: .revealPartially
        case .turnOn: .turnOn
        case .turnOff: .turnOff
        case .openClose: .openClose
        case .stop: .stop
        case .toggle: .toggle
        case .execute: .execute
        case .interrupt: .interrupt
        case .interruptAndExecute: .interruptAndExecute
        }
    }

    static func from(id: Int32) -> CarPlayAction {
        for action in allCases {
            if (action.id == id) {
                return action
            }
        }

        fatalError("Action for id \(id) not found")
    }
}
