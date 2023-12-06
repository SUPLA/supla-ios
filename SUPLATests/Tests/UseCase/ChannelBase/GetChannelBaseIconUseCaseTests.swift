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

import XCTest

@testable import SUPLA

final class GetChannelBaseIconUseCaseTests: XCTestCase {
    
    private lazy var useCase: GetChannelBaseIconUseCase! = { GetChannelBaseIconUseCaseImpl() }()
    private lazy var getDefaultIconNameUseCase: GetDefaultIconNameUseCaseMock! = { GetDefaultIconNameUseCaseMock() }()
    
    override func setUp() {
        DiContainer.shared.register(type: GetDefaultIconNameUseCase.self, component: getDefaultIconNameUseCase!)
    }
    
    override func tearDown() {
        useCase = nil
        
        getDefaultIconNameUseCase = nil
    }
    
    func test_noIconForFirstType_whenNotHumidityAndTemperature() {
        // when
        expectFatalError(expectedMessage: "Wrong icon configuration (iconType: 'first', function: '140'") {
            _ = self.useCase.invoke(
                iconData: IconData(
                    function: SUPLA_CHANNELFNC_LIGHTSWITCH,
                    altIcon: 123,
                    state: .notUsed,
                    type: .first,
                    userIcon: nil,
                    nightMode: false
                )
            )
        }
    }
    
    func test_defaultIcon_whenThereIsNoUserIcon() {
        // given
        getDefaultIconNameUseCase.returns = "uv-on"
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_LIGHTSWITCH,
                altIcon: 123,
                state: .on,
                type: .single,
                userIcon: nil,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(icon, .suplaIcon(icon: UIImage(named: "uv-on")))
    }
    
    func test_defaultIconInNightMode_whenThereIsNoUserIcon() {
        // given
        getDefaultIconNameUseCase.returns = "uv-on"
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_LIGHTSWITCH,
                altIcon: 123,
                state: .on,
                type: .single,
                userIcon: nil,
                nightMode: true
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(icon, .suplaIcon(icon: UIImage(named: "uv-on-nightmode")))
    }
    
    func test_userIcon_activeState() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage2 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_LIGHTSWITCH,
                altIcon: 123,
                state: .on,
                type: .single,
                userIcon: userIcon,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [])
    }
    
    func test_userIcon_inactiveState() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage1 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_LIGHTSWITCH,
                altIcon: 123,
                state: .off,
                type: .single,
                userIcon: userIcon,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [])
    }
    
    func test_userIcon_humidityAndTemperatureFirst() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage2 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
                altIcon: 123,
                state: .notUsed,
                type: .first,
                userIcon: userIcon,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [])
    }
    
    func test_userIcon_humidityAndTemperatureSecond() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage1 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
                altIcon: 123,
                state: .notUsed,
                type: .second,
                userIcon: userIcon,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [])
    }
    
    func test_userIcon_thermometer() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage1 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_THERMOMETER,
                altIcon: 123,
                state: .notUsed,
                type: .single,
                userIcon: userIcon,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [])
    }
    
    func test_userIcon_garageDoorOpened() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage2 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
                altIcon: 123,
                state: .opened,
                type: .single,
                userIcon: userIcon,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [])
    }
    
    func test_userIcon_garageDoorPartialyOpened() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage3 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
                altIcon: 123,
                state: .partialyOpened,
                type: .single,
                userIcon: userIcon,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [])
    }
    
    func test_userIcon_garageDoorClosed() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage1 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            iconData: IconData(
                function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
                altIcon: 123,
                state: .closed,
                type: .single,
                userIcon: userIcon,
                nightMode: false
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [])
    }
}