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
#import "SADigiglassController.h"

@interface SADigiglassControllerTests : XCTestCase <SADigiglassControllerDelegate>
@end

@implementation SADigiglassControllerTests {
    SADigiglassController *controller;
}

- (void)setUp {
    controller = [[SADigiglassController alloc] init];
}

- (void)tearDown {
    controller = nil;
}

- (void)testBarColorProperty {
    XCTAssertEqualObjects(controller.barColor, [UIColor whiteColor]);
    controller.barColor = nil;
    XCTAssertNotNil(controller.barColor);
    controller.barColor = [UIColor yellowColor];
    XCTAssertTrue([controller.barColor isEqual:[UIColor yellowColor]]);
}

- (void)testLineColorProperty {
    XCTAssertEqualObjects(controller.lineColor, [UIColor blackColor]);
    controller.lineColor = nil;
    XCTAssertNotNil(controller.lineColor);
    controller.lineColor = [UIColor yellowColor];
    XCTAssertTrue([controller.lineColor isEqual:[UIColor yellowColor]]);
}

- (void)testDotColorProperty {
    XCTAssertEqualObjects(controller.dotColor, [UIColor blackColor]);
    controller.dotColor = nil;
    XCTAssertNotNil(controller.dotColor);
    controller.dotColor = [UIColor yellowColor];
    XCTAssertTrue([controller.dotColor isEqual:[UIColor yellowColor]]);
}

- (void)testGlsssColorProperty {
    XCTAssertEqualObjects(controller.glassColor, [UIColor colorWithRed: 0.74 green: 0.85 blue: 0.95 alpha: 1.00]);
    controller.glassColor = nil;
    XCTAssertNotNil(controller.glassColor);
    controller.glassColor = [UIColor yellowColor];
    XCTAssertTrue([controller.glassColor isEqual:[UIColor yellowColor]]);
}

- (void)testBtnBackgroundColorProperty {
    XCTAssertEqualObjects(controller.btnBackgroundColor, [UIColor whiteColor]);
    controller.btnBackgroundColor = nil;
    XCTAssertNotNil(controller.btnBackgroundColor);
    controller.btnBackgroundColor = [UIColor yellowColor];
    XCTAssertTrue([controller.btnBackgroundColor isEqual:[UIColor yellowColor]]);
}

- (void)testDelegateProperty {
    XCTAssertNil(controller.delegate);
    controller.delegate = self;
    XCTAssertEqualObjects(controller.delegate, self);
    controller.delegate = nil;
    XCTAssertNil(controller.delegate);
}

- (void)testHorizontalProperty {
    XCTAssertFalse(controller.vertical);
    controller.vertical = YES;
    XCTAssertTrue(controller.vertical);
    controller.vertical = NO;
    XCTAssertFalse(controller.vertical);
}

- (void)testLineWidthProperty {
    XCTAssertEqualWithAccuracy(controller.lineWidth, 2.0, 0);
    controller.lineWidth = 1;
    XCTAssertEqualWithAccuracy(controller.lineWidth, 1.0, 0);
    controller.lineWidth = 0;
    XCTAssertEqualWithAccuracy(controller.lineWidth, 0.1, 0.1);
    controller.lineWidth = 21;
    XCTAssertEqualWithAccuracy(controller.lineWidth, 20, 0);
}

-(void)testSections {
    XCTAssertEqualWithAccuracy(controller.sectionCount, 7, 0);
    controller.sectionCount = 8;
    XCTAssertEqualWithAccuracy(controller.sectionCount, 7, 0);
    controller.sectionCount = 0;
    XCTAssertEqualWithAccuracy(controller.sectionCount, 1, 0);
    controller.sectionCount = 5;
    XCTAssertEqualWithAccuracy(controller.sectionCount, 5, 0);
    
    controller.transparentSections = 1;
    XCTAssertNotEqualWithAccuracy(controller.transparentSections, 0, 0);
    [controller setAllOpaque];
    XCTAssertEqualWithAccuracy(controller.transparentSections, 0, 0);
    [controller setAllTransparent];
    XCTAssertEqualWithAccuracy(controller.transparentSections, 31, 0);
    controller.sectionCount = 7;
    XCTAssertEqualWithAccuracy(controller.transparentSections, 31, 0);
    [controller setAllTransparent];
    XCTAssertEqualWithAccuracy(controller.transparentSections, 127, 0);
    controller.sectionCount = 1;
    XCTAssertEqualWithAccuracy(controller.transparentSections, 1, 0);
    controller.sectionCount = 2;
    
    XCTAssertTrue([controller isSectionTransparent:0]);
    XCTAssertFalse([controller isSectionTransparent:2]);
    
    controller.sectionCount = 6;
    controller.transparentSections = 101;
    XCTAssertEqualWithAccuracy(controller.transparentSections, 37, 0);
}

- (void)digiglassSectionTouched:(nonnull id)digiglassController sectionNumber:(int)number isTransparent:(BOOL)transparent {
}

@end
