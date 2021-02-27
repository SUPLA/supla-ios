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

#import "SASuperuserAuthorizationDialog.h"
#import "SuplaClient.h"
#import "SuplaApp.h"
#import "SASuperuserAuthorizationResult.h"

static SASuperuserAuthorizationDialog *_superuserAuthorizationDialogGlobalRef = nil;

@interface SASuperuserAuthorizationDialog ()
@property (weak, nonatomic) IBOutlet UILabel *tvInfo;
@property (weak, nonatomic) IBOutlet UIView *vMain;
@property (weak, nonatomic) IBOutlet UILabel *lErrorMessage;
@property (weak, nonatomic) IBOutlet UITextField *edEmail;
@property (weak, nonatomic) IBOutlet UITextField *edPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndictor;
- (IBAction)btnOkTouch:(id)sender;
- (IBAction)btnPasswordViewtouchDown:(id)sender;

@end

@implementation SASuperuserAuthorizationDialog {
    id<SASuperuserAuthorizationDialogDelegate>_delegate;
    NSTimer *_timeoutTimer;
    BOOL _success;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.cancelByTouchOutside = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tvInfo.text = NSLocalizedString(
                    [[SAApp getServerHostName] containsString:@"supla.org"] ?
                    @"Please enter your Supla Cloud login details."
                    : @"Enter superuser credentials", nil);
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onSuperuserAuthorizationResult:)
     name:kSASuperuserAuthorizationResult object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_success
        && _delegate
        && [_delegate respondsToSelector:@selector(superuserAuthorizationCanceled)] ) {
        [_delegate superuserAuthorizationCanceled];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _delegate = nil;
}

-(void)closeWithAnimation:(BOOL)animation completion:(void (^ __nullable)(void))completion {
    [self timeoutTimerInvalidate];
    [super closeWithAnimation:animation completion:completion];
    
}

-(void)showError:(NSString*)err {
    [self timeoutTimerInvalidate];
    _lErrorMessage.text = err;
    _lErrorMessage.hidden = NO;
    _edEmail.enabled = YES;
    _edPassword.enabled = YES;
    _btnOK.hidden = NO;
    [_actIndictor stopAnimating];
}

-(void)onSuperuserAuthorizationResult:(NSNotification *)notification {
    
    SASuperuserAuthorizationResult *result =
    [SASuperuserAuthorizationResult notificationToAuthorizationResult:notification];
    
    if (result != nil) {
        if (result.success) {
            _success = YES;
            if (_delegate != nil && [SADialog viewControllerIsPresented:self]) {
                [_delegate superuserAuthorizationSuccess];
            }
        }
    }
}

-(void)timeoutTimerInvalidate {
    if (_timeoutTimer != nil) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
}

-(void)authorizeWithDelegate:(id<SASuperuserAuthorizationDialogDelegate>)delegate {
    if ([SAApp.SuplaClient isSuperuserAuthorized]) {
        if (_delegate != nil) {
            [_delegate superuserAuthorizationSuccess];
        }
        return;
    }
    
    _delegate = delegate;
    _success = NO;
    [self timeoutTimerInvalidate];
    _lErrorMessage.text = @"";
    _lErrorMessage.hidden = YES;
    _edEmail.text = [SAApp getEmailAddress];
    _edEmail.enabled = YES;
    _edPassword.text = @"";
    _edPassword.enabled = YES;
    _btnOK.hidden = NO;
    [_actIndictor stopAnimating];
    
    [SADialog showModal:self];
}

+(SASuperuserAuthorizationDialog*)globalInstance {
    if (_superuserAuthorizationDialogGlobalRef == nil) {
        _superuserAuthorizationDialogGlobalRef =
        [[SASuperuserAuthorizationDialog alloc]
         initWithNibName:@"SASuperuserAuthorizationDialog" bundle:nil];
    }
    
    return _superuserAuthorizationDialogGlobalRef;
}

-(void)onTimeout:(id)sender {
    [self showError:NSLocalizedString(@"Time exceeded. Try again.", nil)];
}

- (IBAction)btnPasswordViewtouchDown:(id)sender {
     self.edPassword.secureTextEntry = !self.edPassword.secureTextEntry;
}

- (IBAction)btnOkTouch:(id)sender {
    _btnOK.hidden = YES;
    _edEmail.enabled = NO;
    _edPassword.enabled = NO;
    _lErrorMessage.hidden = YES;
    [_actIndictor startAnimating];
    
    
    [self timeoutTimerInvalidate];
    
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                     target:self
                                                   selector:@selector(onTimeout:)
                                                   userInfo:nil
                                                    repeats:NO];
    

    [SAApp.SuplaClient superuserAuthorizationRequestWithEmail:_edEmail.text andPassword:_edPassword.text];
}

- (void)keyboardDidShow:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect edPasswordRect = [self.edPassword convertRect:self.edPassword.frame toView:self.view];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.vMain.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height - keyboardSize.height - edPasswordRect.origin.y);
    }];
}

- (void)keyboardDidHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.2 animations:^{
        self.vMain.transform = CGAffineTransformIdentity;
    }];
}

- (BOOL)isVisible {
    return [SADialog viewControllerIsPresented:self];
}

@end
