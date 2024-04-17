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

final class ExecuteFacadeBlindActionUseCaseTests: CompletableTestCase {
    private lazy var suplaClientProvider: SuplaClientProviderMock! = SuplaClientProviderMock()
    
    private lazy var vibrationService: VibrationServiceMock! = VibrationServiceMock()
    
    private lazy var useCase: ExecuteFacadeBlindActionUseCase! = ExecuteFacadeBlindActionUseCaseImpl()
    
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
    
    func test_shouldExectionAction_withVibration() {
        // given
        let action: Action = .reveal
        let type: SubjectType = .channel
        let remoteId: Int32 = 123
        
        suplaClientProvider.suplaClientMock.executeActionReturns = true
        
        // when
        useCase.invoke(action: action, type: type, remoteId: remoteId, position: 80, tilt: 20)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.completed])
        
        XCTAssertEqual(vibrationService.vibrateCalls, 1)
        XCTAssertEqual(suplaClientProvider.suplaClientMock.executeActionParameters.count, 1)
        let parameters = suplaClientProvider.suplaClientMock.executeActionParameters[0]
        XCTAssertEqual(parameters.0, action.rawValue)
        XCTAssertEqual(parameters.1, type.rawValue)
        XCTAssertEqual(parameters.2, remoteId)
        XCTAssertEqual(parameters.4, Int32(MemoryLayout<TAction_ShadingSystem_Parameters>.size))
        
        let nativeParameters = parameters.3!.assumingMemoryBound(to: TAction_ShadingSystem_Parameters.self).pointee
        XCTAssertEqual(nativeParameters.Percentage, 80)
        XCTAssertEqual(nativeParameters.Tilt, 20)
    }
    
    func test_shouldExectionAction_withoutVibration() {
        // given
        let action: Action = .reveal
        let type: SubjectType = .group
        let remoteId: Int32 = 123
        
        // when
        useCase.invoke(action: action, type: type, remoteId: remoteId, position: 50, tilt: 50)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertEvents(contains: [.completed])
        
        XCTAssertEqual(vibrationService.vibrateCalls, 0)
        XCTAssertEqual(suplaClientProvider.suplaClientMock.executeActionParameters.count, 1)
        let parameters = suplaClientProvider.suplaClientMock.executeActionParameters[0]
        XCTAssertEqual(parameters.0, action.rawValue)
        XCTAssertEqual(parameters.1, type.rawValue)
        XCTAssertEqual(parameters.2, remoteId)
        XCTAssertEqual(parameters.4, Int32(MemoryLayout<TAction_ShadingSystem_Parameters>.size))
        
        let nativeParameters = parameters.3!.assumingMemoryBound(to: TAction_ShadingSystem_Parameters.self).pointee
        XCTAssertEqual(nativeParameters.Percentage, 50)
        XCTAssertEqual(nativeParameters.Tilt, 50)
    }
}

