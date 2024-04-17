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

final class GetChannelBaseStateUseCaseTests: XCTestCase {
    
    private lazy var useCase: GetChannelBaseStateUseCase! = { GetChannelBaseStateUseCaseImpl() }()
    
    override func tearDown() {
        useCase = nil
    }
    
    func test_closedState() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY
        let activeValue: Int32 = 1
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }
    
    func test_openedState() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK
        let activeValue: Int32 = 0
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }
    
    func test_partialyOpenedState() {
        // given
        let function = SUPLA_CHANNELFNC_CONTROLLINGTHEGATE
        let activeValue: Int32 = 2
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .partialyOpened)
        XCTAssertFalse(state.isActive())
    }
    
    func test_partialyOpenedStateNotUsedForOtherGates() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GATE
        let activeValue: Int32 = 2
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }
    
    func test_onState() {
        // given
        let function = SUPLA_CHANNELFNC_POWERSWITCH
        let activeValue: Int32 = 1
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .on)
        XCTAssertTrue(state.isActive())
    }
    
    func test_offState() {
        // given
        let function = SUPLA_CHANNELFNC_LIGHTSWITCH
        let activeValue: Int32 = 0
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .off)
        XCTAssertFalse(state.isActive())
    }
    
    func test_transparentState() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL
        let activeValue: Int32 = 1
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .transparent)
        XCTAssertTrue(state.isActive())
    }
    
    func test_opaqueState() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL
        let activeValue: Int32 = 0
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .opaque)
        XCTAssertFalse(state.isActive())
    }
    
    func test_dimmerAndRgb_ActiveActive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        let activeValue: Int32 = 3
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .complex([.on, .on]))
        XCTAssertFalse(state.isActive())
    }
    
    func test_dimmerAndRgb_ActiveInactive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        let activeValue: Int32 = 1
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .complex([.on, .off]))
        XCTAssertFalse(state.isActive())
    }
    
    func test_dimmerAndRgb_InactiveActive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        let activeValue: Int32 = 2
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .complex([.off, .on]))
        XCTAssertFalse(state.isActive())
    }
    
    func test_dimmerAndRgb_InactiveInactive() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        let activeValue: Int32 = 0
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .complex([.off, .off]))
        XCTAssertFalse(state.isActive())
    }
    
    func test_noneFunction_notUsedState() {
        // given
        let function = SUPLA_CHANNELFNC_NONE
        let activeValue: Int32 = 0
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .notUsed)
        XCTAssertFalse(state.isActive())
    }
    
    func test_hotelCard_on() {
        // given
        let function = SUPLA_CHANNELFNC_HOTELCARDSENSOR
        let activeValue: Int32 = 1
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .on)
        XCTAssertTrue(state.isActive())
    }
    
    func test_hotelCard_off() {
        // given
        let function = SUPLA_CHANNELFNC_HOTELCARDSENSOR
        let activeValue: Int32 = 0
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .off)
        XCTAssertFalse(state.isActive())
    }
    
    func test_alarmArmament_on() {
        // given
        let function = SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR
        let activeValue: Int32 = 1
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .on)
        XCTAssertTrue(state.isActive())
    }
    
    func test_alarmArmament_off() {
        // given
        let function = SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR
        let activeValue: Int32 = 0
        
        // when
        let state = useCase.invoke(function: function, online: true, activeValue: activeValue)
        
        // then
        XCTAssertEqual(state, .off)
        XCTAssertFalse(state.isActive())
    }
    
    func test_gate_offline() {
        // given
        let function = SUPLA_CHANNELFNC_OPENINGSENSOR_GATE
        
        // when
        let state = useCase.invoke(function: function, online: false, activeValue: 0)
        
        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }
    
    func test_switch_offline() {
        // given
        let function = SUPLA_CHANNELFNC_POWERSWITCH
        
        // when
        let state = useCase.invoke(function: function, online: false, activeValue: 0)
        
        // then
        XCTAssertEqual(state, .off)
        XCTAssertFalse(state.isActive())
    }
    
    func test_dimmerAndRgb_offline() {
        // given
        let function = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        
        // when
        let state = useCase.invoke(function: function, online: false, activeValue: 0)
        
        // then
        XCTAssertEqual(state, .complex([.off, .off]))
        XCTAssertFalse(state.isActive())
    }
    
    func test_digiglass_offline() {
        // given
        let function = SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL
        
        // when
        let state = useCase.invoke(function: function, online: false, activeValue: 0)
        
        // then
        XCTAssertEqual(state, .opaque)
        XCTAssertFalse(state.isActive())
    }
}
