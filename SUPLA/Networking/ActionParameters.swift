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

import Foundation

public enum SubjectType: Int32 {
    case channel = 1
    case group = 2
    case scene = 3
}

public enum Action: Int32 {
    case open = 10
    case close = 20
    case shut = 30
    case reveal = 40
    case reveal_partially = 50
    case shut_partially = 51
    case turn_on = 60
    case turn_off = 70
    case set_rgbw_parameters = 80
    case open_close = 90
    case stop = 100
    case toggle = 110
    case up_or_stop = 140
    case down_or_stop = 150
    case step_by_step = 160
    case execute = 3000
    case interrupt = 3001
    case interrupt_and_execute = 3002
}

public enum ActionParameters {
    case simple(action: Action, subjectType: SubjectType, subjectId: Int32)
    case rgbw(action: Action, subjectType: SubjectType, subjectId: Int32, brightness: Int8, colorBrightness: Int8, color: UInt32, colorRandom: Bool, onOff: Bool)
    case rollerShutter(action: Action, subjectType: SubjectType, subjectId: Int32, percentage: Int8, delta: Bool)
}
