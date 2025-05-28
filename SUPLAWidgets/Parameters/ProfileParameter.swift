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
struct ProfileParameter: AppEntity {
    
    var id: Int
    var name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Profile"
    static var defaultQuery = Query()
    
    struct Query: EntityQuery {
        func entities(for identifiers: [ProfileParameter.ID]) async throws -> [ProfileParameter] {
            var seen: Set<Int> = []
            
            let profiles = GroupShared.Implementation().channels
                .map { ProfileParameter(id: Int($0.profileId), name: $0.profileCaption) }
                .filter { seen.insert($0.id).inserted }
                .filter { identifiers.contains($0.id) }
                
            return profiles
        }
        
        func suggestedEntities() throws -> [ProfileParameter] {
            var seen: Set<Int> = []
            
            let profiles = GroupShared.Implementation().channels
                .map { ProfileParameter(id: Int($0.profileId), name: $0.profileCaption) }
                .filter { seen.insert($0.id).inserted }
                
            return profiles
        }
        
        func defaultResult() -> ProfileParameter? {
            try? suggestedEntities().first ?? ProfileParameter(id: -1, name: Strings.General.select)
        }
        
        static var persistentIdentifier: String = "ProfileQuery"
    }
}
