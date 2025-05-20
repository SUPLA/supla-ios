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

final class AutAuthProfileItemTokenTests: XCTestCase {
    
    func test_checkIfTokenIsProperlyInitialized() {
        // given
        let tokenBytes: [Int8] = [0x53, 0x75, 0x70, 0x6c, 0x61]
        let tokenData = Data(bytes: tokenBytes, count: 5)
        let name = "Test name"
        let profile = AuthProfileItem(testContext: nil)
        profile.name = name
        
        // when
        let token = profile.token(tokenData)
        
        // then
        XCTAssertEqual(token.AppId, SINGLE_CALL_APP_ID)
        XCTAssertEqual(token.Platform, PLATFORM_IOS)
        XCTAssertEqual(token.DevelopmentEnv, 1)
        XCTAssertTuple(Mirror(reflecting: token.ProfileName), name)
        XCTAssertTupleHex(Mirror(reflecting: token.Token), "Supla")
        XCTAssertEqual(token.TokenSize, 11)
        XCTAssertEqual(token.RealTokenSize, 11)
    }
    
    func test_checkIfLongerTokenIsProperlyInitialized() {
        let tokenBytes: [Int8] = .init(repeating: 1, count: Int(SUPLA_PN_CLIENT_TOKEN_MAXSIZE) + 10)
        let tokenData = Data(bytes: tokenBytes, count: tokenBytes.count)
        let name = "Test name"
        let profile = AuthProfileItem(testContext: nil)
        profile.name = name
        
        // when
        let token = profile.token(tokenData)
        
        // then
        let tokenString = "0101010101010101010101010101010101010101010101010101010101" +
            "010101010101010101010101010101010101010101010101010101010101010101010101" +
            "010101010101010101010101010101010101010101010101010101010101010101010101" +
            "01010101010101010101010101010101010101010101010101010"
        XCTAssertEqual(token.AppId, SINGLE_CALL_APP_ID)
        XCTAssertEqual(token.Platform, PLATFORM_IOS)
        XCTAssertEqual(token.DevelopmentEnv, 1)
        XCTAssertTuple(Mirror(reflecting: token.ProfileName), name)
        XCTAssertTuple(Mirror(reflecting: token.Token), tokenString)
        XCTAssertEqual(token.TokenSize, 256)
        XCTAssertEqual(token.RealTokenSize, 533)
    }
}
