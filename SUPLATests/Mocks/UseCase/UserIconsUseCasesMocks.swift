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
    
@testable import SUPLA

extension UserIcons {
    final class Mock: UseCase {
        var getIconMock: FunctionMock<(Int32, Int32, SUPLA.UserIcon), UIImage?> = .init()
        func getIcon(profileId: Int32, iconId: Int32, icon: SUPLA.UserIcon) -> UIImage? {
            getIconMock.handle((profileId, iconId, icon))
        }
        
        var storeIconDataMock: FunctionMock<(Data, Int32, Int32, SUPLA.UserIcons.IconType), Void> = .init()
        func storeIconData(_ data: Data, profileId: Int32, iconId: Int32, type: SUPLA.UserIcons.IconType) {
            storeIconDataMock.set((data, profileId, iconId, type))
        }
        
        var existingIconIdsMock: FunctionMock<Int32, [Int32]> = .init()
        func existingIconIds(profileId: Int32) -> [Int32] {
            existingIconIdsMock.handle(profileId)
        }
        
        var removeProfileIconsMock: FunctionMock<Int32, Void> = .init()
        func removeProfileIcons(_ profileId: Int32) {
            removeProfileIconsMock.set(profileId)
        }
    }
}
