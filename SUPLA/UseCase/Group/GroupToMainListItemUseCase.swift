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

import CoreGraphics

enum GroupToMainListItem {
    protocol UseCase {
        func invoke(_ group: SAChannelGroup) -> MainListItem?
        func invoke(_ group: SAChannelGroup, location: _SALocation) -> MainListItem
    }

    final class Implementation: UseCase {
        @Singleton<GetCaptionUseCase> var getCaptionUseCase
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase
        @Singleton<GetGroupActivePercentageUseCase> var getGroupActivePercentageUseCase
        @Singleton<GetChannelActionStringUseCase> var getChannelActionStringUseCase
        @Singleton<SharedCore.ThermometerValueFormatter> var thermometerValueFormatter

        func invoke(_ group: SAChannelGroup) -> MainListItem? {
            guard let location = group.location else { return nil }
            return invoke(group, location: location)
        }

        func invoke(_ group: SAChannelGroup, location: _SALocation) -> MainListItem {
            let function = SuplaFunction.companion.from(value: group.func)

            return switch function {
            case .thermostatHeatpolHomeplus: .heatpolThermostat(groupToHeatpoThermostatListItem(function, group, location))
            case .unknown,
                 .none,
                 .controllingTheGatewayLock,
                 .controllingTheGate,
                 .controllingTheGarageDoor,
                 .thermometer,
                 .humidity,
                 .humidityAndTemperature,
                 .openSensorGateway,
                 .openSensorGate,
                 .openSensorGarageDoor,
                 .noLiquidSensor,
                 .controllingTheDoorLock,
                 .openSensorDoor,
                 .controllingTheRollerShutter,
                 .controllingTheRoofWindow,
                 .openSensorRollerShutter,
                 .openSensorRoofWindow,
                 .powerSwitch,
                 .lightswitch,
                 .ring,
                 .alarm,
                 .notification,
                 .dimmer,
                 .dimmerCct,
                 .rgbLighting,
                 .dimmerAndRgbLighting,
                 .dimmerCctAndRgb,
                 .depthSensor,
                 .distanceSensor,
                 .openingSensorWindow,
                 .hotelCardSensor,
                 .alarmArmamentSensor,
                 .mailSensor,
                 .windSensor,
                 .pressureSensor,
                 .rainSensor,
                 .weightSensor,
                 .weatherStation,
                 .staircaseTimer,
                 .electricityMeter,
                 .icElectricityMeter,
                 .icGasMeter,
                 .icWaterMeter,
                 .icHeatMeter,
                 .hvacThermostat,
                 .hvacThermostatHeatCool,
                 .hvacDomesticHotWater,
                 .hvacHrv,
                 .valveOpenClose,
                 .valvePercentage,
                 .generalPurposeMeasurement,
                 .generalPurposeMeter,
                 .digiglassHorizontal,
                 .digiglassVertical,
                 .controllingTheFacadeBlind,
                 .terraceAwning,
                 .projectorScreen,
                 .curtain,
                 .verticalBlind,
                 .rollerGarageDoor,
                 .pumpSwitch,
                 .heatOrColdSourceSwitch,
                 .container,
                 .septicTank,
                 .waterTank,
                 .containerLevelSensor,
                 .floodSensor,
                 .motionSensor,
                 .binarySensor,
                 .smokeSensor,
                 .carbonMonoxideSensor,
                 .gasSensor: .default(groupToDefaultListItem(function, group, location))
            }
        }

        private func groupToDefaultListItem(
            _ function: SuplaFunction,
            _ group: SAChannelGroup,
            _ location: _SALocation
        ) -> DefaultListItem {
            let activePercentage = getGroupActivePercentageUseCase.invoke(group).clamped(to: 0 ... 100)
            let state = getChannelBaseStateUseCase.invoke(channelBase: group)

            return DefaultListItem(
                remoteId: group.remote_id,
                profileId: group.profile.id,
                userCaption: group.caption ?? "",
                function: function,
                locationCaption: location.caption ?? "",
                locationId: location.location_id?.int32Value ?? 0,
                status: .group(
                    onlinePercentage: CGFloat(group.online) / 100,
                    activePercentage: CGFloat(activePercentage) / 100
                ),
                title: getCaptionUseCase.invoke(data: group.shareableBase).string,
                icon: getChannelBaseIconUseCase.stateIcon(group, state: state),
                value: nil,
                leftButtonTitle: getChannelActionStringUseCase.leftButton(function: group.func.suplaFuntion)?.value,
                rightButtonTitle: getChannelActionStringUseCase.rightButton(function: group.func.suplaFuntion)?.value
            )
        }

        private func groupToHeatpoThermostatListItem(
            _ function: SuplaFunction,
            _ group: SAChannelGroup,
            _ location: _SALocation
        ) -> HeatpolThermostatListItem {
            let activePercentage = getGroupActivePercentageUseCase.invoke(group).clamped(to: 0 ... 100)
            let state = getChannelBaseStateUseCase.invoke(channelBase: group)

            return HeatpolThermostatListItem(
                base: DefaultListItem(
                    remoteId: group.remote_id,
                    profileId: group.profile.id,
                    userCaption: group.caption ?? "",
                    function: function,
                    locationCaption: location.caption ?? "",
                    locationId: location.location_id?.int32Value ?? 0,
                    status: .group(
                        onlinePercentage: CGFloat(group.online) / 100,
                        activePercentage: CGFloat(activePercentage) / 100
                    ),
                    title: getCaptionUseCase.invoke(data: group.shareableBase).string,
                    icon: getChannelBaseIconUseCase.stateIcon(group, state: state),
                    value: getHeatpolThermostatValue(group: group),
                    leftButtonTitle: getChannelActionStringUseCase.leftButton(function: group.func.suplaFuntion)?.value,
                    rightButtonTitle: getChannelActionStringUseCase.rightButton(function: group.func.suplaFuntion)?.value
                ),
                subValue: getHeatpolThermostatSubvalue(group: group)
            )
        }
        
        private func getHeatpolThermostatValue(group: SAChannelGroup) -> String {
            let min = group.measuredTemperatureMin()
            let max = group.measuredTemperatureMax()
            
            return formatHeatpolTemperatures(min, max)
        }
        
        private func getHeatpolThermostatSubvalue(group: SAChannelGroup) -> String {
            let min = group.presetTemperatureMin()
            let max = group.presetTemperatureMax()
            
            return formatHeatpolTemperatures(min, max)
        }
        
        private func formatHeatpolTemperatures(_ min: Double, _ max: Double) -> String {
            if (min == Self.UNKNOWN_TEMPERATURE || max == Self.UNKNOWN_TEMPERATURE) {
                return NO_VALUE_TEXT
            }
        
            let format = ValueFormat(
                withUnit: true,
                precision: ValueFormatPrecisionCustom(valuePrecision: ValuePrecisionKt.exactPrecision(value: 1)),
                customUnit: ValueUnit.temperatureDegree.getString()
            )
            let minString = thermometerValueFormatter.format(value: min, format: format)
            let maxString = thermometerValueFormatter.format(value: max, format: format)
            
            return "\(minString) - \(maxString)"
        }
        
        private static let UNKNOWN_TEMPERATURE = Double(ThermometerValueProviderImpl.UNKNOWN_VALUE)
    }
}
