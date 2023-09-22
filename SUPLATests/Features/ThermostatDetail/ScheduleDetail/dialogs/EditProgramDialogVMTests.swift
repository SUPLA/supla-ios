//
//  EditProgramDialogVMTests.swift
//  SUPLATests
//
//  Created by Michał Polański on 21/09/2023.
//  Copyright © 2023 AC SOFTWARE SP. Z O.O. All rights reserved.
//

import XCTest
import RxTest
import RxSwift

@testable import SUPLA

final class EditProgramDialogVMTests: ViewModelTest<EditProgramDialogViewState, EditProgramDialogViewEvent> {
    
    private let initialState = EditProgramDialogViewState(
        program: ScheduleDetailProgram(program: .off, mode: .notSet),
        showHeatEdit: false,
        showCoolEdit: false,
        configMin: 0,
        configMax: 0
    )
    
    private lazy var viewModel: EditProgramDialogVM! = {
        EditProgramDialogVM(initialState: initialState)
    }()
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func test_shouldSaveChanges() {
        // when
        observe(viewModel)
        viewModel.save()
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 1)
        assertStates(expected: [initialState])
        assertEvents(expected: [.dismiss(program: initialState.program)])
    }
    
    // MARK: - Heat temperature by step -
    
    func test_shouldIncreaseHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.heatTemperature, to: 21))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.heatTemperatureChange(.smallUp)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.heatTemperature, to: 21.1))
                .changing(path: \.heatTemperatureText, to: "21.1")
        ])
    }
    
    func test_shouldDecreaseHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.heatTemperature, to: 21))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.heatTemperatureChange(.smallDown)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.heatTemperature, to: 20.9))
                .changing(path: \.heatTemperatureText, to: "20.9")
        ])
    }
    
    func test_shouldLockPlusButtonWhenReachingMaxHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.heatTemperature, to: 39.9))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.heatTemperatureChange(.smallUp)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.heatTemperature, to: 40))
                .changing(path: \.heatTemperatureText, to: "40.0")
                .changing(path: \.heatPlusActive, to: false)
        ])
    }
    
    func test_shouldLockMinusButtonWhenReachingMinHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.heatTemperature, to: 10.1))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.heatTemperatureChange(.smallDown)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.heatTemperature, to: 10))
                .changing(path: \.heatTemperatureText, to: "10.0")
                .changing(path: \.heatMinusActive, to: false)
        ])
    }
    
    func test_shouldMarkInputRedWhenHeatTemperatureOutOfRange() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.heatTemperature, to: 41))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.heatTemperatureChange(.smallDown)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.heatTemperature, to: 40.9))
                .changing(path: \.heatTemperatureText, to: "40.9")
                .changing(path: \.heatPlusActive, to: false)
                .changing(path: \.heatCorrect, to: false)
        ])
    }
    
    // MARK: - Heat temperature by value -
    
    func test_shouldChangeHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.heatTemperature, to: 21))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.heatTemperatureChange("25.5")
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.heatTemperature, to: 25.5))
                .changing(path: \.heatTemperatureText, to: "25.5")
        ])
    }
    
    func test_shouldChangeHeatTemperatureWithComa() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.heatTemperature, to: 21))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.heatTemperatureChange("25,5")
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.heatTemperature, to: 25.5))
                .changing(path: \.heatTemperatureText, to: "25.5")
        ])
    }
    
    // MARK: - Cool temperature by step -
    
    func test_shouldIncreaseCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.coolTemperature, to: 21))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange(.smallUp)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.coolTemperature, to: 21.1))
                .changing(path: \.coolTemperatureText, to: "21.1")
        ])
    }
    
    func test_shouldDecreaseCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.coolTemperature, to: 21))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange(.smallDown)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.coolTemperature, to: 20.9))
                .changing(path: \.coolTemperatureText, to: "20.9")
        ])
    }
    
    func test_shouldLockPlusButtonWhenReachingMaxCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.coolTemperature, to: 39.9))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange(.smallUp)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.coolTemperature, to: 40))
                .changing(path: \.coolTemperatureText, to: "40.0")
                .changing(path: \.coolPlusActive, to: false)
        ])
    }
    
    func test_shouldLockMinusButtonWhenReachingMinCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.coolTemperature, to: 10.1))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange(.smallDown)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.coolTemperature, to: 10))
                .changing(path: \.coolTemperatureText, to: "10.0")
                .changing(path: \.coolMinusActive, to: false)
        ])
    }
    
    func test_shouldMarkInputRedWhenCoolTemperatureOutOfRange() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.coolTemperature, to: 41))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange(.smallDown)
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.coolTemperature, to: 40.9))
                .changing(path: \.coolTemperatureText, to: "40.9")
                .changing(path: \.coolPlusActive, to: false)
                .changing(path: \.coolCorrect, to: false)
        ])
    }
    
    // MARK: - Cool temperature by value -
    
    func test_shouldChangeCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.coolTemperature, to: 21))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange("25.5")
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.coolTemperature, to: 25.5))
                .changing(path: \.coolTemperatureText, to: "25.5")
        ])
    }
    
    func test_shouldChangeCoolTemperatureWithComa() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.coolTemperature, to: 21))
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange("25,5")
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.program, to: state.program.changing(path: \.coolTemperature, to: 25.5))
                .changing(path: \.coolTemperatureText, to: "25.5")
        ])
    }
    
    // MARK: - Rest -
    
    func test_shouldNotChangeTemperatureWhenGivenValueIsNotValid() {
        // given
        let state = initialState
            .changing(path: \.program, to: initialState.program.changing(path: \.coolTemperature, to: 21))
            .changing(path: \.coolTemperatureText, to: "21.0")
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange("abcd")
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
        ])
    }
}
