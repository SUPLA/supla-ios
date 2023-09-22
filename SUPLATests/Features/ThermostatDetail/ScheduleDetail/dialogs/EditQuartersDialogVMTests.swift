//
//  EditQuartersDialogVMTests.swift
//  SUPLATests
//
//  Created by Michał Polański on 21/09/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import XCTest
import RxTest
import RxSwift

@testable import SUPLA

final class EditQuartersDialogVMTests: ViewModelTest<EditQuartersDialogViewState, EditQuartersDialogViewEvent> {
    
    private let initialState = EditQuartersDialogViewState(
        key: ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 13),
        activeProgram: nil,
        availablePrograms: [
            ScheduleDetailProgram(program: .off, mode: .notSet),
            ScheduleDetailProgram(program: .program1, mode: .heat),
            ScheduleDetailProgram(program: .program2, mode: .cool)
        ],
        quarterPrograms: ScheduleDetailBoxValue(oneProgram: .program3)
    )
    
    private lazy var viewModel: EditQuartersDialogVM! = {
        EditQuartersDialogVM(initialState: initialState)
    }()
    
    private lazy var temperatureFormatter: TemperatureFormatterMock! = {
        TemperatureFormatterMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: TemperatureFormatter.self, component: temperatureFormatter!)
    }
    
    override func tearDown() {
        viewModel = nil
        temperatureFormatter = nil
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
