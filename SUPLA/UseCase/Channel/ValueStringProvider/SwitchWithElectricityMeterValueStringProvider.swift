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
    
class SwitchWithElectricityMeterValueStringProvider: ChannelValueStringProvider {
    @Singleton private var switchWithElectricityMeterValueProvider: SwitchWithElectricityMeterValueProvider
    @Singleton private var userStateHolder: UserStateHolder
    
    private var formatter = ListElectricityMeterValueFormatter()
    
    func handle(_ channel: SAChannel) -> Bool {
        switchWithElectricityMeterValueProvider.handle(channel)
    }
    
    func value(_ channel: SAChannel, valueType: ValueType, withUnit: Bool) -> String {
        let value = switchWithElectricityMeterValueProvider.value(channel, valueType: valueType)
        let type = userStateHolder.getElectricityMeterSettings(profileId: channel.profile.idString, remoteId: channel.remote_id).showOnList
        return formatter.format(value, withUnit: withUnit, precision: .defaultPrecision(value: 2), custom: type)
    }
}