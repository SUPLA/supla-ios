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

enum MainListItem: Equatable, Identifiable {
    case channel(DefaultListItem)
    case group(DefaultListItem)
    case scene(SceneListItem)
    case location(LocationListItem)
    case hvacThermostat(HvacThermostatListItem)
    case heatpolThermostat(HeatpolThermostatListItem)
    case doubleValue(DoubleValueListItem)

    var id: String { key }

    var key: String {
        switch (self) {
        case .channel(let item): "C\(item.remoteId)"
        case .group(let item): "G\(item.remoteId)"
        case .scene(let item): "S\(item.remoteId)"
        case .location(let item): "L\(item.remoteId)"
        case .hvacThermostat(let item): "C\(item.base.remoteId)"
        case .heatpolThermostat(let item): "C\(item.base.remoteId)"
        case .doubleValue(let item): "C\(item.base.remoteId)"
        }
    }

    var remoteId: Int32 {
        switch (self) {
        case .channel(let item), .group(let item): item.remoteId
        case .scene(let item): item.remoteId
        case .location(let item): item.remoteId
        case .hvacThermostat(let item): item.base.remoteId
        case .heatpolThermostat(let item): item.base.remoteId
        case .doubleValue(let item): item.base.remoteId
        }
    }

    var profileId: Int32 {
        switch (self) {
        case .channel(let item), .group(let item): item.profileId
        case .scene(let item): item.profileId
        case .location(let item): item.profileId
        case .hvacThermostat(let item): item.base.profileId
        case .heatpolThermostat(let item): item.base.profileId
        case .doubleValue(let item): item.base.profileId
        }
    }

    var userCaption: String {
        switch (self) {
        case .channel(let item), .group(let item): item.userCaption
        case .scene(let item): item.userCaption
        case .location(let item): item.userCaption
        case .hvacThermostat(let item): item.base.userCaption
        case .heatpolThermostat(let item): item.base.userCaption
        case .doubleValue(let item): item.base.userCaption
        }
    }

    var locationCaption: String? {
        switch (self) {
        case .channel(let item), .group(let item):
            item.locationCaption
        case .scene(let item):
            item.locationCaption
        case .location(let item):
            item.userCaption
        case .hvacThermostat(let item):
            item.base.locationCaption
        case .heatpolThermostat(let item):
            item.base.locationCaption
        case .doubleValue(let item):
            item.base.locationCaption
        }
    }

    var locationId: Int32? {
        switch (self) {
        case .channel(let item), .group(let item):
            item.locationId
        case .scene(let item):
            Int32(item.locationId)
        case .location(let item):
            item.remoteId
        case .hvacThermostat(let item):
            item.base.locationId
        case .heatpolThermostat(let item):
            item.base.locationId
        case .doubleValue(let item):
            item.base.locationId
        }
    }

    var leftButtonTitle: String? {
        switch (self) {
        case .channel(let item), .group(let item):
            item.leftButtonTitle
        case .scene(let item):
            item.leftButtonTitle
        case .hvacThermostat(let item):
            item.base.leftButtonTitle
        case .heatpolThermostat(let item):
            item.base.leftButtonTitle
        case .doubleValue(let item):
            item.base.leftButtonTitle
        default:
            nil
        }
    }

    var rightButtonTitle: String? {
        switch (self) {
        case .channel(let item), .group(let item):
            item.rightButtonTitle
        case .scene(let item):
            item.rightButtonTitle
        case .hvacThermostat(let item):
            item.base.rightButtonTitle
        case .heatpolThermostat(let item):
            item.base.rightButtonTitle
        case .doubleValue(let item):
            item.base.rightButtonTitle
        default:
            nil
        }
    }

    var draggable: Bool {
        switch (self) {
        case .location: false
        default: true
        }
    }
}

struct DefaultListItem: Equatable {
    let remoteId: Int32
    let profileId: Int32
    let userCaption: String
    let function: SuplaFunction
    let locationCaption: String
    let locationId: Int32
    let status: ListItemStatus
    let title: String
    let icon: IconResult
    let value: String?
    let issues: ListItemIssues
    let processing: Bool
    let estimatedTimerEndDate: Date?
    let infoSupported: Bool
    let leftButtonTitle: String?
    let rightButtonTitle: String?

    init(
        remoteId: Int32,
        profileId: Int32,
        userCaption: String,
        function: SuplaFunction,
        locationCaption: String,
        locationId: Int32,
        status: ListItemStatus,
        title: String,
        icon: IconResult,
        value: String?,
        issues: ListItemIssues = ListItemIssues(icons: [], issuesStrings: []),
        processing: Bool = false,
        estimatedTimerEndDate: Date? = nil,
        infoSupported: Bool = false,
        leftButtonTitle: String? = nil,
        rightButtonTitle: String? = nil
    ) {
        self.remoteId = remoteId
        self.profileId = profileId
        self.userCaption = userCaption
        self.function = function
        self.locationCaption = locationCaption
        self.locationId = locationId
        self.status = status
        self.title = title
        self.icon = icon
        self.value = value
        self.issues = issues
        self.processing = processing
        self.estimatedTimerEndDate = estimatedTimerEndDate
        self.infoSupported = infoSupported
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
    }
}

struct SceneListItem: Equatable {
    let remoteId: Int32
    let profileId: Int32
    let userCaption: String
    let locationCaption: String
    let locationId: Int
    let status: ListItemStatus
    let icon: IconResult
    let estimatedTimerEndDate: Date?
    let leftButtonTitle: String?
    let rightButtonTitle: String?

    init(
        remoteId: Int32,
        profileId: Int32,
        userCaption: String,
        locationCaption: String,
        locationId: Int,
        status: ListItemStatus,
        icon: IconResult,
        estimatedTimerEndDate: Date?,
        leftButtonTitle: String? = nil,
        rightButtonTitle: String? = nil
    ) {
        self.remoteId = remoteId
        self.profileId = profileId
        self.userCaption = userCaption
        self.locationCaption = locationCaption
        self.locationId = locationId
        self.status = status
        self.icon = icon
        self.estimatedTimerEndDate = estimatedTimerEndDate
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
    }
}

struct LocationListItem: Equatable {
    let remoteId: Int32
    let profileId: Int32
    let userCaption: String
    let collapsed: Bool

    init(
        remoteId: Int32,
        profileId: Int32,
        userCaption: String,
        collapsed: Bool
    ) {
        self.remoteId = remoteId
        self.profileId = profileId
        self.userCaption = userCaption
        self.collapsed = collapsed
    }
}

struct HvacThermostatListItem: Equatable {
    let base: DefaultListItem
    let subValue: String
    let indicatorIcon: ThermostatIndicatorIcon?
}

struct HeatpolThermostatListItem: Equatable {
    let base: DefaultListItem
    let subValue: String
}

struct DoubleValueListItem: Equatable {
    let base: DefaultListItem
    let secondIcon: IconResult?
    let secondValue: String?
}

extension DefaultListItem {
    static func == (lhs: DefaultListItem, rhs: DefaultListItem) -> Bool {
        lhs.remoteId == rhs.remoteId &&
            lhs.profileId == rhs.profileId &&
            lhs.userCaption == rhs.userCaption &&
            lhs.function.value == rhs.function.value &&
            lhs.locationCaption == rhs.locationCaption &&
            lhs.locationId == rhs.locationId &&
            lhs.status == rhs.status &&
            lhs.title == rhs.title &&
            lhs.icon == rhs.icon &&
            lhs.value == rhs.value &&
            lhs.issues.isEqual(rhs.issues) &&
            lhs.processing == rhs.processing &&
            lhs.estimatedTimerEndDate == rhs.estimatedTimerEndDate &&
            lhs.infoSupported == rhs.infoSupported &&
            lhs.leftButtonTitle == rhs.leftButtonTitle &&
            lhs.rightButtonTitle == rhs.rightButtonTitle
    }
}
