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

protocol ProvideChannelDetailTypeUseCase {
    func invoke(channelWithChildren: ChannelWithChildren) -> DetailType?
}

final class ProvideChannelDetailTypeUseCaseImpl: BaseDetailTypeProviderUseCase, ProvideChannelDetailTypeUseCase {
    func invoke(channelWithChildren: ChannelWithChildren) -> DetailType? {
        switch (channelWithChildren.channel.func) {
            case SUPLA_CHANNELFNC_LIGHTSWITCH,
                 SUPLA_CHANNELFNC_POWERSWITCH,
                 SUPLA_CHANNELFNC_STAIRCASETIMER,
                 SUPLA_CHANNELFNC_PUMPSWITCH,
                 SUPLA_CHANNELFNC_HEATORCOLDSOURCESWITCH: .switchDetail(pages: getSwitchDetailPages(channelWithChildren))

            case SUPLA_CHANNELFNC_HVAC_THERMOSTAT: .thermostatDetail(pages: getThermostatDetailPages(channelWithChildren))

            case SUPLA_CHANNELFNC_IC_ELECTRICITY_METER,
                 SUPLA_CHANNELFNC_IC_GAS_METER,
                 SUPLA_CHANNELFNC_IC_WATER_METER,
                 SUPLA_CHANNELFNC_IC_HEAT_METER: .impulseCounterDetail(pages: getImpulseCounterDetailPages(channelWithChildren))

            case SUPLA_CHANNELFNC_VALVE_OPENCLOSE: .valveDetail(pages: [.valveGeneral])

            case SUPLA_CHANNELFNC_CONTAINER,
                 SUPLA_CHANNELFNC_WATER_TANK,
                 SUPLA_CHANNELFNC_SEPTIC_TANK: .containerDetail(pages: [.containerGeneral])

            default: provide(channelWithChildren.channel)
        }
    }

    private func getSwitchDetailPages(_ channelWithChildren: ChannelWithChildren) -> [DetailPage] {
        var list: [DetailPage] = [.switchGeneral]

        if (channelWithChildren.supportsTimer) {
            list.append(.switchTimer)
        }

        if (channelWithChildren.isOrHasElectricityMeter) {
            list.append(.electricityMeterHistory)
            list.append(.electricityMeterSettings)
        } else if (channelWithChildren.isOrHasImpulseCounter) {
            list.append(.impulseCounterHistory)
        }

        return list
    }

    private func getThermostatDetailPages(_ channelWithChildren: ChannelWithChildren) -> [DetailPage] {
        var list: [DetailPage] = [.thermostatGeneral]

        if (channelWithChildren.children.first(where: { $0.relationType == .masterThermostat }) != nil) {
            list.append(.thermostatList)
        }

        list.append(.schedule)
        list.append(.thermostatTimer)
        list.append(.thermostatHistory)

        return list
    }

    private func getImpulseCounterDetailPages(_ channelWithChildren: ChannelWithChildren) -> [DetailPage] {
        if (channelWithChildren.channel.flags & Int64(SUPLA_CHANNEL_FLAG_OCR) > 0) {
            [.impulseCounterGeneral, .impulseCounterHistory, .impulseCounterOcr]
        } else {
            [.impulseCounterGeneral, .impulseCounterHistory]
        }
    }
}

private extension ChannelWithChildren {
    var supportsTimer: Bool {
        channel.flags & Int64(SUPLA_CHANNEL_FLAG_COUNTDOWN_TIMER_SUPPORTED) > 0 && channel.func != SUPLA_CHANNELFNC_STAIRCASETIMER
    }
}
