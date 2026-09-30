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

extension ThermostatScheduleDetailFeature {
    protocol ViewDelegate {
        func onProgramTap(_ program: ScheduleDetailProgram)
        func onBoxTap(_ key: ScheduleDetailBoxKey)
        func onBoxTapFinished()
        func onShowProgramDialog(_ program: ScheduleDetailProgram)
        func onShowQuartersDialog(_ key: ScheduleDetailBoxKey)
        
        func onProgramDialogDismiss()
        func onProgramDialogChange(_ setpointType: SetpointType, _ value: String)
        func onProgramDialogModeChange(_ mode: SuplaHvacMode)
        func onProgramDialogPlus(_ setpointType: SetpointType, _ value: String)
        func onProgramDialogMinus(_ setpointType: SetpointType, _ value: String)
        func onProgramDialogSave(_ heatValue: String, _ coolValue: String)
        
        func onQuartersDialogDismiss()
        func onQuartersDialogProgramChange(_ program: SuplaScheduleProgram)
        func onQuartersDialogQuarterChange(_ quarter: QuarterOfHour)
        func onQuartersDialogSave()
    }

    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState
        let delegate: ViewDelegate?

        var body: some SwiftUI.View {
            WeeklyScheduleEditor(
                programs: state.programs.map { WeeklyScheduleProgram(program: $0.scheduleProgram, icon: $0.icon) },
                activeProgram: state.activeProgram,
                schedule: state.schedule.mapValues {
                    WeeklyScheduleBoxValue(
                        $0.firstQuarterProgram,
                        $0.secondQuarterProgram,
                        $0.thirdQuarterProgram,
                        $0.fourthQuarterProgram
                    )
                },
                currentDay: state.currentDay,
                currentHour: state.currentHour,
                onProgramTap: { program in
                    if let original = state.programs.first(where: { $0.scheduleProgram.program == program.program }) {
                        delegate?.onProgramTap(original)
                    }
                },
                onProgramLongPress: { program in
                    if let original = state.programs.first(where: { $0.scheduleProgram.program == program.program }) {
                        delegate?.onShowProgramDialog(original)
                    }
                },
                onBoxTap: { delegate?.onBoxTap($0) },
                onBoxTapFinished: { delegate?.onBoxTapFinished() },
                onBoxLongPress: { delegate?.onShowQuartersDialog($0) },
                dialogs: {
                    if let editProgramState = state.editProgramState {
                        AnyView(ThermostatScheduleDetailFeature.EditProgramDialog(
                            state: editProgramState,
                            onDismiss: { delegate?.onProgramDialogDismiss() },
                            onChange: { delegate?.onProgramDialogChange($0, $1) },
                            onModeChange: { delegate?.onProgramDialogModeChange($0) },
                            onPlus: { delegate?.onProgramDialogPlus($0, $1) },
                            onMinus: { delegate?.onProgramDialogMinus($0, $1) },
                            onSave: { delegate?.onProgramDialogSave($0, $1) }
                        ))
                    } else if let editQuartersState = state.editQuartersState {
                        AnyView(ThermostatScheduleDetailFeature.EditQuartersDialog(
                            state: editQuartersState,
                            onDismiss: { delegate?.onQuartersDialogDismiss() },
                            onProgramChange: { delegate?.onQuartersDialogProgramChange($0) },
                            onQuarterChange: { delegate?.onQuartersDialogQuarterChange($0) },
                            onSave: { delegate?.onQuartersDialogSave() }
                        ))
                    } else {
                        AnyView(EmptyView())
                    }
                }
            )
        }
    }
}

private let previewState = ThermostatScheduleDetailFeature.ViewState(
    programs: [
        scheduleDetailProgram(.program1, 2100),
        scheduleDetailProgram(.program2, 2300),
        scheduleDetailProgram(.program3, 1800),
        scheduleDetailProgram(.program4, 2500),
        ScheduleDetailProgram(scheduleProgram: .OFF)
    ],
    activeProgram: .program1,
    schedule: generateSchedule([
        .init(dayOfWeek: .saturday, hour: 18): .init(oneProgram: .program1)
    ])
)

#Preview {
    ThermostatScheduleDetailFeature.View(
        state: previewState,
        delegate: nil
    )
}

#if swift(>=5.9)
@available(iOS 17.0, *)
#Preview("Landscape", traits: .landscapeRight) {
    ZStack {
        ThermostatScheduleDetailFeature.View(
            state: previewState,
            delegate: nil
        )
    }
    .safeAreaPadding()
}
#endif // swift(>=5.9)

private func scheduleDetailProgram(
    _ program: SuplaScheduleProgram,
    _ heatTemperature: Int16
) -> ScheduleDetailProgram {
    ScheduleDetailProgram(
        scheduleProgram: .init(
            program: program,
            mode: .heat,
            setpointTemperatureHeat: heatTemperature,
            setpointTemperatureCool: nil
        )
    )
}
