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

struct ChannelWithChildren: Equatable {
    let channel: SAChannel
    let children: [ChannelChild]

    var allDescendantFlat: [ChannelChild] { getChildren(children) }

    var pumpSwitchChild: ChannelChild? { children.first(where: { $0.relationType == .pumpSwitch }) }

    var heatOrColdSourceSwitchChild: ChannelChild? {
        children.first(where: { $0.relationType == .heatOrColdSourceSwitch })
    }
    
    var hasElectricityMeter: Bool {
        if let child = children.first(where: { $0.relationType == .meter }),
           child.channel.isElectricityMeter() {
            return true
        }
        
        return (channel.value?.sub_value_type ?? 0) == SUBV_TYPE_ELECTRICITY_MEASUREMENTS
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

extension ChannelWithChildren: BaseCellData {
    var infoSupported: Bool {
        channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) > 0
    }
}
