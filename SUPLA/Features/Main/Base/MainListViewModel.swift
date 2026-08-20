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

import Foundation

class MainListViewModel<S: ObservableObject>: SuplaCore.ViewModel<S> {
    @Singleton<AppRouter> private var router

    func navigateToDetail(_ detailType: DetailType, item: ItemBundle, remoteId: Int32) {
        switch (detailType) {
        case let .legacy(type: legacyDetailType):
            router.navigate(to: .legacyDetail(type: legacyDetailType, channelRemoteId: remoteId))
        case let .standardDetail(pages):
            router.navigate(to: .standardDetail(item: item, pages: pages))
        case let .impulseCounterDetail(pages):
            router.navigate(to: .impulseCounterDetail(item: item, pages: pages))
        case let .rgbwDetail(pages):
            router.navigate(to: .rgbwDetail(item: item, pages: pages))
        }
    }

    func isAvailableInOffline(_ channel: SAChannelBase, children: [ChannelChild]? = nil) -> Bool {
        switch (channel.func) {
        case
            SUPLA_CHANNELFNC_THERMOMETER,
            SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE,
            SUPLA_CHANNELFNC_HUMIDITY,
            SUPLA_CHANNELFNC_ELECTRICITY_METER,
            SUPLA_CHANNELFNC_IC_ELECTRICITY_METER,
            SUPLA_CHANNELFNC_IC_GAS_METER,
            SUPLA_CHANNELFNC_IC_WATER_METER,
            SUPLA_CHANNELFNC_IC_HEAT_METER,
            SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER,
            SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
            SUPLA_CHANNELFNC_HVAC_THERMOSTAT_HEAT_COOL,
            SUPLA_CHANNELFNC_GENERAL_PURPOSE_METER,
            SUPLA_CHANNELFNC_GENERAL_PURPOSE_MEASUREMENT,
            SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER,
            SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW,
            SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND,
            SUPLA_CHANNELFNC_TERRACE_AWNING,
            SUPLA_CHANNELFNC_PROJECTOR_SCREEN,
            SUPLA_CHANNELFNC_CURTAIN,
            SUPLA_CHANNELFNC_VERTICAL_BLIND,
            SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR,
            SUPLA_CHANNELFNC_VALVE_OPENCLOSE,
            SUPLA_CHANNELFNC_VALVE_PERCENTAGE,
            SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
            SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK,
            SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
            SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK,
            SUPLA_CHANNELFNC_LIGHTSWITCH,
            SUPLA_CHANNELFNC_POWERSWITCH,
            SUPLA_CHANNELFNC_STAIRCASETIMER,
            SUPLA_CHANNELFNC_RGBLIGHTING,
            SUPLA_CHANNELFNC_DIMMER,
            SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            return true
        default:
            return false
        }
    }
}
