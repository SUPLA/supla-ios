//
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
    
struct UserIconData: Hashable {
    let id: Int32
    let subjectType: SubjectType
    let subjectId: Int32
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(subjectType)
        hasher.combine(subjectId)
    }
    
    static func channelIconData(_ id: Int32, channelId: Int32) -> UserIconData {
        return .init(id: id, subjectType: .channel, subjectId: channelId)
    }
    
    static func groupIconData(_ id: Int32, groupId: Int32) -> UserIconData {
        return .init(id: id, subjectType: .group, subjectId: groupId)
    }
    
    static func sceneIconData(_ id: Int32, sceneId: Int32) -> UserIconData {
        return .init(id: id, subjectType: .scene, subjectId: sceneId)
    }
}
