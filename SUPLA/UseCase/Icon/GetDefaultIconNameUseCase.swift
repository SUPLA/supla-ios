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

protocol GetDefaultIconNameUseCase {
    func invoke(function: Int32, state: ChannelState, altIcon: Int32, iconType: IconType) -> String
}

protocol IconNameProducer {
    func accepts(function: Int32) -> Bool
    func produce(function: Int32, state: ChannelState, altIcon: Int32, iconType: IconType) -> String
}

extension IconNameProducer {
    func addStateSufix(name: String, state: ChannelState) -> String {
        switch (state) {
        case .opened: return String.init(format: "%@-%@", name, "open")
        case .partialyOpened, .closed: return String.init(format: "%@-%@", name, "closed")
        case .on: return String.init(format: "%@-%@", name, "on")
        case .off: return String.init(format: "%@-%@", name, "off")
        case .transparent: return String.init(format: "%@-%@", name, "transparent")
        default: return name
        }
    }
}

final class GetDefaultIconNameUseCaseImpl: GetDefaultIconNameUseCase {
    
    func invoke(function: Int32, state: ChannelState, altIcon: Int32, iconType: IconType) -> String {
        var name: String? = nil
        producers.forEach { producer in
            if (producer.accepts(function: function)) {
                name = producer.produce(function: function, state: state, altIcon: altIcon, iconType: iconType)
            }
        }
        if let name = name {
            return name
        } else {
            return "unknown_channel"
        }
    }
    
    let producers: [IconNameProducer] = [
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY, name: "gateway"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK, name: "gateway"),
        GateIconNameProducer(),
        GarageDoorIconNameProducer(),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR, name: "door"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK, name: "door"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER, name: "rollershutter"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER, name: "rollershutter"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW, name: "roofwindow"),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW, name: "roofwindow"),
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
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_IC_GAS_METER, name: "gasmeter", withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_IC_WATER_METER, name: "watermeter", withSuffix: false),
        StaticIconNameProducer(function: SUPLA_CHANNELFNC_IC_HEAT_METER, name: "heatmeter", withSuffix: false),
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
        DigiglassVerticalIconNameProducer()
    ]
}

