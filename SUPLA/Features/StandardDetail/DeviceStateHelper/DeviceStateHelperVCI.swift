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

protocol DeviceStateHelperVCI {}

extension DeviceStateHelperVCI {
    func updateDeviceStateView(_ view: DeviceStateView, with state: DeviceStateViewState) {
        @Singleton<GetChannelBaseIconUseCase> var getChannelBaseIconUseCase
        
        if (!state.isOnline) {
            view.value = Strings.SwitchDetail.stateOffline
        } else if (state.isOn) {
            view.value = Strings.SwitchDetail.stateOn
        } else {
            view.value = Strings.SwitchDetail.stateOff
        }
        
        if let timerEndDate = state.timerEndDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Strings.General.hourFormat
            let dateString = dateFormatter.string(from: timerEndDate)
            view.label = .init(format: Strings.SwitchDetail.stateLabelForTimer, dateString)
        } else {
            view.label =  Strings.SwitchDetail.stateLabel
        }
        
        view.icon = getChannelBaseIconUseCase.invoke(
            function: state.iconData.function,
            userIcon: state.iconData.userIcon,
            channelState: state.iconData.channelState,
            altIcon: state.iconData.altIcon
        ).icon
    }
}
