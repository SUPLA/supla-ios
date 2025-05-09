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
    func invoke(iconData: IconData) -> IconResult
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

    func invoke(iconData: IconData) -> IconResult {
        if (iconData.type != .single && iconData.function != SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            // Currently only humidity and temperature may have multiple icons
            fatalError("Wrong icon configuration (iconType: '\(iconData.type)', function: '\(iconData.function)'")
        }
        
        let name = getDefaultIconNameUseCase.invoke(iconData: iconData)
        
        if let icon = getUserIcon(iconData.function, iconData.userIcon, iconData.state, iconData.type, iconData.subfunction) {
            return .userIcon(icon: icon, fallbackName: name)
        }

        return .suplaIcon(name: name)
    }

    private func getUserIcon(_ function: Int32, _ userIcon: SAUserIcon?, _ channelState: ChannelState, _ iconType: IconType, _ subfunction: ThermostatSubfunction?) -> UIImage? {
        if let data = findUserIcon(function, userIcon, channelState, iconType, subfunction) as? Data {
            return UIImage(data: data)
        }

        return nil
    }

    private func findUserIcon(_ function: Int32, _ userIcon: SAUserIcon?, _ channelState: ChannelState, _ iconType: IconType, _ subfunction: ThermostatSubfunction?) -> NSObject? {
        let darkMode = settings.darkMode == .always || (settings.darkMode == .auto && UITraitCollection.current.userInterfaceStyle == .dark)

        switch (function) {
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return iconType == .second ? userIcon?.getIcon(.icon1, darkMode: darkMode) : userIcon?.getIcon(.icon2, darkMode: darkMode)
        case SUPLA_CHANNELFNC_THERMOMETER:
            return userIcon?.getIcon(.icon1, darkMode: darkMode)
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            if (channelState == .closed) {
                return userIcon?.getIcon(.icon2, darkMode: darkMode)
            } else if (channelState == .partialyOpened) {
                return userIcon?.getIcon(.icon3, darkMode: darkMode)
            } else {
                return userIcon?.getIcon(.icon1, darkMode: darkMode)
            }
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
             SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER:
            if (subfunction == nil || subfunction == .heat) {
                return userIcon?.getIcon(.icon1, darkMode: darkMode)
            } else {
                return userIcon?.getIcon(.icon2, darkMode: darkMode)
            }
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            switch (channelState) {
            case .complex(let states):
                switch (states) {
                case [.off, .off]:
                    return userIcon?.getIcon(.icon1, darkMode: darkMode)
                case [.on, .off]:
                    return userIcon?.getIcon(.icon2, darkMode: darkMode)
                case [.off, .on]:
                    return userIcon?.getIcon(.icon3, darkMode: darkMode)
                case [.on, .on]:
                    return userIcon?.getIcon(.icon4, darkMode: darkMode)
                default:
                    return channelState.isActive() ? userIcon?.getIcon(.icon2, darkMode: darkMode) : userIcon?.getIcon(.icon1, darkMode: darkMode)
                }
            default:
                return channelState.isActive() ? userIcon?.getIcon(.icon2, darkMode: darkMode) : userIcon?.getIcon(.icon1, darkMode: darkMode)
            }
        default:
            return channelState.isActive() ? userIcon?.getIcon(.icon2, darkMode: darkMode) : userIcon?.getIcon(.icon1, darkMode: darkMode)
        }
    }
}

enum IconResult: Equatable, Hashable {
    case suplaIcon(name: String)
    case userIcon(icon: UIImage?, fallbackName: String)
}

extension IconResult {
    var uiImage: UIImage? {
        switch (self) {
        case .suplaIcon(let name): return .init(named: name)
        case .userIcon(let icon, _): return icon
        }
    }
    
    var image: Image {
        switch (self) {
        case .suplaIcon(let name):
            Image(name)
        case .userIcon(let icon, _):
            if let icon = icon {
                Image(uiImage: icon)
            } else {
                Image(.Icons.fncUnknown)
            }
        }
    }
    
    var name: String {
        switch (self) {
        case .suplaIcon(let name): name
        case .userIcon(_ , let fallbackName): fallbackName
        }
    }
}

