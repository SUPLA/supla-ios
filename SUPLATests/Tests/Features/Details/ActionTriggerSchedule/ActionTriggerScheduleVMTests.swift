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

@testable import SUPLA

final class ActionTriggerScheduleVMTests: XCTestCase {
    private let remoteId: Int32 = 321
    private var subject: DelayedWeeklyScheduleConfigSubjectMock!
    private var dateProvider: DateProviderMock!
    private var viewModel: ActionTriggerScheduleFeature.ViewModel!

    override func setUp() {
        super.setUp()
        subject = DelayedWeeklyScheduleConfigSubjectMock()
        dateProvider = DateProviderMock()
        dateProvider.currentTimestampReturns = .single(100)
        DiContainer.shared.register(type: DelayedWeeklyScheduleConfigSubject.self, subject)
        DiContainer.shared.register(type: DateProvider.self, dateProvider)
        viewModel = ActionTriggerScheduleFeature.ViewModel(item: .from(remoteId: remoteId))
    }

    override func tearDown() {
        viewModel = nil
        subject = nil
        dateProvider = nil
        super.tearDown()
    }

    func test_programTapSelectsAndRetapClearsProgram() {
        let selected = WeeklyScheduleProgram(program: SuplaButtonWeeklyScheduleProgram(program: .program1, mode: .locked, buttonTemporaryUnlockDurationS: 0))
        viewModel.state.programs = [.init(program: .program1, mode: .locked, buttonTemporaryUnlockDurationS: 0)]
        viewModel.onProgramTap(selected)
        XCTAssertEqual(viewModel.state.activeProgram, .program1)
        viewModel.onProgramTap(selected)
        XCTAssertNil(viewModel.state.activeProgram)
    }

    func test_programSettingsSaveWritesModeAndDuration() {
        let model = SuplaButtonWeeklyScheduleProgram(program: .program1, mode: .locked, buttonTemporaryUnlockDurationS: 0)
        viewModel.state.programs = [model]
        viewModel.onProgramLongPress(WeeklyScheduleProgram(program: model))
        viewModel.onProgramSettingsModeChange(.lockedTemporaryUnlockAllowed)
        viewModel.onProgramSettingsDurationOptionChange(.custom)
        viewModel.onProgramSettingsDurationChange(70_000)
        viewModel.onProgramSettingsSave()

        XCTAssertEqual(viewModel.state.programs[0].mode, .lockedTemporaryUnlockAllowed)
        XCTAssertEqual(viewModel.state.programs[0].buttonTemporaryUnlockDurationS, 64_800)
        XCTAssertEqual(subject.emitParameters.last?.programs, .actionTrigger(viewModel.state.programs))
    }

    func test_programSettingsDismissLeavesProgramUntouched() {
        let model = SuplaButtonWeeklyScheduleProgram(program: .program1, mode: .locked, buttonTemporaryUnlockDurationS: 75)
        viewModel.state.programs = [model]
        viewModel.onProgramLongPress(WeeklyScheduleProgram(program: model))
        viewModel.onProgramSettingsModeChange(.lockedTemporaryUnlockAllowed)
        viewModel.onProgramSettingsDurationOptionChange(.custom)
        viewModel.onProgramSettingsDurationChange(1_200)
        viewModel.onProgramSettingsDismiss()

        XCTAssertEqual(viewModel.state.programs, [model])
        XCTAssertTrue(subject.emitParameters.isEmpty)
    }

    func test_defaultDurationOptionDisplaysChannelDefaultAndSavesZero() {
        var settings = AtProgramSettings.State(
            program: .program1,
            mode: .lockedTemporaryUnlockAllowed,
            duration: 0,
            defaultDuration: 600
        )

        XCTAssertEqual(settings.durationOption, .default)
        XCTAssertEqual(settings.duration, 600)
        XCTAssertFalse(settings.timePickerEnabled)
        XCTAssertTrue(settings.saveEnabled)
        XCTAssertEqual(settings.selectedDuration, 0)

        settings.selectDurationOption(.custom)
        XCTAssertEqual(settings.duration, 0)
        XCTAssertTrue(settings.timePickerEnabled)
        XCTAssertFalse(settings.saveEnabled)
    }

    func test_customDurationIsRestoredWhenSwitchingBackFromDefault() {
        var settings = AtProgramSettings.State(
            program: .program1,
            mode: .lockedTemporaryUnlockAllowed,
            duration: 1_200,
            defaultDuration: 600
        )

        settings.selectDurationOption(.default)
        XCTAssertEqual(settings.duration, 600)
        settings.selectDurationOption(.custom)

        XCTAssertEqual(settings.duration, 1_200)
        XCTAssertEqual(settings.selectedDuration, 1_200)
    }

    func test_programSettingsDefaultDurationSavesZero() {
        viewModel.state.programs = [
            .init(program: .program1, mode: .lockedTemporaryUnlockAllowed, buttonTemporaryUnlockDurationS: 0)
        ]
        viewModel.state.programSettings = AtProgramSettings.State(
            program: .program1,
            mode: .lockedTemporaryUnlockAllowed,
            duration: 0,
            defaultDuration: 900
        )

        viewModel.onProgramSettingsSave()

        XCTAssertEqual(viewModel.state.programs[0].buttonTemporaryUnlockDurationS, 0)
        XCTAssertEqual(subject.emitParameters.last?.programs, .actionTrigger(viewModel.state.programs))
    }

    func test_offProgramCanPaintScheduleAndIsOmittedFromConfigurationPrograms() {
        viewModel.onProgramTap(WeeklyScheduleProgram(program: .off, label: Strings.Schedule.programDefault))
        let key = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 10)
        viewModel.onBoxTap(key)

        XCTAssertEqual(viewModel.state.schedule[key]?.hasSingleProgram, true)
        XCTAssertEqual(viewModel.state.schedule[key]?.firstQuarterProgram, .off)
        XCTAssertEqual(subject.emitParameters.last?.programs, .actionTrigger([]))
        XCTAssertEqual(subject.emitParameters.last?.schedule.count, 4)
    }

    func test_quarterEditorAppliesFourQuarterValuesOnSave() {
        let key = ScheduleDetailBoxKey(dayOfWeek: .monday, hour: 10)
        viewModel.state.programs = [.init(program: .program1, mode: .locked, buttonTemporaryUnlockDurationS: 0)]
        viewModel.state.schedule[key] = WeeklyScheduleBoxValue(.off, .program1, .off, .program1)
        viewModel.onProgramTap(WeeklyScheduleProgram(program: viewModel.state.programs[0]))
        viewModel.onShowQuarters(key)
        viewModel.onQuartersChange(.first)
        viewModel.onQuartersSave()

        XCTAssertNil(viewModel.state.quarters)
        XCTAssertEqual(viewModel.state.schedule[key], WeeklyScheduleBoxValue(.program1, .program1, .off, .program1))
        XCTAssertEqual(subject.emitParameters.last?.schedule.count, 4)
    }
}
