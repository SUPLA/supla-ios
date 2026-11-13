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

protocol GetChannelValueStringUseCase {
    func invoke(_ channelWithChildren: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String
    func valueOrNil(_ channelWithChildren: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String?
}

extension GetChannelValueStringUseCase {
    func invoke(_ channelWithChildren: ChannelWithChildren, valueType: ValueType = .first, withUnit: Bool = true) -> String {
        invoke(channelWithChildren, valueType: valueType, withUnit: withUnit)
    }

    func valueOrNil(_ channelWithChildren: ChannelWithChildren) -> String? {
        valueOrNil(channelWithChildren, valueType: .first, withUnit: true)
    }

    func valueOrNil(_ channelWithChildren: ChannelWithChildren, valueType: ValueType = .first) -> String? {
        valueOrNil(channelWithChildren, valueType: valueType, withUnit: true)
    }
}

final class GetChannelValueStringUseCaseImpl: GetChannelValueStringUseCase {
    
    private let providers: [ChannelValueStringProvider] = [
        DepthValueStringProvider(),
        DistanceValueStringProvider(),
        GpmValueStringProvider(),
        HumidityValueStringProvider(),
        PressureValueStringProvider(),
        RainValueStringProvider(),
        ThermometerAndHumidityValueStringProvider(),
        ThermometerValueStringProvider(),
        WeigthValueStringProvider(),
        WindValueStringProvider(),
        ElectricityMeterValueStringProvider(),
        SwitchWithElectricityMeterValueStringProvider(),
        ImpulseCounterValueStringProvider(),
        SwitchWithImpulseCounterValueStringProvider(),
        ContainerValueStringProvider(),
        HomePlusThermostatValueStringProvider(),
        HvacThermostatValueStringProvider(),

        NoValueStringProvider(SUPLA_CHANNELFNC_STAIRCASETIMER),
        NoValueStringProvider(SUPLA_CHANNELFNC_POWERSWITCH),
        NoValueStringProvider(SUPLA_CHANNELFNC_LIGHTSWITCH),
        NoValueStringProvider(SUPLA_CHANNELFNC_MAILSENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW),
        NoValueStringProvider(SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_OPENINGSENSOR_GATE),
        NoValueStringProvider(SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY),
        NoValueStringProvider(SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW),
        NoValueStringProvider(SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER),
        NoValueStringProvider(SUPLA_CHANNELFNC_DIMMER),
        NoValueStringProvider(SUPLA_CHANNELFNC_DIMMER_CCT),
        NoValueStringProvider(SUPLA_CHANNELFNC_RGBLIGHTING),
        NoValueStringProvider(SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING),
        NoValueStringProvider(SUPLA_CHANNELFNC_DIMMER_CCT_AND_RGB),
        NoValueStringProvider(SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK),
        NoValueStringProvider(SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK),
        NoValueStringProvider(SUPLA_CHANNELFNC_CONTROLLINGTHEGATE),
        NoValueStringProvider(SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER),
        NoValueStringProvider(SUPLA_CHANNELFNC_VALVE_OPENCLOSE),
        NoValueStringProvider(SUPLA_CHANNELFNC_NOLIQUIDSENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_FLOOD_SENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_HOTELCARDSENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_ACTIONTRIGGER),
        NoValueStringProvider(SUPLA_CHANNELFNC_GAS_SENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_CARBON_MONOXIDE_SENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_SMOKE_SENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_MOTION_SENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_HVAC_HRV),
        NoValueStringProvider(SUPLA_CHANNELFNC_BINARY_SENSOR),
        NoValueStringProvider(SUPLA_CHANNELFNC_VERTICAL_BLIND),
        NoValueStringProvider(SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND),
        NoValueStringProvider(SUPLA_CHANNELFNC_CONTAINER_LEVEL_SENSOR)
    ]

    func invoke(_ channelWithChildren: ChannelWithChildren, valueType: ValueType = .first, withUnit: Bool = true) -> String {
        return valueOrNil(channelWithChildren, valueType: valueType, withUnit: withUnit) ?? NO_VALUE_TEXT
    }

    func valueOrNil(_ channelWithChildren: ChannelWithChildren, valueType: ValueType = .first, withUnit: Bool = true) -> String? {
        if let provider = providers.first(where: { $0.handle(channelWithChildren) }) {
            return provider.valueWithOfflineCheck(channelWithChildren, valueType: valueType, withUnit: withUnit)
        }

        SALog.debug("No value provider for channel function `\(channelWithChildren.function)`")
        return nil
    }
}

protocol ChannelValueStringProvider {
    func handle(_ channel: ChannelWithChildren) -> Bool
    func value(_ channel: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String?
}

private extension ChannelValueStringProvider {
    func valueWithOfflineCheck(_ channel: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String? {
        if (channel.channel.status().offline) {
            return NO_VALUE_TEXT
        }

        return value(channel, valueType: valueType, withUnit: withUnit)
    }
}

class NoValueStringProvider: ChannelValueStringProvider {
    private let function: Int32

    init(_ function: Int32) {
        self.function = function
    }

    func handle(_ channel: ChannelWithChildren) -> Bool {
        channel.function == function
    }

    func value(_ channel: ChannelWithChildren, valueType: ValueType, withUnit: Bool) -> String? {
        nil
    }
}
