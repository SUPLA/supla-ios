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

struct WeeklyScheduleEditor: View {
    let programs: [WeeklyScheduleProgram]
    let activeProgram: SuplaScheduleProgram?
    let schedule: [ScheduleDetailBoxKey: WeeklyScheduleBoxValue]
    let currentDay: DayOfWeek?
    let currentHour: Int?
    let onProgramTap: (WeeklyScheduleProgram) -> Void
    let onProgramLongPress: (WeeklyScheduleProgram) -> Void
    let onBoxTap: (ScheduleDetailBoxKey) -> Void
    let onBoxTapFinished: () -> Void
    let onBoxLongPress: (ScheduleDetailBoxKey) -> Void
    let dialogs: () -> AnyView

    @ObservedObject private var orientationObserver = OrientationObserver()

    init(
        programs: [WeeklyScheduleProgram],
        activeProgram: SuplaScheduleProgram?,
        schedule: [ScheduleDetailBoxKey: WeeklyScheduleBoxValue],
        currentDay: DayOfWeek?,
        currentHour: Int?,
        onProgramTap: @escaping (WeeklyScheduleProgram) -> Void,
        onProgramLongPress: @escaping (WeeklyScheduleProgram) -> Void,
        onBoxTap: @escaping (ScheduleDetailBoxKey) -> Void,
        onBoxTapFinished: @escaping () -> Void,
        onBoxLongPress: @escaping (ScheduleDetailBoxKey) -> Void,
        @ViewBuilder dialogs: @escaping () -> some View = { EmptyView() }
    ) {
        self.programs = programs
        self.activeProgram = activeProgram
        self.schedule = schedule
        self.currentDay = currentDay
        self.currentHour = currentHour
        self.onProgramTap = onProgramTap
        self.onProgramLongPress = onProgramLongPress
        self.onBoxTap = onBoxTap
        self.onBoxTapFinished = onBoxTapFinished
        self.onBoxLongPress = onBoxLongPress
        self.dialogs = { AnyView(dialogs()) }
    }

    var body: some View {
        BackgroundStack(alignment: .top) {
            if orientationObserver.orientation.isLandscape {
                HStack(spacing: Distance.tiny) {
                    ProgramButtonsLandscape()
                    Table().padding(.vertical, Distance.small)
                }
            } else {
                VStack(spacing: Distance.tiny) {
                    ProgramButtonsPortrait()
                    Table().padding(.horizontal, Distance.default)
                }
                .padding(.vertical, Distance.small)
            }
            dialogs()
        }
    }

    private func Table() -> some View {
        ScheduleTable(
            schedule: schedule,
            currentDay: currentDay,
            currentHour: currentHour,
            onFingerMoved: onBoxTap,
            onFingerMoveFinished: onBoxTapFinished,
            onFingerLongPressed: onBoxLongPress
        )
    }

    private func ProgramButtonsPortrait() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: Distance.tiny) {
                ForEach(programs) { program in Button(program) }
            }
            .padding(.horizontal, Distance.default)
        }
        .hideScrollIndicators()
    }

    private func ProgramButtonsLandscape() -> some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: Distance.tiny) {
                ForEach(programs) { program in Button(program) }
            }
            .padding(.vertical, Distance.small)
        }
        .hideScrollIndicators()
    }

    private func Button(_ program: WeeklyScheduleProgram) -> some View {
        ScheduleProgramButton(
            state: program.buttonState(activeProgram),
            action: { onProgramTap(program) },
            onLongPress: { onProgramLongPress(program) }
        )
    }
}
