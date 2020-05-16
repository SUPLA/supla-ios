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
#import "SARangeCalibrationWheel.h"

@interface SARangeCalibrationWheelTests : XCTestCase {
    SARangeCalibrationWheel *calibrationWheel;
}

@end

@implementation SARangeCalibrationWheelTests

- (void)setUp {
    calibrationWheel = [[SARangeCalibrationWheel alloc] init];
}

- (void)tearDown {
    calibrationWheel = nil;
}

- (void)testWheelColorProperty {
    calibrationWheel.wheelColor = nil;
    XCTAssertNotNil(calibrationWheel.wheelColor);
    calibrationWheel.wheelColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.wheelColor isEqual:[UIColor yellowColor]]);
}

- (void)testBorderColorProperty {
    calibrationWheel.borderColor = nil;
    XCTAssertNotNil(calibrationWheel.borderColor);
    calibrationWheel.borderColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.borderColor isEqual:[UIColor yellowColor]]);
}

- (void)testBtnColorProperty {
    calibrationWheel.btnColor = nil;
    XCTAssertNotNil(calibrationWheel.btnColor);
    calibrationWheel.btnColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.btnColor isEqual:[UIColor yellowColor]]);
}

- (void)testRangeColorProperty {
    calibrationWheel.rangeColor = nil;
    XCTAssertNotNil(calibrationWheel.rangeColor);
    calibrationWheel.rangeColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.rangeColor isEqual:[UIColor yellowColor]]);
}

- (void)testInsideBtnColorProperty {
    calibrationWheel.insideBtnColor = nil;
    XCTAssertNotNil(calibrationWheel.insideBtnColor);
    calibrationWheel.insideBtnColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.insideBtnColor isEqual:[UIColor yellowColor]]);
}

- (void)testBoostLineColorProperty {
    calibrationWheel.boostLineColor = nil;
    XCTAssertNotNil(calibrationWheel.boostLineColor);
    calibrationWheel.boostLineColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.boostLineColor isEqual:[UIColor yellowColor]]);
}

- (void)testBorderLineWidthProperty {
    calibrationWheel.borderLineWidth = 0;
    XCTAssertGreaterThan(calibrationWheel.borderLineWidth, 0);
    calibrationWheel.borderLineWidth = 11.22;
    XCTAssertEqual(calibrationWheel.borderLineWidth, 11.22);
}

- (void)testMaximumValueProperty {
    calibrationWheel.maximumValue = 0;
    XCTAssertEqual(calibrationWheel.maximumValue, calibrationWheel.minimumRange);
    XCTAssertEqual(calibrationWheel.minimum, 0);
    XCTAssertEqual(calibrationWheel.leftEdge, 0);
    XCTAssertEqual(calibrationWheel.maximum, calibrationWheel.minimumRange);
    XCTAssertEqual(calibrationWheel.rightEdge, calibrationWheel.minimumRange);
    
    calibrationWheel.maximumValue = 1500;
    calibrationWheel.rightEdge = 1500;
    calibrationWheel.maximum = 1500;
    calibrationWheel.minimum = 1000;
    
    XCTAssertEqual(calibrationWheel.maximumValue, 1500);
    
    calibrationWheel.maximumValue = 500;
    
    XCTAssertEqual(calibrationWheel.maximumValue, 500);
    XCTAssertEqual(calibrationWheel.rightEdge, 500);
    XCTAssertEqual(calibrationWheel.maximum, 500);
    XCTAssertEqual(calibrationWheel.minimum, calibrationWheel.maximum-calibrationWheel.minimumRange);
}

-(void)testMinimumRangeProperty {
    calibrationWheel.maximumValue = 1000;
    calibrationWheel.minimumRange = 0;
    calibrationWheel.leftEdge = 500;
    calibrationWheel.rightEdge = 600;
    
    XCTAssertEqual(calibrationWheel.leftEdge, 500);
    XCTAssertEqual(calibrationWheel.rightEdge, 600);
    XCTAssertEqual(calibrationWheel.minimum, 500);
    XCTAssertEqual(calibrationWheel.maximum, 600);
    
    calibrationWheel.minimumRange = 200;
    
    XCTAssertNotEqual(calibrationWheel.leftEdge, 500);
    XCTAssertNotEqual(calibrationWheel.rightEdge, 600);
    XCTAssertNotEqual(calibrationWheel.minimum, 500);
    XCTAssertNotEqual(calibrationWheel.maximum, 600);

    XCTAssertGreaterThanOrEqual(calibrationWheel.rightEdge-calibrationWheel.leftEdge, calibrationWheel.minimumRange);
    XCTAssertLessThan(calibrationWheel.rightEdge-calibrationWheel.leftEdge, calibrationWheel.maximumValue);
    XCTAssertGreaterThanOrEqual(calibrationWheel.maximum-calibrationWheel.minimum, calibrationWheel.minimumRange);
    XCTAssertLessThan(calibrationWheel.maximum-calibrationWheel.minimum, calibrationWheel.maximumValue);

    calibrationWheel.minimumRange = calibrationWheel.maximumValue+1;
    
    XCTAssertEqual(calibrationWheel.minimumRange, calibrationWheel.maximumValue);
    XCTAssertEqual(calibrationWheel.leftEdge, 0);
    XCTAssertEqual(calibrationWheel.rightEdge, calibrationWheel.maximumValue);
    XCTAssertEqual(calibrationWheel.minimum, 0);
    XCTAssertEqual(calibrationWheel.maximum, calibrationWheel.maximumValue);
    
    calibrationWheel.minimumRange = 0;
    calibrationWheel.leftEdge = 100;
    calibrationWheel.rightEdge = 900;
    calibrationWheel.maximum= 500;
    calibrationWheel.minimum = 500;
    
    XCTAssertEqual(calibrationWheel.leftEdge, 100);
    XCTAssertEqual(calibrationWheel.rightEdge, 900);
    XCTAssertEqual(calibrationWheel.minimum, 500);
    XCTAssertEqual(calibrationWheel.maximum, 500);
    
    calibrationWheel.minimumRange = 200;
    
    XCTAssertEqual(calibrationWheel.leftEdge, 100);
    XCTAssertEqual(calibrationWheel.rightEdge, 900);
    
    XCTAssertNotEqual(calibrationWheel.minimum, 500);
    XCTAssertNotEqual(calibrationWheel.maximum, 500);
    
    XCTAssertGreaterThanOrEqual(calibrationWheel.maximum-calibrationWheel.minimum, calibrationWheel.minimumRange);
    XCTAssertLessThan(calibrationWheel.maximum-calibrationWheel.minimum, calibrationWheel.maximumValue);
    
    calibrationWheel.leftEdge = 200;
    calibrationWheel.rightEdge = 300;
    
    XCTAssertEqual(calibrationWheel.leftEdge, 100);
    XCTAssertEqual(calibrationWheel.rightEdge, 300);
    XCTAssertEqual(calibrationWheel.minimum, 100);
    XCTAssertEqual(calibrationWheel.maximum, 300);
    
    calibrationWheel.leftEdge = 200;
    
    XCTAssertEqual(calibrationWheel.leftEdge, 200);
    XCTAssertEqual(calibrationWheel.rightEdge, 400);
    XCTAssertEqual(calibrationWheel.minimum, 200);
    XCTAssertEqual(calibrationWheel.maximum, 400);
    
}

-(void)testNumberOfTurnsProperty {
    calibrationWheel.numerOfTurns = 0;
    XCTAssertEqual(calibrationWheel.numerOfTurns, 1);
    calibrationWheel.numerOfTurns = 10;
    XCTAssertEqual(calibrationWheel.numerOfTurns, 10);
}

-(void)testMinimumProperty {
    
}

/*
 @property (nonatomic) double minimum;
 @property (nonatomic) double maximum;
 @property (nonatomic) double leftEdge;
 @property (nonatomic) double rightEdge;
 @property (nonatomic) double boostLevel;
 @property (nonatomic) BOOL boostHidden;
 */


@end
