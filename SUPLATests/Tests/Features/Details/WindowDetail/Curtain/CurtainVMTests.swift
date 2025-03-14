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

final class CurtainVMTests: ViewModelTest<CurtainViewState, BaseWindowViewEvent> {
    
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = ReadChannelByRemoteIdUseCaseMock()
    
    private lazy var readGroupByRemoteIdUseCase: ReadGroupByRemoteIdUseCaseMock! = ReadGroupByRemoteIdUseCaseMock()
    
    private lazy var getGroupOnlineSummaryUseCase: GetGroupOnlineSummaryUseCaseMock! = GetGroupOnlineSummaryUseCaseMock()
    
    private lazy var settings: GlobalSettingsMock! = GlobalSettingsMock()
    
    private lazy var viewModel: CurtainVM! = CurtainVM()
    
    override func setUp() {
        
        DiContainer.register(ReadChannelByRemoteIdUseCase.self, readChannelByRemoteIdUseCase!)
        DiContainer.register(ReadGroupByRemoteIdUseCase.self, readGroupByRemoteIdUseCase!)
        DiContainer.register(GetGroupOnlineSummaryUseCase.self, getGroupOnlineSummaryUseCase!)
        DiContainer.register(GlobalSettings.self, settings!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        readChannelByRemoteIdUseCase = nil
        settings = nil
        viewModel = nil
    }
    
    func test_shouldLoadChannel() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.remote_id = 123
        channel.flags = Int64(SUPLA_CHANNEL_FLAG_CALCFG_RECALIBRATE)
        channel.value = SAChannelValue(testContext: nil)
        channel.value?.value = NSData(data: RollerShutterValue.mockData(position: 50, flags: SuplaShadingSystemFlag.motorProblem.value))
        channel.value?.online = SUPLA_CHANNEL_ONLINE_FLAG_ONLINE
        
        settings.showOpeningPercentReturns = false
        readChannelByRemoteIdUseCase.returns = .just(channel)
        
        // when
        observe(viewModel)
        viewModel.loadData(remoteId: 123, type: .channel)
        
        // then
        assertStates(expected: [
            CurtainViewState(),
            CurtainViewState(
                remoteId: 123,
                curtainWindowState: CurtainWindowState(position: .similar(50)),
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
            ShadingSystemGroupValue(position: 50, closedSensorActive: false),
            ShadingSystemGroupValue(position: 80, closedSensorActive: false)
        ])
        
        settings.showOpeningPercentReturns = true
        readGroupByRemoteIdUseCase.returns = .just(group)
        getGroupOnlineSummaryUseCase.returns = .just(groupOnlineSummary)
        
        // when
        observe(viewModel)
        viewModel.loadData(remoteId: 234, type: .group)
        
        // then
        assertStates(expected: [
            CurtainViewState(),
            CurtainViewState(
                remoteId: 234,
                curtainWindowState: CurtainWindowState(
                    position: .different(min: 50, max: 80),
                    positionTextFormat: .openingPercentage,
                    markers: [50, 80]
                ),
                offline: false,
                positionPresentation: .asOpened,
                isGroup: true,
                onlineStatusString: "2/3"
            )
        ])
    }
}

