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

@testable import SUPLA
import XCTest
import SharedCore

final class VerticalBlindsVMTests: ViewModelTest<VerticalBlindsViewState, BaseWindowViewEvent> {
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = ReadChannelByRemoteIdUseCaseMock()
    
    private lazy var readGroupByRemoteIdUseCase: ReadGroupByRemoteIdUseCaseMock! = ReadGroupByRemoteIdUseCaseMock()
    
    private lazy var getGroupOnlineSummaryUseCase: GetGroupOnlineSummaryUseCaseMock! = GetGroupOnlineSummaryUseCaseMock()
    
    private lazy var channelConfigEventsManager: ChannelConfigEventsManagerMock! = ChannelConfigEventsManagerMock()
    
    private lazy var executeFacadeBlindActionUseCase: ExecuteFacadeBlindActionUseCaseMock! = ExecuteFacadeBlindActionUseCaseMock()
    
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    
    private lazy var viewModel: VerticalBlindsVM! = VerticalBlindsVM()
    
    override func setUp() {
        DiContainer.register(ReadChannelByRemoteIdUseCase.self, readChannelByRemoteIdUseCase!)
        DiContainer.register(ReadGroupByRemoteIdUseCase.self, readGroupByRemoteIdUseCase!)
        DiContainer.register(GetGroupOnlineSummaryUseCase.self, getGroupOnlineSummaryUseCase!)
        DiContainer.register(ChannelConfigEventsManager.self, channelConfigEventsManager!)
        DiContainer.register(ExecuteFacadeBlindActionUseCase.self, executeFacadeBlindActionUseCase!)
        DiContainer.register(GlobalSettings.self, settings!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        readChannelByRemoteIdUseCase = nil
        readGroupByRemoteIdUseCase = nil
        getGroupOnlineSummaryUseCase = nil
        channelConfigEventsManager = nil
        executeFacadeBlindActionUseCase = nil
        settings = nil
        viewModel = nil
    }
    
    func test_shouldLoadChannel() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.remote_id = 123
        channel.flags = Int64(SUPLA_CHANNEL_FLAG_CALCFG_RECALIBRATE)
        channel.value = SAChannelValue(testContext: nil)
        channel.value?.value = NSData(data: FacadeBlindValue.mockData(position: 50, tilt: 70, flags: SuplaShadingSystemFlag.motorProblem.value | SuplaShadingSystemFlag.tiltIsSet.value))
        channel.value?.online = SUPLA_CHANNEL_ONLINE_FLAG_ONLINE
        
        settings.showOpeningPercentReturns = false
        readChannelByRemoteIdUseCase.returns = .just(channel)
        
        // when
        observe(viewModel)
        viewModel.loadData(remoteId: 123, type: .channel)
        
        // then
        assertStates(expected: [
            VerticalBlindsViewState(),
            VerticalBlindsViewState(
                lastPosition: 50,
                remoteId: 123,
                verticalBlindWindowState: VerticalBlindWindowState(
                    position: .similar(50),
                    slatTilt: .similar(70)
                ),
                issues: [
                    ChannelIssueItem.Error(string: LocalizedStringWithId(id: LocalizedStringId.motorProblem))
                ],
                offline: false,
                positionPresentation: .asClosed,
                calibrating: false,
                calibrationPossible: true
            )
        ])
        assertEvents(expected: [])
    }
    
    func test_shouldLoadGroup() {
        // given
        let groupOnlineSummary = GroupOnlineSummary(onlineCount: 2, count: 3)
        let group = SAChannelGroup(testContext: nil)
        group.remote_id = 234
        group.online = 1
        group.total_value = GroupTotalValue(values: [
            ShadowingBlindGroupValue(position: 50, tilt: 50),
            ShadowingBlindGroupValue(position: 80, tilt: 20)
        ])
        
        settings.showOpeningPercentReturns = true
        readGroupByRemoteIdUseCase.returns = .just(group)
        getGroupOnlineSummaryUseCase.returns = .just(groupOnlineSummary)
        
        // when
        observe(viewModel)
        viewModel.loadData(remoteId: 234, type: .group)
        
        // then
        assertStates(expected: [
            VerticalBlindsViewState(),
            VerticalBlindsViewState(
                lastPosition: 0,
                remoteId: 234,
                verticalBlindWindowState: VerticalBlindWindowState(
                    position: .different(min: 50, max: 80),
                    positionTextFormat: .openingPercentage,
                    slatTilt: .similar(50),
                    markers: [
                        ShadingBlindMarker(position: 50, tilt: 50),
                        ShadingBlindMarker(position: 80, tilt: 20)
                    ]
                ),
                offline: false,
                positionPresentation: .asOpened,
                isGroup: true,
                onlineStatusString: "2/3"
            )
        ])
    }
    
    func test_shouldLoadConfig() {
        // given
        let configEvent = ChannelConfigEvent(
            result: .resultTrue,
            config: SuplaChannelFacadeBlindConfig(
                remoteId: 123,
                channelFunc: SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND,
                crc32: 0,
                closingTimeMs: 10000,
                openingTimeMs: 10500,
                motorUpsideDown: false,
                buttonUpsideDown: true,
                timeMargin: 20,
                tiltingTimeMs: 1500,
                tilt0Angle: 10,
                tilt100Angle: 80,
                type: .tiltsOnlyWhenFullyClosed
            )
        )
        channelConfigEventsManager.observeConfigReturns = [.just(configEvent)]
        
        // when
        observe(viewModel)
        viewModel.observeConfig(123, .channel)
        
        // then
        assertStates(expected: [
            VerticalBlindsViewState(),
            VerticalBlindsViewState(
                tiltControlType: .tiltsOnlyWhenFullyClosed,
                tiltingTime: 1500,
                openingTime: 10500,
                closingTime: 10000,
                verticalBlindWindowState: VerticalBlindWindowState(
                    position: .similar(0),
                    tilt0Angle: 10,
                    tilt100Angle: 80
                )
            )
        ])
    }
    
    func test_shouldTiltToDefinedValue() {
        // when
        viewModel.updateView { $0.changing(path: \.remoteId, to: 111) }
        observe(viewModel)
        viewModel.handleAction(.tiltTo(tilt: 10), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            VerticalBlindsViewState(remoteId: 111),
            VerticalBlindsViewState(
                remoteId: 111,
                verticalBlindWindowState: VerticalBlindWindowState(position: .similar(0), slatTilt: .similar(10)),
                manualMoving: true
            )
        ])
    }
    
    func test_shouldTiltToDefinedValue_andUpdateMarkers() {
        // given
        let initialState = VerticalBlindsViewState(
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .different(min: 10, max: 20),
                slatTilt: .different(min: 40, max: 60),
                markers: [
                    ShadingBlindMarker(position: 10, tilt: 40),
                    ShadingBlindMarker(position: 20, tilt: 60)
                ]
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.tiltTo(tilt: 50), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState
                .changing(
                    path: \.verticalBlindWindowState,
                    to: initialState.verticalBlindWindowState
                        .changing(path: \.slatTilt, to: .similar(50))
                        .changing(path: \.markers, to: [
                            ShadingBlindMarker(position: 10, tilt: 50),
                            ShadingBlindMarker(position: 20, tilt: 50)
                        ])
                )
                .changing(path: \.manualMoving, to: true)
        ])
    }
    
    func test_shouldTiltToDefinedValue_andSetPositionToClosedWhenTiltsOnlyWhenFullyClosed() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .tiltsOnlyWhenFullyClosed,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(50),
                slatTilt: .similar(50)
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.tiltTo(tilt: 60), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState
                .changing(
                    path: \.verticalBlindWindowState,
                    to: initialState.verticalBlindWindowState
                        .changing(path: \.position, to: .similar(100))
                        .changing(path: \.slatTilt, to: .similar(60))
                )
                .changing(path: \.manualMoving, to: true)
        ])
    }
    
    func test_shouldSetTilt() {
        let initialState = VerticalBlindsViewState(
            manualMoving: true
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.tiltSetTo(tilt: 80), remoteId: 222, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.manualMoving, to: false)
        ])
        XCTAssertTuples(executeFacadeBlindActionUseCase.parameters, [
            (Action.shutPartially, SubjectType.channel, Int32(222), CGFloat(VALUE_IGNORE), 80)
        ])
    }
    
    func test_shouldMoveAndTiltToDefinedValue() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .standsInPositionWhileTilting,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(10),
                slatTilt: .similar(50)
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.moveAndTiltTo(position: 20, tilt: 90), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState
                .changing(
                    path: \.verticalBlindWindowState,
                    to: initialState.verticalBlindWindowState
                        .changing(path: \.position, to: .similar(20))
                        .changing(path: \.slatTilt, to: .similar(90))
                )
                .changing(path: \.manualMoving, to: true)
        ])
    }
    
    func test_shouldMoveAndTiltToDefinedValue_whenTiltNotSet() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .standsInPositionWhileTilting,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(10)
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.moveAndTiltTo(position: 20, tilt: 90), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState
                .changing(
                    path: \.verticalBlindWindowState,
                    to: initialState.verticalBlindWindowState
                        .changing(path: \.position, to: .similar(20))
                )
                .changing(path: \.manualMoving, to: true)
        ])
    }
    
    func test_shouldMoveAndTiltToDefinedValue_andLimitTiltWhenChangesPositionWhileTilting_onTop() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .changesPositionWhileTilting,
            tiltingTime: 2000,
            openingTime: 20000,
            closingTime: 20000,
            lastPosition: 10,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(10),
                slatTilt: .similar(50)
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.moveAndTiltTo(position: 2.5, tilt: 80), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState
                .changing(
                    path: \.verticalBlindWindowState,
                    to: initialState.verticalBlindWindowState
                        .changing(path: \.position, to: .similar(2.5))
                        .changing(path: \.slatTilt, to: .similar(25))
                )
                .changing(path: \.manualMoving, to: true)
        ])
    }
    
    func test_shouldMoveAndTiltToDefinedValue_andLimitTiltWhenChangesPositionWhileTilting_onBottom() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .changesPositionWhileTilting,
            tiltingTime: 2000,
            openingTime: 20000,
            closingTime: 20000,
            lastPosition: 10,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(10),
                slatTilt: .similar(50)
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.moveAndTiltTo(position: 95, tilt: 0), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState
                .changing(
                    path: \.verticalBlindWindowState,
                    to: initialState.verticalBlindWindowState
                        .changing(path: \.position, to: .similar(95))
                        .changing(path: \.slatTilt, to: .similar(50))
                )
                .changing(path: \.manualMoving, to: true)
        ])
    }
    
    func test_shouldSetPositionAndTiltToDefinedValue() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .standsInPositionWhileTilting,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(10),
                slatTilt: .similar(50)
            ),
            manualMoving: true
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.moveAndTiltSetTo(position: 20, tilt: 90), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.manualMoving, to: false)
        ])
        XCTAssertTuples(executeFacadeBlindActionUseCase.parameters, [
            (Action.shutPartially, SubjectType.channel, Int32(111), 20, 90)
        ])
    }
    
    func test_shouldSetPositionAndTiltToDefinedValue_whenTiltNotSet() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .standsInPositionWhileTilting,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(10)
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.moveAndTiltSetTo(position: 20, tilt: 90), remoteId: 111, type: .channel)
        
        // then
        // then
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.manualMoving, to: false)
        ])
        XCTAssertTuples(executeFacadeBlindActionUseCase.parameters, [
            (Action.shutPartially, SubjectType.channel, Int32(111), 20, CGFloat(VALUE_IGNORE))
        ])
    }
    
    func test_shouldSetPositionAndTiltToDefinedValue_andLimitTiltWhenChangesPositionWhileTilting_onTop() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .changesPositionWhileTilting,
            tiltingTime: 2000,
            openingTime: 20000,
            closingTime: 20000,
            lastPosition: 10,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(10),
                slatTilt: .similar(50)
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.moveAndTiltSetTo(position: 2.5, tilt: 80), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.manualMoving, to: false)
        ])
        XCTAssertTuples(executeFacadeBlindActionUseCase.parameters, [
            (Action.shutPartially, SubjectType.channel, Int32(111), 2.5, 25)
        ])
    }
    
    func test_shouldSetPositionAndTiltToDefinedValue_andLimitTiltWhenChangesPositionWhileTilting_onBottom() {
        // given
        let initialState = VerticalBlindsViewState(
            tiltControlType: .changesPositionWhileTilting,
            tiltingTime: 2000,
            openingTime: 20000,
            closingTime: 20000,
            lastPosition: 10,
            remoteId: 111,
            verticalBlindWindowState: VerticalBlindWindowState(
                position: .similar(10),
                slatTilt: .similar(50)
            )
        )
        viewModel.updateView { _ in initialState }
        
        // when
        observe(viewModel)
        viewModel.handleAction(.moveAndTiltSetTo(position: 95, tilt: 0), remoteId: 111, type: .channel)
        
        // then
        assertStates(expected: [
            initialState,
            initialState.changing(path: \.manualMoving, to: false)
        ])
        XCTAssertTuples(executeFacadeBlindActionUseCase.parameters, [
            (Action.shutPartially, SubjectType.channel, Int32(111), 95, 50)
        ])
    }
}
