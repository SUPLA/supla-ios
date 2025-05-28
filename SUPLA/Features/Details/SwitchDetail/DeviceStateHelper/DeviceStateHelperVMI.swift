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

protocol DeviceStateHelperVMI {}

extension DeviceStateHelperVMI {
    
    func createDeviceState(from channel: SAChannel) -> DeviceStateViewState {
        return DeviceStateViewState(
            isOnline: channel.status().online,
            isOn: channel.value?.hiValue() ?? 0 > 0,
            timerEndDate: createTimerEndDateFor(channel),
            timerStartDate: channel.ev?.timerStartTime,
            iconData: createIconData(channel)
        )
    }
    
    private func createIconData(_ channel: SAChannelBase) -> FetchIconData {
        @Singleton<GetChannelBaseStateUseCase> var getChannelBaseStateUseCase
        
        return FetchIconData(
            function: channel.func,
            altIcon: channel.alticon,
            profileId: channel.profile.id,
            state: getChannelBaseStateUseCase.invoke(channelBase: channel),
            userIconId: channel.usericon_id
        )
    }
    
    private func createTimerEndDateFor(_ channel: SAChannel) -> Date? {
        @Singleton<DateProvider> var dateProvider
        
        if
            let state = channel.ev?.timerState,
            let timerEndTime = state.countdownEndsAt {
            if (timerEndTime.timeIntervalSince1970 > dateProvider.currentTimestamp()) {
                return timerEndTime
            }
        }
        
        return nil
    }
}

struct DeviceStateViewState: Equatable {
    let isOnline: Bool
    let isOn: Bool
    let timerEndDate: Date?
    let timerStartDate: Date?
    let iconData: FetchIconData
}
