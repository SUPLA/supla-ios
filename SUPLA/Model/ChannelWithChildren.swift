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
import SharedCore

struct ChannelWithChildren: Equatable {
    let channel: SAChannel
    let children: [ChannelChild]
    
    var allDescendantFlat: [ChannelChild] { getChildren(children) }

    var pumpSwitchChild: ChannelChild? { children.first(where: { $0.relationType == .pumpSwitch }) }

    var heatOrColdSourceSwitchChild: ChannelChild? {
        children.first(where: { $0.relationType == .heatOrColdSourceSwitch })
    }

    var isOrHasImpulseCounter: Bool {
        channel.isImpulseCounter() || channel.value?.sub_value_type == Int16(SUBV_TYPE_IC_MEASUREMENTS) ||
            children.first { $0.relationType == .meter }?.channel.isImpulseCounter() == true
    }

    var isOrHasElectricityMeter: Bool {
        channel.isElectricityMeter() || channel.value?.sub_value_type == Int16(SUBV_TYPE_ELECTRICITY_MEASUREMENTS) ||
            children.first { $0.relationType == .meter }?.channel.isElectricityMeter() == true
    }

    var hasElectricityMeter: Bool {
        if let child = children.first(where: { $0.relationType == .meter }),
           child.channel.isElectricityMeter()
        {
            return true
        }

        return (channel.value?.sub_value_type ?? 0) == SUBV_TYPE_ELECTRICITY_MEASUREMENTS
    }
    
    var onlineState: ListOnlineState {
        channel.onlineState.mergeWith(children.onlineState)
    }
    
    init(channel: SAChannel, children: [ChannelChild] = []) {
        self.channel = channel
        self.children = children
    }

    private func getChildren(_ tree: [ChannelChild]) -> [ChannelChild] {
        var children: [ChannelChild] = []
        for item in tree {
            children.append(item)
            if (!item.children.isEmpty) {
                children.append(contentsOf: getChildren(item.children))
            }
        }
        return children
    }
}

extension ChannelWithChildren {
    var remoteId: Int32 { channel.remote_id }
    var function: Int32 { channel.func }
}

extension ChannelWithChildren: BaseCellData {
    var infoSupported: Bool {
        channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) > 0
    }
}

extension ChannelWithChildren {
    var shareable: SharedCore.ChannelWithChildren {
        SharedCore.ChannelWithChildren(
            channel: channel.shareable,
            children: children.map { $0.shareable }
        )
    }
}
