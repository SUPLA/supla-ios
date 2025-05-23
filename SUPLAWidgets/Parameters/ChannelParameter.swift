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
struct ChannelParameter: AppEntity {
    
    var id: Int
    var name: String
    var icon: GroupShared.WidgetIcon
    var authorizationEntity: SingleCallAuthorizationEntity?
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Channel"
    static var defaultQuery = Query()
    
    struct Query: EntityQuery {
        @IntentParameterDependency<SuplaValueWidget.ValueIntent>(\.$profile, \.$location)
        var intent
        
        func entities(for identifiers: [ChannelParameter.ID]) async throws -> [ChannelParameter] {
            var seen: Set<Int> = []
            
            let profiles = GroupShared.Implementation().channels
                .filter { $0.profileId == intent?.profile.id ?? 0 }
                .filter { $0.locationId == intent?.location.id ?? 0 }
                .map { $0.parameter }
                .filter { seen.insert($0.id).inserted }
                .filter { identifiers.contains($0.id) }
                
            return profiles
        }
        
        func suggestedEntities() throws -> [ChannelParameter] {
            var seen: Set<Int> = []
            
            let profiles = GroupShared.Implementation().channels
                .filter { $0.profileId == intent?.profile.id ?? 0 }
                .filter { $0.locationId == intent?.location.id ?? 0 }
                .map { $0.parameter }
                .filter { seen.insert($0.id).inserted }
                
            return profiles
        }
        
        func defaultResult() -> ChannelParameter? {
            try? suggestedEntities().first ?? ChannelParameter(id: -1, name: Strings.General.select, icon: .single(.suplaIcon(name: .Icons.fncUnknown)), authorizationEntity: nil)
        }
        
        static var persistentIdentifier: String = "ChannelQuery"
    }
}

@available(iOS 17.0, *)
private extension GroupShared.WidgetChannel {
    var parameter: ChannelParameter {
        .init(
            id: Int(subjectId),
            name: subjectCaption,
            icon: icon,
            authorizationEntity: authorizationEntity
        )
    }
}
