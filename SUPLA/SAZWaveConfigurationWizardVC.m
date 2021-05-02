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
#import "SAChannelBasicCfg.h"
#import "SAPickerField.h"

#define ERROR_TYPE_TIMEOUT 1
#define ERROR_TYPE_DISCONNECTED 2
#define ERROR_TYPE_OTHER 3

#define RESET_TIMEOUT_SEC 15
#define ADD_NODE_BUTTON_PRESS_TIMEOUT_SEC 35
#define ADD_NODE_TIMEOUT_SEC 30
#define REMOVE_NODE_TIMEOUT_SEC 45
#define GET_ASSIGNED_NODE_ID_TIMEOUT_SEC 5
#define GET_BASIC_CFG_TIMEOUT_SEC 5
#define SET_CHANNEL_FUNCTION_TIMEOUT_SEC 5
#define SET_CHANNEL_CAPTION_TIMEOUT_SEC 5
#define ASSIGN_NODE_ID_TIMEOUT_SEC 15
#define GET_NODE_LIST_TIMEOUT_SEC 250

static SAZWaveConfigurationWizardVC *_zwaveConfigurationWizardGlobalRef = nil;

@interface SAZWaveConfigurationWizardVC () <SAPickerFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *welcomePage;
@property (strong, nonatomic) IBOutlet UIView *errorPage;
@property (strong, nonatomic) IBOutlet UIView *channelSelectionPage;
@property (strong, nonatomic) IBOutlet UIView *channelDetailsPage;
@property (strong, nonatomic) IBOutlet UIView *itTakeAWhilePage;
@property (strong, nonatomic) IBOutlet UIView *settingsPage;
@property (strong, nonatomic) IBOutlet UIView *successInfoPage;
@property (weak, nonatomic) IBOutlet UIImageView *errorIcon;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet SAPickerField *pfBridge;
@property (weak, nonatomic) IBOutlet SAPickerField *pfChannel;

@end

@implementation SAZWaveConfigurationWizardVC {
    NSTimer *_anyCalCfgResultWatchdogTimer;
    NSTimer *_watchdogTimer;
    NSMutableArray *_deviceList;
    NSMutableArray *_deviceChannelList;
    NSMutableArray *_channelList;
    NSMutableArray *_channelBasicCfgList;
    NSMutableArray *_channelBasicCfgToFetch;
    SAChannel *_selectedChannel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceList = [[NSMutableArray alloc] init];
    _channelList = [[NSMutableArray alloc] init];
    _deviceChannelList = [[NSMutableArray alloc] init];
    _channelBasicCfgToFetch = [[NSMutableArray alloc] init];
    _channelBasicCfgList = [[NSMutableArray alloc] init];
    self.pfBridge.pf_delegate = self;
    self.pfChannel.pf_delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.page = self.welcomePage;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onCalCfgResult:)
     name:kSACalCfgResult object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onChannelBasicCfg:)
     name:kSAOnChannelBasicCfg object:nil];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)onCalCfgResult:(NSNotification *)notification {
   // SACalCfgResult *result = [SACalCfgResult notificationToDeviceCalCfgResult:notification];
}

-(void)onChannelBasicCfg:(NSNotification *)notification {
    SAChannelBasicCfg *basicCfg = [SAChannelBasicCfg notificationToChannelBasicCfg:notification];
    
    for(SAChannelBasicCfg *cfg in _channelBasicCfgList) {
        if (cfg.channelId == basicCfg.channelId) {
            [_channelBasicCfgList removeObject:cfg];
            break;
        }
    }
    
    [_channelBasicCfgList addObject:basicCfg];
    
    if (_channelBasicCfgToFetch.count) {
        [self fetchChannelBasicCfg:0];
    } else {
        [self watchdogDeactivate];
        self.btnNextEnabled = YES;
        self.preloaderVisible = NO;
        
        if (self.page == self.channelDetailsPage) {
            
        } else if (self.page == self.channelSelectionPage
                   && _deviceList.count == 0) {
            for(SAChannel *channel in _channelList) {
                NSNumber *dev_id = [NSNumber numberWithInt:channel.device_id];
                if (![_deviceList containsObject:dev_id]) {
                    [_deviceList addObject:dev_id];
                }
            }
            [self.pfBridge update];
        }
    }
}

- (void)hideInfoMessage {
    
}

- (NSString*)btnNextTitleForThePage:(UIView*)page {
    if (page == self.errorPage) {
        return NSLocalizedString(@"Exit", nil);
    } else if (page == self.successInfoPage) {
        return NSLocalizedString(@"OK", nil);
    }
    
    return NSLocalizedString(@"Next", nil);
}

- (void)showError:(int)type withMessage:(NSString *)message {
    [self watchdogDeactivate];
    [self.errorMessage setText: NSLocalizedString(message, nil)];
    [self setPreloaderVisible:NO];
    self.btnNextTitle = [self btnNextTitleForThePage:self.page];
    [self hideInfoMessage];
    UIImage *img = nil;
    switch(type) {
        case ERROR_TYPE_DISCONNECTED:
            img = [UIImage imageNamed:@"bridge_disconnected"];
            break;
        case ERROR_TYPE_TIMEOUT:
            img = [UIImage imageNamed:@"zwave_timeout"];
            break;
        default:
            img = [UIImage imageNamed:@"wizard_error"];
            break;
    }
    [self.errorIcon setImage:img];
    self.page = self.errorPage;
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
    [self showError:ERROR_TYPE_DISCONNECTED withMessage:@"The z-wave bridge is not responding. Check if the bridge is connected to the server."];
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

- (void)fetchChannelBasicCfg:(int)channelId {
    if (channelId == 0
        && _channelBasicCfgToFetch.count) {
        channelId = ((SAChannel*)[_channelBasicCfgToFetch objectAtIndex:0]).remote_id;
        [_channelBasicCfgToFetch removeObjectAtIndex:0];
    }
    
    if (channelId == 0) {
        return;
    }
    
    [self watchdogActivateWithTime:GET_BASIC_CFG_TIMEOUT_SEC timeoutMessage:@"The waiting time for basic channel configuration data has expired." calCfg:NO];
    
    [SAApp.SuplaClient getChannelBasicCfg:channelId];
}

- (void)loadChannelList {
    self.btnNextEnabled = NO;
    
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
        self.btnNextEnabled = NO;
        self.preloaderVisible = YES;
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

- (NSInteger)numberOfRowsInPickerField:(SAPickerField *)pickerField {
    if (pickerField == self.pfBridge) {
        return _deviceList.count;
    } else if (pickerField == self.pfChannel) {
        return _deviceChannelList.count;
    }
    return 0;
}

- (NSInteger)selectedRowIndexInPickerField:(SAPickerField *)pickerField {
    return -1;
}

- (void)pickerField:(SAPickerField *)pickerField tappedAtRow:(NSInteger)index {
    if (pickerField == self.pfBridge) {
        [_deviceChannelList removeAllObjects];
        int devId = [[_deviceList objectAtIndex:index] intValue];
        for(SAChannel *channel in _channelList) {
            if (channel.device_id == devId) {
                [_deviceChannelList addObject:channel];
            }
        }
        
        _selectedChannel = [_deviceChannelList firstObject];
        [self.pfChannel update];
    }
}

- (NSString *)channelNameOfChannel:(SAChannel *)channel customFunc:(NSNumber*)func {
    return [NSString stringWithFormat:@"#%i %@",
            channel.remote_id,
            [SAChannelBase getNonEmptyCaptionOfChannel:channel customFunc:func]];
}

- (NSString *)pickerField:(SAPickerField *)pickerField titleForRow:(NSInteger)row {
    if (row < 0) {
        return nil;
    }
    
    NSString *result = nil;
    
    if (pickerField == self.pfBridge) {
        if (row < _deviceList.count) {
            NSNumber *devId = [_deviceList objectAtIndex:row];
            result = [NSString stringWithFormat:@"#%@", devId];
            for(SAChannelBasicCfg *basicCfg in _channelBasicCfgList) {
                if (basicCfg.deviceId == [devId intValue]) {
                    result = [NSString stringWithFormat:@"%@ %@", result, basicCfg.deviceName];
                    break;
                }
            }
        }
    } else if (pickerField == self.pfChannel) {
        if (row < _deviceChannelList.count) {
            return [self channelNameOfChannel:[_deviceChannelList objectAtIndex:row] customFunc:nil];
        }
    }

    return result;
}

@end
