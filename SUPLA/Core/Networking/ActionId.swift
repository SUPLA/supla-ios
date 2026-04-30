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

import SharedCore

public enum ActionId: Equatable, CaseIterable, Codable, Sendable, ScopeFunctions {
    typealias T = ActionId
    
    case none
    case open
    case close
    case shut
    case reveal
    case collapse
    case expand
    case revealPartially
    case shutPartially
    case turnOn
    case turnOff
    case setRgbwParameters
    case openClose
    case stop
    case toggle
    case upOrStop
    case downOrStop
    case stepByStep
    case up
    case down
    case setHvacParameters
    case execute
    case interrupt
    case interruptAndExecute

    static func from(_ value: Int32) -> ActionId {
        ActionId.allCases.first(where: { $0.value == value }) ?? .none
    }
    
    static func from(carPlayId id: Int32) -> ActionId {
        ActionId.allCases.first(where: { $0.carPlayId == id }) ?? .none
    }
}

extension ActionId {
    var value: Int32 {
        switch (self) {
        case .none: 0
        case .open: 10
        case .close: 20
        case .shut: 30
        case .reveal: 40
        case .collapse: 30
        case .expand: 40
        case .revealPartially: 50
        case .shutPartially: 51
        case .turnOn: 60
        case .turnOff: 70
        case .setRgbwParameters: 80
        case .openClose: 90
        case .stop: 100
        case .toggle: 110
        case .upOrStop: 140
        case .downOrStop: 150
        case .stepByStep: 160
        case .up: 170
        case .down: 180
        case .setHvacParameters: 230
        case .execute: 3000
        case .interrupt: 3001
        case .interruptAndExecute: 302
        }
    }
}

extension ActionId {
    var name: String? {
        switch (self) {
        case .none: nil
        case .open: Strings.General.open
        case .close: Strings.General.close
        case .shut: Strings.General.shut
        case .reveal: Strings.General.reveal
        case .collapse: Strings.General.collapse
        case .expand: Strings.General.expand
        case .revealPartially: Strings.General.reveal
        case .shutPartially: Strings.General.shut
        case .turnOn: Strings.General.turnOn
        case .turnOff: Strings.General.turnOff
        case .setRgbwParameters: nil
        case .openClose: Strings.General.openClose
        case .stop: Strings.General.stop
        case .toggle: Strings.General.toggle
        case .upOrStop: Strings.General.reveal
        case .downOrStop: Strings.General.shut
        case .stepByStep: Strings.General.stepByStep
        case .up: Strings.General.reveal
        case .down: Strings.General.shut
        case .setHvacParameters: nil
        case .execute: Strings.Scenes.ActionButtons.execute
        case .interrupt: Strings.Scenes.ActionButtons.abort
        case .interruptAndExecute: Strings.Scenes.ActionButtons.abortAndExecute
        }
    }
}

extension ActionId {
    func state(_ function: Int32) -> ChannelState {
        switch (self) {
        case .none: .default(value: .notUsed)
        case .open: .default(value: .opened)
        case .close: .default(value: .closed)
        case .shut: .default(value: .closed)
        case .reveal: .default(value: .opened)
        case .collapse: .default(value: .closed)
        case .expand: .default(value: .opened)
        case .revealPartially: .default(value: .opened)
        case .shutPartially: .default(value: .closed)
        case .turnOn:
            if (function == SuplaFunction.dimmerAndRgbLighting.value) {
                .rgbAndDimmer(dimmer: .on, rgb: .on)
            } else {
                .default(value: .on)
            }
        case .turnOff:
            if (function == SuplaFunction.dimmerAndRgbLighting.value) {
                .rgbAndDimmer(dimmer: .off, rgb: .off)
            } else {
                .default(value: .off)
            }
        case .setRgbwParameters: .rgbAndDimmer(dimmer: .on, rgb: .on)
        case .openClose: .default(value: .opened)
        case .stop: .default(value: .notUsed)
        case .toggle: .default(value: .on)
        case .upOrStop: .default(value: .opened)
        case .downOrStop: .default(value: .closed)
        case .stepByStep: .default(value: .opened)
        case .up: .default(value: .opened)
        case .down: .default(value: .closed)
        case .setHvacParameters: .default(value: .on)
        case .execute: .default(value: .notUsed)
        case .interrupt: .default(value: .notUsed)
        case .interruptAndExecute: .default(value: .notUsed)
        }
    }
}

extension ActionId {
    var carPlayId: Int32 {
        switch (self) {
        case .none: 0
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
        
        // Below are not supported
        case .revealPartially: 15
        case .shutPartially: 16
        case .setRgbwParameters: 17
        case .upOrStop: 18
        case .downOrStop: 19
        case .stepByStep: 20
        case .up: 21
        case .down: 22
        case .setHvacParameters: 23
        }
    }
}
