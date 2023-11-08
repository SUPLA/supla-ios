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

final class CreateTemperaturesListUseCaseTests: XCTestCase {
    
    private lazy var useCase: CreateTemperaturesListUseCase! = {
        CreateTemperaturesListUseCaseImpl()
    }()
    
    private lazy var getChannelBaseIconUseCaseMock: GetChannelBaseIconUseCaseMock! = {
        GetChannelBaseIconUseCaseMock()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, component: getChannelBaseIconUseCaseMock!)
        DiContainer.shared.register(type: GlobalSettings.self, component: GlobalSettingsImpl())
    }
    
    override func tearDown() {
        getChannelBaseIconUseCaseMock = nil
        useCase = nil
        super.tearDown()
    }
    
    func test_createTemperaturesList() {
        // given
        let channelWithChildren = ChannelWithChildren(channel: SAChannel.mock(123), children: [
            ChannelChild(channel: SAChannel.mock(234, SUPLA_CHANNELFNC_THERMOMETER), relationType: .mainThermometer),
            ChannelChild(channel: SAChannel.mock(345), relationType: .defaultType),
            ChannelChild(channel: SAChannel.mock(456, SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE), relationType: .auxThermometerFloor)
        ])
        
        // when
        let temperatures = useCase.invoke(channelWithChildren: channelWithChildren)
        
        // then
        XCTAssertEqual(temperatures, [
            MeasurementValue(icon: nil, value: "---"),
            MeasurementValue(icon: nil, value: "---"),
            MeasurementValue(icon: nil, value: "---")
        ])
    }
    
    func test_createTemperaturesList_oneThermometer() {
        // given
        let channelWithChildren = ChannelWithChildren(channel: SAChannel.mock(123), children: [
            ChannelChild(channel: SAChannel.mock(234, SUPLA_CHANNELFNC_THERMOMETER), relationType: .mainThermometer),
            ChannelChild(channel: SAChannel.mock(345), relationType: .defaultType),
        ])
        
        // when
        let temperatures = useCase.invoke(channelWithChildren: channelWithChildren)
        
        // then
        XCTAssertEqual(temperatures, [
            MeasurementValue(icon: nil, value: "---"),
        ])
    }
    
    func test_createTemperaturesList_online() {
        // given
        var temperature: Int32 = 23400
        let value = SAChannelValue(testContext: nil)
        value.online = true
        value.value = NSData(bytes: &temperature, length: MemoryLayout<Int>.size)
        let channel = SAChannel.mock(234, SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE)
        channel.value = value
        
        let channelWithChildren = ChannelWithChildren(channel: SAChannel.mock(123), children: [
            ChannelChild(channel: channel, relationType: .mainThermometer),
        ])
        
        // when
        let temperatures = useCase.invoke(channelWithChildren: channelWithChildren)
        
        // then
        XCTAssertEqual(temperatures, [
            MeasurementValue(icon: nil, value: "23.4°"),
            MeasurementValue(icon: nil, value: "---")
        ])
    }
}

