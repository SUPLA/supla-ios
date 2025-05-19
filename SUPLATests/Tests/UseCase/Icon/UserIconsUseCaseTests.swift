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
import XCTest

final class UserIconsUseCaseTests: XCTestCase {
    private lazy var useCase: UserIcons.UseCase! = UserIcons.Implementation()
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    
    override func setUp() {
        super.setUp()
        DiContainer.shared.register(type: GlobalSettings.self, settings!)
        settings.darkModeReturns = .never
    }
    
    override func tearDown() {
        super.tearDown()
        settings = nil
    }

    func testIfIconsAreStoredCorrectly() {
        // given
        let profileId: Int32 = 12345
        let iconId: Int32 = 1
        let image = UIImage(named: "error")
        guard let imageData = image?.pngData() else {
            XCTFail("Could not load data for image")
            return
        }

        // when
        useCase.storeIconData(imageData, profileId: profileId, iconId: iconId, type: .light0)
        let loadedImage = useCase.getIcon(profileId: profileId, iconId: iconId, icon: .icon1)
        useCase.removeProfileIcons(profileId)
        let loadedImageAfterRemoval = useCase.getIcon(profileId: profileId, iconId: iconId, icon: .icon1)
        
        // then
        XCTAssertNotNil(loadedImage)
        XCTAssertNil(loadedImageAfterRemoval)
    }
    
    func testIfReturnsNullWhenNoIconStored() {
        // given
        let profileId: Int32 = 12346
        let iconId: Int32 = 1

        // when
        let icon = useCase.getIcon(profileId: profileId, iconId: iconId, icon: .icon1)
        
        // then
        XCTAssertNil(icon)
    }
}
