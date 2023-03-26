//
//  SuplaClientActionExtension.swift
//  SUPLA
//
//  Created by Michał Polański on 22/03/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import Foundation

extension SASuplaClient {
    public func executeAction(parameters: ActionParameters) -> Bool {
        switch parameters {
        case let .simple(action, subjectType, subjectId):
            return executeAction(action.rawValue, subjecType: subjectType.rawValue, subjectId: subjectId, rsParameters: nil, rgbwParameters: nil)
        case let .rgbw(action, subjectType, subjectId, brightness, colorBrightness, color, colorRandom, onOff):
            var parameters = TAction_RGBW_Parameters()
            parameters.Brightness = brightness
            parameters.ColorBrightness = colorBrightness
            parameters.Color = color
            parameters.ColorRandom = colorRandom ? 1 : 0
            parameters.OnOff = onOff ? 1 : 0
            return executeAction(action.rawValue, subjecType: subjectType.rawValue, subjectId: subjectId, rsParameters: nil, rgbwParameters: &parameters)
        case let .rollerShutter(action, subjectType, subjectId, percentage, delta):
            var parameters = TAction_RS_Parameters()
            parameters.Percentage = percentage
            parameters.Delta = delta ? 1 : 0
            return executeAction(action.rawValue, subjecType: subjectType.rawValue, subjectId: subjectId, rsParameters: &parameters, rgbwParameters: nil)
        }
    }
}
