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

struct SwitchTimerConfigurationView: SwiftUI.View {
    @ObservedObject var state: SwitchTimerDetailFeature.ViewState
    let delegate: SwitchTimerDetailFeature.ViewDelegate?

    private let timeFormat = "%02d:%02d:%02d"

    var body: some SwiftUI.View {
        VStack(spacing: Distance.default) {
            Text(header)
                .fontTitleSmall()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            if (!state.editMode) {
                SuplaCore.SegmentedPicker(
                    selected: actionBinding,
                    items: [TimerTargetAction.turnOn, .turnOff]
                )
                .frame(height: 44)
            }

            TimePicker()

            if (!state.editMode) {
                Rectangle()
                    .fill(Color.Supla.background)
                    .frame(height: 1)

                Text(infoText)
                    .fontBodyMedium()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            } else {
                TitleButton(title: Strings.TimerDetail.editCancel, fullWidth: true) {
                    delegate?.onCancelEditMode()
                }
                .borderedButtonStyle()
            }

            TitleButton(
                title: state.editMode ? Strings.TimerDetail.save : Strings.General.start,
                fullWidth: true,
                action: { delegate?.onStartTimer() }
            )
            .filledButtonStyle()
            .disabled(state.deviceState?.isOnline != true || state.timerStartDisabled)
        }
        .padding(Distance.default)
        .background(Color.Supla.surface)
    }

    private var header: String {
        guard !state.timerStartDisabled else { return Strings.TimerDetail.disabledForcedMode }
        guard (state.editMode) else { return Strings.TimerDetail.header }
        let headerArgument = state.deviceState?.isOn == true
            ? Strings.TimerDetail.editHeaderOn
            : Strings.TimerDetail.editHeaderOff
        return Strings.TimerDetail.editHeader.arguments(headerArgument)
    }

    private var actionBinding: Binding<TimerTargetAction> {
        Binding(
            get: { state.targetAction },
            set: { delegate?.onTargetActionChange($0) }
        )
    }

    private var infoText: String {
        let actionText = state.targetAction == .turnOn ? Strings.TimerDetail.infoOn : Strings.TimerDetail.infoOff
        let nextActionText = state.targetAction == .turnOn ? Strings.TimerDetail.infoNextOff : Strings.TimerDetail.infoNextOn
        let time = String(format: timeFormat, state.hours, state.minutes, state.seconds)
        return Strings.TimerDetail.info.arguments(actionText, time, nextActionText)
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
        switch(value) {
        case 0: return .turnOn
        case 1: return .turnOff
        default: fatalError("Invalid value '\(value)' for target action")
        }
    }
}
