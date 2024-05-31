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

final class GetChannelBaseDefaultCaptionUseCaseTests: XCTestCase {
    
    private lazy var useCase: GetChannelBaseDefaultCaptionUseCase! = {
        GetChannelBaseDefaultCaptionUseCaseImpl()
    }()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        useCase = nil
        
        super.tearDown()
    }
    
    func test_shouldGetCaption() {
        doTest(function: SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY, "Gateway opening sensor")
        doTest(function: SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK, "Gateway")
        doTest(function: SUPLA_CHANNELFNC_OPENINGSENSOR_GATE, "Gate opening sensor")
        doTest(function: SUPLA_CHANNELFNC_CONTROLLINGTHEGATE, "Gate")
        doTest(function: SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR, "Garage door opening sensor")
        doTest(function: SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR, "Garage door")
        doTest(function: SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR, "Door opening sensor")
        doTest(function: SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK, "Door")
        doTest(function: SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER, "Roller shutter opening sensor")
        doTest(function: SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW, "Roof window opening sensor")
        doTest(function: SUPLA_CHANNELFNC_HOTELCARDSENSOR, Strings.General.Channel.captionHotelCard)
        doTest(function: SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR, Strings.General.Channel.captionAlarmArmament)
        doTest(function: SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER, "Roller shutter")
        doTest(function: SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW, "Roof window")
        doTest(function: SUPLA_CHANNELFNC_POWERSWITCH, "Power switch")
        doTest(function: SUPLA_CHANNELFNC_LIGHTSWITCH, "Lighting switch")
        doTest(function: SUPLA_CHANNELFNC_STAIRCASETIMER, "Staircase timer")
        doTest(function: SUPLA_CHANNELFNC_THERMOMETER, "Thermometer")
        doTest(function: SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE, "Temperature and humidity")
        doTest(function: SUPLA_CHANNELFNC_HUMIDITY, "Humidity")
        doTest(function: SUPLA_CHANNELFNC_NOLIQUIDSENSOR, "No liquid sensor")
        doTest(function: SUPLA_CHANNELFNC_RGBLIGHTING, "RGB Lighting")
        doTest(function: SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING, "Dimmer and RGB lighting")
        doTest(function: SUPLA_CHANNELFNC_DIMMER, "Dimmer")
        doTest(function: SUPLA_CHANNELFNC_DISTANCESENSOR, "Distance sensor")
        doTest(function: SUPLA_CHANNELFNC_DEPTHSENSOR, "Depth sensor")
        doTest(function: SUPLA_CHANNELFNC_WINDSENSOR, "Wind sensor")
        doTest(function: SUPLA_CHANNELFNC_WEIGHTSENSOR, "Weight sensor")
        doTest(function: SUPLA_CHANNELFNC_PRESSURESENSOR, "Pressure sensor")
        doTest(function: SUPLA_CHANNELFNC_RAINSENSOR, "Rain sensor")
        doTest(function: SUPLA_CHANNELFNC_MAILSENSOR, "Mail sensor")
        doTest(function: SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW, "Window opening sensor")
        doTest(function: SUPLA_CHANNELFNC_ELECTRICITY_METER, "Electricity Meter")
        doTest(function: SUPLA_CHANNELFNC_IC_ELECTRICITY_METER, "Electricity Meter")
        doTest(function: SUPLA_CHANNELFNC_IC_GAS_METER, "Gas Meter")
        doTest(function: SUPLA_CHANNELFNC_IC_WATER_METER, "Water Meter")
        doTest(function: SUPLA_CHANNELFNC_IC_HEAT_METER, "Heat Meter")
        doTest(function: SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS, "Home+ Heater")
        doTest(function: SUPLA_CHANNELFNC_VALVE_OPENCLOSE, "Valve")
        doTest(function: SUPLA_CHANNELFNC_VALVE_PERCENTAGE, "Valve")
        doTest(function: SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL, "Digiglass")
        doTest(function: SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL, "Digiglass")
        doTest(function: SUPLA_CHANNELFNC_HVAC_THERMOSTAT, "Thermostat")
        doTest(function: SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER, "Thermostat")
        doTest(function: SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT, Strings.General.Channel.captionGeneralPurposeMeasurement)
        doTest(function: SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER, Strings.General.Channel.captionGeneralPurposeMeter)
        doTest(function: SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND, Strings.General.Channel.captionFacadeBlinds)
        doTest(function: SUPLA_CHANNELFNC_TERRACE_AWNING, Strings.General.Channel.captionTerraceAwning)
        doTest(function: SUPLA_CHANNELFNC_PROJECTOR_SCREEN, Strings.General.Channel.captionProjectorScreen)
        doTest(function: SUPLA_CHANNELFNC_CURTAIN, Strings.General.Channel.captionCurtain)
        doTest(function: SUPLA_CHANNELFNC_VERTICAL_BLIND, Strings.General.Channel.captionVerticalBlind)
        doTest(function: SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR, Strings.General.Channel.captionGarageDoor)
        doTest(function: -1, "Not supported function")
    }
    
    private func doTest(function: Int32, _ expectedCaption: String) {
        // when
        let caption = useCase.invoke(function: function)
        
        // then
        XCTAssertEqual(caption, expectedCaption)
    }
}
