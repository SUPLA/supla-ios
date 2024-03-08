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

final class GetChannelValueStringUseCaseTests: XCTestCase {
    
    private lazy var depthValueProvider: DepthValueProviderMock! = {
        DepthValueProviderMock()
    }()
    
    private lazy var distanceValueProvider: DistanceValueProviderMock! = {
        DistanceValueProviderMock()
    }()
    
    private lazy var gpmValueProvider: GpmValueProviderMock! = {
        GpmValueProviderMock()
    }()
    
    private lazy var humidityValueProvider: HumidityValueProviderMock! = {
        HumidityValueProviderMock()
    }()
    
    private lazy var pressureValueProvider: PressureValueProviderMock! = {
        PressureValueProviderMock()
    }()
    
    private lazy var rainValueProvider: RainValueProviderMock! = {
        RainValueProviderMock()
    }()
    
    private lazy var thermometerAndHumidityValueProvider: ThermometerAndHumidityValueProviderMock! = {
        ThermometerAndHumidityValueProviderMock()
    }()
    
    private lazy var thermometerValueProvider: ThermometerValueProviderMock! = {
        ThermometerValueProviderMock()
    }()
    
    private lazy var weightValueProvider: WeightValueProviderMock! = {
        WeightValueProviderMock()
    }()
    
    private lazy var windValueProvider: WindValueProviderMock! = {
        WindValueProviderMock()
    }()
    
    private lazy var useCase: GetChannelValueStringUseCase! = {
        GetChannelValueStringUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
        
        DiContainer.shared.register(type: DepthValueProvider.self, depthValueProvider!)
        DiContainer.shared.register(type: DistanceValueProvider.self, distanceValueProvider!)
        DiContainer.shared.register(type: GpmValueProvider.self, gpmValueProvider!)
        DiContainer.shared.register(type: HumidityValueProvider.self, humidityValueProvider!)
        DiContainer.shared.register(type: PressureValueProvider.self, pressureValueProvider!)
        DiContainer.shared.register(type: RainValueProvider.self, rainValueProvider!)
        DiContainer.shared.register(type: ThermometerAndHumidityValueProvider.self, thermometerAndHumidityValueProvider!)
        DiContainer.shared.register(type: ThermometerValueProvider.self, thermometerValueProvider!)
        DiContainer.shared.register(type: WeightValueProvider.self, weightValueProvider!)
        DiContainer.shared.register(type: WindValueProvider.self, windValueProvider!)
    }
    
    override func tearDown() {
        useCase = nil
        depthValueProvider = nil
        gpmValueProvider = nil
        humidityValueProvider = nil
        pressureValueProvider = nil
        rainValueProvider = nil
        thermometerAndHumidityValueProvider = nil
        thermometerValueProvider = nil
        weightValueProvider = nil
        windValueProvider = nil
        
        super.tearDown()
    }
    
    func test_shouldGetNoValueText_whenChannelIsOffline() {
        // given
        let channel = SAChannel.mock(value: SAChannelValue.mock(online: false))
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, NO_VALUE_TEXT)
    }
    
    func test_shouldGetNoValueTest_whenNoProviderFound() {
        // given
        let channel = SAChannel.mock(function: -1, value: SAChannelValue.mock(online: true))
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, NO_VALUE_TEXT)
    }
    
    func test_shouldGetDepthValueStringInMeters() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_DEPTHSENSOR,
            value: SAChannelValue.mock(online: true)
        )
        depthValueProvider.valueReturns = 25.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "25.0 m")
    }
    
    func test_shouldGetDepthValueStringInKilometers() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_DEPTHSENSOR,
            value: SAChannelValue.mock(online: true)
        )
        depthValueProvider.valueReturns = 25000.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "25.0 km")
    }
    
    func test_shouldGetDepthValueStringInCentimeters() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_DEPTHSENSOR,
            value: SAChannelValue.mock(online: true)
        )
        depthValueProvider.valueReturns = 0.025
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "2.5 cm")
    }
    
    func test_shouldGetDepthValueStringInMilimeters() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_DEPTHSENSOR,
            value: SAChannelValue.mock(online: true)
        )
        depthValueProvider.valueReturns = 0.0025
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "2.5 mm")
    }
    
    func test_shouldGetDepthValueStringInMilimetersWithoutUnit() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_DEPTHSENSOR,
            value: SAChannelValue.mock(online: true)
        )
        depthValueProvider.valueReturns = 0.0025
        
        // when
        let valueText = useCase.invoke(channel, withUnit: false)
        
        // then
        XCTAssertEqual(valueText, "2.5")
    }
    
    func test_shouldGetDistanceValueStringInMeters() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_DISTANCESENSOR,
            value: SAChannelValue.mock(online: true)
        )
        distanceValueProvider.valueReturns = 25.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "25.0 m")
    }
    
    func test_shouldGetGpmValueString() {
        // given
        let config = SuplaChannelGeneralPurposeMeterConfig.mock(
            valuePrecision: 2,
            unitBeforValue: "$",
            unitAfterValue: "k",
            noSpaceBeforeValue: true
        )
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
            value: SAChannelValue.mock(online: true),
            config: SAChannelConfig.mock(type: .generalPurposeMeter, config: config.toJson())
        )
        gpmValueProvider.valueReturns = 12.50
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "$12.50 k")
    }
    
    func test_shouldGetGpmValueString_whenValueIsNan() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
            value: SAChannelValue.mock(online: true)
        )
        gpmValueProvider.valueReturns = Double.nan
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, NO_VALUE_TEXT)
    }
    
    func test_shouldGetGpmValueString_whenNoConfigFound() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
            value: SAChannelValue.mock(online: true)
        )
        gpmValueProvider.valueReturns = 12.443
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "12")
    }
    
    func test_shouldGetHumidityValueString() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_HUMIDITY,
            value: SAChannelValue.mock(online: true)
        )
        humidityValueProvider.valueReturns = 25.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "25.0%")
    }
    
    func test_shouldGetPressureValueString() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_PRESSURESENSOR,
            value: SAChannelValue.mock(online: true)
        )
        pressureValueProvider.valueReturns = 25.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "25 hPa")
    }
    
    func test_shouldGetRainValueString() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_RAINSENSOR,
            value: SAChannelValue.mock(online: true)
        )
        rainValueProvider.valueReturns = 250.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "0.25 l/m²")
    }
    
    func test_shouldGetTemperatureAndHumidityValueString_temperature() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
            value: SAChannelValue.mock(online: true)
        )
        thermometerAndHumidityValueProvider.valueReturns = 25.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "25.0 °C")
    }
    
    func test_shouldGetTemperatureAndHumidityValueString_humidity() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
            value: SAChannelValue.mock(online: true)
        )
        thermometerAndHumidityValueProvider.valueReturns = 25.0
        
        // when
        let valueText = useCase.invoke(channel, valueType: .second)
        
        // then
        XCTAssertEqual(valueText, "25.0%")
    }
    
    func test_shouldGetWeightValueString() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_WEIGHTSENSOR,
            value: SAChannelValue.mock(online: true)
        )
        weightValueProvider.valueReturns = 25.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "25 g")
    }
    
    func test_shouldGetWindValueString() {
        // given
        let channel = SAChannel.mock(
            function: SUPLA_CHANNELFNC_WINDSENSOR,
            value: SAChannelValue.mock(online: true)
        )
        windValueProvider.valueReturns = 25.0
        
        // when
        let valueText = useCase.invoke(channel)
        
        // then
        XCTAssertEqual(valueText, "25.0 l/m²")
    }
}
