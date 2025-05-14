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
        DiContainer.shared.register(type: GetDefaultIconNameUseCase.self, getDefaultIconNameUseCase!)
    }
    
    override func tearDown() {
        useCase = nil
        
        getDefaultIconNameUseCase = nil
    }
    
    func test_noIconForFirstType_whenNotHumidityAndTemperature() {
        // when
        expectFatalError(expectedMessage: "Wrong icon configuration (iconType: 'IconType(rawValue: 1)', function: '140'") {
            _ = self.useCase.invoke(
                iconData: FetchIconData(
                    function: SUPLA_CHANNELFNC_LIGHTSWITCH,
                    altIcon: 123,
                    profileId: 1,
                    state: .notUsed,
                    type: .first
                )
            )
        }
    }
    
    func test_defaultIcon_whenThereIsNoUserIcon() {
        // given
        getDefaultIconNameUseCase.returns = "uv-on"
        
        // when
        let icon = useCase.invoke(
            iconData: FetchIconData(
                function: SUPLA_CHANNELFNC_LIGHTSWITCH,
                altIcon: 123,
                profileId: 1,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(icon, .suplaIcon(name: "uv-on"))
    }
    
    func test_userIcon_activeState() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_LIGHTSWITCH,
            altIcon: 123,
            profileId: 1,
            state: .on,
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_inactiveState() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_LIGHTSWITCH,
            altIcon: 123,
            profileId: 1,
            state: .off,
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_humidityAndTemperatureFirst() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
            altIcon: 123,
            profileId: 1,
            state: .notUsed,
            type: .first
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_humidityAndTemperatureSecond() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
            altIcon: 123,
            profileId: 1,
            state: .notUsed,
            type: .second
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_thermometer() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_THERMOMETER,
            altIcon: 123,
            profileId: 1,
            state: .notUsed,
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_garageDoorOpened() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
            altIcon: 123,
            profileId: 1,
            state: .opened,
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_garageDoorPartialyOpened() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
            altIcon: 123,
            profileId: 1,
            state: .partialyOpened,
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_garageDoorClosed() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
            altIcon: 123,
            profileId: 1,
            state: .closed,
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_dimmerAndRgb_icon1() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING,
            altIcon: 123,
            profileId: 1,
            state: .complex([.off, .off]),
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_dimmerAndRgb_icon2() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING,
            altIcon: 123,
            profileId: 1,
            state: .complex([.on, .off]),
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_dimmerAndRgb_icon3() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING,
            altIcon: 123,
            profileId: 1,
            state: .complex([.off, .on]),
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
    
    func test_userIcon_dimmerAndRgb_icon4() {
        // given
        let iconData = FetchIconData(
            function: SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING,
            altIcon: 123,
            profileId: 1,
            state: .complex([.on, .on]),
            type: .single
        )
        
        // when
        let icon = useCase.invoke(iconData: iconData)
        
        // then
        XCTAssertNotNil(icon)
        // no call to get default icon means that the user icon was properly loaded.
        XCTAssertEqual(getDefaultIconNameUseCase.parameters, [iconData])
    }
}
