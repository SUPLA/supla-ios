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

import SwiftUI
import SharedCore

protocol GetChannelBaseIconUseCase {
    func invoke(iconData: FetchIconData) -> IconResult
}

extension GetChannelBaseIconUseCase {
    func invoke(
        channel: SAChannelBase,
        type: IconType = .single,
        subfunction: ThermostatSubfunction? = nil
    ) -> IconResult {
        return invoke(iconData: channel.getIconData(type: type, subfunction: subfunction))
    }

    func stateIcon(_ channelBase: SAChannelBase, state: ChannelState) -> IconResult {
        if let channel = channelBase as? SAChannel {
            let subfunction = channel.isHvacThermostat().ifTrue { channel.value?.asThermostatValue().subfunction }
            let iconData = channel.getIconData(state: state, subfunction: subfunction)

            return invoke(iconData: iconData)
        }

        if let group = channelBase as? SAChannelGroup {
            return invoke(iconData: group.getIconData(state: state))
        }

        return .suplaIcon(name: .Icons.fncUnknown)
    }
}

final class GetChannelBaseIconUseCaseImpl: GetChannelBaseIconUseCase {
    @Singleton<GetDefaultIconNameUseCase> private var getDefaultIconNameUseCase
    @Singleton<GlobalSettings> private var settings
    @Singleton<UserIcons.UseCase> private var iconPathsUseCase

    func invoke(iconData: FetchIconData) -> IconResult {
        if (iconData.type != .single && iconData.function != SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            // Currently only humidity and temperature may have multiple icons
            fatalError("Wrong icon configuration (iconType: '\(iconData.type)', function: '\(iconData.function)'")
        }
        
        let name = getDefaultIconNameUseCase.invoke(iconData: iconData)
        
        if (iconData.userIconId != 0){
            return .userIcon(profileId: iconData.profileId, iconId: iconData.userIconId, type: getIcon(iconData), defaultName: name)
        }

        return .suplaIcon(name: name)
    }

    private func getIcon(_ iconData: FetchIconData) -> UserIcon {
        switch (iconData.function) {
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            iconData.type == .second ? .icon1 : .icon2
        case SUPLA_CHANNELFNC_THERMOMETER: .icon1
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            if (iconData.state == .closed) {
                .icon2
            } else if (iconData.state == .partialyOpened) {
                .icon3
            } else {
                .icon1
            }
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
             SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER:
            iconData.subfunction == .cool ? .icon2 : .icon1
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            switch (iconData.state) {
            case .complex(let states):
                switch (states) {
                case [.off, .off]:
                        .icon1
                case [.on, .off]:
                        .icon2
                case [.off, .on]:
                        .icon3
                case [.on, .on]:
                        .icon4
                default:
                    iconData.state.isActive() ? .icon2 : .icon1
                }
            default:
                iconData.state.isActive() ? .icon2 : .icon1
            }
        default:
            iconData.state.isActive() ? .icon2 : .icon1
        }
    }
}

