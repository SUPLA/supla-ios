//
//  ActionParameters.swift
//  SUPLA
//
//  Created by Michał Polański on 22/03/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

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
