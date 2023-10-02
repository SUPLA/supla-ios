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

final class ExecuteSimpleActionUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: ExecuteSimpleActionUseCase! = { ExecuteSimpleActionUseCaseImpl() }()
    
    private lazy var suplaClientProvider: SuplaClientProviderMock! = {
        SuplaClientProviderMock()
    }()
    private lazy var vibrationService: VibrationServiceMock! = {
        VibrationServiceMock()
    }()
    
    override func setUp() {
        DiContainer.shared.register(type: SuplaClientProvider.self, component: suplaClientProvider!)
        DiContainer.shared.register(type: VibrationService.self, component: vibrationService!)
    }
    
    override func tearDown() {
        useCase = nil
        suplaClientProvider = nil
        vibrationService = nil
        
        super.tearDown()
    }
    
    func test_execute_positive() {
        // given
        let action: Action = .turn_on
        let type: SubjectType = .channel
        let remoteId: Int32 = 3234
        
        suplaClientProvider.suplaClientMock.executeActionReturns = true
        
        // when
        useCase.invoke(action: action, type: type, remoteId: remoteId)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2) // next & complete
        XCTAssertEqual(vibrationService.vibrateCalls, 1)
        assertTuple(suplaClientProvider.suplaClientMock.executeActionParameters, equalTo: [
            (action.rawValue, type.rawValue, remoteId, nil, nil)
        ])
    }
    
    func test_execute_negative() {
        // given
        let action: Action = .turn_on
        let type: SubjectType = .channel
        let remoteId: Int32 = 3234
        
        suplaClientProvider.suplaClientMock.executeActionReturns = false
        
        // when
        useCase.invoke(action: action, type: type, remoteId: remoteId)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2) // next & complete
        XCTAssertEqual(vibrationService.vibrateCalls, 0)
        assertTuple(suplaClientProvider.suplaClientMock.executeActionParameters, equalTo: [
            (action.rawValue, type.rawValue, remoteId, nil, nil)
        ])
    }
}
