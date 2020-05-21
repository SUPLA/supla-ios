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
#import "SAChartFilterField.h"

@interface ChartFilterFieldTests : XCTestCase

@end

@implementation ChartFilterFieldTests {
    SAChartFilterField *_filterField;
}

- (void)setUp {
    _filterField = [[SAChartFilterField alloc] init];
}

- (void)tearDown {
    _filterField = nil;
}

- (void)testDefaultFilterType {
    XCTAssertEqual(TypeFilter, _filterField.filterType);
}

- (void)testFilterSize {
    XCTAssertEqual(ChartTypeMax+1, _filterField.count);
    _filterField.filterType = DateRangeFilter;
    XCTAssertEqual(DateRangeMax+1, _filterField.count);
}

- (void)testDefaultChartType {
    XCTAssertEqual(Bar_Minutes, _filterField.chartType);
}

- (void)testDefaultDateRange {
    XCTAssertEqual(Last24hours, _filterField.dateRange);
}

- (void)testSettingChartType {
    _filterField.chartType = Bar_Days;
    XCTAssertEqual(Bar_Days, _filterField.chartType);
    
    _filterField.chartType = ChartTypeMax;
    XCTAssertEqual(ChartTypeMax, _filterField.chartType);
    
    _filterField.chartType = Bar_Years;
    XCTAssertEqual(Bar_Years, _filterField.chartType);
    
    _filterField.chartType = ChartTypeMax+1;
    XCTAssertEqual(Bar_Years, _filterField.chartType);
}

- (void)testSettingDateRange {
    _filterField.dateRange = Last7days;
    XCTAssertEqual(Last24hours, _filterField.dateRange);
    
    _filterField.filterType = DateRangeFilter;
    
    _filterField.dateRange = Last7days;
    XCTAssertEqual(Last7days, _filterField.dateRange);
    
    _filterField.dateRange = DateRangeMax;
    XCTAssertEqual(DateRangeMax, _filterField.dateRange);
    
    _filterField.dateRange = Last30days;
    XCTAssertEqual(Last30days, _filterField.dateRange);
    
    _filterField.dateRange = DateRangeMax+1;
    XCTAssertEqual(Last30days, _filterField.dateRange);
}

- (void)testExculudeElements {
    
    XCTAssertEqual(NO, [_filterField excludeElements:nil]);
    XCTAssertEqual(ChartTypeMax+1, _filterField.count);
    
    NSArray *elements = @[[NSNumber numberWithInt:Bar_Days], [NSNumber numberWithInt:Bar_Years]];
    XCTAssertEqual(YES, [_filterField excludeElements:elements]);
    XCTAssertEqual(NO, [_filterField excludeElements:elements]);
    
    XCTAssertEqual(ChartTypeMax-1, _filterField.count);
    
    _filterField.chartType = Bar_Hours;
    XCTAssertEqual(Bar_Hours, _filterField.chartType);
    
    _filterField.chartType = Bar_Years;
    XCTAssertEqual(Bar_Hours, _filterField.chartType);
    
    _filterField.chartType = Bar_Days;
    XCTAssertEqual(Bar_Hours, _filterField.chartType);
    
    _filterField.filterType = TypeFilter;
    
    _filterField.chartType = Bar_Years;
    XCTAssertEqual(Bar_Years, _filterField.chartType);
    
    _filterField.chartType = Bar_Days;
    XCTAssertEqual(Bar_Days, _filterField.chartType);
}

- (void)testExcludeAll {
    _filterField.filterType = DateRangeFilter;
     XCTAssertEqual(DateRangeMax+1, _filterField.count);
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    for(int a=0;a<=DateRangeMax;a++) {
        [elements addObject:[NSNumber numberWithInt:a]];
    }
    
    XCTAssertEqual(YES, [_filterField excludeElements:elements]);
    XCTAssertEqual(1, _filterField.count);
}

- (void)testOfLeavingOneElement {
    
    XCTAssertTrue(ChartTypeMax > DateRangeMax);
    
    _filterField.filterType = DateRangeFilter;
    [_filterField leaveOneElement:ChartTypeMax];
    XCTAssertEqual(DateRangeMax+1, _filterField.count);
    [_filterField leaveOneElement:AllAvailableHistory];
    XCTAssertEqual(1, _filterField.count);
}

- (void)testMasterSlave {
    
    SAChartFilterField *slave = [[SAChartFilterField alloc] init];
    XCTAssertEqual(TypeFilter, slave.filterType);
    _filterField.dateRangeFilterField = slave;
    XCTAssertEqual(DateRangeFilter, slave.filterType);
    XCTAssertEqual(Last24hours, slave.dateRange);
    
    _filterField.chartType = Bar_Comparsion_DayDay;
    XCTAssertEqual(Last7days, slave.dateRange);
    
    _filterField.chartType = Bar_Years;
    XCTAssertEqual(AllAvailableHistory, slave.dateRange);
}

- (void)testGettingDateFrom {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay: -30];
    
    NSDate *date = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    
    XCTAssertNil(_filterField.dateFrom);
    _filterField.filterType = DateRangeFilter;
    _filterField.dateRange = Last30days;
    XCTAssertNotNil(_filterField.dateFrom);
    XCTAssertTrue(fabs([date timeIntervalSince1970] - [_filterField.dateFrom timeIntervalSince1970]) <= 1);
}

@end
