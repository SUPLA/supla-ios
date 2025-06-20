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

let VALUE_IGNORE = -1

public enum Action: Int32, Equatable, CaseIterable, Codable, Sendable {
    case open = 10
    case close = 20
    case shut = 30
    case reveal = 40
    case revealPartially = 50
    case shutPartially = 51
    case turnOn = 60
    case turnOff = 70
    case setRgbwParameters = 80
    case openClose = 90
    case stop = 100
    case toggle = 110
    case upOrStop = 140
    case downOrStop = 150
    case stepByStep = 160
    case up = 170
    case down = 180
    case setHvacParameters = 230
    case execute = 3000
    case interrupt = 3001
    case interruptAndExecute = 3002
}

public enum ActionParameters {
    case simple(action: Action, subjectType: SubjectType, subjectId: Int32)
    case rgbw(
        action: Action,
        subjectType: SubjectType,
        subjectId: Int32,
        brightness: Int8,
        colorBrightness: Int8,
        color: UInt32,
        colorRandom: Bool,
        onOff: Bool
    )
    case rollerShutter(
        action: Action,
        subjectType: SubjectType,
        subjectId: Int32,
        percentage: Int8,
        delta: Bool
    )
    case facadeBlind(
        action: Action,
        subjectType: SubjectType,
        subjectId: Int32,
        percentage: Int8,
        tilt: Int8,
        percentageAsDelta: Bool,
        tiltAsDelta: Bool
    )
    case hvac(
        subjectType: SubjectType,
        subjectId: Int32,
        durationInSec: Int32?,
        mode: SuplaHvacMode?,
        setpointTemperatureHeat: Float?,
        setpointTemperatureCool: Float?
    )
}


extension Action {
    func state(_ function: Int32) -> ChannelState {
        switch (self) {
        case .open: .opened
        case .close: .closed
        case .shut: .closed
        case .reveal: .opened
        case .revealPartially: .opened
        case .shutPartially: .closed
        case .turnOn:
            if (function == SuplaFunction.dimmerAndRgbLighting.value) {
                .complex([.on, .on])
            } else {
                .on
            }
        case .turnOff:
            if (function == SuplaFunction.dimmerAndRgbLighting.value) {
                .complex([.off, .off])
            } else {
                .off
            }
        case .setRgbwParameters: .complex([.on, .on])
        case .openClose: .opened
        case .stop: .notUsed
        case .toggle: .on
        case .upOrStop: .opened
        case .downOrStop: .closed
        case .stepByStep: .opened
        case .up: .opened
        case .down: .closed
        case .setHvacParameters: .on
        case .execute: .notUsed
        case .interrupt: .notUsed
        case .interruptAndExecute: .notUsed
        }
    }
}
