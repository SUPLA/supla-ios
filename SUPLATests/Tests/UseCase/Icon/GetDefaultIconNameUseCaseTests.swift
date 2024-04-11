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

final class GetDefaultIconNameUseCaseTests: XCTestCase {
    
    private lazy var useCase: GetDefaultIconNameUseCase! = { GetDefaultIconNameUseCaseImpl() }()
    
    override func tearDown() {
        useCase = nil
    }
    
    func test_gatewayActiveIcon() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gateway-open")
    }
    
    func test_gatewayInactiveIcon() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gateway-closed")
    }
    
    func test_gatewayLockActiveIcon() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gateway-open")
    }
    
    func test_gatewayLockInactiveIcon() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gateway-closed")
    }
    
    func test_controllingGate50PercentAltIcon0() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .partialyOpened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gate-closed-50percent")
    }
    
    func test_controllingGate50PercentAltIcon1() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .partialyOpened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gatealt1-closed-50percent")
    }
    
    func test_controllingGate50PercentAltIcon2() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 2,
                state: .partialyOpened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "barier-closed")
    }
    
    func test_controllingGateOpened() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gate-open")
    }
    
    func test_controllingGateClosed() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gate-closed")
    }
    
    func test_openingSensorAltIcon0() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GATE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gate-open")
    }
    
    func test_openingSensorAltIcon1() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GATE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "gatealt1-closed")
    }
    
    func test_openingSensorAltIcon2() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GATE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 2,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "barier-open")
    }
    
    func test_garageDoorSensor50Percent() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .partialyOpened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "garagedoor-closed-50percent")
    }
    
    func test_garageDoorSensorOpened() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "garagedoor-open")
    }
    
    func test_garageDoorSensorClosed() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "garagedoor-closed")
    }
    
    func test_doorSensorOpened() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "door-open")
    }
    
    func test_doorSensorClosed() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "door-closed")
    }
    
    func test_rollershutterSensorOpened() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "rollershutter-open")
    }
    
    func test_rollershutterSensorClosed() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "rollershutter-closed")
    }
    
    func test_roofwindowSensorOpened() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "roofwindow-open")
    }
    
    func test_roofwindowSensorClosed() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "roofwindow-closed")
    }
    
    func test_powerSwitchAltIcon0() {
        // given
        let function = SUPLA_CHANNELFNC_POWERSWITCH
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_power-on")
    }
    
    func test_powerSwitchAltIcon1() {
        // given
        let function = SUPLA_CHANNELFNC_POWERSWITCH
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "tv-off")
    }
    
    func test_powerSwitchAltIcon2() {
        // given
        let function = SUPLA_CHANNELFNC_POWERSWITCH
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 2,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "radio-on")
    }
    
    func test_powerSwitchAltIcon3() {
        // given
        let function = SUPLA_CHANNELFNC_POWERSWITCH
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 3,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "pc-off")
    }
    
    func test_powerSwitchAltIcon4() {
        // given
        let function = SUPLA_CHANNELFNC_POWERSWITCH
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 4,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fan-on")
    }
    
    func test_lightSwitchAltIcon0() {
        // given
        let function = SUPLA_CHANNELFNC_LIGHTSWITCH
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "light-on")
    }
    
    func test_lightSwitchAltIcon1() {
        // given
        let function = SUPLA_CHANNELFNC_LIGHTSWITCH
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "xmastree-off")
    }
    
    func test_lightSwitchAltIcon2() {
        // given
        let function = SUPLA_CHANNELFNC_LIGHTSWITCH
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 2,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "uv-on")
    }
    
    func test_staircaseTimerAltIcon0() {
        // given
        let function = SUPLA_CHANNELFNC_STAIRCASETIMER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "staircasetimer-on")
    }
    
    func test_staircaseTimerAltIcon1() {
        // given
        let function = SUPLA_CHANNELFNC_STAIRCASETIMER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "staircasetimer_1-off")
    }
    
    func test_thermometerIcon() {
        // given
        let function = SUPLA_CHANNELFNC_THERMOMETER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "thermometer")
    }
    
    func test_humidityAndThermometerFirstIcon() {
        // given
        let function = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "thermometer")
    }
    
    func test_humidityAndThermometerSecondIcon() {
        // given
        let function = SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .second
            )
        )
        
        // then
        XCTAssertEqual(iconName, "humidity")
    }
    
    func test_humidityIcon() {
        // given
        let function = SUPLA_CHANNELFNC_HUMIDITY
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "humidity")
    }
    
    func test_liquidSensorActive() {
        // given
        let function = SUPLA_CHANNELFNC_NOLIQUIDSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "liquid")
    }
    
    func test_liquidSensorInactive() {
        // given
        let function = SUPLA_CHANNELFNC_NOLIQUIDSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "noliquid")
    }
    
    func test_dimmerActive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "dimmer-on")
    }
    
    func test_dimmerInactive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "dimmer-off")
    }
    
    func test_rgbActive() {
        // given
        let function = SUPLA_CHANNELFNC_RGBLIGHTING
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "rgb-on")
    }
    
    func test_rgbInactive() {
        // given
        let function = SUPLA_CHANNELFNC_RGBLIGHTING
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "rgb-off")
    }
    
    func test_dimmerAndRgbActive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .complex([.on, .on]),
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "dimmerrgb-onon")
    }
    
    func test_dimmerAndRgbInctive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .complex([.off, .off]),
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "dimmerrgb-offoff")
    }
    
    func test_dimmerAndRgbActiveInactive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .complex([.off, .on]),
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "dimmerrgb-offon")
    }
    
    func test_dimmerAndRgbInactiveActive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .complex([.on, .off]),
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "dimmerrgb-onoff")
    }
    
    func test_dimmerAndRgbFail_whenWrongState() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        
        // when
        expectFatalError(expectedMessage: "Dimmer and RGB function needs complex state") {
            _ = self.useCase.invoke(
                iconData: IconData(
                    function: function,
                    altIcon: 0,
                    state: .notUsed,
                    type: .single
                )
            )
        }
    }
    
    func test_dimmerAndRgbFail_whenWrongValues() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        
        // when
        expectFatalError(expectedMessage: "Dimmer and RGB function needs complex with two values but got [SUPLA.ChannelState.on, SUPLA.ChannelState.off, SUPLA.ChannelState.on]") {
            _ = self.useCase.invoke(
                iconData: IconData(
                    function: function,
                    altIcon: 0,
                    state: .complex([.on, .off, .on]),
                    type: .single
                )
            )
        }
    }
    
    func test_windowOpened() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "window-open")
    }
    
    func test_windowClosed() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "window-closed")
    }
    
    func test_mailActive() {
        // given
        let function = SUPLA_CHANNELFNC_MAILSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "mail")
    }
    
    func test_mailInactive() {
        // given
        let function = SUPLA_CHANNELFNC_MAILSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "nomail")
    }
    
    func test_electricityMeterAltIcon0() {
        // given
        let function = SUPLA_CHANNELFNC_ELECTRICITY_METER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, .Icons.fncElectricitymeter)
    }
    
    func test_electricityMeterAltIcon1() {
        // given
        let function = SUPLA_CHANNELFNC_IC_ELECTRICITY_METER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "powerstation")
    }
    
    func test_gasmeterIcon() {
        // given
        let function = SUPLA_CHANNELFNC_IC_GAS_METER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_gasmeter")
    }
    
    func test_watermeterIcon() {
        // given
        let function = SUPLA_CHANNELFNC_IC_WATER_METER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_watermeter")
    }
    
    func test_heatmeterIcon() {
        // given
        let function = SUPLA_CHANNELFNC_IC_HEAT_METER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_heatmeter")
    }
    
    func test_heatpolHomeplusAltIcon0() {
        // given
        let function = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "thermostat_hp_homeplus-on")
    }
    
    func test_heatpolHomeplusAltIcon1() {
        // given
        let function = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "thermostat_hp_homeplus1-off")
    }
    
    func test_heatpolHomeplusAltIcon2() {
        // given
        let function = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 2,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "thermostat_hp_homeplus2-on")
    }
    
    func test_heatpolHomeplusAltIcon3() {
        // given
        let function = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 3,
                state: .off,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "thermostat_hp_homeplus3-off")
    }
    
    func test_heatpolHomeplusAltIcon4() {
        // given
        let function = SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 4,
                state: .on,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "thermostat_hp_homeplus-on")
    }
    
    func test_distanceIcon() {
        // given
        let function = SUPLA_CHANNELFNC_DISTANCESENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "distance")
    }
    
    func test_depthIcon() {
        // given
        let function = SUPLA_CHANNELFNC_DEPTHSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "depth")
    }
    
    func test_windIcon() {
        // given
        let function = SUPLA_CHANNELFNC_WINDSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "wind")
    }
    
    func test_pressureIcon() {
        // given
        let function = SUPLA_CHANNELFNC_PRESSURESENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "pressure")
    }
    
    func test_weightIcon() {
        // given
        let function = SUPLA_CHANNELFNC_WEIGHTSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "weight")
    }
    
    func test_rainIcon() {
        // given
        let function = SUPLA_CHANNELFNC_RAINSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "rain")
    }
    
    func test_valveOpenedIcon() {
        // given
        let function = SUPLA_CHANNELFNC_VALVE_OPENCLOSE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opened,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "valve-open")
    }
    
    func test_valveClosedIcon() {
        // given
        let function = SUPLA_CHANNELFNC_VALVE_PERCENTAGE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .closed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "valve-closed")
    }
    
    func test_digiglassHorizontalAltIcon0() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opaque,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "digiglass")
    }
    
    func test_digiglassHorizontalAltIcon1() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .transparent,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "digiglass1-transparent")
    }
    
    func test_digiglassVerticalAltIcon0Active() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .transparent,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "digiglassv-transparent")
    }
    
    func test_digiglassVerticalAltIcon0Inactive() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .opaque,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "digiglass")
    }
    
    func test_digiglassVerticalAltIcon1Active() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .transparent,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "digiglassv1-transparent")
    }
    
    func test_digiglassVerticalAltIcon1Inactive() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .opaque,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "digiglass1")
    }
    
    func test_unknownChannelFunction() {
        // given
        let function = SUPLA_CHANNELFNC_NONE
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 1,
                state: .opaque,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "unknown_channel")
    }
    
    func test_thermostatFunctionHeat() {
        // given
        let function = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single,
                subfunction: .heat
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_thermostat_heat")
    }
    
    func test_thermostatFunctionCool() {
        // given
        let function = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single,
                subfunction: .cool
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_thermostat_cool")
    }
    
    func test_thermostatFunctionDhw() {
        // given
        let function = SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_thermostat_dhw")
    }
    
    func test_thermostatFunctionNotSet() {
        // given
        let function = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .notUsed,
                type: .single,
                subfunction: .notSet
            )
        )
        
        // then
        XCTAssertEqual(iconName, "unknown_channel")
    }
    
    func test_hotelCardFunctionOn() {
        // given
        let function = SUPLA_CHANNELFNC_HOTELCARDSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single,
                subfunction: .notSet
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_hotel_card-on")
    }
    
    func test_hotelCardFunctionOff() {
        // given
        let function = SUPLA_CHANNELFNC_HOTELCARDSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .off,
                type: .single,
                subfunction: .notSet
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_hotel_card-off")
    }
    
    func test_alarmArmamentFunctionOn() {
        // given
        let function = SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .on,
                type: .single,
                subfunction: .notSet
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_alarm_armament-on")
    }
    
    func test_alarmArmamentFunctionOff() {
        // given
        let function = SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR
        
        // when
        let iconName = useCase.invoke(
            iconData: IconData(
                function: function,
                altIcon: 0,
                state: .off,
                type: .single,
                subfunction: .notSet
            )
        )
        
        // then
        XCTAssertEqual(iconName, "fnc_alarm_armament-off")
    }
}
