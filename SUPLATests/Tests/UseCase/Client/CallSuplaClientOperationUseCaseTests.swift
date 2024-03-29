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

final class CallSuplaClientOperationUseCaseTests: CompletableTestCase {
    private lazy var suplaClientProvider: SuplaClientProviderMock! = SuplaClientProviderMock()
    
    private lazy var vibrationService: VibrationServiceMock! = VibrationServiceMock()
    
    private lazy var useCase: CallSuplaClientOperationUseCase! = CallSuplaClientOperationUseCaseImpl()
    
    override func setUp() {
        super.setUp()
        DiContainer.register(SuplaClientProvider.self, suplaClientProvider!)
        DiContainer.register(VibrationService.self, vibrationService!)
    }
    
    override func tearDown() {
        super.tearDown()
        
        suplaClientProvider = nil
        vibrationService = nil
        useCase = nil
    }
    
    func test_shouldPerformMoveUp_andVibrate() {
        // given
        let remoteId: Int32 = 123
        let type: SubjectType = .channel
        let operation: SuplaClientOperation = .moveUp
        
        suplaClientProvider.suplaClientMock.cgReturns = true
        
        // when
        useCase.invoke(remoteId: remoteId, type: type, operation: operation)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.completed])
        
        XCTAssertEqual(vibrationService.vibrateCalls, 1)
        XCTAssertTuples(suplaClientProvider.suplaClientMock.cgParameters, [
            (remoteId, 2, false)
        ])
    }
    
    func test_shouldPerformMoveDown_andDoNotVibrate() {
        // given
        let remoteId: Int32 = 123
        let type: SubjectType = .group
        let operation: SuplaClientOperation = .moveDown
        
        // when
        useCase.invoke(remoteId: remoteId, type: type, operation: operation)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.completed])
        
        XCTAssertEqual(vibrationService.vibrateCalls, 0)
        XCTAssertTuples(suplaClientProvider.suplaClientMock.cgParameters, [
            (remoteId, 1, true)
        ])
    }
    
    
    
    func test_shouldPerformRecalibrate() {
        // given
        let remoteId: Int32 = 123
        let type: SubjectType = .group
        let operation: SuplaClientOperation = .recalibrate
        
        suplaClientProvider.suplaClientMock.deviceCalCfgCommandReturns = true
        
        // when
        useCase.invoke(remoteId: remoteId, type: type, operation: operation)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.completed])
        
        XCTAssertEqual(vibrationService.vibrateCalls, 1)
        XCTAssertTuples(suplaClientProvider.suplaClientMock.deviceCalCfgCommandParameters, [
            (SUPLA_CALCFG_CMD_RECALIBRATE, remoteId, true)
        ])
    }
}
