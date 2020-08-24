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
#import "SAColorBrightnessPicker.h"

@interface SAColorBrightnessPickerTests : XCTestCase {
    SAColorBrightnessPicker *picker;
}

@end

@implementation SAColorBrightnessPickerTests

- (void)setUp {
    picker = [[SAColorBrightnessPicker alloc] init];
}

- (void)tearDown {
    picker = nil;
}

- (void)testColorWheelHiddenProperty {
    XCTAssertFalse(picker.colorWheelHidden);
    picker.colorWheelHidden = YES;
    XCTAssertTrue(picker.colorWheelHidden);
    picker.colorWheelHidden = NO;
    XCTAssertFalse(picker.colorWheelHidden);
}

- (void)testCircleInsteadArrowProperty {
    XCTAssertTrue(picker.circleInsteadArrow);
    picker.circleInsteadArrow = NO;
    XCTAssertFalse(picker.circleInsteadArrow);
    picker.circleInsteadArrow = YES;
    XCTAssertTrue(picker.circleInsteadArrow);
}

- (void)testColorfulBrightnessWheelProperty {
    XCTAssertTrue(picker.colorfulBrightnessWheel);
    picker.colorfulBrightnessWheel = NO;
    XCTAssertFalse(picker.colorfulBrightnessWheel);
    picker.colorfulBrightnessWheel = YES;
    XCTAssertTrue(picker.colorfulBrightnessWheel);
}

- (void)testSliderHiddenProperty {
    XCTAssertTrue(picker.sliderHidden);
    picker.sliderHidden = NO;
    XCTAssertFalse(picker.sliderHidden);
    picker.sliderHidden = YES;
    XCTAssertTrue(picker.sliderHidden);
}

- (void)testPowerButtonHiddenProperty {
    XCTAssertFalse(picker.powerButtonHidden);
    picker.powerButtonHidden = YES;
    XCTAssertTrue(picker.powerButtonHidden);
    picker.powerButtonHidden = NO;
    XCTAssertFalse(picker.powerButtonHidden);
}

- (void)testPowerButtonEnabledProperty {
    XCTAssertTrue(picker.powerButtonEnabled);
    picker.powerButtonEnabled = NO;
    XCTAssertFalse(picker.powerButtonEnabled);
    picker.powerButtonEnabled = YES;
    XCTAssertTrue(picker.powerButtonEnabled);
}

- (void)testPowerButtonOnProperty {
    XCTAssertFalse(picker.powerButtonOn);
    picker.powerButtonOn = YES;
    XCTAssertTrue(picker.powerButtonOn);
    picker.powerButtonOn = NO;
    XCTAssertFalse(picker.powerButtonOn);
}

- (void)testPowerButtonColorOnProperty {
    XCTAssertEqualObjects(picker.powerButtonColorOn, [UIColor whiteColor]);
    picker.powerButtonColorOn = nil;
    XCTAssertNotNil(picker.powerButtonColorOn);
    picker.powerButtonColorOn = [UIColor yellowColor];
    XCTAssertTrue([picker.powerButtonColorOn isEqual:[UIColor yellowColor]]);
}

- (void)testPowerButtonColorOffProperty {
    XCTAssertEqualObjects(picker.powerButtonColorOff, [UIColor colorWithRed: 0.25 green: 0.25 blue: 0.25 alpha: 1.00]);
    picker.powerButtonColorOff = nil;
    XCTAssertNotNil(picker.powerButtonColorOff);
    picker.powerButtonColorOff = [UIColor yellowColor];
    XCTAssertTrue([picker.powerButtonColorOff isEqual:[UIColor yellowColor]]);
}

- (void)testColorProperty {
    XCTAssertEqualObjects(picker.color, [UIColor colorWithRed:0 green:255 blue:0 alpha:1]);
    picker.color= nil;
    XCTAssertNotNil(picker.color);
    picker.color = [UIColor yellowColor];
    XCTAssertTrue([picker.color isEqual:[UIColor yellowColor]]);
}

- (void)testBrightnessProperty {
    XCTAssertEqual(picker.brightness, 0.0);
    picker.brightness = 55.54;
    XCTAssertEqualWithAccuracy(picker.brightness, 55.54, 0.001);
    picker.brightness = -1;
    XCTAssertEqual(picker.brightness, 0.0);
    picker.brightness = 80.88;
    XCTAssertEqualWithAccuracy(picker.brightness, 80.88, 0.001);
    picker.brightness = 110;
    XCTAssertEqual(picker.brightness, 100);
}

- (void)testMinBrightnessProperty {
    XCTAssertEqual(picker.minBrightness, 0.0);
    picker.minBrightness = 55.54;
    XCTAssertEqualWithAccuracy(picker.minBrightness, 55.54, 0.001);
    picker.minBrightness = -1;
    XCTAssertEqual(picker.minBrightness, 0.0);
    picker.minBrightness = 80.88;
    XCTAssertEqualWithAccuracy(picker.minBrightness, 80.88, 0.001);
    picker.minBrightness = 110;
    XCTAssertEqual(picker.minBrightness, 100);
}

- (void)testMovingProperty {
    XCTAssertFalse(picker.moving);
}

- (void)testBrightnessMarkersProperty {
    XCTAssertNil(picker.brightnessMarkers);
    
    picker.brightnessMarkers = @[[NSNumber numberWithFloat:0],
                                [NSNumber numberWithFloat:10.0],
                                [NSNumber numberWithFloat:50.0],
                                [NSNumber numberWithFloat:90.0],
                                [NSNumber numberWithFloat:100.0]
    ];
    
    XCTAssertNotNil(picker.brightnessMarkers);
    XCTAssertEqual(picker.brightnessMarkers.count, 5);
    picker.brightnessMarkers = nil;
    XCTAssertNil(picker.brightnessMarkers);
}

- (void)testColorMarkersProperty {
    XCTAssertNil(picker.colorMarkers);
    
    picker.colorMarkers = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor]];
    
    XCTAssertNotNil(picker.colorMarkers);
    XCTAssertEqual(picker.colorMarkers.count, 3);
    picker.colorMarkers = nil;
    XCTAssertNil(picker.colorMarkers);
}

- (void)testJumpToThePointOfTouchEnabledProperty {
    XCTAssertTrue(picker.jumpToThePointOfTouchEnabled);
    picker.jumpToThePointOfTouchEnabled = NO;
    XCTAssertFalse(picker.jumpToThePointOfTouchEnabled);
    picker.jumpToThePointOfTouchEnabled = YES;
    XCTAssertTrue(picker.jumpToThePointOfTouchEnabled);
}
@end
