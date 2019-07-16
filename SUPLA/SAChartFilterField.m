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
    ChartFilterFieldType _filterType;
    BOOL _initialized;
}

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
        
        self.chartType = TypeFilter;
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
    [_pickerView reloadComponent:0];
    [_pickerView selectRow:_filterType == TypeFilter ? self.chartType : self.dateRange inComponent:0 animated:NO];
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
    if (_filterType == TypeFilter) {
        self.chartType = [_pickerView selectedRowInComponent:0];
    } else {
        self.dateRange = [_pickerView selectedRowInComponent:0];
    }
    
    [self resignFirstResponder];
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
    return (_filterType == TypeFilter ? ChartTypeMax : DateRangeMax)+1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _filterType == TypeFilter
    ? [SAChartHelper stringRepresentationOfChartType:row] : [SAChartFilterField stringRepresentationOfDateRange:row];
}

- (void)setChartType:(ChartType)chartType {
    if (_filterType == TypeFilter
        && chartType >= 0 && chartType <= ChartTypeMax) {
        _chartType = chartType;
        [self setText:[SAChartHelper stringRepresentationOfChartType:_chartType]];
    }
}

- (ChartType)chartType {
    return _chartType;
}

- (void)setDateRange:(DateRange)dateRange {
    if (_filterType == DateRangeFilter
        && dateRange >= 0 && dateRange <= DateRangeMax) {
        _dateRange = dateRange;
        [self setText:[SAChartFilterField stringRepresentationOfDateRange:dateRange]];
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

-(void)setFilterType:(ChartFilterFieldType)filterType {
    _filterType = filterType;
    self.dateRange = self.dateRange;
    self.chartType = self.chartType;
}

-(ChartFilterFieldType)filterType {
    return _filterType;
}

@end
