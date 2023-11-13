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

protocol GetChannelBaseIconUseCase {
    func invoke(iconData: IconData) -> IconResult
}

extension GetChannelBaseIconUseCase {
    func invoke(
        channel: SAChannel,
        type: IconType = .single,
        nightMode: Bool = false,
        subfunction: ThermostatSubfunction? = nil
    ) -> UIImage? {
        return invoke(iconData: channel.getIconData(type: type, nightMode: nightMode, subfunction: subfunction)).icon
    }
}

final class GetChannelBaseIconUseCaseImpl: GetChannelBaseIconUseCase {
    
    @Singleton<GetDefaultIconNameUseCase> private var getDefaultIconNameUseCase
    
    func invoke(iconData: IconData) -> IconResult {
        if (iconData.type != .single && iconData.function != SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            // Currently only humidity and temperature may have multiple icons
            fatalError("Wrong icon configuration (iconType: '\(iconData.type)', function: '\(iconData.function)'")
        }
        
        if let icon = getUserIcon(iconData.function, iconData.userIcon, iconData.state, iconData.type, iconData.subfunction) {
            return .userIcon(icon: icon)
        }
        
        let name = getDefaultIconNameUseCase.invoke(iconData: iconData)
        
        if (iconData.nightMode) {
            return .suplaIcon(icon: .init(named: .init(format: "%@-nightmode", name)))
        }
        return .suplaIcon(icon: .init(named: name))
    }
    
    private func getUserIcon(_ function: Int32, _ userIcon: SAUserIcon?, _ channelState: ChannelState, _ iconType: IconType, _ subfunction: ThermostatSubfunction?) -> UIImage? {
        if let data = findUserIcon(function, userIcon, channelState, iconType, subfunction) as? Data {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    private func findUserIcon(_ function: Int32, _ userIcon: SAUserIcon?, _ channelState: ChannelState, _ iconType: IconType, _ subfunction: ThermostatSubfunction?) -> NSObject? {
        switch (function) {
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return iconType == .second ? userIcon?.uimage1 : userIcon?.uimage2
        case SUPLA_CHANNELFNC_THERMOMETER:
            return userIcon?.uimage1
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
        SUPLA_CHANNELFNC_CONTROLLINGTHEGATE:
            if (channelState == .opened) {
                return userIcon?.uimage2
            } else if (channelState == .partialyOpened) {
                return userIcon?.uimage3
            } else {
                return userIcon?.uimage1
            }
        case SUPLA_CHANNELFNC_HVAC_THERMOSTAT,
        SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER:
            if (subfunction == nil || subfunction == .heat) {
                return userIcon?.uimage1
            } else {
                return userIcon?.uimage2
            }
        default:
            return channelState.isActive() ? userIcon?.uimage2 : userIcon?.uimage1
        }
    }
}

enum IconResult: Equatable {
    case suplaIcon(icon: UIImage?)
    case userIcon(icon: UIImage?)
}

extension IconResult {
    var icon: UIImage? {
        get {
            switch(self) {
            case .suplaIcon(let icon): return icon
            case .userIcon(let icon): return icon
            }
        }
    }
}
