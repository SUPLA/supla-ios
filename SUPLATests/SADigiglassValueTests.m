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
#import "SADigiglassValue.h"
#import "proto.h"

@interface SADigiglassValueTests : XCTestCase

@end

@implementation SADigiglassValueTests

-(void)testNil {
    SADigiglassValue *value = [[SADigiglassValue alloc] initWithData:nil];
    XCTAssertEqual(0, value.flags);
    XCTAssertEqual(0, value.mask);
    XCTAssertEqual(0, value.sectionCount);
    
    value = [[SADigiglassValue alloc] init];
    XCTAssertEqual(0, value.flags);
    XCTAssertEqual(0, value.mask);
    XCTAssertEqual(0, value.sectionCount);
}

-(void)testIncorrectLength {
    char v[] = {1};
    NSData *data = [NSData dataWithBytes:v length:1];
    
    SADigiglassValue *value = [[SADigiglassValue alloc] initWithData:data];
    XCTAssertEqual(0, value.flags);
    XCTAssertEqual(0, value.mask);
    XCTAssertEqual(0, value.sectionCount);
}

-(void)testCorrectValue {
    SADigiglassValue *value = nil;

    {
        char v[] = {DIGIGLASS_TOO_LONG_OPERATION_WARNING, 7, 31, 0, 0, 0, 0, 0};
        NSData *data = [NSData dataWithBytes:v length:sizeof(v)];
        value = [[SADigiglassValue alloc] initWithData:data];
    }

    XCTAssertEqual(1, value.flags);
    XCTAssertEqual(31, value.mask);
    XCTAssertEqual(7, value.sectionCount);
    
    XCTAssertTrue([value isAnySectionTransparent]);
    XCTAssertFalse([value isPlannedRegenerationInProgress]);
    XCTAssertTrue([value isTooLongOperationPresent]);
    XCTAssertTrue([value isSectionTransparent:0]);
    XCTAssertTrue([value isSectionTransparent:4]);
    XCTAssertFalse([value isSectionTransparent:5]);
    
    {
        char v[] = {DIGIGLASS_PLANNED_REGENERATION_IN_PROGRESS, 5, 0, 0, 0, 0, 0, 0};
        NSData *data = [NSData dataWithBytes:v length:sizeof(v)];
        value = [[SADigiglassValue alloc] initWithData:data];
    }
    
    XCTAssertFalse([value isAnySectionTransparent]);
    XCTAssertTrue([value isPlannedRegenerationInProgress]);
    XCTAssertFalse([value isTooLongOperationPresent]);
    XCTAssertFalse([value isSectionTransparent:0]);
    
    {
        char v[] = {DIGIGLASS_TOO_LONG_OPERATION_WARNING
                    | DIGIGLASS_PLANNED_REGENERATION_IN_PROGRESS,
                    5, 0, 0, 0, 0, 0, 0};
        NSData *data = [NSData dataWithBytes:v length:sizeof(v)];
        value = [[SADigiglassValue alloc] initWithData:data];
    }
    
    XCTAssertFalse([value isAnySectionTransparent]);
    XCTAssertTrue([value isPlannedRegenerationInProgress]);
    XCTAssertTrue([value isTooLongOperationPresent]);
    XCTAssertFalse([value regenerationAfter20hInProgress]);
    XCTAssertFalse([value isSectionTransparent:0]);
    
    {
        char v[] = {DIGIGLASS_TOO_LONG_OPERATION_WARNING
                    | DIGIGLASS_PLANNED_REGENERATION_IN_PROGRESS
                    | DIGIGLASS_REGENERATION_AFTER_20H_IN_PROGRESS,
                    5, 0, 0, 0, 0, 0, 0};
        NSData *data = [NSData dataWithBytes:v length:sizeof(v)];
        value = [[SADigiglassValue alloc] initWithData:data];
    }
    
    XCTAssertFalse([value isAnySectionTransparent]);
    XCTAssertTrue([value isPlannedRegenerationInProgress]);
    XCTAssertTrue([value isTooLongOperationPresent]);
    XCTAssertTrue([value regenerationAfter20hInProgress]);
    XCTAssertFalse([value isSectionTransparent:0]);
}

@end
