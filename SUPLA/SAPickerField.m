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

#import "SAPickerField.h"

@implementation SAPickerField {
    id<SAPickerFieldDelegate> _pf_delegate;
}

- (NSInteger)numberOfRows {
    if (_pf_delegate) {
        return [_pf_delegate numberOfRowsInPickerField:self];
    }
    return 0;
}

- (NSInteger)selectedRowIndex {
    if (_pf_delegate) {
        return [_pf_delegate selectedRowIndexInPickerField:self];
    }
    return -1;
}

- (void)pickerTappedAtRow:(NSInteger)row {
    NSString *result = nil;
    
    if (_pf_delegate) {
        [_pf_delegate pickerField:self tappedAtRow:&row];
        result = [_pf_delegate pickerField:self titleForRow:row];
    }
    
    [self setText:result];
}

- (NSString *)pickerViewTitleForRow:(NSInteger)row {
    if (_pf_delegate) {
        return [_pf_delegate pickerField:self titleForRow:row];
    }
    
    return nil;
}

-(id<SAPickerFieldDelegate>)pf_delegate {
    return _pf_delegate;
}

-(void)setPf_delegate:(id<SAPickerFieldDelegate>)pf_delegate {
    _pf_delegate = pf_delegate;
    [self update];
}

-(void)update {
    [self setText:[_pf_delegate pickerField:self titleForRow:[self selectedRowIndex]]];
}

@end
