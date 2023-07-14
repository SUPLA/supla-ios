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
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_LIGHTSWITCH,
            userIcon: nil,
            channelState: .notUsed,
            altIcon: 123,
            iconType: .first,
            nightMode: false
        )
        
        // when
        XCTAssertNil(icon)
    }
    
    func test_defaultIcon_whenThereIsNoUserIcon() {
        // given
        getDefaultIconNameUseCase.returns = "uv-on"
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_LIGHTSWITCH,
            userIcon: nil,
            channelState: .on,
            altIcon: 123,
            iconType: .single,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(icon, UIImage(named: "uv-on"))
    }
    
    func test_defaultIconInNightMode_whenThereIsNoUserIcon() {
        // given
        getDefaultIconNameUseCase.returns = "uv-on"
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_LIGHTSWITCH,
            userIcon: nil,
            channelState: .on,
            altIcon: 123,
            iconType: .single,
            nightMode: true
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(icon, UIImage(named: "uv-on-nightmode"))
    }
    
    func test_userIcon_activeState() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage2 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_LIGHTSWITCH,
            userIcon: userIcon,
            channelState: .on,
            altIcon: 123,
            iconType: .single,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.functionsArray, [])
    }
    
    func test_userIcon_inactiveState() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage1 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_LIGHTSWITCH,
            userIcon: userIcon,
            channelState: .off,
            altIcon: 123,
            iconType: .single,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.functionsArray, [])
    }
    
    func test_userIcon_humidityAndTemperatureFirst() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage2 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
            userIcon: userIcon,
            channelState: .notUsed,
            altIcon: 123,
            iconType: .first,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.functionsArray, [])
    }
    
    func test_userIcon_humidityAndTemperatureSecond() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage1 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
            userIcon: userIcon,
            channelState: .notUsed,
            altIcon: 123,
            iconType: .second,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.functionsArray, [])
    }
    
    func test_userIcon_thermometer() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage1 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_THERMOMETER,
            userIcon: userIcon,
            channelState: .notUsed,
            altIcon: 123,
            iconType: .single,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.functionsArray, [])
    }
    
    func test_userIcon_garageDoorOpened() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage2 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
            userIcon: userIcon,
            channelState: .opened,
            altIcon: 123,
            iconType: .single,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.functionsArray, [])
    }
    
    func test_userIcon_garageDoorPartialyOpened() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage3 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
            userIcon: userIcon,
            channelState: .partialyOpened,
            altIcon: 123,
            iconType: .single,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.functionsArray, [])
    }
    
    func test_userIcon_garageDoorClosed() {
        // given
        let userIcon = SAUserIcon(testContext: nil)
        userIcon.uimage1 = NSData(data: (UIImage.iconTimer?.pngData())!)
        
        // when
        let icon = useCase.invoke(
            function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
            userIcon: userIcon,
            channelState: .closed,
            altIcon: 123,
            iconType: .single,
            nightMode: false
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.functionsArray, [])
    }
}
