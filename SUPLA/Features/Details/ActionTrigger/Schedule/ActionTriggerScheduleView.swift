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

extension ActionTriggerScheduleFeature {
    protocol ViewDelegate: AtProgramSettings.ViewDelegate {
        func onProgramTap(_ program: WeeklyScheduleProgram)
        func onProgramLongPress(_ program: WeeklyScheduleProgram)
        func onBoxTap(_ key: ScheduleDetailBoxKey)
        func onBoxTapFinished()
        func onShowQuarters(_ key: ScheduleDetailBoxKey)
        func onQuartersDismiss()
        func onQuartersProgramChange(_ program: SuplaScheduleProgram)
        func onQuartersChange(_ quarter: QuarterOfHour)
        func onQuartersSave()
    }

    struct View: SwiftUI.View {
        @ObservedObject var state: ViewState; let delegate: ViewDelegate?
        var body: some SwiftUI.View {
            WeeklyScheduleEditor(
                programs: actionTriggerProgramsForView(state.programs),
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
                        AnyView(
                            QuartersSelectionDialog(
                                state: quarters,
                                onDismiss: { delegate?.onQuartersDismiss() },
                                onProgramChange: { delegate?.onQuartersProgramChange($0) },
                                onQuarterChange: { delegate?.onQuartersChange($0) },
                                onSave: { delegate?.onQuartersSave() }
                            )
                        )
                    } else if let settings = state.programSettings {
                        AnyView(AtProgramSettings.Dialog(state: settings, delegate: delegate))
                    } else {
                        AnyView(EmptyView())
                    }
                }
            )
        }
    }

}

#Preview("Action trigger schedule") {
    let state = ActionTriggerScheduleFeature.ViewState()
    state.programs = [
        .init(program: .program1, mode: .lockedTemporaryUnlockAllowed, buttonTemporaryUnlockDurationS: 65)
    ]
    return ActionTriggerScheduleFeature.View(state: state, delegate: nil)
}

#Preview("Action trigger quarters dialog") {
    let state = ActionTriggerScheduleFeature.ViewState()
    state.programs = [.init(program: .program1, mode: .locked, buttonTemporaryUnlockDurationS: 0)]
    state.quarters = QuartersSelectionData(
        key: .init(dayOfWeek: .monday, hour: 9),
        programs: actionTriggerProgramsForView(state.programs),
        activeProgram: .program1,
        hourPrograms: .init(.program1, .off, .program1, .off)
    )
    return ActionTriggerScheduleFeature.View(state: state, delegate: nil)
}
