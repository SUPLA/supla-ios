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

protocol SuplaClientProvider {
    func provide() -> SuplaClientProtocol
}

class SuplaClientProviderImpl: SuplaClientProvider {
    func provide() -> SuplaClientProtocol { SAApp.suplaClient() }
}

extension SuplaClientProtocol {
    public func executeAction(parameters: ActionParameters) -> Bool {
        switch parameters {
        case let .simple(action, subjectType, subjectId):
            return executeAction(
                action.rawValue,
                subjecType: subjectType.rawValue,
                subjectId: subjectId,
                parameters: nil,
                length: 0
            )
        case let .rgbw(action, subjectType, subjectId, brightness, colorBrightness, color, colorRandom, onOff):
            var parameters = TAction_RGBW_Parameters()
            parameters.Brightness = brightness
            parameters.ColorBrightness = colorBrightness
            parameters.Color = color
            parameters.ColorRandom = colorRandom ? 1 : 0
            parameters.OnOff = onOff ? 1 : 0
            
            return executeAction(
                action.rawValue,
                subjecType: subjectType.rawValue,
                subjectId: subjectId,
                parameters: &parameters,
                length: Int32(MemoryLayout<TAction_RGBW_Parameters>.size)
            )
        case let .rollerShutter(action, subjectType, subjectId, percentage, delta):
            var parameters = TAction_ShadingSystem_Parameters()
            parameters.Percentage = percentage
            parameters.Tilt = Int8(VALUE_IGNORE)
            if (delta) {
                parameters.Flags = UInt8(SSP_FLAG_PERCENTAGE_AS_DELTA)
            }
            
            return executeAction(
                action.rawValue,
                subjecType: subjectType.rawValue,
                subjectId: subjectId,
                parameters: &parameters,
                length: Int32(MemoryLayout<TAction_ShadingSystem_Parameters>.size)
            )
        case let .facadeBlind(action, subjectType, subjectId, percentage, tilt, percentageAsDelta, tiltAsDelta):
            var parameters = TAction_ShadingSystem_Parameters()
            parameters.Percentage = percentage
            if (percentageAsDelta) {
                parameters.Flags = UInt8(SSP_FLAG_PERCENTAGE_AS_DELTA)
            }
            parameters.Tilt = tilt
            if (tiltAsDelta) {
                parameters.Flags |= UInt8(SSP_FLAG_TILT_AS_DELTA)
            }
            
            return executeAction(
                action.rawValue,
                subjecType: subjectType.rawValue,
                subjectId: subjectId,
                parameters: &parameters,
                length: Int32(MemoryLayout<TAction_ShadingSystem_Parameters>.size)
            )
        case let .hvac(subjectType, subjectId, durationInSec, mode, setpointTemperatureHeat, setpointTemperatureCool):
            var parameters = TAction_HVAC_Parameters()
            if let durationInSec = durationInSec {
                parameters.DurationSec = UInt32(durationInSec)
            }
            if let mode = mode {
                parameters.Mode = mode.rawValue
            }
            if let heatTemperature = setpointTemperatureHeat {
                parameters.SetpointTemperatureHeat = heatTemperature.toSuplaTemperature()
                parameters.Flags |= UInt16(SUPLA_HVAC_VALUE_FLAG_SETPOINT_TEMP_HEAT_SET)
            }
            if let coolTemperature = setpointTemperatureCool {
                parameters.SetpointTemperatureCool = coolTemperature.toSuplaTemperature()
                parameters.Flags |= UInt16(SUPLA_HVAC_VALUE_FLAG_SETPOINT_TEMP_COOL_SET)
            }
            
            return executeAction(
                Action.setHvacParameters.rawValue,
                subjecType: subjectType.rawValue,
                subjectId: subjectId,
                parameters: &parameters,
                length: Int32(MemoryLayout<TAction_HVAC_Parameters>.size)
            )
        }
    }
}
