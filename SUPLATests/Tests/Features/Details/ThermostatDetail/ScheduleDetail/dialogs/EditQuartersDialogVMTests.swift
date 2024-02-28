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

import XCTest
import RxTest
import RxSwift

@testable import SUPLA

final class EditQuartersDialogVMTests: ViewModelTest<EditQuartersDialogViewState, EditQuartersDialogViewEvent> {
    
    private let initialState = EditQuartersDialogViewState(
        key: ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 13),
        activeProgram: nil,
        availablePrograms: [
            ScheduleDetailProgram(scheduleProgram: .OFF),
            ScheduleDetailProgram(scheduleProgram: SuplaWeeklyScheduleProgram(program: .program1, mode: .heat, setpointTemperatureHeat: nil, setpointTemperatureCool: nil)),
            ScheduleDetailProgram(scheduleProgram: SuplaWeeklyScheduleProgram(program: .program1, mode: .cool, setpointTemperatureHeat: nil, setpointTemperatureCool: nil))
        ],
        quarterPrograms: ScheduleDetailBoxValue(oneProgram: .program3)
    )
    
    private lazy var viewModel: EditQuartersDialogVM! = {
        EditQuartersDialogVM(initialState: initialState)
    }()
    
    private lazy var valuesFormatter: ValuesFormatterMock! = {
        ValuesFormatterMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: ValuesFormatter.self, valuesFormatter!)
    }
    
    override func tearDown() {
        viewModel = nil
        valuesFormatter = nil
        super.tearDown()
    }
    
    func test_shouldSaveChanges() {
        // given
        let state = initialState.changing(path: \.activeProgram, to: .program2)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.save()
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 1)
        assertStates(expected: [state])
        assertEvents(expected: [.dismiss(programs: initialState.quarterPrograms, activeProgram: .program2)])
    }
    
    func test_shouldChangeActiveProgram() {
        // when
        observe(viewModel)
        viewModel.onProgramTap(.program1)
        viewModel.onProgramTap(.program1)
        
        // then
        assertObserverItems(statesCount: 3, eventsCount: 0)
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.activeProgram, to: .program1),
            initialState
        ])
    }
    
    func test_shouldChangeQuarter() {
        // given
        let state = initialState.changing(path: \.activeProgram, to: .program1)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.onBoxTap(.second)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state.changing(path: \.quarterPrograms, to: ScheduleDetailBoxValue(.program3, .program1, .program3, .program3))
        ])
    }
}
