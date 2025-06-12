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

@testable import SUPLA
import SharedCore

extension SuplaChannelHvacConfig {
    
    static func mock(remoteId: Int32, channelFunction: Int32, subfunction: ThermostatSubfunction, configMin: Int16, configMax: Int16?) -> SuplaChannelHvacConfig {
        return SuplaChannelHvacConfig(
            remoteId: remoteId,
            channelFunc: channelFunction,
            crc32: 0,
            mainThermometerRemoteId: 111,
            auxThermometerRemoteId: 111,
            auxThermometerType: .floor,
            antiFreezeAndOverheatProtectionEnabled: false,
            availableAlgorithms: [],
            usedAlgorithm: .notSet,
            minOnTimeSec: 111,
            minOffTimeSec: 111,
            outputValueOnError: 111,
            subfunction: subfunction,
            temperatureControlType: .roomTemperature,
            temperatures: SuplaHvacTemperatures(
                freezeProtection: nil,
                eco: nil,
                comfort: nil,
                boost: nil,
                heatProtection: nil,
                histeresis: nil,
                belowAlarm: nil,
                aboveAlarm: nil,
                auxMinSetpoint: nil,
                auxMaxSetpoint: nil,
                roomMin: configMin,
                roomMax: configMax,
                auxMin: nil,
                auxMax: nil,
                histeresisMin: nil,
                histeresisMax: nil,
                autoOffsetMin: nil,
                autoOffsetMax: nil
            )
        )
    }
}
