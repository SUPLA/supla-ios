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

final class ProvideDetailTypeUseCaseTests: XCTestCase {
    
    private lazy var useCase: ProvideDetailTypeUseCase! = { ProvideDetailTypeUseCaseImpl() }()
    
    override func tearDown() {
        useCase = nil
    }
    
    func test_shouldProvideRgbw_forDimmerFunction() {
        doTest(expectedResult: .legacy(type: .rgbw)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_DIMMER
            
            return channel
        }
    }
    
    func test_shouldProvideRgbw_forRgbFunction() {
        doTest(expectedResult: .legacy(type: .rgbw)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_RGBLIGHTING
            
            return channel
        }
    }
    
    func test_shouldProvideRgbw_forDimmerAndRgbFunction() {
        doTest(expectedResult: .legacy(type: .rgbw)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forRollerShutterFunction() {
        doTest(expectedResult: .legacy(type: .rs)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forRoofWindowFunction() {
        doTest(expectedResult: .legacy(type: .rs)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW
            
            return channel
        }
    }
    
    func test_shouldProvideEm_forEmFunction() {
        doTest(expectedResult: .legacy(type: .em)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_ELECTRICITY_METER
            
            return channel
        }
    }
    
    func test_shouldProvideElectricityIc_forElectricityMetterFunction() {
        doTest(expectedResult: .legacy(type: .ic)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_IC_ELECTRICITY_METER
            
            return channel
        }
    }
    
    func test_shouldProvideGasIc_forGasMetterFunction() {
        doTest(expectedResult: .legacy(type: .ic)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_IC_GAS_METER
            
            return channel
        }
    }
    
    func test_shouldProvideWaterIc_forWaterMetterFunction() {
        doTest(expectedResult: .legacy(type: .ic)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_IC_WATER_METER
            
            return channel
        }
    }
    
    func test_shouldProvideHeatIc_forHeatMetterFunction() {
        doTest(expectedResult: .legacy(type: .ic)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_IC_HEAT_METER
            
            return channel
        }
    }
    
    func test_shouldProvideTemp_forThermometerFunction() {
        doTest(expectedResult: .legacy(type: .temperature)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_THERMOMETER
            
            return channel
        }
    }
    
    func test_shouldProvideHumidityAndTemp_forHumidityAndTemperatureFunction() {
        doTest(expectedResult: .legacy(type: .temperature_humidity)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
            
            return channel
        }
    }
    
    func test_shouldProvideTempHp_forHomeplusThermostatFunction() {
        doTest(expectedResult: .legacy(type: .thermostat_hp)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
            
            return channel
        }
    }
    
    func test_shouldProvideDigiglass_forDigiglassVerticalFunction() {
        doTest(expectedResult: .legacy(type: .digiglass)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL
            
            return channel
        }
    }
    
    func test_shouldProvideDigiglass_forDigiglassHorizontalFunction() {
        doTest(expectedResult: .legacy(type: .digiglass)) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL
            
            return channel
        }
    }
    
    func test_shouldProvideNil_forUnsupportedFunction() {
        doTest(expectedResult: nil) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_RING
            
            return channel
        }
    }
    
    private func doTest(expectedResult: DetailType?, provider: () -> SAChannelBase) {
        // given
        let channel = provider()
        
        // when
        let type = useCase.invoke(channelBase: channel)
        
        // then
        XCTAssertEqual(type, expectedResult)
    }
}
