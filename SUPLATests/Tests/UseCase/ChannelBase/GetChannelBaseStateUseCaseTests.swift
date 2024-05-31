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
    private lazy var useCase: GetChannelBaseStateUseCase! = GetChannelBaseStateUseCaseImpl()
    
    override func tearDown() {
        useCase = nil
    }
    
    private func mockChannelValue(
        online: Bool = true,
        byte0: UInt8 = 0,
        byte1: UInt8 = 0,
        byte2: UInt8 = 0,
        byte3: UInt8 = 0,
        byte4: UInt8 = 0,
        byte5: UInt8 = 0,
        byte6: UInt8 = 0,
        byte7: UInt8 = 0
    ) -> SAChannelValue {
        var value: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) =
            (byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.online = online
        channelValue.value = NSData(data: Data(bytes: &value, count: 8))
        
        return channelValue
    }
    
    private func mockChannelSubValue(
        online: Bool = true,
        byte0: UInt8 = 0,
        byte1: UInt8 = 0,
        byte2: UInt8 = 0,
        byte3: UInt8 = 0,
        byte4: UInt8 = 0,
        byte5: UInt8 = 0,
        byte6: UInt8 = 0,
        byte7: UInt8 = 0
    ) -> SAChannelValue {
        var value: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) =
            (byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7)
        
        let channelValue = SAChannelValue(testContext: nil)
        channelValue.online = online
        channelValue.sub_value = NSData(data: Data(bytes: &value, count: 8))
        
        return channelValue
    }
    
    func test_closedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_OPENINGSENSOR_GATEWAY
        channel.value = mockChannelValue(byte0: 1)
        
        // when
        let state = useCase.invoke(channelBase: channel)
        
        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }
    
    func test_openedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEGATEWAYLOCK
        channel.value = mockChannelValue()
        
        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }

    func test_partialyOpenedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_CONTROLLINGTHEGATE
        channel.value = mockChannelSubValue(byte1: 1)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .partialyOpened)
        XCTAssertFalse(state.isActive())
    }

    func test_partialyOpenedStateNotUsedForOtherGates() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_OPENINGSENSOR_GATE
        channel.value = mockChannelValue(byte0: 2)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }

    func test_onState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_POWERSWITCH
        channel.value = mockChannelValue(byte0: 1)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .on)
        XCTAssertTrue(state.isActive())
    }

    func test_offState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_LIGHTSWITCH
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .off)
        XCTAssertFalse(state.isActive())
    }

    func test_transparentState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL
        channel.value = mockChannelValue(byte0: 0, byte1: 4, byte2: 2)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .transparent)
        XCTAssertTrue(state.isActive())
    }

    func test_opaqueState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL
        channel.value = mockChannelValue(byte0: 0, byte1: 4, byte2: 0)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opaque)
        XCTAssertFalse(state.isActive())
    }

    func test_dimmerAndRgb_ActiveActive() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        channel.value = mockChannelValue(byte0: 1, byte1: 1)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .complex([.on, .on]))
        XCTAssertFalse(state.isActive())
    }

    func test_dimmerAndRgb_ActiveInactive() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        channel.value = mockChannelValue(byte0: 1)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .complex([.on, .off]))
        XCTAssertFalse(state.isActive())
    }

    func test_dimmerAndRgb_InactiveActive() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        channel.value = mockChannelValue(byte1: 1)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .complex([.off, .on]))
        XCTAssertFalse(state.isActive())
    }

    func test_dimmerAndRgb_InactiveInactive() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .complex([.off, .off]))
        XCTAssertFalse(state.isActive())
    }

    func test_noneFunction_notUsedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_NONE
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .notUsed)
        XCTAssertFalse(state.isActive())
    }

    func test_hotelCard_on() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_HOTELCARDSENSOR
        channel.value = mockChannelValue(byte0: 1)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .on)
        XCTAssertTrue(state.isActive())
    }

    func test_hotelCard_off() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_HOTELCARDSENSOR
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .off)
        XCTAssertFalse(state.isActive())
    }

    func test_alarmArmament_on() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR
        channel.value = mockChannelValue(byte0: 1)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .on)
        XCTAssertTrue(state.isActive())
    }

    func test_alarmArmament_off() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_ALARMARMAMENTSENSOR
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .off)
        XCTAssertFalse(state.isActive())
    }

    func test_gate_offline() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_OPENINGSENSOR_GATE
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }

    func test_switch_offline() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_POWERSWITCH
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .off)
        XCTAssertFalse(state.isActive())
    }

    func test_dimmerAndRgb_offline() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .complex([.off, .off]))
        XCTAssertFalse(state.isActive())
    }

    func test_digiglass_offline() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_DIGIGLASS_HORIZONTAL
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opaque)
        XCTAssertFalse(state.isActive())
    }

    func test_terraceAwningClosedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_TERRACE_AWNING
        channel.value = mockChannelValue(byte0: 100)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }

    func test_terraceAwningOpenedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_TERRACE_AWNING
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }

    func test_terraceAwningOfflineState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_TERRACE_AWNING
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }
    
    func test_projectorScreenClosedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_PROJECTOR_SCREEN
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }

    func test_projectorScreenOpenedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_PROJECTOR_SCREEN
        channel.value = mockChannelValue(byte0: 100)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }

    func test_projectorScreenOfflineState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_PROJECTOR_SCREEN
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }
    
    func test_curtainScreenClosedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_CURTAIN
        channel.value = mockChannelValue(byte0: 100)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }

    func test_curtainOpenedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_CURTAIN
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }

    func test_curtainOfflineState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_CURTAIN
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }
    
    func test_verticalBlindClosedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_VERTICAL_BLIND
        channel.value = mockChannelValue(byte0: 100)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }

    func test_verticalBlindOpenedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_VERTICAL_BLIND
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }

    func test_verticalBlindOfflineState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_VERTICAL_BLIND
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }
    
    func test_garageDoorClosedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR
        channel.value = mockChannelValue(byte0: 100)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .closed)
        XCTAssertTrue(state.isActive())
    }

    func test_garageDoorOpenedState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR
        channel.value = mockChannelValue()

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }

    func test_garageDoorOfflineState() {
        // given
        let channel = SAChannel(testContext: nil)
        channel.func = SUPLA_CHANNELFNC_ROLLER_GARAGE_DOOR
        channel.value = mockChannelValue(online: false)

        // when
        let state = useCase.invoke(channelBase: channel)

        // then
        XCTAssertEqual(state, .opened)
        XCTAssertFalse(state.isActive())
    }
}
