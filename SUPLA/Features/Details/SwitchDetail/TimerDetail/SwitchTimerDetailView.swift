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

        private var timerEndDate: Date? { state.timerEndDate }
        private var timerIsRunning: Bool { timerEndDate != nil }
        private let timeFormat = "%02d:%02d:%02d"

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

        @ViewBuilder
        private func PortraitView() -> some SwiftUI.View {
            if (timerIsRunning) {
                PortraitRunningView()
            } else {
                PortraitDefaultView()
            }
        }

        @ViewBuilder
        private func PortraitDefaultView() -> some SwiftUI.View {
            VStack(spacing: 0) {
                ChannelStateView(currentState: state.channelCurrentStateData, programState: state.channelProgramState)
                Spacer(minLength: 0)
                VStack(spacing: 0) {
                    SwitchTimerConfigurationHeader(state: state, delegate: delegate)
                    TimePicker()
                    InfoText().padding(.vertical, Distance.default)
                    SaveButton()
                }
                .padding(Distance.default)
                .background(Color.Supla.surface)
            }
        }

        @ViewBuilder
        private func PortraitRunningView() -> some SwiftUI.View {
            VStack(spacing: 0) {
                ChannelStateView(currentState: state.channelCurrentStateData, programState: state.channelProgramState)
                ZStack(alignment: .top) {
                    if (timerIsRunning) {
                        VStack(spacing: 0) {
                            Spacer(minLength: Distance.small)
                            TimerProgress()
                            Spacer(minLength: Distance.small)
                            TimerActionsPortrait()
                        }
                    }

                    if (state.editMode) {
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            VStack(spacing: 0) {
                                SwitchTimerConfigurationHeader(state: state, delegate: delegate)
                                TimePicker()
                                CancelButton().padding(.vertical, Distance.default)
                                SaveButton()
                            }
                            .padding(Distance.default)
                            .background(Color.Supla.surface)
                        }
                    }
                }
            }
        }

        private func LandscapeView() -> some SwiftUI.View {
            HStack(spacing: Distance.default) {
                if (state.editMode) {
                    LandscapeEditView()
                } else if (timerIsRunning) {
                    LandscapeRunningView()
                } else {
                    LandscapeDefaultView()
                }
            }
            .padding(.horizontal, Distance.default)
            .padding(.vertical, Distance.small)
            .background(Color.Supla.surface)
        }

        @ViewBuilder
        private func LandscapeDefaultView() -> some SwiftUI.View {
            VStack(spacing: Distance.default) {
                ChannelStateView(currentState: state.channelCurrentStateData, programState: state.channelProgramState, padding: .zero)
                Spacer(minLength: 0)
                if (!state.timerStartDisabled) {
                    InfoText()
                }
                SaveButton()
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 0) {
                SwitchTimerConfigurationHeader(state: state, delegate: delegate)
                TimePicker()
                Spacer(minLength: Distance.tiny)
            }
            .frame(maxWidth: .infinity)
        }

        @ViewBuilder
        private func LandscapeRunningView() -> some SwiftUI.View {
            VStack(spacing: 0) {
                ChannelStateView(currentState: state.channelCurrentStateData, programState: state.channelProgramState, padding: .zero)
                Spacer(minLength: Distance.tiny)
                TimerProgress()
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 0) {
                TimerActionsLandscape()
            }
            .frame(maxWidth: .infinity)
        }

        @ViewBuilder
        private func LandscapeEditView() -> some SwiftUI.View {
            VStack() {
                ChannelStateView(currentState: state.channelCurrentStateData, programState: state.channelProgramState, padding: .zero)
                Spacer(minLength: 0)
                TimerProgress()
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 0) {
                SwitchTimerConfigurationHeader(state: state, delegate: delegate)
                TimePicker()
                Spacer(minLength: 0)
                CancelButton()
                SaveButton().padding(.top, Distance.small)
            }
            .frame(maxWidth: .infinity)
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

        private func InfoText() -> some SwiftUI.View {
            Text(infoText)
                .fontBodyMedium()
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }

        private var infoText: String {
            let actionText = state.targetAction == .turnOn ? Strings.TimerDetail.infoOn : Strings.TimerDetail.infoOff
            let nextActionText = state.targetAction == .turnOn ? Strings.TimerDetail.infoNextOff : Strings.TimerDetail.infoNextOn
            let time = String(format: timeFormat, state.hours, state.minutes, state.seconds)
            return Strings.TimerDetail.info.arguments(actionText, time, nextActionText)
        }

        private var progressData: ProgressViewData? {
            _ = currentTime
            guard let timerEndDate else { return nil }
            return delegate?.calculateProgressViewData(
                startTime: state.timerStartDate ?? state.referenceDate,
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

        @ViewBuilder
        private func TimerActionsPortrait() -> some SwiftUI.View {
            let isOn = state.isOn
            EditTimerButton()
            VStack(spacing: Distance.default) {
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
            .padding(Distance.default)
            .padding(.top, Distance.small)
        }

        @ViewBuilder
        private func TimerActionsLandscape() -> some SwiftUI.View {
            let isOn = state.isOn

            VStack(spacing: Distance.small) {
                Spacer(minLength: 0)
                EditTimerButton()
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

        private func CancelButton() -> some SwiftUI.View {
            TitleButton(title: Strings.TimerDetail.editCancel, fullWidth: true) {
                delegate?.onCancelEditMode()
            }
            .borderedButtonStyle()
        }

        private func SaveButton() -> some SwiftUI.View {
            TitleButton(
                title: state.editMode ? Strings.TimerDetail.save : Strings.General.start,
                fullWidth: true,
                action: { delegate?.onStartTimer() }
            )
            .filledButtonStyle()
            .disabled(!state.isOnline || state.timerStartDisabled)
        }

        private func TimePicker() -> some SwiftUI.View {
            HStack(spacing: 0) {
                SuplaCore.WheelPicker(selected: hoursBinding, items: (0..<24).map { $0.asHourPickerItem })
                SuplaCore.WheelPicker(selected: minutesBinding, items: (0..<60).map { $0.asMinutePickerItem })
                SuplaCore.WheelPicker(selected: secondsBinding, items: (0..<60).map {
                    NumberPickerItem(id: $0, pattern: Strings.TimerDetail.secondPattern)
                })
            }
            .frame(height: 160)
        }

        private var hoursBinding: Binding<HourPickerItem> {
            Binding(
                get: { state.hours.asHourPickerItem },
                set: {
                    state.hours = $0.id
                    delegate?.onTimeChange(state.timeInSeconds)
                }
            )
        }

        private var minutesBinding: Binding<NumberPickerItem> {
            Binding(
                get: { state.minutes.asMinutePickerItem },
                set: {
                    state.minutes = $0.id
                    delegate?.onTimeChange(state.timeInSeconds)
                }
            )
        }

        private var secondsBinding: Binding<NumberPickerItem> {
            Binding(
                get: { NumberPickerItem(id: state.seconds, pattern: Strings.TimerDetail.secondPattern) },
                set: {
                    state.seconds = $0.id
                    delegate?.onTimeChange(state.timeInSeconds)
                }
            )
        }
    }
}

struct SwitchTimerConfigurationHeader: SwiftUI.View {
    @ObservedObject var state: SwitchTimerDetailFeature.ViewState
    let delegate: SwitchTimerDetailFeature.ViewDelegate?

    var body: some SwiftUI.View {
        VStack(spacing: Distance.tiny) {
            Text(header)
                .fontTitleSmall()
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            if (!state.editMode) {
                SuplaCore.SegmentedPicker(
                    selected: actionBinding,
                    items: [TimerTargetAction.turnOn, .turnOff]
                )
                .frame(height: 44)
            }
        }
    }

    private var header: String {
        guard !state.timerStartDisabled else { return Strings.TimerDetail.disabledForcedMode }
        guard (state.editMode) else { return Strings.TimerDetail.header }
        let headerArgument = state.isOn ? Strings.TimerDetail.editHeaderOn : Strings.TimerDetail.editHeaderOff
        return Strings.TimerDetail.editHeader.arguments(headerArgument)
    }

    private var actionBinding: Binding<TimerTargetAction> {
        Binding(
            get: { state.targetAction },
            set: { delegate?.onTargetActionChange($0) }
        )
    }
}

enum TimerTargetAction: Int, PickerItem {
    case turnOn = 0
    case turnOff = 1

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .turnOn: Strings.TimerDetail.turnedOn
        case .turnOff: Strings.TimerDetail.turnedOff
        }
    }

    static func from(value: Int) -> TimerTargetAction {
        switch (value) {
        case 0: return .turnOn
        case 1: return .turnOff
        default: fatalError("Invalid value '\(value)' for target action")
        }
    }
}

#Preview("Timer setup") {
    DetailPreviewScaffold {
        SwitchTimerDetailFeature.View(
            state: switchTimerDetailPreviewState(isRunning: false, isEditing: false),
            delegate: nil
        )
    }
}

#Preview("Timer running") {
    DetailPreviewScaffold {
        SwitchTimerDetailFeature.View(
            state: switchTimerDetailPreviewState(isRunning: true, isEditing: false),
            delegate: nil
        )
    }
}

#Preview("Edit running timer") {
    DetailPreviewScaffold {
        SwitchTimerDetailFeature.View(
            state: switchTimerDetailPreviewState(isRunning: true, isEditing: true),
            delegate: nil
        )
    }
}

private func switchTimerDetailPreviewState(isRunning: Bool, isEditing: Bool) -> SwitchTimerDetailFeature.ViewState {
    let state = SwitchTimerDetailFeature.ViewState()
    let now = Date()
    let endDate = isRunning ? now.addingTimeInterval(3600) : nil
    let iconData = FetchIconData(function: SUPLA_CHANNELFNC_POWERSWITCH, altIcon: 0, profileId: 0)

    state.isOn = isRunning
    state.isOnline = true
    state.timerEndDate = endDate
    state.timerStartDate = isRunning ? now.addingTimeInterval(-3600) : nil
    state.channelCurrentStateData = ChannelCurrentState.Data(
        label: isRunning ? "State until \(endDate!.formatted(date: .omitted, time: .shortened))" : "State",
        icon: .suplaIcon(name: .Icons.fncGpm1),
        value: isRunning ? "On" : "Off"
    )
    state.channelProgramState = [
        .init(
            label: Strings.ThermostatDetail.programCurrent,
            description: Strings.Schedule.programForceOn,
            time: Strings.ThermostatDetail.programTime.arguments(
                Strings.General.time_just_minutes.arguments(12)
            )
        ),
        .init(
            label: Strings.ThermostatDetail.programNext,
            description: Strings.General.turnOff
        )
    ]
    state.editMode = isEditing
    state.targetAction = .turnOff
    state.setTimeInSeconds(3661)
    return state
}
