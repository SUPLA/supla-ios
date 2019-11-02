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

#import <XCTest/XCTest.h>
#import "SAKeychain.h"

@interface KeychainTests : XCTestCase
@end

@implementation KeychainTests

- (void)testKeychainStorage {
    NSString *source = @"ABCDEFGH";
    [SAKeychain deleteObjectWithKey:@"1"];
    XCTAssertFalse([SAKeychain deleteObjectWithKey:@"1"]);
    XCTAssertNil([SAKeychain getObjectWithKey:@"1"]);
    XCTAssertTrue([SAKeychain addObject:source withKey:@"1"]);
    XCTAssertFalse([SAKeychain addObject:@"XYZ" withKey:@"1"]);
    XCTAssertNil([SAKeychain getObjectWithKey:@"2"]);
    NSString *dest = [SAKeychain getObjectWithKey:@"1"];
    XCTAssertNotNil(dest);
    XCTAssertTrue([source isEqualToString:dest]);
    XCTAssertTrue([SAKeychain deleteObjectWithKey:@"1"]);
}

@end
