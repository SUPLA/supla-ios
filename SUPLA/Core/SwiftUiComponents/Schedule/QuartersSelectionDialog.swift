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

final class QuartersSelectionData: ObservableObject, Equatable {
    let key: ScheduleDetailBoxKey
    let programs: [WeeklyScheduleProgram]
    @Published var activeProgram: SuplaScheduleProgram?
    @Published var hourPrograms: WeeklyScheduleBoxValue

    init(
        key: ScheduleDetailBoxKey,
        programs: [WeeklyScheduleProgram],
        activeProgram: SuplaScheduleProgram?,
        hourPrograms: WeeklyScheduleBoxValue
    ) {
        self.key = key
        self.programs = programs
        self.activeProgram = activeProgram
        self.hourPrograms = hourPrograms
    }

    static func == (lhs: QuartersSelectionData, rhs: QuartersSelectionData) -> Bool {
        lhs.key == rhs.key
            && lhs.programs == rhs.programs
            && lhs.activeProgram == rhs.activeProgram
            && lhs.hourPrograms == rhs.hourPrograms
    }
}

struct QuartersSelectionDialog: SwiftUI.View {
    @ObservedObject var state: QuartersSelectionData

    let onDismiss: () -> Void
    let onProgramChange: (SuplaScheduleProgram) -> Void
    let onQuarterChange: (QuarterOfHour) -> Void
    let onSave: () -> Void

    @ObservedObject private var orientationObserver = OrientationObserver()

    var body: some SwiftUI.View {
        let isLandscape = orientationObserver.orientation.isLandscape
        let width: CGFloat = isLandscape ? 500 : 300

        SuplaCore.Dialog.Base(onDismiss: onDismiss, width: width) {
            SuplaCore.Dialog.Header(title: Strings.ThermostatDetail.editQuartersDialogHeader.arguments(state.key.hour))

            Programs()

            Text(state.key.dayOfWeek.fullText().uppercased())
                .fontBodyMedium()
                .padding(.horizontal, Distance.default)
                .padding(.vertical, Distance.small)

            Quarters(isLandscape: isLandscape)
            Buttons(isLandscape: isLandscape)
        }
    }

    private func Programs() -> some SwiftUI.View {
        FlowHStack(data: state.programs) { _, program in
            ScheduleProgramButton(
                state: program.buttonState(state.activeProgram),
                action: { onProgramChange(program.program) }
            )
        }
        .padding(.vertical, Distance.tiny)
        .padding(.horizontal, Distance.default)
        .background(Color.Supla.background)
    }

    @ViewBuilder
    private func Quarters(isLandscape: Bool) -> some SwiftUI.View {
        if isLandscape {
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
    private func Buttons(isLandscape: Bool) -> some SwiftUI.View {
        SuplaCore.Dialog.Buttons(
            onSecondaryClick: onDismiss,
            onPrimaryClick: onSave
        )
    }
}

private let quartersSelectionPreviewData = QuartersSelectionData(
    key: .init(dayOfWeek: .monday, hour: 6),
    programs: [
        WeeklyScheduleProgram(program: .program1, label: "Program 1"),
        WeeklyScheduleProgram(program: .program2, label: "Program 2"),
        WeeklyScheduleProgram(program: .program3, label: "Program 3"),
        WeeklyScheduleProgram(program: .program4, label: "Program 4"),
        WeeklyScheduleProgram(program: .off, label: Strings.Schedule.programDefault)
    ],
    activeProgram: .program1,
    hourPrograms: WeeklyScheduleBoxValue(.program1, .program2, .program3, .off)
)

#Preview {
    BackgroundStack {
        QuartersSelectionDialog(
            state: quartersSelectionPreviewData,
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
        QuartersSelectionDialog(
            state: quartersSelectionPreviewData,
            onDismiss: {},
            onProgramChange: { _ in },
            onQuarterChange: { _ in },
            onSave: {}
        )
    }
}
#endif
