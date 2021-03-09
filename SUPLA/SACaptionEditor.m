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

#import "SACaptionEditor.h"
#import "SuplaApp.h"

@interface SACaptionEditor ()
@property (weak, nonatomic) IBOutlet UITextField *edCaption;
@property (weak, nonatomic) IBOutlet UILabel *lCaption;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
- (IBAction)btnOKTouch:(id)sender;
- (IBAction)onCaptionChanged:(id)sender;
@end

@implementation SACaptionEditor {
    NSString *_originalCaption;
    int _recordId;
}

- (id) init {
    return [self initWithNibName:@"SACaptionEditor" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(int)recordId {
    return _recordId;
}

-(void)editCaptionWithRecordId:(int)recordId {
    _recordId = recordId;
    [SASuperuserAuthorizationDialog.globalInstance authorizeWithDelegate:self];
}

-(void) superuserAuthorizationSuccess {
    [SASuperuserAuthorizationDialog.globalInstance closeWithAnimation:YES completion:^(){
        self->_originalCaption = [self getCaption];
        self.edCaption.placeholder = [self getPlaceholder];
        self.edCaption.text = self->_originalCaption;
        self.lCaption.text = [self getTitle];
        [self onCaptionChanged:self.edCaption];
        
        [SADialog showModal:self];
    }];
}

- (IBAction)onCaptionChanged:(id)sender {
    self.btnOK.enabled = self.edCaption.text.length >= [self minCaptionLen]
     && self.edCaption.text.length <= [self maxCaptionLen];
}

- (IBAction)btnOKTouch:(id)sender {
    if ((_originalCaption == nil  && self.edCaption.text != nil)
         || (_originalCaption != nil  && self.edCaption.text == nil)
         || (_originalCaption != nil  && self.edCaption.text != nil
             && ![_originalCaption isEqual:self.edCaption.text] )) {
        [self applyChanges:self.edCaption.text];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSADataChangedNotification object:self userInfo:nil];
        [self close];
    }
}

- (int)minCaptionLen {
    return 0;
}

- (int)maxCaptionLen {
    return 100;
}

- (NSString*) getPlaceholder {
    return @"";
}

- (NSString*) getTitle {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

- (NSString*) getCaption {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

- (void) applyChanges:(NSString*)caption {
    ABSTRACT_METHOD_EXCEPTION;
}

@end
