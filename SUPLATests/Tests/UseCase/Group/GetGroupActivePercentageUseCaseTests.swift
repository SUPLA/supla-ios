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

final class GroupActivePercentageUseCaseTests: XCTestCase {
    
    private lazy var useCase: GetGroupActivePercentageUseCase! = GetGroupActivePercentageUseCaseImpl()
    
    func test_shouldGetActivePercentageForPowerSwitchGroup() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_POWERSWITCH
        group.total_value = GroupTotalValue(values: [
            BoolGroupValue(value: true),
            BoolGroupValue(value: false),
            BoolGroupValue(value: true),
            BoolGroupValue(value: true)
        ])
        
        // when
        let activePercentage = useCase.invoke(group)
        
        // then
        XCTAssertEqual(activePercentage, 75)
    }
    
    func test_shouldGetActivePercentageForRollerShutter() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER
        group.total_value = GroupTotalValue(values: [
            RollerShutterGroupValue(position: 100, closedSensorActive: false),
            RollerShutterGroupValue(position: 0, closedSensorActive: false),
            RollerShutterGroupValue(position: 0, closedSensorActive: true),
            RollerShutterGroupValue(position: 100, closedSensorActive: true)
        ])
        
        // when
        let activePercentage = useCase.invoke(group)
        
        // then
        XCTAssertEqual(activePercentage, 75)
    }
    
    func test_shouldGetActivePercentageForFacadeBlind() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
        group.total_value = GroupTotalValue(values: [
            FacadeBlindGroupValue(position: 100, tilt: 10),
            FacadeBlindGroupValue(position: 0, tilt: 30),
            FacadeBlindGroupValue(position: 20, tilt: 0),
            FacadeBlindGroupValue(position: 80, tilt: 90)
        ])
        
        // when
        let activePercentage = useCase.invoke(group)
        
        // then
        XCTAssertEqual(activePercentage, 25)
    }
    
    func test_shouldGetActivePercentageForProjectorScreen() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_PROJECTOR_SCREEN
        group.total_value = GroupTotalValue(values: [
            IntegerGroupValue(value: 100),
            IntegerGroupValue(value: 30),
            IntegerGroupValue(value: 0),
            IntegerGroupValue(value: 90)
        ])
        
        // when
        let activePercentage = useCase.invoke(group)
        
        // then
        XCTAssertEqual(activePercentage, 25)
    }
    
    func test_shouldGetActivePercentageForDimmer() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_DIMMER
        group.total_value = GroupTotalValue(values: [
            IntegerGroupValue(value: 100),
            IntegerGroupValue(value: 30),
            IntegerGroupValue(value: 0),
            IntegerGroupValue(value: 90)
        ])
        
        // when
        let activePercentage = useCase.invoke(group)
        
        // then
        XCTAssertEqual(activePercentage, 75)
    }
    
    func test_shouldGetActivePercentageForRgb() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_RGBLIGHTING
        group.total_value = GroupTotalValue(values: [
            RgbLightingGroupValue(color: .suplaGreen, brightness: 25),
            RgbLightingGroupValue(color: .suplaGreen, brightness: 30),
            RgbLightingGroupValue(color: .suplaGreen, brightness: 0),
            RgbLightingGroupValue(color: .suplaGreen, brightness: 90)
        ])
        
        // when
        let activePercentage = useCase.invoke(group)
        
        // then
        XCTAssertEqual(activePercentage, 75)
    }
    
    func test_shouldGetActivePercentageForDimmerAndRgb_all() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        group.total_value = GroupTotalValue(values: [
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 10, brightness: 25),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 0, brightness: 30),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 0, brightness: 0),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 10, brightness: 0)
        ])
        
        // when
        let activePercentage = useCase.invoke(group)
        
        // then
        XCTAssertEqual(activePercentage, 50)
    }
    
    func test_shouldGetActivePercentageForDimmerAndRgb_brightness() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        group.total_value = GroupTotalValue(values: [
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 10, brightness: 25),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 0, brightness: 30),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 0, brightness: 0),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 10, brightness: 0),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 10, brightness: 10),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 10, brightness: 10)
        ])
        
        // when
        let activePercentage = useCase.invoke(group, valueIndex: 2)
        
        // then
        XCTAssertEqual(activePercentage, 66)
    }
    
    func test_shouldGetActivePercentageForDimmerAndRgb_colorBrightness() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        group.total_value = GroupTotalValue(values: [
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 10, brightness: 25),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 0, brightness: 30),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 0, brightness: 0),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 0, brightness: 0),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 0, brightness: 10),
            DimmerAndRgbLightingGroupValue(color: .suplaGreen, colorBrightness: 10, brightness: 10)
        ])
        
        // when
        let activePercentage = useCase.invoke(group, valueIndex: 1)
        
        // then
        XCTAssertEqual(activePercentage, 33)
    }
    
    func test_shouldGetActivePercentageForHeatpolThermostat() {
        // given
        let group = SAChannelGroup(testContext: nil)
        group.func = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
        group.total_value = GroupTotalValue(values: [
            HeatpolThermostatGroupValue(on: true, measuredTemperature: 0, presetTemperature: 0),
            HeatpolThermostatGroupValue(on: false, measuredTemperature: 0, presetTemperature: 30),
            HeatpolThermostatGroupValue(on: true, measuredTemperature: 20, presetTemperature: 20),
            HeatpolThermostatGroupValue(on: true, measuredTemperature: 30, presetTemperature: 0),
        ])
        
        // when
        let activePercentage = useCase.invoke(group)
        
        // then
        XCTAssertEqual(activePercentage, 75)
    }
}
