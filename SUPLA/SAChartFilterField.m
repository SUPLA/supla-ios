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

#import "SAChartFilterField.h"
#import "SAChartHelper.h"


@implementation SAChartFilterField {
    ChartType _chartType;
    DateRange _dateRange;
    SAChartFilterField *_dateRangeFilterField;
    ChartFilterFieldType _filterType;
    NSArray *_items;
}

@synthesize ff_delegate;
@synthesize chartHelper;

-(void) __init {
    self.filterType = TypeFilter;
}

- (id)init {
    if (self = [super init]) {
        [self __init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __init];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __init];
    }
    return self;
}

- (NSInteger)numberOfRows {
    return _items != nil ? _items.count : 0;
}

- (void)pickerTappedAtRow:(NSInteger)row {
    int i = [[_items objectAtIndex:row] intValue];
    
    if (_filterType == TypeFilter) {
        self.chartType = i;
    } else {
        self.dateRange = i;
    }
}


- (NSString *)pickerViewTitleForRow:(NSInteger)row {
    NSNumber *idx = [_items objectAtIndex:row];
    if (_filterType == TypeFilter) {
        return chartHelper == nil ? @"" : [chartHelper stringRepresentationOfChartType:[idx intValue]];
    }
    return [SAChartFilterField stringRepresentationOfDateRange:[idx intValue]];
}

-(void)afterResignFirstResponder {
    if (self.ff_delegate!=nil) {
        [ff_delegate onFilterChanged:self];
    }
}

- (NSInteger)findIndexForValue:(NSUInteger)value {
    for(NSInteger a=0;a<_items.count;a++) {
        if ([[_items objectAtIndex:a] intValue] == value) {
            return a;
        }
    }
    
    return -1;
}

- (NSInteger)selectedRowIndex {
    return [self findIndexForValue:_filterType == TypeFilter ? (NSInteger)self.chartType : (NSInteger)self.dateRange];
}

- (void)setChartType:(ChartType)chartType {
    if (_filterType == TypeFilter) {
        NSInteger i = [self findIndexForValue:chartType];
        if ( i > -1 ) {
            _chartType = chartType;
            [self setText:chartHelper==nil ? @"" : [chartHelper stringRepresentationOfChartType:_chartType]];
        
            if (_dateRangeFilterField != nil) {
                _dateRangeFilterField.filterType = DateRangeFilter;
                
                switch(_chartType) {
                    case Bar_Minutes:
                    case Bar_Hours:
                    case Bar_Comparsion_MinMin:
                    case Bar_Comparsion_HourHour:
                    case Bar_AritmeticBalance_Minutes:
                    case Bar_VectorBalance_Minutes:
                    case Bar_AritmeticBalance_Hours:
                    case Bar_VectorBalance_Hours:
                        break;
                    case Bar_Days:
                    case Bar_Comparsion_DayDay:
                    case Bar_AritmeticBalance_Days:
                    case Bar_VectorBalance_Days:
                        [_dateRangeFilterField excludeElements:@[[NSNumber numberWithInt:Last24hours]]];
                        break;
                    default:
                        [_dateRangeFilterField leaveOneElement:AllAvailableHistory];
                }
                
                [_dateRangeFilterField goToToFirst];
            }
        }
    }
}

- (ChartType)chartType {
    return _chartType;
}

- (void)setDateRange:(DateRange)dateRange {
    if (_filterType == DateRangeFilter) {
        NSInteger i = [self findIndexForValue:dateRange];
        if ( i > -1 ) {
            _dateRange = dateRange;
            [self setText:[SAChartFilterField stringRepresentationOfDateRange:dateRange]];
        }
    }
}

- (DateRange)dateRange {
    return _dateRange;
}

+ (NSString *)stringRepresentationOfDateRange:(DateRange)dateRange {
    
    switch(dateRange) {
        case Last7days:
            return NSLocalizedString(@"Last 7 days", nil);
        case Last30days:
            return NSLocalizedString(@"Last 30 days", nil);
        case Last90days:
            return NSLocalizedString(@"Last 90 days", nil);
        case AllAvailableHistory:
            return NSLocalizedString(@"All available history", nil);
        default:
            return NSLocalizedString(@"Last 24 hours", nil);
    }

}

- (void)assignItemsArrayWithMaximumValue:(int)max {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(int a=0;a<=max;a++) {
        NSNumber *v = [NSNumber numberWithInt:a];
        [items addObject:v];
    }
    
    _items = items;
}

-(void)resetList {
    [self assignItemsArrayWithMaximumValue:_filterType == TypeFilter ? ChartTypeMax : DateRangeMax];
}

-(void)setFilterType:(ChartFilterFieldType)filterType {
    _filterType = filterType;
    [self resetList];
    self.dateRange = self.dateRange;
    self.chartType = self.chartType;
}

-(ChartFilterFieldType)filterType {
    return _filterType;
}

-(void)setDateRangeFilterField:(SAChartFilterField *)dateRangeFilterField {
    _dateRangeFilterField = dateRangeFilterField;
    
    if (dateRangeFilterField!=nil) {
        self.filterType = TypeFilter;
    }
}

-(SAChartFilterField*)dateRangeFilterField {
    return _dateRangeFilterField;
}

- (void)goToToFirst {
    if (_filterType == TypeFilter) {
        self.chartType = [[_items objectAtIndex:0] intValue];
    } else if (_filterType == DateRangeFilter) {
        self.dateRange = [[_items objectAtIndex:0] intValue];
    }
}

- (BOOL)excludeElements:(NSArray*)el {
    
    if (el==nil) {
        return NO;
    }
    
    BOOL excluded = NO;
    NSMutableArray *mitems = [NSMutableArray arrayWithArray:_items];
    
    for(int a=0;a<el.count;a++) {
        NSNumber *n = [el objectAtIndex:a];
        if ([n isKindOfClass:[NSNumber class]]) {
            int i = [n intValue];
            
            for(int b=0;b<mitems.count;b++) {
                if ([[mitems objectAtIndex:b] intValue] == i) {
                    
                    if (mitems.count > 1) {
                        [mitems removeObjectAtIndex:b];
                        excluded = YES;
                        b--;
                    } else {
                        break;
                    }
                    
                }
            }
        }
    }
        
        
    if (excluded) {
        _items = mitems;
        if([self selectedRowIndex] >= [_items count])
            [self goToToFirst];
    }
    
    return excluded;
}

- (BOOL)excludeAllFrom:(int)el {
    
    BOOL excluded = NO;
    NSMutableArray *mitems = [NSMutableArray arrayWithArray:_items];
    
    for(int b=0;b<mitems.count;b++) {
        if ([[mitems objectAtIndex:b] intValue] >= el) {
            if (mitems.count > 1) {
                [mitems removeObjectAtIndex:b];
                excluded = YES;
                b--;
            }
        }
    }
    
    if (excluded) {
        _items = mitems;
        if([self selectedRowIndex] >= [_items count])
            [self goToToFirst];
    }
    
    return excluded;
}

- (void)leaveOneElement:(int)el {
    if (el < 0) {
        return;
    }
    
    if ((_filterType == TypeFilter && el <= ChartTypeMax)
        || (_filterType == DateRangeFilter && el <= DateRangeMax)) {
        _items = @[[NSNumber numberWithInt:el]];
    }
    
    [self goToToFirst];
}

- (NSUInteger)count {
    return _items ? _items.count : 0;
}

- (NSDate *)dateFrom {
    
    if (self.filterType != DateRangeFilter) {
        return nil;
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    switch(self.dateRange) {
        case Last24hours:
            [components setHour: -24];
            break;
        case Last7days:
            [components setDay: -7];
            break;
        case Last30days:
            [components setDay: -30];
            break;
        case Last90days:
            [components setDay: -90];
            break;
        case AllAvailableHistory:
            return nil;
    }
    
    return [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
}

@end
