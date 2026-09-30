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

extension RelayScheduleFeature {
    protocol ViewDelegate {
        func onProgramTap(_ program: WeeklyScheduleProgram)
        func onProgramLongPress(_ program: WeeklyScheduleProgram)
        func onBoxTap(_ key: ScheduleDetailBoxKey)
        func onBoxTapFinished()
        func onShowQuarters(_ key: ScheduleDetailBoxKey)
        func onQuartersDismiss()
        func onQuartersProgramChange(_ program: SuplaScheduleProgram)
        func onQuartersChange(_ quarter: QuarterOfHour)
        func onQuartersSave()
        func onProgramSettingsDismiss()
        func onProgramSettingsModeChange(_ mode: SuplaRelayMode)
        func onProgramSettingsDurationChange(_ value: String)
        func onProgramSettingsOppositeDurationChange(_ value: String)
        func onProgramSettingsDurationMinus(_ duration: ProgramDuration)
        func onProgramSettingsDurationPlus(_ duration: ProgramDuration)
        func onProgramSettingsSave()
    }

    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        let delegate: ViewDelegate?

        var body: some SwiftUI.View {
            WeeklyScheduleEditor(
                programs: relayProgramsForView(state.programs),
                activeProgram: state.activeProgram,
                schedule: state.schedule,
                currentDay: state.currentDay,
                currentHour: state.currentHour,
                onProgramTap: { delegate?.onProgramTap($0) },
                onProgramLongPress: { delegate?.onProgramLongPress($0) },
                onBoxTap: { delegate?.onBoxTap($0) },
                onBoxTapFinished: { delegate?.onBoxTapFinished() },
                onBoxLongPress: { delegate?.onShowQuarters($0) },
                dialogs: {
                    if let quarters = state.quarters {
                        AnyView(QuartersDialog(state: quarters, delegate: delegate))
                    } else if let settings = state.programSettings {
                        AnyView(ProgramSettingsDialog(state: settings, delegate: delegate))
                    } else {
                        AnyView(EmptyView())
                    }
                }
            )
        }
    }

    private struct QuartersDialog: SwiftUI.View {
        @ObservedObject var state: QuartersState
        let delegate: ViewDelegate?
        @ObservedObject private var orientationObserver = OrientationObserver()

        var body: some SwiftUI.View {
            let width: CGFloat = orientationObserver.orientation.isLandscape ? 500 : 300
            SuplaCore.Dialog.Base(onDismiss: { delegate?.onQuartersDismiss() }, width: width) {
                SuplaCore.Dialog.Header(title: Strings.ThermostatDetail.editQuartersDialogHeader.arguments(state.key.hour))
                FlowHStack(data: state.programs) { _, program in
                    ScheduleProgramButton(
                        state: program.buttonState(state.activeProgram),
                        action: { delegate?.onQuartersProgramChange(program.program) }
                    )
                }
                .padding(.vertical, Distance.tiny)
                .padding(.horizontal, Distance.default)
                .background(Color.Supla.background)

                Text(state.key.dayOfWeek.fullText().uppercased())
                    .fontBodyMedium()
                    .padding(.horizontal, Distance.default)
                    .padding(.vertical, Distance.small)

                ForEach(QuarterOfHour.allCases, id: \.self) { quarter in
                    HStack(spacing: Distance.default) {
                        Text(state.key.hour.toHour(withMinutes: quarter.minutes())).fontBodyMedium()
                        state.hourPrograms.programForQuarter(quarter).color
                            .frame(maxWidth: .infinity, maxHeight: 36)
                            .clipShape(RoundedRectangle(cornerRadius: Dimens.radiusSmall))
                            .onTapGesture { delegate?.onQuartersChange(quarter) }
                    }
                    .padding(.horizontal, Distance.default)
                    .padding(.bottom, Distance.tiny)
                }

                SuplaCore.Dialog.HorizontalButtons(
                    onSecondaryClick: { delegate?.onQuartersDismiss() },
                    onPrimaryClick: { delegate?.onQuartersSave() }
                )
            }
        }
    }

    private struct ProgramSettingsDialog: SwiftUI.View {
        @ObservedObject var state: ProgramSettings
        let delegate: ViewDelegate?

        var body: some SwiftUI.View {
            SuplaCore.Dialog.Base(onDismiss: { delegate?.onProgramSettingsDismiss() }, alignment: .leading) {
                ScheduleProgramDialogHeader(program: state.program)

                LabelText(text: Strings.RelaySchedule.operationType)
                    .padding(.horizontal, Distance.default + Distance.small)
                    .padding(.bottom, Distance.tiny)
                SuplaCore.Picker(
                    selected: Binding<RelayModePickerItem?>(
                        get: { RelayModePickerItem(mode: state.mode) },
                        set: { if let mode = $0 { delegate?.onProgramSettingsModeChange(mode.mode) } }
                    ),
                    items: state.availableModes.map { RelayModePickerItem(mode: $0) }
                )
                .style(.dialog)
                .padding(.horizontal, Distance.default)
                .padding(.bottom, Distance.small)

                if state.showsDurations {
                    DurationControl(
                        label: Strings.RelaySchedule.firstDuration.arguments(state.mode.relayStateLabel),
                        value: state.duration,
                        onChange: { delegate?.onProgramSettingsDurationChange($0) },
                        onMinus: { delegate?.onProgramSettingsDurationMinus(.relayMode) },
                        onPlus: { delegate?.onProgramSettingsDurationPlus(.relayMode) }
                    )
                    .padding(.bottom, Distance.small)
                    DurationControl(
                        label: Strings.RelaySchedule.secondDuration.arguments(state.mode.oppositeStateLabel),
                        value: state.oppositeDuration,
                        onChange: { delegate?.onProgramSettingsOppositeDurationChange($0) },
                        onMinus: { delegate?.onProgramSettingsDurationMinus(.oppositeMode) },
                        onPlus: { delegate?.onProgramSettingsDurationPlus(.oppositeMode) }
                    )
                }

                SuplaCore.Dialog.HorizontalButtons(
                    onSecondaryClick: { delegate?.onProgramSettingsDismiss() },
                    onPrimaryClick: { delegate?.onProgramSettingsSave() }
                )
            }
        }

        private func DurationControl(
            label: String,
            value: String,
            onChange: @escaping (String) -> Void,
            onMinus: @escaping () -> Void,
            onPlus: @escaping () -> Void
        ) -> some SwiftUI.View {
            VStack(alignment: .leading, spacing: Distance.tiny) {
                LabelText(text: label)
                    .padding(.leading, Distance.small)
                HStack(spacing: Distance.tiny) {
                    IconButton(name: .Icons.minus, action: onMinus)
                        .filledButtonStyle()
                        .disabled((UInt16(value) ?? 0) == 0)
                        .clipShape(Circle())
                    AccessoryTextField(
                        text: Binding(get: { value }, set: onChange),
                        suffix: { AccessoryText("s") }
                    )
                    .keyboardType(.numberPad)
                    .frame(width: 120)
                    IconButton(name: .Icons.plus, action: onPlus)
                        .filledButtonStyle()
                        .disabled((UInt16(value) ?? 0) == UInt16.max)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, Distance.default)
        }
    }
}

private struct RelayModePickerItem: PickerItem {
    let mode: SuplaRelayMode

    var id: Int32 { mode.value }
    var label: String { mode.scheduleLabel }
}

private extension SuplaRelayMode {
    var scheduleLabel: String {
        switch self {
        case .startOn: Strings.RelaySchedule.modeStartOn
        case .startOff: Strings.RelaySchedule.modeStartOff
        case .forcedOn: Strings.RelaySchedule.modeForcedOn
        case .forcedOff: Strings.RelaySchedule.modeForcedOff
        case .automatic: Strings.RelaySchedule.modeAutomatic
        case .notSet, .cmdWeeklySchedule, .cmdSwitchToManual: NO_VALUE_TEXT
        }
    }

    var relayStateLabel: String { self == .startOn ? "ON" : self == .startOff ? "OFF" : "" }
    var oppositeStateLabel: String { self == .startOn ? "OFF" : self == .startOff ? "ON" : "" }
}

private func relaySchedulePreviewState() -> RelayScheduleFeature.ViewState {
    let state = RelayScheduleFeature.ViewState()
    state.programs = relaySchedulePreviewPrograms
    state.activeProgram = .program1
    state.schedule = relaySchedulePreviewSchedule()
    state.currentDay = .monday
    state.currentHour = 8
    return state
}

private let relaySchedulePreviewPrograms: [SuplaRelayWeeklyScheduleProgram] = [
    SuplaRelayWeeklyScheduleProgram(
            program: .program1,
            mode: .startOn,
            modeDurationS: 20,
            oppositeModeDurationS: 10
    ),
    SuplaRelayWeeklyScheduleProgram(
            program: .program2,
            mode: .startOff,
            modeDurationS: 60,
            oppositeModeDurationS: 0
    ),
    SuplaRelayWeeklyScheduleProgram(program: .program3, mode: .forcedOn, modeDurationS: 0, oppositeModeDurationS: 0)
]

private func relaySchedulePreviewSchedule() -> [ScheduleDetailBoxKey: WeeklyScheduleBoxValue] {
    var schedule: [ScheduleDetailBoxKey: WeeklyScheduleBoxValue] = [:]
    for day in DayOfWeek.allCases {
        for hour in 0...23 {
            schedule[.init(dayOfWeek: day, hour: hour)] = .init(oneProgram: .off)
        }
    }
    schedule[.init(dayOfWeek: .monday, hour: 8)] = .init(oneProgram: .program1)
    schedule[.init(dayOfWeek: .monday, hour: 9)] = .init(.program1, .program2, .program1, .program2)
    schedule[.init(dayOfWeek: .friday, hour: 18)] = .init(oneProgram: .program3)
    return schedule
}

#Preview("Relay schedule") {
    RelayScheduleFeature.View(
        state: relaySchedulePreviewState(),
        delegate: nil
    )
}

#Preview("Relay program dialog") {
    let state = relaySchedulePreviewState()
    state.programSettings = RelayScheduleFeature.ProgramSettings(
        program: relaySchedulePreviewPrograms[0].program,
        mode: .startOn,
        duration: "20",
        oppositeDuration: "10"
    )
    return RelayScheduleFeature.View(state: state, delegate: nil)
}

#Preview("Relay quarters dialog") {
    let state = relaySchedulePreviewState()
    state.quarters = RelayScheduleFeature.QuartersState(
        key: .init(dayOfWeek: .monday, hour: 9),
        programs: relayProgramsForView(relaySchedulePreviewPrograms),
        activeProgram: .program1,
        hourPrograms: .init(.program1, .program2, .program1, .program2)
    )
    return RelayScheduleFeature.View(state: state, delegate: nil)
}

func relayProgramsForView(_ programs: [SuplaRelayWeeklyScheduleProgram]) -> [WeeklyScheduleProgram] {
    programs.map { WeeklyScheduleProgram(program: $0) }
        + [WeeklyScheduleProgram(program: SuplaRelayWeeklyScheduleProgram.default(), label: Strings.Schedule.programDefault)]
}
