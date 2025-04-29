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

protocol GetChannelBaseStateUseCase {
    func invoke(channelBase: SAChannelBase) -> ChannelState
    func getOfflineState(_ function: Int32) -> ChannelState
}

final class GetChannelBaseStateUseCaseImpl: GetChannelBaseStateUseCase {
    func invoke(channelBase: SAChannelBase) -> ChannelState {
        if let channel = channelBase as? SAChannel {
            guard let value = channel.value else { return .notUsed }
            return getChannelState(channel.func, ChannelValueStateWrapper(channelValue: value))
        }
        if let group = channelBase as? SAChannelGroup {
            return getChannelState(group.func, ChannelGroupStateWrapper(channelGroup: group))
        }
        
        fatalError("Channel base is extended by unknown class!")
    }
    
    func getOfflineState(_ function: Int32) -> ChannelState {
        switch (function) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
             SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK,
             SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER,
             SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW,
             SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND,
             SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY,
             SUPLA_CHANNELFNC_OPENINGSENSOR_GATE,
             SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR,
             SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR,
             SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER,
             SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW,
             SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW,
             SUPLA_CHANNELFNC_TERRACE_AWNING,
             SUPLA_CHANNELFNC_CURTAIN,
             SUPLA_CHANNELFNC_VERTICAL_BLIND,
             SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR,
             SUPLA_CHANNELFNC_VALVE_OPENCLOSE,
             SUPLA_CHANNELFNC_VALVE_PERCENTAGE: .opened
        case SUPLA_CHANNELFNC_PROJECTOR_SCREEN: .closed
        case SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER,
             SUPLA_CHANNELFNC_NOLIQUIDSENSOR,
             SUPLA_CHANNELFNC_MAILSENSOR,
             SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS,
             SUPLA_CHANNELFNC_HOTELCARDSENSOR,
             SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR,
             SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_DIMMER,
             SUPLA_CHANNELFNC_RGBLIGHTING,
             SUPLA_CHANNELFNC_PUMPSWITCH,
             SUPLA_CHANNELFNC_HEATORCOLDSOURCESWITCH,
             SUPLA_CHANNELFNC_FLOOD_SENSOR,
             SUPLA_CHANNELFNC_CONTAINER_LEVEL_SENSOR: .off
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING: .complex([.off, .off])
        case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL,
             SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL: .opaque
        case SUPLA_CHANNELFNC_CONTAINER,
             SUPLA_CHANNELFNC_SEPTIC_TANK,
             SUPLA_CHANNELFNC_WATER_TANK: .empty
        default: .notUsed
        }
    }
    
    private func getChannelState(_ function: Int32, _ valueWrapper: ValueStateWrapper) -> ChannelState {
        if (!valueWrapper.online) {
            return getOfflineState(function)
        }
        
        switch (function) {
        case SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGATE,
             SUPLA_CHANNELFNC_CONTROLLINGTHEGARAGEDOOR,
             SUPLA_CHANNELFNC_CONTROLLINGTHEDOORLOCK:
            return getOpenClose(valueWrapper.subValueHi)
        case SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER,
             SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW,
             SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND,
             SUPLA_CHANNELFNC_CURTAIN,
             SUPLA_CHANNELFNC_VERTICAL_BLIND,
             SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR:
            return valueWrapper.rollerShutterClosed ? .closed : .opened
        case SUPLA_CHANNELFNC_PROJECTOR_SCREEN,
             SUPLA_CHANNELFNC_TERRACE_AWNING:
            return valueWrapper.shadingSystemReversedClosed ? .closed : .opened
        case SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY,
             SUPLA_CHANNELFNC_OPENINGSENSOR_GATE,
             SUPLA_CHANNELFNC_OPENINGSENSOR_GARAGEDOOR,
             SUPLA_CHANNELFNC_OPENINGSENSOR_DOOR,
             SUPLA_CHANNELFNC_OPENINGSENSOR_ROLLERSHUTTER,
             SUPLA_CHANNELFNC_OPENINGSENSOR_WINDOW,
             SUPLA_CHANNELFNC_OPENINGSENSOR_ROOFWINDOW,
             SUPLA_CHANNELFNC_VALVE_OPENCLOSE,
             SUPLA_CHANNELFNC_VALVE_PERCENTAGE:
            return valueWrapper.isClosed ? .closed : .opened
        case SUPLA_CHANNELFNC_POWERSWITCH,
             SUPLA_CHANNELFNC_STAIRCASETIMER,
             SUPLA_CHANNELFNC_NOLIQUIDSENSOR,
             SUPLA_CHANNELFNC_MAILSENSOR,
             SUPLA_CHANNELFNC_THERMOSTAT_HEATPOL_HOMEPLUS,
             SUPLA_CHANNELFNC_HOTELCARDSENSOR,
             SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR,
             SUPLA_CHANNELFNC_LIGHTSWITCH,
             SUPLA_CHANNELFNC_PUMPSWITCH,
             SUPLA_CHANNELFNC_HEATORCOLDSOURCESWITCH,
             SUPLA_CHANNELFNC_FLOOD_SENSOR,
             SUPLA_CHANNELFNC_CONTAINER_LEVEL_SENSOR:
            return valueWrapper.isClosed ? .on : .off
        case SUPLA_CHANNELFNC_DIMMER:
            return valueWrapper.brightness > 0 ? .on : .off
        case SUPLA_CHANNELFNC_RGBLIGHTING:
            return valueWrapper.colorBrightness > 0 ? .on : .off
        case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
            let first: ChannelState = valueWrapper.brightness > 0 ? .on : .off
            let second: ChannelState = valueWrapper.colorBrightness > 0 ? .on : .off
            return .complex([first, second])
        case SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL,
             SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL:
            return valueWrapper.transparent ? .transparent : .opaque
        case SUPLA_CHANNELFNC_CONTAINER,
             SUPLA_CHANNELFNC_SEPTIC_TANK,
             SUPLA_CHANNELFNC_WATER_TANK:
            let value = valueWrapper.containerValue
            if (value.level > 80) {
                return .full
            } else if (value.level > 20) {
                return .half
            } else {
                return .empty
            }
        default: return .notUsed
        }
    }
    
    private func getOpenClose(_ value: Int32) -> ChannelState {
        if ((value & 0x2) == 0x2 && (value & 0x1) == 0) {
            return .partialyOpened
        } else if (value > 0) {
            return .closed
        } else {
            return .opened
        }
    }
}

protocol ValueStateWrapper {
    var online: Bool { get }
    var subValueHi: Int32 { get }
    var isClosed: Bool { get }
    var brightness: Int32 { get }
    var colorBrightness: Int32 { get }
    var transparent: Bool { get }
    var rollerShutterClosed: Bool { get }
    var shadingSystemReversedClosed: Bool { get }
    var containerValue: ContainerValue { get }
}

private class ChannelValueStateWrapper: ValueStateWrapper {
    var online: Bool {
        channelValue.status.online
    }
    
    var subValueHi: Int32 {
        channelValue.hiSubValue()
    }
    
    var isClosed: Bool {
        channelValue.isClosed()
    }
    
    var brightness: Int32 {
        channelValue.brightnessValue()
    }
    
    var colorBrightness: Int32 {
        channelValue.colorBrightnessValue()
    }
    
    var transparent: Bool {
        channelValue.digiglassValue().isAnySectionTransparent()
    }
    
    var rollerShutterClosed: Bool {
        let percentage = channelValue.asRollerShutterValue().position
        let subValueHi = channelValue.hiSubValue()
        return (subValueHi > 0 && percentage < 100) || percentage >= 100
    }
    
    var shadingSystemReversedClosed: Bool {
        let percentage = channelValue.asRollerShutterValue().position
        return percentage < 100
    }
    
    var containerValue: ContainerValue {
        channelValue.asContainerValue()
    }
    
    private let channelValue: SAChannelValue
    
    init(channelValue: SAChannelValue) {
        self.channelValue = channelValue
    }
}

private class ChannelGroupStateWrapper: ValueStateWrapper {
    var online: Bool {
        channelGroup.status().online
    }
    
    var subValueHi: Int32 {
        getActivePercentage() >= 100 ? 1 : 0
    }
    
    var isClosed: Bool {
        getActivePercentage() >= 100
    }
    
    var brightness: Int32 {
        getActivePercentage(valueIndex: 2) >= 100 ? 1 : 0
    }
    
    var colorBrightness: Int32 {
        getActivePercentage(valueIndex: 1) >= 100 ? 1 : 0
    }
    
    var transparent: Bool { false }
    
    var rollerShutterClosed: Bool {
        getActivePercentage() >= 100
    }
    
    var shadingSystemReversedClosed: Bool {
        getActivePercentage() < 100
    }
    
    var containerValue: ContainerValue {
        return ContainerValue(status: channelGroup.status(), flags: [], rawLevel: 0)
    }
    
    private let channelGroup: SAChannelGroup
    @Singleton<GetGroupActivePercentageUseCase> private var getGroupActivePercentageUseCase
    
    init(channelGroup: SAChannelGroup) {
        self.channelGroup = channelGroup
    }
    
    private func getActivePercentage(valueIndex: Int = 0) -> Int {
        getGroupActivePercentageUseCase.invoke(channelGroup, valueIndex: valueIndex)
    }
}
