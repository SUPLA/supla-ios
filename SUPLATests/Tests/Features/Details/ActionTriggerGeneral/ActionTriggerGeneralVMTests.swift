import Foundation
import RxSwift
import XCTest

@testable import SUPLA
import SharedCore

final class ActionTriggerGeneralVMTests: XCTestCase {
    private let remoteId: Int32 = 123
    private lazy var viewModel = ActionTriggerGeneralFeature.ViewModel(itemBundle: .from(remoteId: remoteId))
    private lazy var observeChannelUseCase = ObserveChannelWithChildren.Mock()
    private lazy var channelConfigEventsManager = ChannelConfigEventsManagerMock()
    private lazy var deviceConfigEventsManager = DeviceConfigEventsManagerMock()
    private lazy var getChannelConfigUseCase = GetChannelConfigUseCaseMock()
    private lazy var getDeviceConfigUseCase = ActionTriggerGetDeviceConfigUseCaseMock()
    private lazy var executeSimpleActionUseCase = ExecuteSimpleAction.Mock()
    private lazy var executeActionTriggerActionUseCase = ExecuteActionTriggerActionUseCaseMock()
    private lazy var dateProvider = DateProviderMock()
    private lazy var schedulers = ActionTriggerImmediateSchedulers()

    override func setUp() {
        super.setUp()
        DiContainer.shared.register(type: ObserveChannelWithChildren.UseCase.self, observeChannelUseCase)
        DiContainer.shared.register(type: ChannelConfigEventsManager.self, channelConfigEventsManager)
        DiContainer.shared.register(type: DeviceConfigEventsManager.self, deviceConfigEventsManager)
        DiContainer.shared.register(type: GetChannelConfigUseCase.self, getChannelConfigUseCase)
        DiContainer.shared.register(type: GetDeviceConfigUseCase.self, getDeviceConfigUseCase)
        DiContainer.shared.register(type: ExecuteSimpleAction.UseCase.self, executeSimpleActionUseCase)
        DiContainer.shared.register(type: ExecuteActionTriggerActionUseCase.UseCase.self, executeActionTriggerActionUseCase)
        DiContainer.shared.register(type: DateProvider.self, dateProvider)
        DiContainer.shared.register(type: ValuesFormatter.self, ValuesFormatterMock())
        DiContainer.shared.register(type: SuplaSchedulers.self, schedulers)

        dateProvider.currentDayOfWeekReturns = .sunday
        dateProvider.currentHourReturns = 0
        dateProvider.currentMinuteReturns = 0
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_offlineChannelDisplaysOfflineStateAndDoesNotDisplaySchedule() {
        let channel = makeChannel(
            mode: .lockedTemporaryUnlockAllowed,
            valueFlags: weeklyScheduleFlag,
            online: false,
            channelFlags: buttonModeSupportedFlag | weeklyScheduleSupportedFlag
        )
        load(channel)

        XCTAssertFalse(viewModel.state.online)
        XCTAssertEqual(viewModel.state.channelCurrentStateData?.value, Strings.SwitchDetail.stateOffline)
        XCTAssertEqual(viewModel.state.channelCurrentStateData?.label, "\(Strings.ActionTrigger.scheduleButtonMode):")
        XCTAssertTrue(viewModel.state.channelProgramState.isEmpty)
        XCTAssertFalse(viewModel.state.manualActive)
        XCTAssertTrue(viewModel.state.weeklyActive)
    }

    func test_temporaryUnlockFlagActivatesUnlockButtonForAllowedLockedMode() {
        let channel = makeChannel(
            mode: .lockedTemporaryUnlockAllowed,
            valueFlags: temporaryUnlockActiveFlag
        )
        load(channel)

        XCTAssertTrue(viewModel.state.temporaryUnlockActive)
        XCTAssertFalse(viewModel.state.lockActive)
        XCTAssertTrue(viewModel.state.unlockActive)
    }

    func test_unlockFromLockedTemporaryUnlockAllowedOpensDialogWithCurrentProgramDuration() {
        let channel = makeChannel(
            mode: .lockedTemporaryUnlockAllowed,
            valueFlags: weeklyScheduleFlag
        )
        load(channel, schedule: weeklySchedule(temporaryUnlockDurationS: 1_800), defaultTemporaryUnlockDurationS: 600)

        viewModel.onUnlock()

        XCTAssertTrue(viewModel.state.unlockDialogPresented)
        XCTAssertEqual(viewModel.state.unlockDialogDurationS, 1_800)
        XCTAssertTrue(viewModel.state.unlockTemporaryAllowed)
        XCTAssertEqual(viewModel.state.channelProgramState.first?.description, "\(Strings.General.locked) 30:00")
        XCTAssertTrue(executeActionTriggerActionUseCase.parameters.isEmpty)
        XCTAssertEqual(getChannelConfigUseCase.parameters.count, 2)
        XCTAssertEqual(getChannelConfigUseCase.parameters.last?.1, .defaultConfig)
    }

    func test_unlockUsesDefaultTemporaryUnlockDurationWhenScheduleValueIsUnavailable() {
        let channel = makeChannel(mode: .lockedTemporaryUnlockAllowed)
        load(channel, defaultTemporaryUnlockDurationS: 600)

        viewModel.onUnlock()

        XCTAssertEqual(viewModel.state.unlockDialogDurationS, 600)
        XCTAssertTrue(viewModel.state.unlockTemporaryAllowed)
    }

    func test_zeroScheduleDurationDoesNotUseDefaultTemporaryUnlockDuration() {
        let channel = makeChannel(mode: .lockedTemporaryUnlockAllowed, valueFlags: weeklyScheduleFlag)
        load(channel, schedule: weeklySchedule(temporaryUnlockDurationS: 0), defaultTemporaryUnlockDurationS: 600)

        viewModel.onUnlock()

        XCTAssertEqual(viewModel.state.unlockDialogDurationS, 0)
        XCTAssertFalse(viewModel.state.unlockTemporaryAllowed)
    }

    func test_activeTemporaryUnlockChangesOnlyCurrentProgramDescription() {
        let channel = makeChannel(
            mode: .lockedTemporaryUnlockAllowed,
            valueFlags: weeklyScheduleFlag | temporaryUnlockActiveFlag
        )
        load(channel, schedule: weeklySchedule(temporaryUnlockDurationS: 1_800, includeNextProgram: true))

        XCTAssertEqual(viewModel.state.channelProgramState.count, 2)
        XCTAssertEqual(viewModel.state.channelProgramState[0].description, Strings.ActionTrigger.temporaryUnlocked)
        XCTAssertNil(viewModel.state.channelProgramState[0].time)
        XCTAssertEqual(viewModel.state.channelProgramState[1].description, Strings.General.locked)
    }

    func test_temporaryUnlockActiveIsShownAsCurrentManualMode() {
        let channel = makeChannel(mode: .lockedTemporaryUnlockAllowed, valueFlags: temporaryUnlockActiveFlag)
        load(channel)

        XCTAssertEqual(viewModel.state.channelCurrentStateData?.label, "\(Strings.ActionTrigger.scheduleButtonMode):")
        XCTAssertEqual(viewModel.state.channelCurrentStateData?.value, Strings.ActionTrigger.temporaryUnlocked)
    }

    func test_temporaryUnlockDialogClampsDurationAndExecutesTemporaryUnlock() {
        let channel = makeChannel(
            mode: .lockedTemporaryUnlockAllowed,
            valueFlags: weeklyScheduleFlag
        )
        load(channel, schedule: weeklySchedule(temporaryUnlockDurationS: 1_800))
        viewModel.onUnlock()

        viewModel.onUnlockDialogDurationChange(70_000)
        XCTAssertEqual(viewModel.state.unlockDialogDurationS, 64_800)
        XCTAssertTrue(viewModel.state.unlockTemporaryAllowed)

        viewModel.onUnlockDialogTemporaryUnlock()

        XCTAssertFalse(viewModel.state.unlockDialogPresented)
        XCTAssertEqual(executeActionTriggerActionUseCase.parameters.count, 1)
        XCTAssertEqual(executeActionTriggerActionUseCase.parameters[0].mode, .cmdTemporaryUnlock)
        XCTAssertEqual(executeActionTriggerActionUseCase.parameters[0].durationSec, 64_800)
    }

    func test_unlockInLockedModeExecutesImmediatelyWithoutDialog() {
        let channel = makeChannel(mode: .locked)
        load(channel)

        viewModel.onUnlock()

        XCTAssertFalse(viewModel.state.unlockDialogPresented)
        XCTAssertEqual(executeActionTriggerActionUseCase.parameters.count, 1)
        XCTAssertEqual(executeActionTriggerActionUseCase.parameters[0].mode, .notSet)
        XCTAssertNil(executeActionTriggerActionUseCase.parameters[0].durationSec)
    }

    func test_temporaryUnlockDialogEnablesTemporaryActionAfterSelectingDurationWithoutScheduleValue() {
        let channel = makeChannel(mode: .lockedTemporaryUnlockAllowed)
        load(channel)
        viewModel.onUnlock()

        XCTAssertTrue(viewModel.state.unlockDialogPresented)
        XCTAssertFalse(viewModel.state.unlockTemporaryAllowed)

        viewModel.onUnlockDialogDurationChange(45)

        XCTAssertTrue(viewModel.state.unlockTemporaryAllowed)
        XCTAssertEqual(viewModel.state.unlockDialogDurationS, 45)
    }

    private func load(
        _ channel: SAChannel,
        schedule: SuplaChannelWeeklyScheduleConfig? = nil,
        defaultTemporaryUnlockDurationS: UInt32? = nil
    ) {
        observeChannelUseCase.invokeMock.returns = .single(.just(ChannelWithChildren(channel: channel, children: [])))
        let scheduleEvent = schedule.map { Observable.just(ChannelConfigEvent(result: .resultTrue, config: $0)) } ?? .empty()
        let defaultConfigEvent = defaultTemporaryUnlockDurationS.map {
            Observable.just(ChannelConfigEvent(
                result: .resultTrue,
                config: SuplaChannelActionTriggerConfig(
                    remoteId: remoteId,
                    channelFunc: SUPLA_CHANNELFNC_ACTIONTRIGGER,
                    crc32: 0,
                    temporaryUnlockDurationSec: $0
                )
            ))
        } ?? .empty()
        channelConfigEventsManager.observeConfigReturns = [scheduleEvent, defaultConfigEvent]

        viewModel.onViewCreated()
    }

    private func makeChannel(
        mode: SuplaButtonMode,
        valueFlags: UInt8 = 0,
        online: Bool = true,
        channelFlags: Int64 = Int64(SUPLA_CHANNEL_FLAG_BUTTON_MODE_SUPPORTED)
    ) -> SAChannel {
        let bytes: [UInt8] = [0, 0, 0, 0, 0, UInt8(mode.value), valueFlags, 0]
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.value = NSData(data: Data(bytes))
        channelValue.online = online ? SUPLA_CHANNEL_ONLINE_FLAG_ONLINE : SUPLA_CHANNEL_ONLINE_FLAG_OFFLINE

        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_ACTIONTRIGGER
        channel.flags = channelFlags
        channel.value = channelValue
        return channel
    }

    private func weeklySchedule(temporaryUnlockDurationS: UInt16, includeNextProgram: Bool = false) -> SuplaChannelWeeklyScheduleConfig {
        SuplaChannelWeeklyScheduleConfig(
            remoteId: remoteId,
            channelFunc: SUPLA_CHANNELFNC_ACTIONTRIGGER,
            crc32: 0,
            programConfigurations: .actionTrigger([
                SuplaButtonWeeklyScheduleProgram(
                    program: .program1,
                    mode: .lockedTemporaryUnlockAllowed,
                    buttonTemporaryUnlockDurationS: temporaryUnlockDurationS
                ),
                SuplaButtonWeeklyScheduleProgram(
                    program: .program2,
                    mode: .locked,
                    buttonTemporaryUnlockDurationS: 0
                )
            ]),
            schedule: [
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: .sunday,
                    hour: 0,
                    quarterOfHour: .first,
                    program: .program1
                ),
                SuplaWeeklyScheduleEntry(
                    dayOfWeek: .sunday,
                    hour: 0,
                    quarterOfHour: .second,
                    program: includeNextProgram ? .program2 : .program1
                )
            ]
        )
    }

    private var weeklyScheduleFlag: UInt8 { 1 << 0 }
    private var temporaryUnlockActiveFlag: UInt8 { 1 << 1 }
    private var buttonModeSupportedFlag: Int64 { Int64(SUPLA_CHANNEL_FLAG_BUTTON_MODE_SUPPORTED) }
    private var weeklyScheduleSupportedFlag: Int64 { Int64(SUPLA_CHANNEL_FLAG_WEEKLY_SCHEDULE) }
}

private final class ExecuteActionTriggerActionUseCaseMock: ExecuteActionTriggerActionUseCase.UseCase {
    struct Parameters {
        let type: SUPLA.SubjectType
        let remoteId: Int32
        let mode: SuplaButtonMode
        let durationSec: Int32?
    }

    private(set) var parameters: [Parameters] = []

    func invoke(type: SUPLA.SubjectType, remoteId: Int32, mode: SuplaButtonMode, durationSec: Int32?) -> Observable<RequestResult> {
        parameters.append(Parameters(type: type, remoteId: remoteId, mode: mode, durationSec: durationSec))
        return .empty()
    }
}

private final class ActionTriggerGetDeviceConfigUseCaseMock: GetDeviceConfigUseCase {
    func invoke(deviceId: Int32) -> Observable<RequestResult> { .empty() }
}

private final class ActionTriggerImmediateSchedulers: SuplaSchedulers {
    var background: SchedulerType { MainScheduler.instance }
    var main: SchedulerType { MainScheduler.instance }
}
