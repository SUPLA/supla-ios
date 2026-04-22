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

        @ObservedObject private var orientationObserver = OrientationObserver()

        var body: some SwiftUI.View {
            BackgroundStack(alignment: .top) {
                if (orientationObserver.orientation.isLandscape) {
                    HStack(spacing: Distance.tiny) {
                        ProgramButtonsLandscape()
                        ScheduleTableView()
                            .padding(.vertical, Distance.small)
                    }
                } else {
                    VStack(spacing: Distance.tiny) {
                        ProgramButtonsPortrait()
                        ScheduleTableView()
                            .padding(.horizontal, Distance.default)
                    }
                    .padding(.vertical, Distance.small)
                }
                
                if let state = state.editProgramState {
                    ThermostatScheduleDetailFeature.EditProgramDialog(
                        state: state,
                        onDismiss: { delegate?.onProgramDialogDismiss() },
                        onChange: { delegate?.onProgramDialogChange($0, $1) },
                        onPlus: { delegate?.onProgramDialogPlus($0, $1) },
                        onMinus: { delegate?.onProgramDialogMinus($0, $1) },
                        onSave: { delegate?.onProgramDialogSave($0, $1) }
                    )
                }
                
                if let state = state.editQuartersState {
                    ThermostatScheduleDetailFeature.EditQuartersDialog(
                        state: state,
                        onDismiss: { delegate?.onQuartersDialogDismiss() },
                        onProgramChange: { delegate?.onQuartersDialogProgramChange($0) },
                        onQuarterChange: { delegate?.onQuartersDialogQuarterChange($0) },
                        onSave: { delegate?.onQuartersDialogSave() }
                    )
                }
            }
        }

        private func ProgramButtonsPortrait() -> some SwiftUI.View {
            ScrollView(.horizontal) {
                HStack(spacing: Distance.tiny) {
                    ForEach(state.programs.indices, id: \.self) { index in
                        ProgramButton(index)
                    }
                }
                .padding(.horizontal, Distance.default)
            }
            .hideScrollIndicators()
        }

        private func ProgramButtonsLandscape() -> some SwiftUI.View {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: Distance.tiny) {
                    ForEach(state.programs.indices, id: \.self) { index in
                        ProgramButton(index)
                    }
                }
                .padding(.vertical, Distance.small)
            }
            .hideScrollIndicators()
        }

        @ViewBuilder
        private func ScheduleTableView() -> some SwiftUI.View {
            ScheduleTable(
                schedule: state.schedule,
                currentDay: state.currentDay,
                currentHour: state.currentHour,
                onFingerMoved: { delegate?.onBoxTap($0) },
                onFingerMoveFinished: { delegate?.onBoxTapFinished() },
                onFingerLongPressed: { delegate?.onShowQuartersDialog($0) }
            )
        }
        
        @ViewBuilder
        private func ProgramButton(_ index: Int) -> some SwiftUI.View {
            let program = state.programs[index]
            ScheduleProgramButton(
                state: program.buttonState(state.activeProgram),
                action: { delegate?.onProgramTap(program) },
                onLongPress: { delegate?.onShowProgramDialog(program) }
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
