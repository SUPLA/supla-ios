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

#import "SADimmerCalibrationTool.h"
#import "SuplaApp.h"
#import "SAPreloaderPopup.h"
#import "SACalCfgResult.h"
#import "UIColor+SUPLA.h"

#define LED_ON_WHEN_CONNECTED 0
#define LED_OFF_WHEN_CONNECTED 1
#define LED_ALWAYS_OFF 2

#define MIN_SEND_DELAY_TIME 0.5
#define DISPLAY_DELAY_TIME 1.0

@implementation SADimmerCalibrationTool {
    BOOL _grInitialized;
    NSTimer *_delayTimer1;
    NSTimer *_delayTimer2;
    SADetailView *_detailView;
    NSDate *_configStartedAtTime;
    NSDate *_lastCalCfgTime;
    BOOL _sueruserAuthoriztionStarted;
    SAPreloaderPopup *_preloaderPopup;
    BOOL _settingsChanged;
}

-(void)setSettingsChanged:(BOOL)changed {
    _settingsChanged = changed;
    [self.btnOK setImage:[UIImage imageNamed:changed ? @"btnOK" : @"btnOK_disabled"] forState:UIControlStateNormal];
}

-(void)_onCalCfgResult:(NSNotification *)notification {
    if (_detailView == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        return;
    }
    
    SACalCfgResult *result = [SACalCfgResult notificationToDeviceCalCfgResult:notification];
    
    if (result && result.channelID == _detailView.channelBase.remote_id) {
        [self onCalCfgResult:result];
    }
}

-(void) superuserAuthorizationSuccess {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(_onCalCfgResult:)
     name:kSACalCfgResult object:nil];
    
    _sueruserAuthoriztionStarted = NO;
    [self onSuperuserAuthorizationSuccess];
}

-(void) superuserAuthorizationCanceled {
    _sueruserAuthoriztionStarted = NO;
}


-(void)initGestureRecognizerForView:(UIView *)view action:(SEL)action {
    if (view) {
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
        tapgr.delegate = self;
        [view addGestureRecognizer:tapgr];
    }
}

-(void)startConfiguration:(SADetailView*)detailView {
    if (detailView == nil) {
        return;
    }
    
    [self setSettingsChanged:NO];
    [self beforeConfigurationStart];
    
    if (!_grInitialized) {
        [self initGestureRecognizerForView:self.tabBgLedOn action:@selector(ledOnTapped:)];
        [self initGestureRecognizerForView:self.tabLedOn action:@selector(ledOnTapped:)];
        
        [self initGestureRecognizerForView:self.tabBgLedOff action:@selector(ledOffTapped:)];
        [self initGestureRecognizerForView:self.tabLedOff action:@selector(ledOffTapped:)];
        
        [self initGestureRecognizerForView:self.tabBgLedAlwaysOff action:@selector(ledAlwaysOffTapped:)];
        [self initGestureRecognizerForView:self.tabLedAlwaysOff action:@selector(ledAlwaysOffTapped:)];
        
        _grInitialized = YES;
    }
    
    _lastCalCfgTime = [NSDate dateWithTimeIntervalSince1970:0];

    _configStartedAtTime = nil;
    [self cfgToUIWithDelay:NO];
    
    [self removeFromSuperview];
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.frame = CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height);
    _detailView = detailView;
    
    _sueruserAuthoriztionStarted = YES;
    [SASuperuserAuthorizationDialog.globalInstance authorizeWithDelegate:self];
}

-(void)dismiss {
    [self onDismiss];
    [self closePreloaderPopup];
    
    if (_configStartedAtTime) {
        _configStartedAtTime = nil;
    }
    
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    _detailView = nil;
}

-(BOOL)isExitLocked {
    return _preloaderPopup != nil
    || (_sueruserAuthoriztionStarted && [SASuperuserAuthorizationDialog.globalInstance isVisible])
    || (_configStartedAtTime != nil
     && [[NSDate date] timeIntervalSince1970] - [_configStartedAtTime timeIntervalSince1970] <= 15);
}

-(BOOL)onMenubarBackButtonPressed {
    
    if (!_settingsChanged) {
        [self dismiss];
        return NO;
    }
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Dimmer settings", nil)
                                 message:NSLocalizedString(@"Do you want to quit without saving?", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesBtn = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Yes", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
        [self dismiss];
    }];
    
    UIAlertAction* noBtn = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"No", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
    }];
    
    
    [alert addAction:noBtn];
    [alert addAction:yesBtn];
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:alert animated:YES completion:nil];
    
    return NO;
}

- (IBAction)btnInfoTouch:(id)sender {
    [self showInformationDialog];
}

- (IBAction)btnRestoreTouch:(id)sender {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Dimmer settings", nil)
                                 message:NSLocalizedString(@"Are you sure you want to restore the default settings?", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesBtn = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Yes", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
        [self doRestore];
        [self setSettingsChanged:NO];
    }];
    
    UIAlertAction* noBtn = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"No", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
    }];
    

    [alert addAction:noBtn];
    [alert addAction:yesBtn];
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:alert animated:YES completion:nil];
}

- (IBAction)btnOKTouch:(id)sender {
    
    if (!_settingsChanged) {
        [self dismiss];
        return;
    }
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Dimmer settings", nil)
                                 message:NSLocalizedString(@"Do you want to save the settings?", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesBtn = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Yes", nil)
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
        self->_configStartedAtTime = nil;
        [self saveChanges];
        [self dismiss];
    }];
    
    UIAlertAction* noBtn = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"No", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
        [self dismiss];
    }];
    
    UIAlertAction* cancelBtn = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Cancel", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {

    }];
    
    [alert addAction:yesBtn];
    [alert addAction:noBtn];
    [alert addAction:cancelBtn];
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:alert animated:YES completion:nil];
    
}

- (void)ledOnTapped:(UITapGestureRecognizer *)tapRecognizer {
    [self _setLedCfg:LED_ON_WHEN_CONNECTED];
}

- (void)ledOffTapped:(UITapGestureRecognizer *)tapRecognizer {
    [self _setLedCfg:LED_OFF_WHEN_CONNECTED];
}

- (void)ledAlwaysOffTapped:(UITapGestureRecognizer *)tapRecognizer {
    [self _setLedCfg:LED_ALWAYS_OFF];
}


- (void) deviceCalCfgCommand:(int)command charValue:(char*)charValue shortValue:(short*)shortValue {
    if (_detailView
        && _detailView.channelBase
        && _detailView.channelBase.isOnline) {
        _lastCalCfgTime = [NSDate date];
        [self setSettingsChanged:YES];
        if (charValue) {
            [SAApp.SuplaClient deviceCalCfgCommand:command cg:_detailView.channelBase.remote_id group:NO charValue:*charValue];
        } else if (shortValue) {
            [SAApp.SuplaClient deviceCalCfgCommand:command cg:_detailView.channelBase.remote_id group:NO shortValue:*shortValue];
        } else {
            [SAApp.SuplaClient deviceCalCfgCommand:command cg:_detailView.channelBase.remote_id group:NO];
        }
    }
}

- (void) deviceCalCfgCommand:(int)command charValue:(char)charValue {
    [self deviceCalCfgCommand:command charValue:&charValue shortValue:NULL];
}

- (void) deviceCalCfgCommand:(int)command shortValue:(short)shortValue {
    [self deviceCalCfgCommand:command charValue:NULL shortValue:&shortValue];
}

- (void)timer1FireMethod:(NSTimer *)timer {
    [self deviceCalCfgCommandWithDelay:[timer.userInfo intValue]];
}

- (void)timer2FireMethod:(NSTimer *)timer {
    [self cfgToUIWithDelay:YES];
}

-(void) delayTimer1Invalidate {
    if ( _delayTimer1 != nil ) {
        [_delayTimer1 invalidate];
        _delayTimer1 = nil;
    }
}

-(void) delayTimer2Invalidate {
    if ( _delayTimer2 != nil ) {
        [_delayTimer2 invalidate];
        _delayTimer2 = nil;
    }
}

-(void)deviceCalCfgCommand:(int)command {
    [self deviceCalCfgCommand:command charValue:NULL shortValue:NULL];
}

- (void) deviceCalCfgCommandWithDelay:(int)command {
    [self delayTimer1Invalidate];
    
    double time = [_lastCalCfgTime timeIntervalSinceNow] * -1;
    
    if (time > MIN_SEND_DELAY_TIME) {
        [self deviceCalCfgCommand:command];
    } else {
        if ( time < MIN_SEND_DELAY_TIME ) {
            time = MIN_SEND_DELAY_TIME-time+0.001;
        } else {
            time = 0.001;
        }
        
        _delayTimer1 = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timer1FireMethod:) userInfo:[NSNumber numberWithInt:command] repeats:NO];
    }
}

- (void)setLedTabApparance:(UIImageView *)iv bgView:(UIView *)bgView selected:(BOOL)selected imgNamed:(NSString*)imgName {
    if (selected && ![self isLedConfigAvailable]) {
        selected = NO;
    }
    
    if (selected) {
        [bgView setBackgroundColor: [UIColor vlCfgButtonColor]];
        [iv setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@white", imgName]]];
    } else {
        [bgView setBackgroundColor: [UIColor clearColor]];
        [iv setImage:[UIImage imageNamed:imgName]];
    }
}

- (void)ledConfigToUI:(unsigned char)ledCfg {
    [self setLedTabApparance:self.tabLedOn
                  bgView:self.tabBgLedOn
                  selected:ledCfg == LED_ON_WHEN_CONNECTED
                  imgNamed:@"ledon"];

    [self setLedTabApparance:self.tabLedOff
                  bgView:self.tabBgLedOff
                  selected:ledCfg == LED_OFF_WHEN_CONNECTED
                  imgNamed:@"ledoff"];

    [self setLedTabApparance:self.tabLedAlwaysOff
                  bgView:self.tabBgLedAlwaysOff
                  selected:ledCfg == LED_ALWAYS_OFF
                  imgNamed:@"ledalwaysoff"];
}

- (void)ledConfigToUI {
    [self ledConfigToUI:[self getLedCfg]];
}

- (void)cfgToUIWithDelay:(BOOL)delay {
    [self delayTimer2Invalidate];
    
    double time = [_lastCalCfgTime timeIntervalSinceNow] * -1;
    
    if (!delay || time > DISPLAY_DELAY_TIME) {
        [self ledConfigToUI];
        [self cfgToUI];
    } else {
        if ( time < DISPLAY_DELAY_TIME ) {
            time = DISPLAY_DELAY_TIME-time+0.001;
        } else {
            time = 0.001;
        }
        
        _delayTimer2 = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timer2FireMethod:) userInfo:nil repeats:NO];
    }
}

-(void)setConfigurationStarted {
    [SASuperuserAuthorizationDialog.globalInstance closeWithAnimation:NO completion:nil];
    [_detailView addSubview:self];
    [_detailView bringSubviewToFront:self];
    _configStartedAtTime = [NSDate date];
    [self closePreloaderPopup];
    [self setSettingsChanged:NO];
}

-(void)showPreloaderWithText:(NSString *)text {
    _preloaderPopup = SAPreloaderPopup.globalInstance;
    [_preloaderPopup setText:text];
    [_preloaderPopup show];
}

-(void)closePreloaderPopup {
    if (_preloaderPopup) {
        [_preloaderPopup close];
        _preloaderPopup = nil;
    }
}

-(BOOL)isConfigurationStarted {
    return _configStartedAtTime != nil;
}

- (void)_setLedCfg:(char)cfg {
    if ([self isLedConfigAvailable]) {
        [self ledConfigToUI:cfg];
        [self setLedCfg:cfg];
    }
}

-(void)setLedCfg:(char)cfg {
    ABSTRACT_METHOD_EXCEPTION;
}

- (char)getLedCfg {
    ABSTRACT_METHOD_EXCEPTION;
    return 0;
}

-(void)onCalCfgResult:(SACalCfgResult *)result {
    ABSTRACT_METHOD_EXCEPTION;
}

- (void)beforeConfigurationStart {
    ABSTRACT_METHOD_EXCEPTION;
}

- (void)onDismiss {
    ABSTRACT_METHOD_EXCEPTION;
}

- (void)saveChanges {
    ABSTRACT_METHOD_EXCEPTION;
}

- (void)cfgToUI {
    ABSTRACT_METHOD_EXCEPTION;
}

- (void)showInformationDialog {
    ABSTRACT_METHOD_EXCEPTION;
}

- (void)onSuperuserAuthorizationSuccess {
    ABSTRACT_METHOD_EXCEPTION;
}

-(BOOL)isLedConfigAvailable {
    ABSTRACT_METHOD_EXCEPTION;
    return NO;
}

- (void)doRestore {
    ABSTRACT_METHOD_EXCEPTION;
}

+(SADimmerCalibrationTool*)newInstance {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

@end
