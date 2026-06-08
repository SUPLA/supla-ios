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
    
class SwitchWithImpulseCounterValueStringProvider: ChannelValueStringProvider {
    @Singleton<UserStateHolder> private var userStateHolder
    @Singleton<SwitchWithImpulseCounterValueProvider> private var switchWithImpulseCounterValueProvider
    
    let icFormatter = SharedCore.ImpulseCounterValueFormatter()
    let emFormatter = SharedCore.ElectricityMeterValueFormatter()
    
    func handle(_ channelWithChildren: ChannelWithChildren) -> Bool {
        switchWithImpulseCounterValueProvider.handle(channelWithChildren.channel)
    }
    
    func value(_ channelWithChildren: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String {
        let channel = channelWithChildren.channel
        let settings = userStateHolder.getImpulseCounterSettings(profileId: channel.profile.id, remoteId: channel.remote_id)
        
        if (settings.showOnList != .noAggregation) {
            return channel.value?.aggregated_value ?? NO_VALUE_TEXT
        }
        
        let value = switchWithImpulseCounterValueProvider.value(channel, valueType: valueType)
        if let meterChild = channelWithChildren.children.first(where: { $0.relationType == .meter }),
           meterChild.channel.func == SUPLA_CHANNELFNC_IC_ELECTRICITY_METER
        {
            return emFormatter.format(value: value, format: ValueFormat(withUnit: withUnit, customUnit: " \(channel.unit())"))
        } else {
            return icFormatter.format(value: value, format: ValueFormat(withUnit: withUnit, customUnit: " \(channel.unit())"))
        }
    }
}
