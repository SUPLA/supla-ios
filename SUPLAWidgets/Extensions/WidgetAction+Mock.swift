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
    
@available(iOS 17.0, *)
extension GroupShared.WidgetAction {
    static func mock(_ id: Int32, caption: String = "Garage door", icon: String = "fnc_garage_door-open") -> Self {
        .init(
            profileId: id,
            profileName: Strings.Profiles.defaultProfileName,
            subjectType: .channel,
            subjectId: 1,
            caption: caption,
            action: .close,
            icon: .suplaIcon(name: icon),
            sfIcon: nil,
            authorizationEntity: nil
        )
    }
}
