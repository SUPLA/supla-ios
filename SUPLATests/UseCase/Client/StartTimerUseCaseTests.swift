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

final class StartTimerUseCaseTests: UseCaseTest<Void> {
    
    private lazy var useCase: StartTimerUseCase! = { StartTimerUseCaseImpl() }()
    
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
    
    func test_arm_positive() {
        // given
        let remoteId: Int32 = 3234
        let turnOn = true
        let duration: Int32 = 15
        
        suplaClientProvider.suplaClientMock.timerArmReturns = true
        
        // when
        useCase.invoke(remoteId: remoteId, turnOn: turnOn, durationInSecs: duration)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2) // next & complete
        XCTAssertEqual(vibrationService.vibrateCalls, 1)
        assertTuple(suplaClientProvider.suplaClientMock.timerArmParameters, equalTo: [
            (remoteId, turnOn, Int32(15000))
        ])
    }
    
    func test_arm_negative() {
        // given
        let remoteId: Int32 = 3234
        let turnOn = true
        let duration: Int32 = 15
        
        suplaClientProvider.suplaClientMock.timerArmReturns = false
        
        // when
        useCase.invoke(remoteId: remoteId, turnOn: turnOn, durationInSecs: duration)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        XCTAssertEqual(observer.events.count, 2) // next & complete
        XCTAssertEqual(vibrationService.vibrateCalls, 0)
        assertTuple(suplaClientProvider.suplaClientMock.timerArmParameters, equalTo: [
            (remoteId, turnOn, Int32(15000))
        ])
    }
    
    func test_arm_wrongDuration() {
        // given
        let remoteId: Int32 = 3234
        let turnOn = true
        let duration: Int32 = 0
        
        suplaClientProvider.suplaClientMock.timerArmReturns = false
        
        // when
        useCase.invoke(remoteId: remoteId, turnOn: turnOn, durationInSecs: duration)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        // then
        assertVoid(observer.events, equalTo: [.error(StartTimerUseCaseImpl.InvalidTimeError())])
        XCTAssertEqual(vibrationService.vibrateCalls, 0)
        assertTuple(suplaClientProvider.suplaClientMock.timerArmParameters, equalTo: [])
    }
}
