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
    func invoke(
        function: Int32,
        userIcon: SAUserIcon?,
        channelState: ChannelState,
        altIcon: Int32,
        iconType: IconType,
        nightMode: Bool
    ) -> UIImage?
}

extension GetChannelBaseIconUseCase {
    func invoke(
        function: Int32,
        userIcon: SAUserIcon?,
        channelState: ChannelState,
        altIcon: Int32,
        iconType: IconType = .single,
        nightMode: Bool = false
    ) -> UIImage? {
        invoke(
            function: function,
            userIcon: userIcon,
            channelState: channelState,
            altIcon: altIcon,
            iconType: iconType,
            nightMode: nightMode
        )
    }
}

final class GetChannelBaseIconUseCaseImpl: GetChannelBaseIconUseCase {
    
    @Singleton<GetDefaultIconNameUseCase> private var getDefaultIconNameUseCase
    
    func invoke(function: Int32, userIcon: SAUserIcon?, channelState: ChannelState, altIcon: Int32, iconType: IconType = .single, nightMode: Bool = false) -> UIImage? {
        if (iconType != .single && function != SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE) {
            // Currently only humidity and temperature may have multiple icons
            return nil
        }
        
        if let icon = getUserIcon(function, userIcon, channelState, iconType) {
            return icon
        }
        
        let name = getDefaultIconNameUseCase.invoke(
            function: function,
            state: channelState,
            altIcon: altIcon,
            iconType: iconType
        )
        
        if (nightMode) {
            return .init(named: .init(format: "%@-nightmode", name))
        }
        return .init(named: name)
    }
    
    private func getUserIcon(_ function: Int32, _ userIcon: SAUserIcon?, _ channelState: ChannelState, _ iconType: IconType) -> UIImage? {
        if let data = findUserIcon(function, userIcon, channelState, iconType) as? Data {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    private func findUserIcon(_ function: Int32, _ userIcon: SAUserIcon?, _ channelState: ChannelState, _ iconType: IconType) -> NSObject? {
        switch (function) {
        case SUPLA_CHANNELFNC_HUMIDITYANDTEMPERATURE:
            return iconType == .first ? userIcon?.uimage2 : userIcon?.uimage1
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
        default:
            return channelState.isActive() ? userIcon?.uimage2 : userIcon?.uimage1
        }
    }
}
