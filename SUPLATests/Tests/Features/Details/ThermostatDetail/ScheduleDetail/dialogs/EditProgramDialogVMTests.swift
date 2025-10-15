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

import RxSwift
import RxTest
import XCTest

@testable import SUPLA

@available(iOS 17.0, *)
final class EditProgramDialogVMTests: ViewModelTest<EditProgramDialogViewState, EditProgramDialogViewEvent> {
    private let initialState = EditProgramDialogViewState(
        program: .off,
        mode: .heat,
        showHeatEdit: false,
        showCoolEdit: false,
        configMin: 0,
        configMax: 0
    )
    
    private lazy var groupSharedSettings: GroupShared.SettingsMock! = GroupShared.SettingsMock()
    
    private lazy var viewModel: EditProgramDialogVM! = EditProgramDialogVM(initialState: initialState)
    
    override func setUp() {
        DiContainer.shared.register(type: ValuesFormatter.self, ValuesFormatterMock())
        DiContainer.shared.register(type: GroupShared.Settings.self, self.groupSharedSettings!)
        
        groupSharedSettings.temperatureUnitMock.returns = .single(.celsius)
        groupSharedSettings.temperaturePrecisionMock.returns = .single(1)
    }
    
    override func tearDown() {
        viewModel = nil
        groupSharedSettings = nil
        super.tearDown()
    }
    
    func test_shouldSaveChanges() {
        // when
        observe(viewModel)
        viewModel.save()
        
        // then
        assertObserverItems(statesCount: 1, eventsCount: 1)
        assertStates(expected: [initialState])
        assertEvents(expected: [.dismiss(program: initialState.weeklyScheduleProgram)])
    }
    
    // MARK: - Heat temperature by step -
    
    func test_shouldIncreaseHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureHeat, to: 21)
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
                .changing(path: \.setpointTemperatureHeat, to: 21.1)
                .changing(path: \.heatTemperatureText, to: "21.1")
        ])
    }
    
    func test_shouldDecreaseHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureHeat, to: 21)
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
                .changing(path: \.setpointTemperatureHeat, to: 20.9)
                .changing(path: \.heatTemperatureText, to: "20.9")
        ])
    }
    
    func test_shouldLockPlusButtonWhenReachingMaxHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureHeat, to: 39.9)
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
                .changing(path: \.setpointTemperatureHeat, to: 40)
                .changing(path: \.heatTemperatureText, to: "40.0")
                .changing(path: \.heatPlusActive, to: false)
        ])
    }
    
    func test_shouldLockMinusButtonWhenReachingMinHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureHeat, to: 10.1)
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
                .changing(path: \.setpointTemperatureHeat, to: 10)
                .changing(path: \.heatTemperatureText, to: "10.0")
                .changing(path: \.heatMinusActive, to: false)
        ])
    }
    
    func test_shouldMarkInputRedWhenHeatTemperatureOutOfRange() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureHeat, to: 41)
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
                .changing(path: \.setpointTemperatureHeat, to: 40.9)
                .changing(path: \.heatTemperatureText, to: "40.9")
                .changing(path: \.heatPlusActive, to: false)
                .changing(path: \.heatCorrect, to: false)
        ])
    }
    
    // MARK: - Heat temperature by value -
    
    func test_shouldChangeHeatTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureHeat, to: 21)
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
                .changing(path: \.setpointTemperatureHeat, to: 25.5)
                .changing(path: \.heatTemperatureText, to: "25.5")
        ])
    }
    
    func test_shouldChangeHeatTemperatureWithComa() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureHeat, to: 21)
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
                .changing(path: \.setpointTemperatureHeat, to: 25.5)
                .changing(path: \.heatTemperatureText, to: "25,5")
        ])
    }
    
    func test_shouldCleanHeatTemperatureWhenValueIsEmpty() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureHeat, to: 21)
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
            .changing(path: \.showHeatEdit, to: true)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.heatTemperatureChange("")
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.setpointTemperatureHeat, to: 0)
                .changing(path: \.heatTemperatureText, to: "")
                .changing(path: \.heatMinusActive, to: false)
                .changing(path: \.heatCorrect, to: false)
        ])
        assertState(1) {
            XCTAssertEqual($0.saveAllowed, false)
        }
    }
    
    // MARK: - Cool temperature by step -
    
    func test_shouldIncreaseCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 21)
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
                .changing(path: \.setpointTemperatureCool, to: 21.1)
                .changing(path: \.coolTemperatureText, to: "21.1")
        ])
    }
    
    func test_shouldDecreaseCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 21)
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
                .changing(path: \.setpointTemperatureCool, to: 20.9)
                .changing(path: \.coolTemperatureText, to: "20.9")
        ])
    }
    
    func test_shouldLockPlusButtonWhenReachingMaxCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 39.9)
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
                .changing(path: \.setpointTemperatureCool, to: 40)
                .changing(path: \.coolTemperatureText, to: "40.0")
                .changing(path: \.coolPlusActive, to: false)
        ])
    }
    
    func test_shouldLockMinusButtonWhenReachingMinCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 10.1)
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
                .changing(path: \.setpointTemperatureCool, to: 10)
                .changing(path: \.coolTemperatureText, to: "10.0")
                .changing(path: \.coolMinusActive, to: false)
        ])
    }
    
    func test_shouldMarkInputRedWhenCoolTemperatureOutOfRange() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 41.0)
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
                .changing(path: \.setpointTemperatureCool, to: 40.9)
                .changing(path: \.coolTemperatureText, to: "40.9")
                .changing(path: \.coolPlusActive, to: false)
                .changing(path: \.coolCorrect, to: false)
        ])
    }
    
    // MARK: - Cool temperature by value -
    
    func test_shouldChangeCoolTemperature() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 21.0)
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
                .changing(path: \.setpointTemperatureCool, to: 25.5)
                .changing(path: \.coolTemperatureText, to: "25.5")
        ])
    }
    
    func test_shouldChangeCoolTemperatureWithComa() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 21.0)
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
                .changing(path: \.setpointTemperatureCool, to: 25.5)
                .changing(path: \.coolTemperatureText, to: "25,5")
        ])
    }
    
    func test_shouldCleanCoolTemperatureWhenValueIsEmpty() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 21.0)
            .changing(path: \.configMin, to: 10)
            .changing(path: \.configMax, to: 40)
            .changing(path: \.showCoolEdit, to: true)
        viewModel.updateView { _ in state }
        
        // when
        observe(viewModel)
        viewModel.coolTemperatureChange("")
        
        // then
        assertObserverItems(statesCount: 2, eventsCount: 0)
        assertStates(expected: [
            state,
            state
                .changing(path: \.setpointTemperatureCool, to: 0)
                .changing(path: \.coolTemperatureText, to: "")
                .changing(path: \.coolMinusActive, to: false)
                .changing(path: \.coolCorrect, to: false)
        ])
        assertState(1) {
            XCTAssertEqual($0.saveAllowed, false)
        }
    }
    
    // MARK: - Rest -
    
    func test_shouldNotChangeTemperatureWhenGivenValueIsNotValid() {
        // given
        let state = initialState
            .changing(path: \.setpointTemperatureCool, to: 21.0)
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
