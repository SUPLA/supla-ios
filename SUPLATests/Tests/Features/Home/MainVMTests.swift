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

class MainVMTests: ViewModelTest<MainViewState, MainViewEvent> {
    
    private lazy var viewModel: MainViewModel! = { MainViewModel() }()
    
    private lazy var profileRepository: ProfileRepositoryMock! = {
        ProfileRepositoryMock()
    }()
    private lazy var channelRepository: ChannelRepositoryMock! = {
        ChannelRepositoryMock()
    }()
    private lazy var updateEventsManager: UpdateEventsManagerMock! = {
        UpdateEventsManagerMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any ProfileRepository).self, component: profileRepository!)
        DiContainer.shared.register(type: (any ChannelRepository).self, component: channelRepository!)
        DiContainer.shared.register(type: UpdateEventsManager.self, component: updateEventsManager!)
    }
    
    override func tearDown() {
        viewModel = nil
        
        profileRepository = nil
        channelRepository = nil
        updateEventsManager = nil
        
        super.tearDown()
    }
    
    func test_shouldLoadIcons_onChannelUpdate() {
        // given
        updateEventsManager.observeChannelUpdatesObservable = Observable.just(())
        updateEventsManager.observeGroupUpdatesObservable = Observable.just(())
        updateEventsManager.observeSceneUpdatesObservable = Observable.just(())
        
        // when
        observe(viewModel)
        viewModel.onViewDidLoad()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 1)
        XCTAssertEqual(eventObserver.events.count, 1)
        
        XCTAssertEqual(eventObserver.events, [.next(0, .loadIcons)])
    }
    
    func test_shouldShowProfileIcon_whenThereIsMoreThanOneProfile() {
        // given
        profileRepository.allProfilesObservable = Observable.just([
            AuthProfileItem(testContext: nil), AuthProfileItem(testContext: nil)
        ])
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.onViewAppear()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        let state = MainViewState()
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state.changing(path: \.showProfilesIcon, to: true))
        ])
    }
    
    func test_shouldHideProfileIcon_whenThereIsOnlyOneProfile() {
        // given
        profileRepository.allProfilesObservable = Observable.just([
            AuthProfileItem(testContext: nil)
        ])
        
        // when
        observe(viewModel)
        scheduler.advanceTo(1)
        viewModel.onViewAppear()
        
        // then
        XCTAssertEqual(stateObserver.events.count, 2)
        XCTAssertEqual(eventObserver.events.count, 0)
        
        let state = MainViewState()
        XCTAssertEqual(stateObserver.events, [
            .next(0, state),
            .next(1, state)
        ])
    }
}
