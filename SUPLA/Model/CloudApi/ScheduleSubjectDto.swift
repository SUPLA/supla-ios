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

extension CloudApi {
    struct ScheduleSubjectDto: Codable {
        var id: Int?
        var channelNumber: Int?
        var caption: String?
        var type: ScheduleSubjectTypeDto?
        var function: ScheduleSubjectFunctionDto?
        var altIcon: Int?
        var enabled: Bool?
        var hidden: Bool?
        var estimatedExecutionTime: Int?
        var activeFrom: String?
        var activeTo: String?
        var activeHours: [String: [Int]]?
        var activityConditions: [[ScheduleActivityConditionDto]]?
        var subDeviceId: Int?
        var conflictDetails: ScheduleSubjectConflictDetailsDto?
        var checksum: String?
        var isVirtual: Bool?
        var ownSubjectType: String?
        var inheritedLocation: Bool?
        var possibleActions: [ScheduleSubjectActionDto]?
        var deletable: Bool?
        var userId: Int?
        var iodeviceId: Int?
        var locationId: Int?
        var functionId: Int?
        var userIconId: Int?
        var typeId: Int?
        var config: ScheduleSubjectConfigDto?
    }
}
