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

struct ChannelChild: Equatable {
    let channel: SAChannel
    let relationType: ChannelRelationType
    let children: [ChannelChild]
    
    init(channel: SAChannel, relationType: ChannelRelationType, children: [ChannelChild] = []) {
        self.channel = channel
        self.relationType = relationType
        self.children = children
    }
}

extension Array where Element == ChannelChild {
    var indicatorIcon: ThermostatIndicatorIcon {
        filter { $0.relationType == .masterThermostat }
            .map { $0.channel.value?.asThermostatValue().indicatorIcon }
            .compactMap { $0 }
            .reduce(ThermostatIndicatorIcon.off) { result, value in value.moreImportantThan(result) ? value : result }
    }
    
    var onlineState: ListOnlineState {
        filter { $0.relationType == .masterThermostat }
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
