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

#import "SAZWaveConfigurationWizardVC.h"
#import "SuplaApp.h"
#import "SAChannel+CoreDataClass.h"

#define ERROR_TYPE_TIMEOUT 1
#define ERROR_TYPE_DISCONNECTED 2

static SAZWaveConfigurationWizardVC *_zwaveConfigurationWizardGlobalRef = nil;

@interface SAZWaveConfigurationWizardVC ()
@property (strong, nonatomic) IBOutlet UIView *welcomePage;
@property (strong, nonatomic) IBOutlet UIView *errorPage;
@property (strong, nonatomic) IBOutlet UIView *channelSelectionPage;
@property (strong, nonatomic) IBOutlet UIView *channelDetailsPage;
@property (strong, nonatomic) IBOutlet UIView *itTakeAWhilePage;
@property (strong, nonatomic) IBOutlet UIView *settingsPage;
@property (strong, nonatomic) IBOutlet UIView *successInfoPage;

@end

@implementation SAZWaveConfigurationWizardVC {
    NSTimer *_anyCalCfgResultWatchdogTimer;
    NSTimer *_watchdogTimer;
    NSMutableArray *_deviceList;
    NSMutableArray *_channelList;
    NSMutableArray *_channelBasicCfgToFetch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceList = [[NSMutableArray alloc] init];
    _channelList = [[NSMutableArray alloc] init];
    _channelBasicCfgToFetch = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.page = self.welcomePage;
}

-(void) superuserAuthorizationSuccess {
    [SASuperuserAuthorizationDialog.globalInstance close];
    [SAApp.UI showViewController:self];
}

-(void)show {
    [SASuperuserAuthorizationDialog.globalInstance authorizeWithDelegate:self];
}

+(SAZWaveConfigurationWizardVC*)globalInstance {
    if ( _zwaveConfigurationWizardGlobalRef == nil ) {
        _zwaveConfigurationWizardGlobalRef = [[SAZWaveConfigurationWizardVC alloc]
                                              initWithNibName:@"SAZWaveConfigurationWizardVC" bundle:nil];
    }
    
    return _zwaveConfigurationWizardGlobalRef;
}

- (void)showError:(int)type withMessage:(NSString *)message {
    
}

- (void)anyCalCfgResultWatchdogDeactivate {
    if (_anyCalCfgResultWatchdogTimer) {
        [_anyCalCfgResultWatchdogTimer invalidate];
        _anyCalCfgResultWatchdogTimer = nil;
    }
}

- (void) watchdogDeactivate {
    [self anyCalCfgResultWatchdogDeactivate];
    
    if (_watchdogTimer) {
        [_watchdogTimer invalidate];
        _watchdogTimer = nil;
    }
}

- (BOOL)isWatchdogActive {
    return _watchdogTimer != nil;
}

-(void)onAnyCalCfgResultTimeout:(NSTimer*)timer {
    [self showError:ERROR_TYPE_DISCONNECTED withMessage:
     NSLocalizedString(@"The z-wave bridge is not responding. Check if the bridge is connected to the server.", nil)];
}

-(void)onWatchdogTimeout:(NSTimer*)timer {
    [self showError:ERROR_TYPE_TIMEOUT withMessage: timer.userInfo];
}

- (void)watchdogActivateWithTime:(NSTimeInterval)time timeoutMessage:(NSString *)message calCfg:(BOOL)calCfg {
    [self watchdogDeactivate];
    
    if (time < 5) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Watchdog - The minimum timeout value is 5 seconds"];
    }
    
    self.btnNextEnabled = NO;
    self.btnCancelOrBackEnabled = NO;
    
    if (calCfg) {
        _anyCalCfgResultWatchdogTimer =
        [NSTimer scheduledTimerWithTimeInterval:time > 10 ? 10 : time-1
                                                target:self
                                                selector:@selector(onAnyCalCfgResultTimeout:)
                                                userInfo:nil
                                                repeats:NO];
    }
    
    _watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                               target:self
                                             selector:@selector(onWatchdogTimeout:)
                                             userInfo:message
                                              repeats:NO];
}

- (void)fetchChannelBasicCfg:(int)chanelId {
    
}

- (void)loadChannelList {
    self.btnNextEnabled = NO;
    self.btnCancelOrBackEnabled = NO;
    
    [_deviceList removeAllObjects];
    _channelList = [[NSMutableArray alloc] initWithArray:[SAApp.DB zwaveBridgeChannels]];
    
    for(id channel in _channelList) {
        BOOL exists = false;
        for(id fc in _channelBasicCfgToFetch) {
            if (((SAChannel*)fc).device_id == ((SAChannel*)channel).device_id) {
                exists = true;
                break;
            }
        }
        
        if (!exists) {
            [_channelBasicCfgToFetch addObject:channel];
        }
    }
    
    [self fetchChannelBasicCfg:0];
}

- (void)setPage:(UIView *)page {
    [super setPage:page];
    self.backButtonInsteadOfCancel = page != self.welcomePage;
    
    if (page == self.channelSelectionPage) {
        [self loadChannelList];
    }
}

- (IBAction)nextTouch:(nullable id)sender {
    [super nextTouch:sender];
    
    if (self.page == self.welcomePage) {
        self.page = self.channelSelectionPage;
    }
}

- (IBAction)cancelOrBackTouch:(id)sender {
    [super cancelOrBackTouch:sender];
    
    if (self.page == self.welcomePage) {
        [[SAApp UI] showMainVC];
    } else if (self.page == self.channelSelectionPage) {
        self.page = self.welcomePage;
    }
}

@end
