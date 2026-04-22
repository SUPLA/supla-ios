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
    struct EditQuartersState: Equatable {
        let key: ScheduleDetailBoxKey
        let programs: [ScheduleDetailProgram]
        let activeProgram: SuplaScheduleProgram?
        let hourPrograms: ThermostatScheduleDetailBoxValue

        init(
            key: ScheduleDetailBoxKey,
            programs: [ScheduleDetailProgram],
            activeProgram: SuplaScheduleProgram?,
            hourPrograms: ThermostatScheduleDetailBoxValue
        ) {
            self.key = key
            self.programs = programs
            self.activeProgram = activeProgram
            self.hourPrograms = hourPrograms
        }

        func withActiveProgram(_ program: SuplaScheduleProgram) -> Self {
            EditQuartersState(
                key: key,
                programs: programs,
                activeProgram: program,
                hourPrograms: hourPrograms
            )
        }

        func withHourPrograms(_ hourPrograms: ThermostatScheduleDetailBoxValue) -> Self {
            EditQuartersState(
                key: key,
                programs: programs,
                activeProgram: activeProgram,
                hourPrograms: hourPrograms
            )
        }
    }

    struct EditQuartersDialog: SwiftUI.View {
        let state: EditQuartersState

        let onDismiss: () -> Void
        let onProgramChange: (SuplaScheduleProgram) -> Void
        let onQuarterChange: (QuarterOfHour) -> Void
        let onSave: () -> Void

        @ObservedObject private var orientationObserver = OrientationObserver()

        var body: some SwiftUI.View {
            let width: CGFloat = orientationObserver.orientation.isLandscape ? 500 : 300

            SuplaCore.Dialog.Base(onDismiss: onDismiss, width: width) {
                SuplaCore.Dialog.Header(title: Strings.ThermostatDetail.editQuartersDialogHeader.arguments(state.key.hour))

                FlowHStack(data: state.programs) { _, program in
                    ProgramButton(program)
                }
                .padding(.vertical, Distance.tiny)
                .padding(.horizontal, Distance.default)
                .background(Color.Supla.background)

                Text(state.key.dayOfWeek.fullText().uppercased())
                    .fontBodyMedium()
                    .padding(.horizontal, Distance.default)
                    .padding(.vertical, Distance.small)

                Quarters()

                Buttons()
            }
        }
        
        @ViewBuilder
        private func Quarters() -> some SwiftUI.View {
            if (orientationObserver.orientation.isLandscape) {
                HStack(spacing: Distance.small) {
                    ForEach(QuarterOfHour.allCases.indices, id: \.self) { index in
                        QuarterRow(QuarterOfHour.allCases[index], spacing: Distance.tiny)
                    }
                }
                .padding(.horizontal, Distance.default)
            } else {
                ForEach(QuarterOfHour.allCases.indices, id: \.self) { index in
                    QuarterRow(QuarterOfHour.allCases[index])
                        .padding(.horizontal, Distance.default)
                }
            }
        }

        @ViewBuilder
        private func ProgramButton(_ program: ScheduleDetailProgram) -> some SwiftUI.View {
            ScheduleProgramButton(
                state: program.buttonState(state.activeProgram),
                action: { onProgramChange(program.scheduleProgram.program) }
            )
        }

        @ViewBuilder
        private func QuarterRow(
            _ quarter: QuarterOfHour,
            spacing: CGFloat = Distance.default
        ) -> some SwiftUI.View {
            HStack(spacing: spacing) {
                Text(state.key.hour.toHour(withMinutes: quarter.minutes()))
                    .fontBodyMedium()
                state.hourPrograms.programForQuarter(quarter).color
                    .frame(maxWidth: .infinity, maxHeight: 36)
                    .clipShape(RoundedRectangle(cornerRadius: Dimens.radiusSmall))
                    .onTapGesture { onQuarterChange(quarter) }
            }
            .padding(.bottom, Distance.tiny)
        }
        
        @ViewBuilder
        private func Buttons() -> some SwiftUI.View {
            if (orientationObserver.orientation.isLandscape) {
                HStack(spacing: Distance.tiny) {
                    TitleButton(
                        title: Strings.General.cancel,
                        action: onDismiss
                    )
                    .textButtonStyle()
                    .frame(maxWidth: .infinity)
                    TitleButton(
                        title: Strings.General.save,
                        action: onSave
                    )
                    .filledButtonStyle()
                }
                .padding(.horizontal, Distance.default)
                .padding(.vertical, Distance.small)
            } else {
                SuplaCore.Dialog.DoubleButtons(
                    onSecondaryClick: onDismiss,
                    onPrimaryClick: onSave
                )
            }
        }
    }
}

#Preview {
    BackgroundStack {
        ThermostatScheduleDetailFeature.EditQuartersDialog(
            state: ThermostatScheduleDetailFeature.EditQuartersState(
                key: .init(dayOfWeek: .monday, hour: 6),
                programs: [
                    scheduleDetailProgram(.program1, 2200),
                    scheduleDetailProgram(.program2, 2100),
                    scheduleDetailProgram(.program3, 2300),
                    scheduleDetailProgram(.program4, 1800),
                    ScheduleDetailProgram(scheduleProgram: .OFF)
                ],
                activeProgram: .program1,
                hourPrograms: .init(oneProgram: .off)
            ),
            onDismiss: {},
            onProgramChange: { _ in },
            onQuarterChange: { _ in },
            onSave: {}
        )
    }
}

#if swift(>=5.9)
@available(iOS 17.0, *)
#Preview("Landscape", traits: .landscapeRight) {
    BackgroundStack {
        ThermostatScheduleDetailFeature.EditQuartersDialog(
            state: ThermostatScheduleDetailFeature.EditQuartersState(
                key: .init(dayOfWeek: .monday, hour: 6),
                programs: [
                    scheduleDetailProgram(.program1, 2200),
                    scheduleDetailProgram(.program2, 2100),
                    scheduleDetailProgram(.program3, 2300),
                    scheduleDetailProgram(.program4, 1800),
                    ScheduleDetailProgram(scheduleProgram: .OFF)
                ],
                activeProgram: .program1,
                hourPrograms: .init(oneProgram: .off)
            ),
            onDismiss: {},
            onProgramChange: { _ in },
            onQuarterChange: { _ in },
            onSave: {}
        )
    }
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
