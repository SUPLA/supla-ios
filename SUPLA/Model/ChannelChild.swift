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

struct ChannelChild: Equatable {
    let channel: SAChannel
    let relation: SAChannelRelation
    let children: [ChannelChild]
    
    var relationType: ChannelRelationType {
        relation.relationType
    }
    
    var withChildren: ChannelWithChildren { ChannelWithChildren(channel: channel, children: children) }
    
    init(channel: SAChannel, relation: SAChannelRelation, children: [ChannelChild] = []) {
        self.channel = channel
        self.relation = relation
        self.children = children
    }
}

extension Array where Element == ChannelChild {
    var indicatorIcon: ThermostatIndicatorIcon {
        filter { $0.relation.relationType == .masterThermostat }
            .map { $0.channel.value?.asThermostatValue().indicatorIcon }
            .compactMap { $0 }
            .reduce(ThermostatIndicatorIcon.off) { result, value in value.moreImportantThan(result) ? value : result }
    }
    
    var onlineState: ListOnlineState {
        filter { $0.relation.relationType == .masterThermostat }
            .map { $0.channel.value?.online }
            .compactMap { $0 }
            .reduce(.unknown) { result, online in
                if (result == .unknown && online) {
                    .online
                } else if (result == .unknown) {
                    .offline
                } else if (result == .online && !online) {
                    .partiallyOnline
                } else if (result == .offline && online) {
                    .partiallyOnline
                } else {
                    result
                }
            }
    }
}

extension ChannelChild {
    var shareable: SharedCore.ChannelChild {
        SharedCore.ChannelChild(
            channel: channel.shareable,
            relation: relation.shareable,
            children: children.map { $0.shareable }
        )
    }
    
    func toSensorItem() -> SensorItemData {
        @Singleton<GetChannelBatteryIconUseCase> var getChannelBatteryIconUseCase
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        
        return SensorItemData(
            channelId: channel.remote_id,
            onlineState: channel.onlineState,
            icon: getChannelBaseIconUseCase.invoke(channel: channel),
            caption: getCaptionUseCase.invoke(data: channel.shareable).string,
            userCaption: channel.caption ?? "",
            batteryIcon: getChannelBatteryIconUseCase.invoke(channel: channel.shareable),
            showChannelStateIcon: channel.value?.online ?? false
        )
    }
}
