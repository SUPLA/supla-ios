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

final class ToggleLocationUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: ToggleLocationUseCase! = { ToggleLocationUseCaseImpl() }()
    
    private lazy var locationRepository: LocationRepositoryMock! = {
        LocationRepositoryMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: (any LocationRepository).self, component: locationRepository!)
    }
    
    override func tearDown() {
        useCase = nil
        locationRepository = nil
    }
    
    func test_collapseLocation() {
        // given
        let remoteId = 123
        let location = _SALocation(testContext: nil)
        location.collapsed = 0
        
        locationRepository.queryItemByPredicateObservable = Observable.just(location)
        locationRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(remoteId: remoteId, collapsedFlag: .scene).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertTrue(location.isCollapsed(flag: .scene))
        XCTAssertEqual(locationRepository.saveCounter, 1)
    }
    
    func test_expandLocation() {
        // given
        let remoteId = 123
        let location = _SALocation(testContext: nil)
        location.collapsed = 0 | CollapsedFlag.group.rawValue
        
        locationRepository.queryItemByPredicateObservable = Observable.just(location)
        locationRepository.saveObservable = Observable.just(())
        
        // when
        useCase.invoke(remoteId: remoteId, collapsedFlag: .group).subscribe(observer).disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2)
        XCTAssertFalse(location.isCollapsed(flag: .group))
        XCTAssertEqual(locationRepository.saveCounter, 1)
    }
}
