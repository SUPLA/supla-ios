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
    struct ScheduleDto: Codable, Identifiable {
        var id: Int?
        var caption: String?
        var subjectType: SubjectType?
        var subjectId: Int?
        var subject: ScheduleSubjectDto?
        var enabled: Bool?
        var dateStart: String?
        var dateEnd: String?
        var retry: Bool?
        var mode: String?
        var config: [ScheduleConfigDto]?
        var state: ScheduleStateDto?
        var closestExecutions: ScheduleClosestExecutionsDto?

        private enum CodingKeys: String, CodingKey {
            case id, caption, subjectType, subjectId, subject, enabled, dateStart, dateEnd, retry, mode, config, state, closestExecutions
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decodeIfPresent(Int.self, forKey: .id)
            caption = try container.decodeIfPresent(String.self, forKey: .caption)
            let subjectTypeValue = try container.decodeIfPresent(String.self, forKey: .subjectType)
            subjectType = subjectTypeValue.flatMap { SubjectType.from($0) }
            subjectId = try container.decodeIfPresent(Int.self, forKey: .subjectId)
            subject = try container.decodeIfPresent(ScheduleSubjectDto.self, forKey: .subject)
            enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled)
            dateStart = try container.decodeIfPresent(String.self, forKey: .dateStart)
            dateEnd = try container.decodeIfPresent(String.self, forKey: .dateEnd)
            retry = try container.decodeIfPresent(Bool.self, forKey: .retry)
            mode = try container.decodeIfPresent(String.self, forKey: .mode)
            config = try container.decodeIfPresent([ScheduleConfigDto].self, forKey: .config)
            state = try container.decodeIfPresent(ScheduleStateDto.self, forKey: .state)
            closestExecutions = try container.decodeIfPresent(ScheduleClosestExecutionsDto.self, forKey: .closestExecutions)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(caption, forKey: .caption)
            if let subjectType {
                try container.encode(subjectType.toCloudString(), forKey: .subjectType)
            }
            try container.encodeIfPresent(subjectId, forKey: .subjectId)
            try container.encodeIfPresent(subject, forKey: .subject)
            try container.encodeIfPresent(enabled, forKey: .enabled)
            try container.encodeIfPresent(dateStart, forKey: .dateStart)
            try container.encodeIfPresent(dateEnd, forKey: .dateEnd)
            try container.encodeIfPresent(retry, forKey: .retry)
            try container.encodeIfPresent(mode, forKey: .mode)
            try container.encodeIfPresent(config, forKey: .config)
            try container.encodeIfPresent(state, forKey: .state)
            try container.encodeIfPresent(closestExecutions, forKey: .closestExecutions)
        }
    }
}
