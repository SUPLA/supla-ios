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
        
        DiContainer.shared.register(type: GetChannelBaseIconUseCase.self, getChannelBaseIconUseCaseMock!)
        DiContainer.shared.register(type: GlobalSettings.self, GlobalSettingsImpl())
        DiContainer.shared.register(type: ValuesFormatter.self, ValuesFormatterImpl())
    }
    
    override func tearDown() {
        getChannelBaseIconUseCaseMock = nil
        useCase = nil
        super.tearDown()
    }
    
    func test_createTemperaturesList() {
        // given
        let channelWithChildren = ChannelWithChildren(channel: SAChannel.mock(123), children: [
            ChannelChild(channel: SAChannel.mock(234, function: SUPLA_CHANNELFNC_THERMOMETER), relation: SAChannelRelation.mock(type: .mainThermometer)),
            ChannelChild(channel: SAChannel.mock(345), relation: SAChannelRelation.mock(type: .default)),
            ChannelChild(channel: SAChannel.mock(456, function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE), relation: SAChannelRelation.mock(type: .auxThermometerFloor))
        ])
        
        // when
        let temperatures = useCase.invoke(channelWithChildren: channelWithChildren)
        
        // then
        XCTAssertEqual(temperatures, [
            MeasurementValue(id: 0, icon: .suplaIcon(name: ""), value: "---"),
            MeasurementValue(id: 1, icon: .suplaIcon(name: ""), value: "---"),
            MeasurementValue(id: 2, icon: .suplaIcon(name: ""), value: "---")
        ])
    }
    
    func test_createTemperaturesList_oneThermometer() {
        // given
        let channelWithChildren = ChannelWithChildren(channel: SAChannel.mock(123), children: [
            ChannelChild(channel: SAChannel.mock(234, function: SUPLA_CHANNELFNC_THERMOMETER), relation: SAChannelRelation.mock(type: .mainThermometer)),
            ChannelChild(channel: SAChannel.mock(345), relation: SAChannelRelation.mock(type: .default)),
        ])
        
        // when
        let temperatures = useCase.invoke(channelWithChildren: channelWithChildren)
        
        // then
        XCTAssertEqual(temperatures, [
            MeasurementValue(id: 0, icon: .suplaIcon(name: ""), value: "---"),
        ])
    }
    
    func test_createTemperaturesList_online() {
        // given
        var temperature: Int = 23400
        let value = SAChannelValue(testContext: nil)
        value.online = SUPLA_CHANNEL_ONLINE_FLAG_ONLINE
        value.value = NSData(bytes: &temperature, length: MemoryLayout<Int>.size)
        let channel = SAChannel.mock(234, function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE)
        channel.value = value
        
        let channelWithChildren = ChannelWithChildren(channel: SAChannel.mock(123), children: [
            ChannelChild(channel: channel, relation: SAChannelRelation.mock(type: .mainThermometer))
        ])
        
        // when
        let temperatures = useCase.invoke(channelWithChildren: channelWithChildren)
        
        // then
        XCTAssertEqual(temperatures, [
            MeasurementValue(id: 0, icon: .suplaIcon(name: ""), value: "23.4°"),
            MeasurementValue(id: 1, icon: .suplaIcon(name: ""), value: "0.0")
        ])
    }
    
    func test_createTemperaturesList_noThermometer() {
        // given
        let channelWithChildren = ChannelWithChildren(channel: SAChannel.mock(123), children: [])
        
        // when
        let temperatures = useCase.invoke(channelWithChildren: channelWithChildren)
        
        // then
        XCTAssertEqual(temperatures, [
            MeasurementValue(id: 0, icon: .suplaIcon(name: .Icons.fncUnknown), value: "---")
        ])
    }
}

