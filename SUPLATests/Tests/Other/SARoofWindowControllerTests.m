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
#import "SARoofWindowController.h"

@interface SARoofWindowControllerTests : XCTestCase {
    SARoofWindowController *roofWindowController;
}
@end

@implementation SARoofWindowControllerTests

- (void)setUp {
    roofWindowController = [[SARoofWindowController alloc] init];
}

- (void)tearDown {
    roofWindowController = nil;
}

- (void)testFrameColorProperty {
    XCTAssertEqualObjects(roofWindowController.frameColor, [UIColor whiteColor]);
    roofWindowController.frameColor = nil;
    XCTAssertNotNil(roofWindowController.frameColor);
    roofWindowController.frameColor = [UIColor yellowColor];
    XCTAssertTrue([roofWindowController.frameColor isEqual:[UIColor yellowColor]]);
}

- (void)testLineColorProperty {
    XCTAssertEqualObjects(roofWindowController.lineColor, [UIColor blackColor]);
    roofWindowController.lineColor = nil;
    XCTAssertNotNil(roofWindowController.lineColor);
    roofWindowController.lineColor = [UIColor yellowColor];
    XCTAssertTrue([roofWindowController.lineColor isEqual:[UIColor yellowColor]]);
}

- (void)testGlassColorProperty {
    XCTAssertEqualObjects(roofWindowController.glassColor, [UIColor colorWithRed: 0.75 green: 0.85 blue: 0.95 alpha: 1.00]);
    roofWindowController.glassColor = nil;
    XCTAssertNotNil(roofWindowController.glassColor);
    roofWindowController.glassColor = [UIColor yellowColor];
    XCTAssertTrue([roofWindowController.glassColor isEqual:[UIColor yellowColor]]);
}

- (void)testMarkerColorProperty {
    XCTAssertEqualObjects(roofWindowController.markerColor, [UIColor colorWithRed: 0.75 green: 0.85 blue: 0.95 alpha: 1.00]);
    roofWindowController.markerColor = nil;
    XCTAssertNotNil(roofWindowController.markerColor);
    roofWindowController.markerColor = [UIColor yellowColor];
    XCTAssertTrue([roofWindowController.markerColor isEqual:[UIColor yellowColor]]);
}

- (void)testOpeningPercentageProperty {
    XCTAssertEqual(roofWindowController.closingPercentage, 0);
    roofWindowController.closingPercentage = 55.55f;
    XCTAssertEqualWithAccuracy(roofWindowController.closingPercentage, 55.55, 0.001);
    roofWindowController.closingPercentage = -1;
    XCTAssertEqual(roofWindowController.closingPercentage, 0);
    roofWindowController.closingPercentage = 110;
    XCTAssertEqual(roofWindowController.closingPercentage, 100);
}

- (void)testMarkerProperty {
    XCTAssertNil(roofWindowController.markers);
    roofWindowController.markers = @[
        [NSNumber numberWithFloat:-1],
        [NSNumber numberWithFloat:10.55],
        [NSNumber numberWithFloat:40.20],
        [NSNumber numberWithFloat:60.70],
        [NSNumber numberWithFloat:110]
    ];
    
    XCTAssertNotNil(roofWindowController.markers);
    XCTAssertEqual(roofWindowController.markers.count, 5);
    XCTAssertEqual([[roofWindowController.markers objectAtIndex:0] floatValue], 0);
    XCTAssertEqualWithAccuracy([[roofWindowController.markers objectAtIndex:1] floatValue], 10.55, 0.001);
    XCTAssertEqualWithAccuracy([[roofWindowController.markers objectAtIndex:2] floatValue], 40.20, 0.001);
    XCTAssertEqualWithAccuracy([[roofWindowController.markers objectAtIndex:3] floatValue], 60.70, 0.001);
    XCTAssertEqual([[roofWindowController.markers objectAtIndex:4] floatValue], 100);
}

@end
