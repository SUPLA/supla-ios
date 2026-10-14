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

extension SwitchTimerDetailFeature {
    protocol ViewDelegate {
        func onEditTimer()
        func onStopTimer()
        func onCancelTimer()
        func onTargetActionChange(_ action: TimerTargetAction)
        func onTimeChange(_ timeInSeconds: Int)
        func onStartTimer()
        func onCancelEditMode()
        func onInvalidTimeAlertDismiss()
        func calculateProgressViewData(startTime: Date, endTime: Date) -> ProgressViewData?
    }

    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        let delegate: ViewDelegate?

        private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        @State private var currentTime = Date()

        private var timerEndDate: Date? { state.deviceState?.timerEndDate }
        private var timerIsRunning: Bool { timerEndDate != nil }

        var body: some SwiftUI.View {
            GeometryReader { geometry in
                BackgroundStack {
                    if (geometry.size.width > geometry.size.height) {
                        LandscapeView()
                    } else {
                        PortraitView()
                    }
                }
            }
            .alert(Strings.TimerDetail.wrongTimeTitle, isPresented: alertBinding) {
                Button(Strings.General.ok) { delegate?.onInvalidTimeAlertDismiss() }
            } message: {
                Text(Strings.TimerDetail.wrongTimeMessage)
            }
            .onReceive(timer) { currentTime = $0 }
        }

        private var alertBinding: Binding<Bool> {
            Binding(
                get: { state.invalidTimeAlertPresented },
                set: { if (!$0) { delegate?.onInvalidTimeAlertDismiss() } }
            )
        }

        private func PortraitView() -> some SwiftUI.View {
            VStack(spacing: 0) {
                ChannelStateView(currentState: state.channelCurrentStateData, programState: state.channelProgramState)

                if (timerIsRunning) {
                    Spacer(minLength: Distance.small)
                    TimerProgress()
                    Spacer(minLength: Distance.small)
                } else {
                    Spacer(minLength: 0)
                }

                if (timerIsRunning && !state.editMode) {
                    TimerActions()
                } else {
                    SwitchTimerConfigurationView(state: state, delegate: delegate)
                }
            }
        }

        private func LandscapeView() -> some SwiftUI.View {
            HStack(spacing: Distance.default) {
                VStack(spacing: Distance.default) {
                    ChannelStateView(currentState: state.channelCurrentStateData, programState: state.channelProgramState)
                    Spacer(minLength: 0)
                    if (timerIsRunning && !state.editMode) {
                        EditTimerButton()
                    }
                }
                .frame(maxWidth: .infinity)

                if (timerIsRunning) {
                    TimerProgress()
                }

                if (timerIsRunning && !state.editMode) {
                    TimerActionButtons()
                        .frame(maxWidth: .infinity)
                } else {
                    SwitchTimerConfigurationView(state: state, delegate: delegate)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(Distance.default)
        }

        private func TimerProgress() -> some SwiftUI.View {
            ZStack {
                TimerProgressView(progressPercentage: progressData?.progres ?? 0)
                VStack(spacing: Distance.tiny) {
                    Text(progressTimeString)
                        .fontTitleLarge()
                        .multilineTextAlignment(.center)
                    Text(endHourString)
                        .fontBodyLarge()
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 220, height: 220)
        }

        private var progressData: ProgressViewData? {
            _ = currentTime
            guard let timerEndDate else { return nil }
            return delegate?.calculateProgressViewData(
                startTime: state.deviceState?.timerStartDate ?? state.referenceDate,
                endTime: timerEndDate
            )
        }

        private var progressTimeString: String {
            guard let data = progressData else { return "" }
            return Strings.TimerDetail.format.arguments(
                data.leftTimeValues.hours,
                data.leftTimeValues.minutes,
                data.leftTimeValues.seconds
            )
        }

        private var endHourString: String {
            guard let timerEndDate else { return "" }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Strings.General.hourFormat
            return Strings.TimerDetail.endHour.arguments(dateFormatter.string(from: timerEndDate))
        }

        private func TimerActions() -> some SwiftUI.View {
            VStack(spacing: Distance.default) {
                EditTimerButton()
                TimerActionButtons()
            }
        }

        private func TimerActionButtons() -> some SwiftUI.View {
            let isOn = state.deviceState?.isOn ?? false
            return VStack(spacing: Distance.default) {
                TitleButton(
                    title: Strings.TimerDetail.stop.arguments(isOn ? Strings.TimerDetail.infoOn : Strings.TimerDetail.infoOff),
                    fullWidth: true,
                    action: { delegate?.onStopTimer() }
                )
                .borderedButtonStyle()

                TitleButton(
                    title: Strings.TimerDetail.cancel.arguments(isOn ? Strings.TimerDetail.cancelOff : Strings.TimerDetail.cancelOn),
                    fullWidth: true,
                    action: { delegate?.onCancelTimer() }
                )
                .filledButtonStyle()
            }
            .padding(.horizontal, Distance.default)
            .padding(.bottom, Distance.default)
        }

        private func EditTimerButton() -> some SwiftUI.View {
            Button(action: { delegate?.onEditTimer() }) {
                HStack(spacing: Distance.tiny) {
                    Text(Strings.TimerDetail.editTime)
                        .fontBodyMedium()
                        .textColor(.Supla.onBackground)
                    Image(.Icons.pencil)
                        .renderingMode(.template)
                        .foregroundColor(.Supla.primary)
                }
            }
        }
    }
}

#Preview("Timer setup") {
    SwitchTimerDetailFeature.View(
        state: switchTimerDetailPreviewState(isRunning: false, isEditing: false),
        delegate: nil
    )
}

#Preview("Timer running") {
    SwitchTimerDetailFeature.View(
        state: switchTimerDetailPreviewState(isRunning: true, isEditing: false),
        delegate: nil
    )
}

#Preview("Edit running timer") {
    SwitchTimerDetailFeature.View(
        state: switchTimerDetailPreviewState(isRunning: true, isEditing: true),
        delegate: nil
    )
}

private func switchTimerDetailPreviewState(isRunning: Bool, isEditing: Bool) -> SwitchTimerDetailFeature.ViewState {
    let state = SwitchTimerDetailFeature.ViewState()
    let now = Date()
    let endDate = isRunning ? now.addingTimeInterval(3600) : nil
    let iconData = FetchIconData(function: SUPLA_CHANNELFNC_POWERSWITCH, altIcon: 0, profileId: 0)

    state.deviceState = DeviceStateViewState(
        isOnline: true,
        isOn: isRunning,
        timerEndDate: endDate,
        timerStartDate: isRunning ? now.addingTimeInterval(-3600) : nil,
        iconData: iconData
    )
    state.channelCurrentStateData = ChannelCurrentState.Data(
        label: isRunning ? "State until \(endDate!.formatted(date: .omitted, time: .shortened))" : "State",
        icon: .suplaIcon(name: .Icons.fncGpm1),
        value: isRunning ? "On" : "Off"
    )
    state.editMode = isEditing
    state.targetAction = .turnOff
    state.setTimeInSeconds(3661)
    return state
}
