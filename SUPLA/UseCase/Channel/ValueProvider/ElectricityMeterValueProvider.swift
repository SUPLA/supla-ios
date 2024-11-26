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
    
protocol ElectricityMeterValueProvider: ChannelValueProvider {}

final class ElectricityMeterValueProviderImpl: ElectricityMeterValueProvider, IntValueParser {
    @Singleton private var userStateHolder: UserStateHolder
    
    func handle(_ channel: SAChannel) -> Bool {
        channel.func == SUPLA_CHANNELFNC_ELECTRICITY_METER
    }
    
    func value(_ channel: SAChannel, valueType: ValueType) -> Any {
        switch (userStateHolder.getElectricityMeterSettings(profileId: channel.profile.id, remoteId: channel.remote_id).showOnList) {
        case .reverseActiveEnergy:
            return channel.ev?.electricityMeter().totalReverseActiveEnergy() ?? ElectricityMeterValueProviderImpl.UNKNOWN_VALUE
        case .powerActive:
            guard let electricityMeterValue = channel.ev?.electricityMeter() else {
                return ElectricityMeterValueProviderImpl.UNKNOWN_VALUE
            }
            let powerActive = Phase.allCases
                .filter { $0.disabledFlag & channel.flags == 0 }
                .map { electricityMeterValue.powerActive(forPhase: $0.rawValue) }
                .sumOrNan()
            
            if (electricityMeterValue.suplaElectricityMeterMeasuredTypes.contains(.powerActiveKw)) {
                return powerActive * 1000
            } else {
                return powerActive
            }
        case .voltage:
            guard let electricityMeterValue = channel.ev?.electricityMeter() else {
                return ElectricityMeterValueProviderImpl.UNKNOWN_VALUE
            }
            
            return Phase.allCases
                .filter { $0.disabledFlag & channel.flags == 0 }
                .map { electricityMeterValue.voltege(forPhase: $0.rawValue) }
                .avgOrNan()
        default:
            if let value = asIntValue(channel.value, startingFromByte: 1) {
                return Double(value) / 100
            } else {
                return ElectricityMeterValueProviderImpl.UNKNOWN_VALUE
            }
        }
    }
    
    static let UNKNOWN_VALUE = 0.0
}
