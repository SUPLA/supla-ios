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

static SASuperuserAuthorizationDialog *_superuserAuthorizationDialogGlobalRef;

@interface SASuperuserAuthorizationDialog ()
@property (weak, nonatomic) IBOutlet UILabel *lErrorMessage;
@property (weak, nonatomic) IBOutlet UITextField *edEmail;
@property (weak, nonatomic) IBOutlet UITextField *edPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndictor;
- (IBAction)btnOkTouch:(id)sender;
@end

@implementation SASuperuserAuthorizationDialog {
    __weak id<SASuperuserAuthorizationDialogDelegate>_delegate;
    NSTimer *_timeoutTimer;
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onSuperuserAuthorizationResult:)
     name:kSASuperuserAuthorizationResult object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _delegate = nil;
}

- (void)close {
    [self timeoutTimerInvalidate];
    [super close];
}

-(void)onSuperuserAuthorizationResult:(NSNotification *)notification {
    [self timeoutTimerInvalidate];
    
    if (notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"result"];
        if (r != nil && [r isKindOfClass:[SASuperuserAuthorizationResult class]]) {
            SASuperuserAuthorizationResult *result = (SASuperuserAuthorizationResult*)r;
            
            if (result.success) {
                if (_delegate != nil && [SADialog viewControllerIsPresented:self]) {
                    [_delegate superuserAuthorizationSuccess];
                }
            } else {
                switch (result.code) {
                    case SUPLA_RESULTCODE_UNAUTHORIZED:
                        _lErrorMessage.text = NSLocalizedString(@"Bad credentials", nil);
                        break;
                    case SUPLA_RESULTCODE_TEMPORARILY_UNAVAILABLE:
                        _lErrorMessage.text = NSLocalizedString(@"Service temporarily unavailable", nil);
                        break;
                    default:
                        _lErrorMessage.text = NSLocalizedString(@"Unknown error", nil);
                        break;
                }
                
                _lErrorMessage.hidden = NO;
                _edEmail.enabled = YES;
                _edPassword.enabled = YES;
                _btnOK.hidden = NO;
                [_actIndictor stopAnimating];
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
    _delegate = delegate;
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
    _edEmail.enabled = YES;
    _edPassword.enabled = YES;
    _btnOK.hidden = NO;
    [_actIndictor stopAnimating];
    _lErrorMessage.hidden = NO;
    _lErrorMessage.text = NSLocalizedString(@"Time exceeded. Try again.", nil);
}

- (IBAction)btnOkTouch:(id)sender {
    _btnOK.hidden = YES;
    _edEmail.enabled = NO;
    _edPassword.enabled = NO;
    _lErrorMessage.hidden = YES;
    [_actIndictor startAnimating];
    
    
    [self timeoutTimerInvalidate];
    
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:6
                                                     target:self
                                                   selector:@selector(onTimeout:)
                                                   userInfo:nil
                                                    repeats:NO];
    
    
     [SAApp.SuplaClient superuserAuthorizationRequestWithEmail:_edEmail.text andPassword:_edPassword.text];
}
@end
