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

import SharedCore

protocol GetDefaultIconNameUseCase {
    func invoke(iconData: IconData) -> String
}

protocol IconNameProducer {
    func accepts(function: Int32) -> Bool
    func produce(iconData: IconData) -> String
}

struct IconData: Changeable, Equatable {
    let function: Int32
    let altIcon: Int32
    var state: ChannelState = .notUsed
    var type: IconType = .single
    var userIcon: SAUserIcon? = nil
    var subfunction: ThermostatSubfunction? = nil // Thermostat specific parameter
}

extension IconNameProducer {
    func addStateSufix(name: String, state: ChannelState) -> String {
        switch (state) {
        case .opened: return String(format: "%@-%@", name, "open")
        case .partialyOpened, .closed: return String(format: "%@-%@", name, "closed")
        case .on: return String(format: "%@-%@", name, "on")
        case .off: return String(format: "%@-%@", name, "off")
        case .transparent: return String(format: "%@-%@", name, "transparent")
        default: return name
        }
    }
}

final class GetDefaultIconNameUseCaseImpl: GetDefaultIconNameUseCase {
    func invoke(iconData: IconData) -> String {
        var name: String? = nil
        for producer in producers {
            if (producer.accepts(function: iconData.function)) {
                name = producer.produce(iconData: iconData)
            }
        }
        if let name = name {
            return name
        } else {
            return .Icons.fncUnknown
        }
    }

    let producers: [IconNameProducer] = [
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY, name: "gateway"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK, name: "gateway"),
        GateIconNameProducer(),
        GarageDoorIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR, name: "door"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK, name: "door"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER, name: "fnc_roller_shutter"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER, name: "fnc_roller_shutter"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW, name: "roofwindow"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW, name: "roofwindow"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND, name: "fnc_facade_blind"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_TERRACE_AWNING, name: "fnc_terrace_awning"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_PROJECTOR_SCREEN, name: "fnc_projector_screen"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CURTAIN, name: "fnc_curtain"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_VERTICAL_BLIND, name: "fnc_vertical_blind"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR, name: "fnc_garage_door"),
        PowerSwitchIconNameProducer(),
        LightSwitchIconNameProducer(),
        StaircaseTimerIconNameProducer(),
        HumidityAndThermometerIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_HUMIDITY, name: "humidity", withSuffix: false),
        LiquidSensorIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_DIMMER, name: "dimmer"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_RGBLIGHTING, name: "rgb"),
        DimmerAndRgbLightningIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW, name: "window"),
        MailSensorIconNameProducer(),
        ElelectricityMeterIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_IC_GAS_METER, name: .Icons.fncGasemeter, withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_IC_WATER_METER, name: .Icons.fncWatermeter, withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_IC_HEAT_METER, name: .Icons.fncHeatmeter, withSuffix: false),
        HeatpolHomeplusIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_DISTANCESENSOR, name: "distance", withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_DEPTHSENSOR, name: "depth", withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_WINDSENSOR, name: "wind", withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_PRESSURESENSOR, name: "pressure", withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_WEIGHTSENSOR, name: "weight", withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_RAINSENSOR, name: "rain", withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_VALVE_OPENCLOSE, name: "valve"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_VALVE_PERCENTAGE, name: "valve"),
        DigiglassHorizontalIconNameProducer(),
        DigiglassVerticalIconNameProducer(),
        ThermostatIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_HOTELCARDSENSOR, name: "fnc_hotel_card"),
        AlarmArmamentIconNameProducer(),
        GeneralPurposeMeasurementIconNameProducer(),
        GeneralPurposeMeterIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_PUMPSWITCH, name: .Icons.fncPumpSwitch),
        HeatOrColdSourceSwitchIconNameProducer(),
        ContainerIconNameProducer(),
        FloodSensorIconNameProducer(),
        ContainerLevelSensorIconNameProducer()
    ]
}
