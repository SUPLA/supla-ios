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

extension ThermostatTimerDetailFeature {
    protocol ViewDelegate {
        func onDeviceModeChange(_ mode: DeviceMode)
        func onTimeSelectionModeChange(_ mode: TimeSelectionMode)
        func onHeatValueChange(_ value: CGFloat)
        func onCoolValueChange(_ value: CGFloat)
        func onSetpointChange(_ step: TemperatureChangeStep)
        
        func onEditTimer()
        func onStart()
        func onCancelEditMode()
        func onCancelTimerIntoManualMode()
        func onCancelTimerIntoProgramMode()
    }
    
    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        var delegate: ViewDelegate?
        
        var body: some SwiftUI.View {
            BackgroundStack(alignment: .topLeading) {
                if (state.isTimerRunning && !state.isTimerEditing) {
                    ThermostatTimerDetailFeature.InProgressView(
                        deviceStateData: state.deviceStateData,
                        timerEndTime: state.timerEndTime,
                        delegate: delegate
                    )
                } else {
                    ThermostatTimerDetailFeature.ConfigurationView(
                        selectedMode: $state.selectedMode,
                        availableModes: state.availableModes,
                        timeSelectionMode: state.timeSelectionMode,
                        infoText: state.timerInfoText,
                        edit: state.isTimerRunning,
                        startDisabled: state.startDisabled,
                        minusDisabled: state.minusDisabled,
                        plusDisabled: state.plusDisabled,
                        setpointInChange: state.setpointInChange,
                        setpointValue: state.setpointValue,
                        heatingValue: $state.heatValue,
                        coolingValue: $state.coolValue,
                        timerDays: $state.timerDays,
                        timerHours: $state.timerHours,
                        timerMinutes: $state.timerMinutes,
                        calendarDate: $state.calendarDate,
                        delegate: delegate
                    )
                }
                
                if (state.loadingState.loading) {
                    SuplaCore.LoadingScrim()
                }
            }
        }
    }
}

#Preview("Time") {
    ThermostatTimerDetailFeature.View(
        state: ThermostatTimerDetailFeature.ViewState(
            availableModes: [.off, .heating],
            selectedMode: .off,
            loadingState: .init(initialLoading: false, loading: false)
        )
    )
}

#Preview("Date") {
    ThermostatTimerDetailFeature.View(
        state: ThermostatTimerDetailFeature.ViewState(
            availableModes: [.off, .cooling],
            selectedMode: .off,
            timeSelectionMode: .calendar,
            loadingState: .init(initialLoading: false, loading: false)
        )
    )
}

#Preview("Running") {
    ThermostatTimerDetailFeature.View(
        state: ThermostatTimerDetailFeature.ViewState(
            isTimersRunning: true,
            availableModes: [.off, .heating],
            selectedMode: .off,
            timeSelectionMode: .calendar,
            deviceStateData: DeviceState.Data(label: "STATE UNTIL 17.04.2026 00:59:", icon: .suplaIcon(name: .Icons.powerButton), value: "OFF"),
            timerEndTime: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 154),
            loadingState: .init(initialLoading: false, loading: false)
        )
    )
}
