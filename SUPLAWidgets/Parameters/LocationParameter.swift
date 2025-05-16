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
struct LocationParameter: AppEntity {
    
    var id: Int
    var name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Location"
    static var defaultQuery = Query()
    
    struct Query: EntityQuery {
        @IntentParameterDependency<SuplaValueWidget.Intent>(\.$profile)
        var intent
        
        func entities(for identifiers: [LocationParameter.ID]) async throws -> [LocationParameter] {
            var seen: Set<Int> = []
            
            return GroupShared.Implementation().channels
                .filter { $0.profileId == intent?.profile.id ?? 0 }
                .map { LocationParameter(id: Int($0.locationId), name: $0.locationCaption) }
                .filter { seen.insert($0.id).inserted }
                .filter { identifiers.contains($0.id) }
        }
        
        func suggestedEntities() throws -> [LocationParameter] {
            var seen: Set<Int> = []
            
            return GroupShared.Implementation().channels
                .filter { $0.profileId == intent?.profile.id ?? 0 }
                .map { LocationParameter(id: Int($0.locationId), name: $0.locationCaption) }
                .filter { seen.insert($0.id).inserted }
        }
        
        func defaultResult() -> LocationParameter? {
            try? suggestedEntities().first ?? LocationParameter(id: -1, name: Strings.General.select)
        }
        
        static var persistentIdentifier: String = "LocationQuery"
    }
}
