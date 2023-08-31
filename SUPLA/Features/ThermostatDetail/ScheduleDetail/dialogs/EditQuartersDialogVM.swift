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

final class EditQuartersDialogVM: BaseViewModel<EditQuartersDialogViewState, EditQuartersDialogViewEvent> {
    
    private let initialState: EditQuartersDialogViewState
    
    override func defaultViewState() -> EditQuartersDialogViewState { initialState }
    
    init(initialState: EditQuartersDialogViewState) {
        self.initialState = initialState
    }
    
    func save() {
        if let state = currentState() {
            send(event: .dismiss(programs: state.quarterPrograms, activeProgram: state.activeProgram))
        }
    }
    
    func onProgramTap(_ program: SuplaScheduleProgram) {
        updateView {
            $0.changing(path: \.activeProgram, to: $0.activeProgram == program ? nil : program)
        }
    }
    
    func onBoxTap(_ quarter: QuarterOfHour) {
        if let activeProgram = currentState()?.activeProgram {
            updateView { state in
                var programs = state.quarterPrograms
                switch (quarter) {
                case .first: programs.firstQuarterProgram = activeProgram
                case .second: programs.secondQuarterProgram = activeProgram
                case .third: programs.thirdQuarterProgram = activeProgram
                case .fourth: programs.fourthQuarterProgram = activeProgram
                }
                return state.changing(path: \.quarterPrograms, to: programs)
            }
        }
    }
}

struct EditQuartersDialogViewState: ViewState {
    let key: ScheduleDetailBoxKey
    var activeProgram: SuplaScheduleProgram?
    var availablePrograms: [ScheduleDetailProgram]
    var quarterPrograms: ScheduleDetailBoxValue
}

enum EditQuartersDialogViewEvent: ViewEvent {
    case dismiss(programs: ScheduleDetailBoxValue, activeProgram: SuplaScheduleProgram?)
}
