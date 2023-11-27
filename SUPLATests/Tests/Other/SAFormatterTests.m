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
#import "SAFormatter.h"

@interface SAFormatterTests : XCTestCase

@end

@implementation SAFormatterTests {
    SAFormatter *formatter;
    NSString *separator;
}

- (void)setUp {
    formatter = [[SAFormatter alloc] init];
    separator = [formatter doubleToString:1.2 withUnit:nil maxPrecision:2];
    separator = [separator isEqual:@"1,2"] ? @"," : @".";
    separator = @".";
}

- (void)tearDown {
    formatter = nil;
}

- (void)testDoubleToStringConversionWithUnit {

    NSString *expected = [NSString stringWithFormat:@"%@%@%@", @"321", separator, @"00"];
    XCTAssertEqualObjects(expected,
                   [formatter doubleToString:321.000000001 withUnit:nil maxPrecision:2]);
    
    expected = @"321";
    XCTAssertEqualObjects(expected,
                   [formatter doubleToString:321.000000001 withUnit:nil maxPrecision:0]);
    
    expected = [NSString stringWithFormat:@"%@%@%@", @"321", separator, @"000000001"];
    XCTAssertEqualObjects(expected,
                   [formatter doubleToString:321.000000001 withUnit:nil maxPrecision:15]);

    expected = [NSString stringWithFormat:@"%@%@%@", @"321", separator, @"000000001"];
    XCTAssertEqualObjects(expected,
                   [formatter doubleToString:321.000000001 withUnit:nil maxPrecision:9]);

    expected = [NSString stringWithFormat:@"%@%@%@", @"321", separator, @"000000001"];
    XCTAssertEqualObjects(expected,
                   [formatter doubleToString:321.00000000101 withUnit:nil maxPrecision:9]);

    expected = [NSString stringWithFormat:@"%@%@%@", @"0", separator, @"00"];
    XCTAssertEqualObjects(expected,
                   [formatter doubleToString:0 withUnit:nil maxPrecision:10]);

    expected = [NSString stringWithFormat:@"%@%@%@", @"321", separator, @"00"];
    XCTAssertEqualObjects(expected,
                   [formatter doubleToString:321 withUnit:nil maxPrecision:10]);
}

@end
