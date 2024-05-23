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

final class ChannelBaseActionUseCaseTests: UseCaseTest<Void> {
    
    private lazy var executeSimpleActionUseCase: ExecuteSimpleActionUseCaseMock! = ExecuteSimpleActionUseCaseMock()
    
    private lazy var useCase: ChannelBaseActionUseCase! = ChannelBaseActionUseCaseImpl()
    
    override func setUp() {
        DiContainer.register(ExecuteSimpleActionUseCase.self, executeSimpleActionUseCase!)
        
        executeSimpleActionUseCase.returns = .just(())
    }
    
    override func tearDown() {
        useCase = nil
        executeSimpleActionUseCase = nil
        
        super.tearDown()
    }
    
    func test_shouldOpenRoofWindow() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW
        
        // when
        useCase.invoke(channel, .rightButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [(Action.upOrStop, SubjectType.channel, remoteId)])
    }
    
    func test_shouldCloseRollerShutter() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROLLERSHUTTER
        
        // when
        useCase.invoke(channel, .leftButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [(Action.downOrStop, SubjectType.channel, remoteId)])
    }
    
    func test_shouldOpenFacadeBlind() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEFACADEBLIND
        
        // when
        useCase.invoke(channel, .rightButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [(Action.upOrStop, SubjectType.channel, remoteId)])
    }
    
    func test_shouldCloseProjectorScreen() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_PROJECTOR_SCREEN
        
        // when
        useCase.invoke(channel, .rightButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [(Action.downOrStop, SubjectType.channel, remoteId)])
    }
    
    func test_shouldOpenProjectorScreen() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_PROJECTOR_SCREEN
        
        // when
        useCase.invoke(channel, .leftButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [(Action.upOrStop, SubjectType.channel, remoteId)])
    }
    
    func test_shouldTurnOnThermostat() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_THERMOSTAT
        
        // when
        useCase.invoke(channel, .rightButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [(Action.turnOn, SubjectType.channel, remoteId)])
    }
    
    func test_shouldTurnOffDomesticHotWater() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannel(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_HVAC_DOMESTIC_HOT_WATER
        
        // when
        useCase.invoke(channel, .leftButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [(Action.turnOff, SubjectType.channel, remoteId)])
    }
    
    func test_shouldOpenCloseWindowGroup() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannelGroup(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEROOFWINDOW
        
        // when
        useCase.invoke(channel, .leftButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertTuples(executeSimpleActionUseCase.parameters, [(Action.downOrStop, SubjectType.group, remoteId)])
    }
    
    func test_shouldJustQuitWhenNoActionFound() {
        // given
        let remoteId: Int32 = 123
        let channel = SAChannelGroup(testContext: nil)
        channel.remote_id = remoteId
        channel.func = SUPLA_CHANNELFNC_NONE
        
        // when
        useCase.invoke(channel, .leftButton).subscribe(observer).disposed(by: disposeBag)
        
        // then
        assertEvents([.next(()), .completed])
        XCTAssertEqual(executeSimpleActionUseCase.parameters.count, 0)
    }
}
