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

final class SwitchDetailVMTests: ViewModelTest<SwitchDetailViewState, SwitchDetailViewEvent> {
    
    private lazy var viewModel: SwitchDetailVM! = { SwitchDetailVM() }()
    
    private lazy var readChannelByRemoteIdUseCase: ReadChannelByRemoteIdUseCaseMock! = {
        ReadChannelByRemoteIdUseCaseMock()
    }()
    
    private lazy var readGroupByRemoteIdUseCase: ReadGroupByRemoteIdUseCaseMock! = {
        ReadGroupByRemoteIdUseCaseMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: ReadChannelByRemoteIdUseCase.self, readChannelByRemoteIdUseCase!)
        DiContainer.shared.register(type: ReadGroupByRemoteIdUseCase.self, readGroupByRemoteIdUseCase!)
    }
    
    override func tearDown() {
        viewModel = nil
        readChannelByRemoteIdUseCase = nil
        readGroupByRemoteIdUseCase = nil
        super.tearDown()
    }
    
    func test_shouldSetTitleFromChannel() {
        // given
        let name = "testname"
        let channel = SAChannel(testContext: nil)
        channel.caption = name
        
        readChannelByRemoteIdUseCase.returns = Observable.just(channel)
        
        // when
        observe(viewModel)
        viewModel.loadData(remoteId: 123, type: .channel)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(stateObserver.events[1].value.element?.title, name)
        
        XCTAssertEqual(readChannelByRemoteIdUseCase.remoteIdArray[0], 123)
    }
    
    func test_shouldSetTitleFromGroup() {
        // given
        let name = "testname"
        let group = SAChannelGroup(testContext: nil)
        group.caption = name
        
        readGroupByRemoteIdUseCase.returns = Observable.just(group)
        
        // when
        observe(viewModel)
        viewModel.loadData(remoteId: 123, type: .group)
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        XCTAssertEqual(stateObserver.events[1].value.element?.title, name)
        
        XCTAssertEqual(readGroupByRemoteIdUseCase.remoteIdArray[0], 123)
    }
}
