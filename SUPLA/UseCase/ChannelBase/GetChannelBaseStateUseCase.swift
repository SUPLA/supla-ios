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
    func getOfflineState(_ function: SuplaFunction) -> ChannelState
}

final class GetChannelBaseStateUseCaseImpl: GetChannelBaseStateUseCase {
    func invoke(channelBase: SAChannelBase) -> ChannelState {
        if let channel = channelBase as? SAChannel {
            guard let value = channel.value else { return .default(value: .notUsed) }
            return getChannelState(channel.func.suplaFuntion, ChannelValueStateWrapper(channelValue: value))
        }
        if let group = channelBase as? SAChannelGroup {
            return getChannelState(group.func.suplaFuntion, ChannelGroupStateWrapper(channelGroup: group))
        }
        
        fatalError("Channel base is extended by unknown class!")
    }
    
    func getOfflineState(_ function: SuplaFunction) -> ChannelState {
        switch (function) {
        case .controllingTheGatewayLock,
             .controllingTheGate,
             .controllingTheGarageDoor,
             .controllingTheDoorLock,
             .controllingTheRollerShutter,
             .controllingTheRoofWindow,
             .controllingTheFacadeBlind,
             .openSensorGateway,
             .openSensorGate,
             .openSensorGarageDoor,
             .openSensorDoor,
             .openSensorRollerShutter,
             .openSensorRoofWindow,
             .curtain,
             .verticalBlind,
             .rollerGarageDoor,
             .valveOpenClose,
             .valvePercentage: .default(value: .opened)
        case .projectorScreen,
             .terraceAwning: .default(value: .closed)
        case .powerSwitch,
             .staircaseTimer,
             .noLiquidSensor,
             .mailSensor,
             .thermostatHeatpolHomeplus,
             .hotelCardSensor,
             .alarmArmamentSensor,
             .lightswitch,
             .dimmer,
             .dimmerCct,
             .rgbLighting,
             .pumpSwitch,
             .heatOrColdSourceSwitch,
             .floodSensor,
             .containerLevelSensor,
             .motionSensor,
             .binarySensor: .default(value: .off)
        case .dimmerAndRgbLighting,
             .dimmerCctAndRgb: .rgbAndDimmer(dimmer: .off, rgb: .off)
        case .digiglassVertical,
             .digiglassHorizontal: .default(value: .opaque)
        case .container,
             .septicTank,
             .waterTank: .default(value: .empty)
        case .unknown,
             .none,
             .thermometer,
             .humidity,
             .humidityAndTemperature,
             .ring,
             .alarm,
             .notification,
             .depthSensor,
             .distanceSensor,
             .openingSensorWindow,
             .windSensor,
             .pressureSensor,
             .rainSensor,
             .weightSensor,
             .weatherStation,
             .electricityMeter,
             .icElectricityMeter,
             .icGasMeter,
             .icWaterMeter,
             .icHeatMeter,
             .hvacThermostat,
             .hvacThermostatHeatCool,
             .hvacDomesticHotWater,
             .generalPurposeMeasurement,
             .generalPurposeMeter: .default(value: .notUsed)
        }
    }
    
    private func getChannelState(_ function: SuplaFunction, _ valueWrapper: ValueStateWrapper) -> ChannelState {
        if (!valueWrapper.online) {
            return getOfflineState(function)
        }
        
        switch (function) {
        case .controllingTheGatewayLock,
             .controllingTheGate,
             .controllingTheGarageDoor,
             .controllingTheDoorLock:
            return getOpenClose(valueWrapper.subValueHi)
        case .controllingTheRollerShutter,
             .controllingTheRoofWindow,
             .controllingTheFacadeBlind,
             .curtain,
             .verticalBlind,
             .rollerGarageDoor:
            return .default(value: valueWrapper.rollerShutterClosed ? .closed : .opened)
        case .projectorScreen,
             .terraceAwning:
            return .default(value: valueWrapper.shadingSystemReversedClosed ? .closed : .opened)
        case .openSensorGateway,
             .openSensorGate,
             .openSensorGarageDoor,
             .openSensorDoor,
             .openSensorRollerShutter,
             .openingSensorWindow,
             .openSensorRoofWindow,
             .valveOpenClose,
             .valvePercentage:
            return .default(value: valueWrapper.isClosed ? .closed : .opened)
        case .powerSwitch,
             .staircaseTimer,
             .noLiquidSensor,
             .mailSensor,
             .thermostatHeatpolHomeplus,
             .hotelCardSensor,
             .alarmArmamentSensor,
             .lightswitch,
             .pumpSwitch,
             .heatOrColdSourceSwitch,
             .floodSensor,
             .containerLevelSensor,
             .motionSensor,
             .binarySensor:
            return .default(value: valueWrapper.isClosed ? .on : .off)
        case .dimmer, .dimmerCct:
            return .default(value: valueWrapper.brightness > 0 ? .on : .off)
        case .rgbLighting:
            return .default(value: valueWrapper.colorBrightness > 0 ? .on : .off)
        case .dimmerAndRgbLighting, .dimmerCctAndRgb:
            let first: ChannelState.Value = valueWrapper.brightness > 0 ? .on : .off
            let second: ChannelState.Value = valueWrapper.colorBrightness > 0 ? .on : .off
            return .rgbAndDimmer(dimmer: first, rgb: second)
        case .digiglassHorizontal,
             .digiglassVertical:
            return .default(value: valueWrapper.transparent ? .transparent : .opaque)
        case .container,
             .septicTank,
             .waterTank:
            let value = valueWrapper.containerValue
            if (value.level > 80) {
                return .default(value: .full)
            } else if (value.level > 20) {
                return .default(value: .half)
            } else {
                return .default(value: .empty)
            }
        case .unknown,
             .none,
             .thermometer,
             .humidity,
             .humidityAndTemperature,
             .ring,
             .alarm,
             .notification,
             .depthSensor,
             .distanceSensor,
             .windSensor,
             .pressureSensor,
             .rainSensor,
             .weightSensor,
             .weatherStation,
             .electricityMeter,
             .icElectricityMeter,
             .icGasMeter,
             .icWaterMeter,
             .icHeatMeter,
             .hvacThermostat,
             .hvacThermostatHeatCool,
             .hvacDomesticHotWater,
             .generalPurposeMeasurement,
             .generalPurposeMeter: return .default(value: .notUsed)
        }
    }
    
    private func getOpenClose(_ value: Int32) -> ChannelState {
        if ((value & 0x2) == 0x2 && (value & 0x1) == 0) {
            return .default(value: .partialyOpened)
        } else if (value > 0) {
            return .default(value: .closed)
        } else {
            return .default(value: .opened)
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
