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

import AppIntents

@available(iOS 17.0, *)
extension GroupShared {
    struct WidgetChannel: Codable {
        let profileId: Int32
        let profileCaption: String
        let locationId: Int32
        let locationCaption: String
        let subjectId: Int32
        let subjectCaption: String
        let icon: WidgetIcon
        let authorizationEntity: SingleCallAuthorizationEntity
        
        init(
            profileId: Int32,
            profileCaption: String,
            locationId: Int32,
            locationCaption: String,
            subjectId: Int32,
            subjectCaption: String,
            icon: WidgetIcon,
            authorizationEntity: SingleCallAuthorizationEntity
        ) {
            self.profileId = profileId
            self.profileCaption = profileCaption
            self.locationId = locationId
            self.locationCaption = locationCaption
            self.subjectId = subjectId
            self.subjectCaption = subjectCaption
            self.icon = icon
            self.authorizationEntity = authorizationEntity
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.profileId = try container.decode(Int32.self, forKey: .profileId)
            self.profileCaption = try container.decode(String.self, forKey: .profileCaption)
            self.locationId = try container.decode(Int32.self, forKey: .locationId)
            self.locationCaption = try container.decode(String.self, forKey: .locationCaption)
            self.subjectId = try container.decode(Int32.self, forKey: .subjectId)
            self.subjectCaption = try container.decode(String.self, forKey: .subjectCaption)
            self.icon = try container.decode(WidgetIcon.self, forKey: .icon)
            self.authorizationEntity = try container.decode(SingleCallAuthorizationEntity.self, forKey: .authorizationEntity)
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(profileId, forKey: .profileId)
            try container.encode(profileCaption, forKey: .profileCaption)
            try container.encode(locationId, forKey: .locationId)
            try container.encode(locationCaption, forKey: .locationCaption)
            try container.encode(subjectId, forKey: .subjectId)
            try container.encode(subjectCaption, forKey: .subjectCaption)
            try container.encode(icon, forKey: .icon)
            try container.encode(authorizationEntity, forKey: .authorizationEntity)
        }
        
        enum CodingKeys: String, CodingKey {
            case profileId
            case profileCaption
            case locationId
            case locationCaption
            case subjectId
            case subjectCaption
            case icon
            case authorizationEntity
        }
        
        static func fromJson(_ jsonString: String?) -> [Self]? {
            guard let data = jsonString?.data(using: .utf8) else { return nil }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode([Self].self, from: data)
        }
    }
}
