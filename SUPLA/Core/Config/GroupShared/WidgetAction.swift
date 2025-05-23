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
    struct WidgetAction: Codable, AppEntity {
        var id: String { "\(String(format: "%03d", profileId))\(String(format: "%02d", action?.id ?? 0))\(String(format: "%08d", subjectId))" }
        let profileId: Int32
        let profileName: String
        let subjectType: SubjectType
        let subjectId: Int32
        let caption: String
        let action: CarPlayAction?
        let icon: IconResult
        let sfIcon: String?
        let authorizationEntity: SingleCallAuthorizationEntity?
        
        var description: String {
            "WidgetConfiguration(profileId: \(profileId), " +
                "subjectType: \(subjectType), " +
                "subjectId: \(subjectId), " +
                "caption: \(caption), " +
                "action: \(String(describing: action)), " +
                "icon: \(icon), " +
                "systemIcon: \(String(describing: sfIcon)))"
        }
        
        var displayRepresentation: DisplayRepresentation {
            DisplayRepresentation(title: "\(caption)")
        }
        
        static var typeDisplayRepresentation: TypeDisplayRepresentation = "Action"
        static var defaultQuery = WidgetConfigurationQuery()
        
        init(
            profileId: Int32,
            profileName: String,
            subjectType: SubjectType,
            subjectId: Int32,
            caption: String,
            action: CarPlayAction?,
            icon: IconResult,
            sfIcon: String?,
            authorizationEntity: SingleCallAuthorizationEntity?
        ) {
            self.profileId = profileId
            self.profileName = profileName
            self.subjectType = subjectType
            self.subjectId = subjectId
            self.caption = caption
            self.action = action
            self.icon = icon
            self.sfIcon = sfIcon
            self.authorizationEntity = authorizationEntity
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            profileId = try container.decode(Int32.self, forKey: .profileId)
            profileName = try container.decode(String.self, forKey: .profileName)
            subjectType = try container.decode(SubjectType.self, forKey: .subjectType)
            subjectId = try container.decode(Int32.self, forKey: .subjectId)
            caption = try container.decode(String.self, forKey: .caption)
            action = try container.decode(CarPlayAction.self, forKey: .action)
            icon = try container.decode(IconResult.self, forKey: .icon)
            sfIcon = try container.decode(String?.self, forKey: .sfIcon)
            authorizationEntity = try container.decode(SingleCallAuthorizationEntity.self, forKey: .authorizationEntity)
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(profileId, forKey: .profileId)
            try container.encode(profileName, forKey: .profileName)
            try container.encode(subjectType, forKey: .subjectType)
            try container.encode(subjectId, forKey: .subjectId)
            try container.encode(caption, forKey: .caption)
            try container.encode(action, forKey: .action)
            try container.encode(icon, forKey: .icon)
            try container.encode(sfIcon, forKey: .sfIcon)
            try container.encode(authorizationEntity, forKey: .authorizationEntity)
        }
        
        enum CodingKeys: String, CodingKey {
            case profileId
            case profileName
            case subjectType
            case subjectId
            case caption
            case action
            case icon
            case sfIcon
            case authorizationEntity
        }
        
        static func fromJson(_ jsonString: String?) -> [Self]? {
            guard let data = jsonString?.data(using: .utf8) else { return nil }
            let jsonDecoder = JSONDecoder()
            return try? jsonDecoder.decode([Self].self, from: data)
        }
    }
    
    struct WidgetConfigurationQuery: EntityQuery {
        func entities(for identifiers: [WidgetAction.ID]) throws -> [WidgetAction] {
            Implementation().actions.filter { $0.sfIcon != nil }.filter { identifiers.contains($0.id) }
        }
        
        func suggestedEntities() throws -> [WidgetAction] {
            Implementation().actions.filter { $0.sfIcon != nil }
        }
        
        func defaultResult() -> WidgetAction? {
            try? suggestedEntities().first
        }
    }
}
