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
import CoreData
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

struct ChannelWithChildrenSignature: Equatable {
    private struct Node: Equatable {
        let channel: CoreDataEntitySignature
        let value: CoreDataEntitySignature?
        let state: CoreDataEntitySignature?
        let extendedValue: CoreDataEntitySignature?
        let config: CoreDataEntitySignature?
        let relation: CoreDataEntitySignature?
        let children: [Node]

        init(channel: SAChannel, relation: SAChannelRelation? = nil, children: [ChannelChild]) {
            self.channel = CoreDataEntitySignature(channel)
            value = channel.value.map(CoreDataEntitySignature.init)
            state = channel.state.map(CoreDataEntitySignature.init)
            extendedValue = channel.ev.map(CoreDataEntitySignature.init)
            config = channel.config.map(CoreDataEntitySignature.init)
            self.relation = relation.map(CoreDataEntitySignature.init)
            self.children = children.map { Node(channel: $0.channel, relation: $0.relation, children: $0.children) }
        }
    }

    private let root: Node

    init(_ channelWithChildren: ChannelWithChildren) {
        root = Node(channel: channelWithChildren.channel, children: channelWithChildren.children)
    }
}

private struct CoreDataEntitySignature: Equatable {
    private let entityName: String
    private let attributes: NSDictionary

    init(_ object: NSManagedObject) {
        entityName = object.entity.name ?? ""

        var attributeNames = Set<String>()
        var entity: NSEntityDescription? = object.entity
        while let current = entity {
            attributeNames.formUnion(current.attributesByName.keys)
            entity = current.superentity
        }

        let values = object.dictionaryWithValues(forKeys: attributeNames.sorted()).mapValues { value in
            (value as? NSCopying)?.copy(with: nil) ?? value
        }
        attributes = NSDictionary(dictionary: values)
    }

    static func == (lhs: CoreDataEntitySignature, rhs: CoreDataEntitySignature) -> Bool {
        lhs.entityName == rhs.entityName && lhs.attributes.isEqual(rhs.attributes)
    }
}

extension ChannelWithChildren {
    var remoteId: Int32 { channel.remote_id }
    var function: Int32 { channel.func }
}

extension ChannelWithChildren {
    var showInfoIcon: Bool {
        (channel.flags & Int64(SUPLA_CHANNEL_FLAG_CHANNELSTATE) > 0 && channel.value?.status.online == true)
            || channel.state != nil
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
