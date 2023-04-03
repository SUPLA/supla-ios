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
