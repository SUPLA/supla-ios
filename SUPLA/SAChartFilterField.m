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
    UIPickerView *_pickerView;
    SAChartFilterField *_dateRangeFilterField;
    ChartFilterFieldType _filterType;
    NSArray *_items;
    BOOL _initialized;
}

@synthesize ff_delegate;

-(void) _init {
    if (!_initialized) {
        _initialized = YES;
  
        self.delegate = self;
        
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.showsSelectionIndicator = YES;
        _pickerView.delegate = self;
        self.inputView = _pickerView;
   
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        tapgr.delegate = self;
        [self addGestureRecognizer:tapgr];
        
        tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewTapped:)];
        tapgr.delegate = self;
        [_pickerView addGestureRecognizer:tapgr];
        
        self.filterType = TypeFilter;
    }
}

- (id)init {
    if (self = [super init]) {
        [self _init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _init];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _init];
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField != self;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    int i = [self findIndexForValue:_filterType == TypeFilter ? self.chartType : self.dateRange];
    if (i > -1) {
        [_pickerView reloadComponent:0];
        [_pickerView selectRow:i inComponent:0 animated:NO];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([self isEditing]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)pickerViewTapped:(UITapGestureRecognizer *)tapRecognizer {
    int i = [[_items objectAtIndex:[_pickerView selectedRowInComponent:0]] intValue];
    
    if (_filterType == TypeFilter) {
        self.chartType = i;
    } else {
        self.dateRange = i;
    }
    
    [self resignFirstResponder];
    
    if (self.ff_delegate!=nil) {
        [ff_delegate onFilterChanged:self];
    }
}

- (void)tapped:(UITapGestureRecognizer *)tapRecognizer {
    if ([self isEditing]) {
        [self resignFirstResponder];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _items != nil ? _items.count : 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSNumber *idx = [_items objectAtIndex:row];
    return _filterType == TypeFilter
         ? [SAChartHelper stringRepresentationOfChartType:[idx intValue]] : [SAChartFilterField stringRepresentationOfDateRange:[idx intValue]];
}

- (int)findIndexForValue:(int)value {
    for(int a=0;a<_items.count;a++) {
        if ([[_items objectAtIndex:a] intValue] == value) {
            return a;
        }
    }
    
    return -1;
}

- (void)setChartType:(ChartType)chartType {
    if (_filterType == TypeFilter) {
        int i = [self findIndexForValue:chartType];
        if ( i > -1 ) {
            _chartType = chartType;
            [self setText:[SAChartHelper stringRepresentationOfChartType:_chartType]];
            
            if (_dateRangeFilterField != nil) {
                _dateRangeFilterField.filterType = DateRangeFilter;
                
                switch(_chartType) {
                    case Bar_Minutely:
                    case Bar_Hourly:
                    case Bar_Comparsion_MinMin:
                    case Bar_Comparsion_HourHour:
                        break;
                    case Bar_Daily:
                    case Bar_Comparsion_DayDay:
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
        int i = [self findIndexForValue:dateRange];
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

-(void)setFilterType:(ChartFilterFieldType)filterType {
    
    [self assignItemsArrayWithMaximumValue:filterType == TypeFilter ? ChartTypeMax : DateRangeMax];
    
    _filterType = filterType;
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
