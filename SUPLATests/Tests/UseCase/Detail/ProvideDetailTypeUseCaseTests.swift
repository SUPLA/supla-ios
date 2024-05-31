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
        doTest(expectedResult: .windowDetail(pages: [.rollerShutter])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forRoofWindowFunction() {
        doTest(expectedResult: .windowDetail(pages: [.roofWindow])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forFacadeBlindFunction() {
        doTest(expectedResult: .windowDetail(pages: [.facadeBlind])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forTerraceAwningFunction() {
        doTest(expectedResult: .windowDetail(pages: [.terraceAwning])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_TERRACE_AWNING
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forProjectorScreenFunction() {
        doTest(expectedResult: .windowDetail(pages: [.projectorScreen])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_PROJECTOR_SCREEN
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forCurtainFunction() {
        doTest(expectedResult: .windowDetail(pages: [.curtain])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_CURTAIN
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forVerticalBlindFunction() {
        doTest(expectedResult: .windowDetail(pages: [.verticalBlind])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_VERTICAL_BLIND
            
            return channel
        }
    }
    
    func test_shouldProvideRs_forGarageDoorFunction() {
        doTest(expectedResult: .windowDetail(pages: [.garageDoor])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR
            
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
        doTest(expectedResult: .thermometerDetail(pages: [.thermometerHistory])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_THERMOMETER
            
            return channel
        }
    }
    
    func test_shouldProvideHumidityAndTemp_forHumidityAndTemperatureFunction() {
        doTest(expectedResult: .thermometerDetail(pages: [.thermometerHistory])) {
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
    
    func test_shouldProvideStandardDetailWithGeneralPage_forGroupOfSwitches() {
        doTest(expectedResult: .switchDetail(pages: [.switchGeneral])) {
            let channel = SAChannelBase(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_LIGHTSWITCH
            
            return channel
        }
    }
    
    func test_shouldProvideStandardDetailWithGeneralPage_forChannelWithoutFlags() {
        doTest(expectedResult: .switchDetail(pages: [.switchGeneral])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_LIGHTSWITCH
            
            return channel
        }
    }
    
    func test_shouldProvideStandardDetailWithGeneralAndTimer_forChannelWithTimer() {
        doTest(expectedResult: .switchDetail(pages: [.switchGeneral, .switchTimer])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_LIGHTSWITCH
            channel.flags = Int64(SUPLA_CHANNEL_FLAG_COUNTDOWN_TIMER_SUPPORTED)
            
            return channel
        }
    }
    
    func test_shouldProvideStandardDetailWithGeneralOnly_forStaircaseWithTimer() {
        doTest(expectedResult: .switchDetail(pages: [.switchGeneral])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_STAIRCASETIMER
            channel.flags = Int64(SUPLA_CHANNEL_FLAG_COUNTDOWN_TIMER_SUPPORTED)
            
            return channel
        }
    }
    
    func test_shouldProvideStandardDetailWithGeneralTimerAndIC() {
        doTest(expectedResult: .switchDetail(pages: [.switchGeneral, .switchTimer, .historyIc])) {
            let value = SAChannelValue(testContext: nil)
            value.sub_value_type = Int16(SUBV_TYPE_IC_MEASUREMENTS)
            
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_POWERSWITCH
            channel.flags = Int64(SUPLA_CHANNEL_FLAG_COUNTDOWN_TIMER_SUPPORTED)
            channel.value = value
            
            return channel
        }
    }
    
    func test_shouldProvideStandardDetailWithGeneralAndIC() {
        doTest(expectedResult: .switchDetail(pages: [.switchGeneral, .historyEm])) {
            let value = SAChannelValue(testContext: nil)
            value.sub_value_type = Int16(SUBV_TYPE_ELECTRICITY_MEASUREMENTS)
            
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_POWERSWITCH
            channel.value = value
            
            return channel
        }
    }
    
    func test_shouldProvideThermostatDetail() {
        doTest(expectedResult: .thermostatDetail(pages: [.thermostatGeneral, .schedule, .thermostatTimer, .thermostatHistory])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
            
            return channel
        }
    }
    
    func test_shouldProvideGpmHistory_forGeneralPurposeMeter() {
        doTest(expectedResult: .gpmDetail(pages: [.gpmHistory])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER
            
            return channel
        }
    }
    
    func test_shouldProvideGpmHistory_forGeneralPurposeMeteasurement() {
        doTest(expectedResult: .gpmDetail(pages: [.gpmHistory])) {
            let channel = SAChannel(testContext: nil)
            channel.func = SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT
            
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
