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

struct ChannelToMainListItem {
    protocol UseCase {
        func invoke(_ channelWithChildren: ChannelWithChildren) -> MainListItem?
        func invoke(_ channelWithChildren: ChannelWithChildren, location: _SALocation) -> MainListItem
    }

    final class Implementation: UseCase {
        @Singleton<UserStateHolder> private var userStateHolder
        @Singleton<DownloadEventsManager> private var downloadEventsManager

        func invoke(_ channelWithChildren: ChannelWithChildren) -> MainListItem? {
            guard let location = channelWithChildren.channel.location else { return nil }
            return invoke(channelWithChildren, location: location)
        }

        func invoke(_ channelWithChildren: ChannelWithChildren, location: _SALocation) -> MainListItem {
            @Singleton<GetCaptionUseCase> var getCaptionUseCase
            @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
            @Singleton<GetChannelValueStringUseCase> var getChannelValueStringUseCase
            @Singleton<GetChannelIssuesForListUseCase> var getChannelIssuesForListUseCase

            let channel = channelWithChildren.channel
            let function = SuplaFunction.companion.from(value: channelWithChildren.function)
            let base = DefaultListItem(
                remoteId: channel.remote_id,
                profileId: channel.profile.id,
                userCaption: channel.caption ?? "",
                function: function,
                locationCaption: location.caption ?? "",
                locationId: location.location_id?.int32Value ?? 0,
                status: .channel(channel.value?.status.onlineState ?? .offline),
                title: getCaptionUseCase.invoke(data: channel.shareable).string,
                icon: getChannelBaseIconUseCase.invoke(channel: channel),
                value: getChannelValueStringUseCase.valueOrNil(channelWithChildren),
                issues: getChannelIssuesForListUseCase.invoke(channelWithChildren: channelWithChildren.shareable),
                processing: isProcessing(channelWithChildren),
                estimatedTimerEndDate: channel.getTimerEndDate(),
                infoSupported: channelWithChildren.showInfoIcon,
                leftButtonTitle: channelWithChildren.leftButtonTitle,
                rightButtonTitle: channelWithChildren.rightButtonTitle
            )

            return switch (function) {
            case .thermostatHeatpolHomeplus:
                MainListItem.heatpolThermostat(
                    HeatpolThermostatListItem(
                        base: base,
                        subValue: getChannelValueStringUseCase.invoke(channelWithChildren, valueType: .second, withUnit: true)
                    )
                )
            case .humidityAndTemperature:
                MainListItem.doubleValue(
                    DoubleValueListItem(
                        base: base,
                        secondIcon: getChannelBaseIconUseCase.invoke(channel: channel, type: .second),
                        secondValue: getChannelValueStringUseCase.invoke(channelWithChildren, valueType: .second, withUnit: true)
                    )
                )
            case .hvacThermostatHeatCool,
                 .hvacThermostat,
                 .hvacDomesticHotWater:
                createHvacThermostatListItem(channelWithChildren: channelWithChildren, base: base)
            default:
                MainListItem.channel(base)
            }
        }

        private func createHvacThermostatListItem(
            channelWithChildren: ChannelWithChildren,
            base: DefaultListItem
        ) -> MainListItem {
            let value = channelWithChildren.channel.value?.asThermostatValue()

            return MainListItem.hvacThermostat(
                HvacThermostatListItem(
                    base: base,
                    subValue: value?.setpointText ?? "",
                    indicatorIcon: value?.indicatorIcon
                )
            )
        }

        private func isProcessing(_ channelWithChildren: ChannelWithChildren) -> Bool {
            if (channelWithChildren.isOrHasImpulseCounter) {
                let settings = userStateHolder.getImpulseCounterSettings(
                    profileId: channelWithChildren.channel.profile.id,
                    remoteId: channelWithChildren.remoteId
                )
                if (settings.showOnList != .noAggregation) {
                    return downloadEventsManager
                        .getLastChannelDownloadState(remoteId: channelWithChildren.remoteId)?
                        .isInProgress() == true
                }
            }

            if (channelWithChildren.isOrHasElectricityMeter) {
                let settings = userStateHolder.getElectricityMeterSettings(
                    profileId: channelWithChildren.channel.profile.id,
                    remoteId: channelWithChildren.remoteId
                )
                if (settings.usingAggregatedValue) {
                    return downloadEventsManager
                        .getLastChannelDownloadState(remoteId: channelWithChildren.remoteId)?
                        .isInProgress() == true
                }
            }

            return false
        }
    }
}

private extension ChannelWithChildren {
    var leftButtonTitle: String? {
        @Singleton<GetChannelActionStringUseCase> var getChannelActionStringUseCase
        return getChannelActionStringUseCase.leftButton(function: function.suplaFuntion)?.value
    }

    var rightButtonTitle: String? {
        @Singleton<GetChannelActionStringUseCase> var getChannelActionStringUseCase
        return getChannelActionStringUseCase.rightButton(function: function.suplaFuntion)?.value
    }
}
