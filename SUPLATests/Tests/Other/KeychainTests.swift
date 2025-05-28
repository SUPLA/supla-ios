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

final class KeychainTests: XCTestCase {
    
    func testKeychainStorage() {
        let string = "ABCDEFGH"
        _ = SAKeychain.deleteObject(withKey: "1")
        XCTAssertFalse(SAKeychain.deleteObject(withKey: "1"))
        XCTAssertNil(SAKeychain.getObjectWithKey("1"))
        XCTAssertTrue(SAKeychain.add(string.data(using: .utf8)!, withKey: "1"))
        XCTAssertFalse(SAKeychain.add("XYZ".data(using: .utf8)!, withKey: "1"))
        XCTAssertNil(SAKeychain.getObjectWithKey("2"))
        let result = SAKeychain.getObjectWithKey("1")
        XCTAssertNotNil(result)
        XCTAssertEqual(string, String(data: result!, encoding: .utf8))
        XCTAssertTrue(SAKeychain.deleteObject(withKey: "1"))
    }
}
