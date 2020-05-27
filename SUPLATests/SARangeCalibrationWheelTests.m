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
    XCTAssertEqualObjects(calibrationWheel.wheelColor, [UIColor colorWithRed: 0.69 green: 0.67 blue: 0.67 alpha: 1.00]);
    calibrationWheel.wheelColor = nil;
    XCTAssertNotNil(calibrationWheel.wheelColor);
    calibrationWheel.wheelColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.wheelColor isEqual:[UIColor yellowColor]]);
}

- (void)testBorderColorProperty {
    XCTAssertEqualObjects(calibrationWheel.btnColor, [UIColor colorWithRed: 0.34 green: 0.34 blue: 0.34 alpha: 1.00]);
    calibrationWheel.borderColor = nil;
    XCTAssertNotNil(calibrationWheel.borderColor);
    calibrationWheel.borderColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.borderColor isEqual:[UIColor yellowColor]]);
}

- (void)testBtnColorProperty {
    XCTAssertEqualObjects(calibrationWheel.btnColor, [UIColor colorWithRed: 0.34 green: 0.34 blue: 0.34 alpha: 1.00]);
    calibrationWheel.btnColor = nil;
    XCTAssertNotNil(calibrationWheel.btnColor);
    calibrationWheel.btnColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.btnColor isEqual:[UIColor yellowColor]]);
}

- (void)testRangeColorProperty {
    XCTAssertEqualObjects(calibrationWheel.rangeColor, [UIColor colorWithRed: 1.00 green: 0.90 blue: 0.09 alpha: 1.00]);
    calibrationWheel.rangeColor = nil;
    XCTAssertNotNil(calibrationWheel.rangeColor);
    calibrationWheel.rangeColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.rangeColor isEqual:[UIColor yellowColor]]);
}

- (void)testInsideBtnColorProperty {
    XCTAssertEqualObjects(calibrationWheel.insideBtnColor, [UIColor whiteColor]);
    calibrationWheel.insideBtnColor = nil;
    XCTAssertNotNil(calibrationWheel.insideBtnColor);
    calibrationWheel.insideBtnColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.insideBtnColor isEqual:[UIColor yellowColor]]);
}

- (void)testBoostLineColorProperty {
    XCTAssertEqualObjects(calibrationWheel.boostLineColor, [UIColor colorWithRed: 0.07 green: 0.65 blue: 0.12 alpha: 1.00]);
    calibrationWheel.boostLineColor = nil;
    XCTAssertNotNil(calibrationWheel.boostLineColor);
    calibrationWheel.boostLineColor = [UIColor yellowColor];
    XCTAssertTrue([calibrationWheel.boostLineColor isEqual:[UIColor yellowColor]]);
}

- (void)testBorderLineWidthProperty {
    XCTAssertEqual(calibrationWheel.borderLineWidth, 1.5);
    
    calibrationWheel.borderLineWidth = 0;
    XCTAssertGreaterThan(calibrationWheel.borderLineWidth, 0);
    calibrationWheel.borderLineWidth = 11.22;
    XCTAssertEqual(calibrationWheel.borderLineWidth, 11.22);
}

- (void)testMaximumValueProperty {
    XCTAssertEqual(calibrationWheel.maximumValue, 1000);
    
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
    XCTAssertEqual(calibrationWheel.minimumRange, 100);
    
    calibrationWheel.maximumValue = 1000;
    calibrationWheel.minimumRange = 0;
    calibrationWheel.leftEdge = 500;
    calibrationWheel.rightEdge = 600;
    
    XCTAssertEqual(calibrationWheel.minimumRange, 0);
    XCTAssertEqual(calibrationWheel.leftEdge, 500);
    XCTAssertEqual(calibrationWheel.rightEdge, 600);
    XCTAssertEqual(calibrationWheel.minimum, 500);
    XCTAssertEqual(calibrationWheel.maximum, 600);
    
    calibrationWheel.minimumRange = 200;
    
    XCTAssertEqual(calibrationWheel.minimumRange, 200);
    
    XCTAssertEqual(calibrationWheel.leftEdge, 450);
    XCTAssertEqual(calibrationWheel.rightEdge, 650);
    XCTAssertEqual(calibrationWheel.minimum, 450);
    XCTAssertEqual(calibrationWheel.maximum, 650);

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

    XCTAssertEqual(calibrationWheel.minimum, 400);
    XCTAssertEqual(calibrationWheel.maximum, 600);
    
    XCTAssertEqual(calibrationWheel.leftEdge, 100);
    XCTAssertEqual(calibrationWheel.rightEdge, 900);

    XCTAssertGreaterThanOrEqual(calibrationWheel.maximum-calibrationWheel.minimum, calibrationWheel.minimumRange);
    XCTAssertLessThan(calibrationWheel.maximum-calibrationWheel.minimum, calibrationWheel.maximumValue);
}

-(void)testNumberOfTurnsProperty {
    XCTAssertEqual(calibrationWheel.numerOfTurns, 5);
    calibrationWheel.numerOfTurns = 0;
    XCTAssertEqual(calibrationWheel.numerOfTurns, 1);
    calibrationWheel.numerOfTurns = 10;
    XCTAssertEqual(calibrationWheel.numerOfTurns, 10);
}

-(void)testMinimumProperty {
    XCTAssertEqual(calibrationWheel.minimum, calibrationWheel.leftEdge);
    
    calibrationWheel.minimum = 300;
    calibrationWheel.maximum = 600;
    
    XCTAssertEqual(calibrationWheel.minimum, 300);
    XCTAssertEqual(calibrationWheel.maximum, 600);
    
    calibrationWheel.minimum = 1000;
    XCTAssertEqual(calibrationWheel.minimum, calibrationWheel.maximum - calibrationWheel.minimumRange);
    
    calibrationWheel.leftEdge = 200;
    calibrationWheel.minimum = -10;
    XCTAssertEqual(calibrationWheel.minimum, calibrationWheel.leftEdge);
    
    calibrationWheel.leftEdge = 0;
    calibrationWheel.minimum = -10;
    XCTAssertEqual(calibrationWheel.minimum, 0);
}

-(void)testMaximumProperty {
    XCTAssertEqual(calibrationWheel.maximum, calibrationWheel.rightEdge);
    
    calibrationWheel.minimum = 300;
    calibrationWheel.maximum = 600;
    calibrationWheel.rightEdge = 700;
    calibrationWheel.maximum = calibrationWheel.rightEdge + 10;
    XCTAssertEqual(calibrationWheel.maximum, calibrationWheel.rightEdge);
    
    calibrationWheel.maximum = 0;
    XCTAssertEqual(calibrationWheel.maximum, calibrationWheel.minimum + calibrationWheel.minimumRange);
    
    calibrationWheel.maximum = 800;
    XCTAssertEqual(calibrationWheel.maximum, calibrationWheel.rightEdge);
}

-(void)testLeftEdgeProperty {
    XCTAssertEqual(calibrationWheel.leftEdge, 0);
    
    calibrationWheel.leftEdge = 100;
    calibrationWheel.rightEdge = 300;
    calibrationWheel.minimum = 100;
    calibrationWheel.maximum = 300;
    calibrationWheel.minimumRange = 200;
    
    XCTAssertEqual(calibrationWheel.leftEdge, 100);
    XCTAssertEqual(calibrationWheel.rightEdge, 300);
    XCTAssertEqual(calibrationWheel.minimum, 100);
    XCTAssertEqual(calibrationWheel.maximum, 300);
    XCTAssertEqual(calibrationWheel.minimumRange, 200);
    
    calibrationWheel.leftEdge = 200;
    
    XCTAssertEqual(calibrationWheel.leftEdge, 200);
    XCTAssertEqual(calibrationWheel.rightEdge, 400);
    XCTAssertEqual(calibrationWheel.minimum, 200);
    XCTAssertEqual(calibrationWheel.maximum, 400);
    
    calibrationWheel.leftEdge = calibrationWheel.maximumValue + 10;
    XCTAssertEqual(calibrationWheel.leftEdge, calibrationWheel.maximumValue-calibrationWheel.minimumRange);
    XCTAssertEqual(calibrationWheel.rightEdge, calibrationWheel.maximumValue);
    XCTAssertEqual(calibrationWheel.minimum, calibrationWheel.leftEdge);
    XCTAssertEqual(calibrationWheel.maximum, calibrationWheel.rightEdge);
    
    calibrationWheel.leftEdge = -10;
    XCTAssertEqual(calibrationWheel.leftEdge, 0);
}

-(void)testRightEdgeProperty {
    XCTAssertEqual(calibrationWheel.rightEdge, calibrationWheel.maximumValue);
    
    calibrationWheel.leftEdge = 100;
    calibrationWheel.rightEdge = 300;
    calibrationWheel.minimum = 100;
    calibrationWheel.maximum = 300;
    calibrationWheel.minimumRange = 200;
    
    XCTAssertEqual(calibrationWheel.leftEdge, 100);
    XCTAssertEqual(calibrationWheel.rightEdge, 300);
    XCTAssertEqual(calibrationWheel.minimum, 100);
    XCTAssertEqual(calibrationWheel.maximum, 300);
    XCTAssertEqual(calibrationWheel.minimumRange, 200);
    
    calibrationWheel.rightEdge = calibrationWheel.maximumValue + 10;
    XCTAssertEqual(calibrationWheel.rightEdge, calibrationWheel.maximumValue);
    
    XCTAssertEqual(calibrationWheel.leftEdge, 100);
    calibrationWheel.rightEdge = -10;
    XCTAssertEqual(calibrationWheel.rightEdge, calibrationWheel.minimumRange);
    XCTAssertEqual(calibrationWheel.leftEdge, 0);
    XCTAssertEqual(calibrationWheel.minimum, calibrationWheel.leftEdge);
    XCTAssertEqual(calibrationWheel.maximum, calibrationWheel.rightEdge);
}

-(void)testBoostLevelProperty {
    XCTAssertEqual(calibrationWheel.leftEdge, 0);
    XCTAssertEqual(calibrationWheel.minimum, 0);
    XCTAssertEqual(calibrationWheel.boostLevel, 0);
    
    calibrationWheel.leftEdge = 400;
    XCTAssertEqual(calibrationWheel.boostLevel, 400);
    
    calibrationWheel.leftEdge = 0;
    XCTAssertEqual(calibrationWheel.boostLevel, 400);
    
    calibrationWheel.rightEdge = 0;
    XCTAssertEqual(calibrationWheel.boostLevel, 100);
    
    calibrationWheel.boostLevel = -1;
    XCTAssertEqual(calibrationWheel.boostLevel, 0);
    
    calibrationWheel.boostLevel = 200;
    XCTAssertEqual(calibrationWheel.boostLevel, 100);
}

-(void)testBoostHiddenProperty {
    XCTAssertEqual(calibrationWheel.boostHidden, YES);
    calibrationWheel.boostHidden = NO;
    XCTAssertEqual(calibrationWheel.boostHidden, NO);
}

-(void)testBoostLineHeightFactorProperty {
    XCTAssertEqual(calibrationWheel.boostLineHeightFactor, (float)1.8);
    calibrationWheel.boostLineHeightFactor = 0;
    XCTAssertEqual(calibrationWheel.boostLineHeightFactor, (float)1.8);
    calibrationWheel.boostLineHeightFactor = 1.1;
    XCTAssertEqual(calibrationWheel.boostLineHeightFactor, (float)1.1);
    calibrationWheel.boostLineHeightFactor = 2.1;
    XCTAssertEqual(calibrationWheel.boostLineHeightFactor, (float)1.1);

}


@end
