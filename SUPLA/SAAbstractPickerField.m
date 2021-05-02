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

#import "SAAbstractPickerField.h"
#import "SuplaApp.h"
#import "UIColor+SUPLA.h"

@interface SAAbstractPickerField () <UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@end

@implementation SAAbstractPickerField {
    UIPickerView *_pickerView;
    BOOL _initialized;
}

- (NSInteger)numberOfRows {
    ABSTRACT_METHOD_EXCEPTION;
    return 0;
}

- (NSInteger)selectedRowIndex {
    ABSTRACT_METHOD_EXCEPTION;
    return 0;
}

- (void)pickerTappedAtRow:(NSInteger)index {
    ABSTRACT_METHOD_EXCEPTION;
}

- (NSString *)pickerViewTitleForRow:(NSInteger)row {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

-(BOOL) _init {
    if (_initialized) {
        return NO;
    }
    
    _initialized = YES;
    
    self.delegate = self;
    
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.showsSelectionIndicator = YES;
    _pickerView.delegate = self;
    _pickerView.backgroundColor = [UIColor pickerViewColor];
    self.inputView = _pickerView;

    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapgr.delegate = self;
    [self addGestureRecognizer:tapgr];
    
    tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewTapped:)];
    tapgr.delegate = self;
    [_pickerView addGestureRecognizer:tapgr];
    
    return YES;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return textField != self;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSInteger i = [self selectedRowIndex];
    if (i > -1) {
        [_pickerView reloadComponent:0];
        [_pickerView selectRow:i inComponent:0 animated:NO];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
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

-(void)afterResignFirstResponder {
}

- (void)pickerViewTapped:(UITapGestureRecognizer *)tapRecognizer {
    [self pickerTappedAtRow:[_pickerView selectedRowInComponent:0]];
    [self resignFirstResponder];
    [self afterResignFirstResponder];
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
    return [self numberOfRows];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self pickerViewTitleForRow:row];
}

@end
