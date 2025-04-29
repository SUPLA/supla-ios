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

extension CarPlayListFeature {
    class ViewState: ObservableObject {
        @Published var playMessages: Bool = false
        @Published var items: [ReadCarPlayItems.Item] = []
    }
}

extension Action {
    func carPlayAction(function: SuplaFunction? = nil) -> CarPlayAction? {
        switch (self) {
        case .open: .open
        case .close: .close
        case .shut:
            function == .projectorScreen || function == .rollerGarageDoor ? .collapse : .shut
        case .reveal:
            function == .projectorScreen || function == .rollerGarageDoor ? .expand : .reveal
        case .turnOn: .turnOn
        case .turnOff: .turnOff
        case .revealPartially: nil
        case .shutPartially: nil
        case .setRgbwParameters: nil
        case .openClose: .openClose
        case .stop: .stop
        case .toggle: .toggle
        case .upOrStop: nil
        case .downOrStop: nil
        case .stepByStep: nil
        case .up: nil
        case .down: nil
        case .setHvacParameters: nil
        case .execute: .execute
        case .interrupt: .interrupt
        case .interruptAndExecute: .interruptAndExecute
        }
    }
}
