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
#import "SAChannelCaptionSetResult.h"
#import "SAChannelFunctionSetResult.h"
#import "SAPickerField.h"
#import "SACalCfgResult.h"
#import "SAZWaveAssignedNodeIdResult.h"

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

#define PRELOADER_DOT_COUNT 8

static SAZWaveConfigurationWizardVC *_zwaveConfigurationWizardGlobalRef = nil;

@interface SAZWaveConfigurationWizardVC () <SAPickerFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *welcomePage;
@property (strong, nonatomic) IBOutlet UIView *errorPage;
@property (strong, nonatomic) IBOutlet UIView *channelSelectionPage;
@property (strong, nonatomic) IBOutlet UIView *channelDetailsPage;
@property (strong, nonatomic) IBOutlet UIView *itTakeAWhilePage;
@property (strong, nonatomic) IBOutlet UIView *zwaveSettingsPage;
@property (strong, nonatomic) IBOutlet UIView *successInfoPage;
@property (weak, nonatomic) IBOutlet UIImageView *errorIcon;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;
@property (weak, nonatomic) IBOutlet SAPickerField *pfBridge;
@property (weak, nonatomic) IBOutlet SAPickerField *pfChannel;
@property (weak, nonatomic) IBOutlet UILabel *lDeviceName;
@property (weak, nonatomic) IBOutlet UILabel *lSoftwareVersion;
@property (weak, nonatomic) IBOutlet UILabel *lDeviceId;
@property (weak, nonatomic) IBOutlet UILabel *lChannelId;
@property (weak, nonatomic) IBOutlet UILabel *lChannelNumber;
@property (weak, nonatomic) IBOutlet SAPickerField *pfFunction;
@property (weak, nonatomic) IBOutlet UITextField *tfCaption;
@property (weak, nonatomic) IBOutlet UILabel *lSelectedChannel;
@property (weak, nonatomic) IBOutlet SAPickerField *pfNodeList;
@property (weak, nonatomic) IBOutlet UILabel *lInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnlAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnrAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnlDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnrDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnlReset;
@property (weak, nonatomic) IBOutlet UIButton *btnrReset;

@end

@implementation SAZWaveConfigurationWizardVC {
    NSTimer *_anyCalCfgResultWatchdogTimer;
    NSTimer *_watchdogTimer;
    NSTimer *_waitMessagePreloaderTimer;
    NSMutableArray *_deviceList;
    NSMutableArray *_devicesToRestart;
    NSMutableArray *_deviceChannelList;
    NSMutableArray *_channelList;
    NSMutableArray *_channelBasicCfgList;
    NSMutableArray *_channelBasicCfgToFetch;
    NSMutableArray *_functionList;
    NSMutableArray *_nodeList;
    
    NSNumber *_selectedDeviceId;
    SAChannel *_selectedChannel;
    int _selectedFunc;
    int _progress;
    int _preloaderVisibleDotCount;
    unsigned char _assignedNodeId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceList = [[NSMutableArray alloc] init];
    _channelList = [[NSMutableArray alloc] init];
    _deviceChannelList = [[NSMutableArray alloc] init];
    _channelBasicCfgToFetch = [[NSMutableArray alloc] init];
    _channelBasicCfgList = [[NSMutableArray alloc] init];
    _functionList = [[NSMutableArray alloc] init];
    _nodeList = [[NSMutableArray alloc] init];
    
    self.pfBridge.pf_delegate = self;
    self.pfChannel.pf_delegate = self;
    self.pfFunction.pf_delegate = self;
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

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onChannelCaptionSetResult:)
     name:kSAOnChannelCaptionSetResult object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onChannelFunctionSetResult:)
     name:kSAOnChannelFunctionSetResult object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onZWaveAssignedNodeIdResult:)
     name:kSAOnZWaveAssignedNodeIdResult object:nil];
    
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
    SACalCfgResult *result = [SACalCfgResult notificationToDeviceCalCfgResult:notification];
    if (result == nil) {
        return;
    }
    
    if (result.command != SUPLA_CALCFG_CMD_DEBUG_STRING) {
        NSLog(@"onCalCfg: %i,%i,%i,%lu",
              result.channelID,
              result.command,
              result.result,
              (unsigned long)(result.data ? result.data.length : 0));
    }
    
    if (_selectedChannel) {
        SAChannel *channel = [SAApp.DB fetchChannelById:result.channelID];
        if (channel && channel.device_id == _selectedChannel.device_id) {
            [self anyCalCfgResultWatchdogDeactivate];
        }
    }
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
        self.btnCancelOrBackEnabled = YES;
        self.btnNextEnabled = YES;
        self.preloaderVisible = NO;
        
        if (self.page == self.channelDetailsPage) {
            [self updateChannelDetailsPageWithBasicCfg:basicCfg];
        } else if (self.page == self.channelSelectionPage
                   && _deviceList.count == 0) {
            for(SAChannel *channel in _channelList) {
                NSNumber *dev_id = [NSNumber numberWithInt:channel.device_id];
                if (![_deviceList containsObject:dev_id]) {
                    [_deviceList addObject:dev_id];
                }
            }
            _selectedDeviceId = nil;
            if (_deviceList.count) {
                _selectedDeviceId = [_deviceList firstObject];
            }
            
            [self pickerField:self.pfBridge tappedAtRow:[self selectedRowIndexInPickerField:self.pfBridge]];
            [self.pfBridge update];
        }
    }
}

-(void)_onChannelFunctionSetResult:(SAChannelFunctionSetResult *)result {
    [self watchdogDeactivate];
    
    if (result == nil || result.resultCode != SUPLA_RESULTCODE_TRUE) {
        int code = result ? result.resultCode : -1;
        NSString *errStr = nil;
        
        switch (code) {
            case SUPLA_RESULTCODE_DENY_CHANNEL_BELONG_TO_GROUP:
                errStr = @"You cannot change the function of a channel that belongs to a group.";
                break;
            case SUPLA_RESULTCODE_DENY_CHANNEL_HAS_SCHEDULE:
                errStr = @"You cannot change the function of a channel that has a schedule.";
                break;
            case SUPLA_RESULTCODE_DENY_CHANNEL_IS_ASSOCIETED_WITH_SCENE:
                errStr = @"You cannot change the function of a channel that is associated with a scene.";
                break;
        }
        
        if (errStr == nil) {
            errStr = [NSString stringWithFormat:NSLocalizedString(@"The channel function change failed. Code %i", nil), code];
        }
        
        [self showError:ERROR_TYPE_OTHER withMessage:errStr];
        return;
    }
    
    if (result.function == 0) {
        [[SAApp UI] showMainVC];
    } else {
        [self fetchChannelBasicCfg:result.remoteId];
        
        if (_nodeList.count == 0) {
            self.page = self.itTakeAWhilePage;
        } else {
            self.page = self.zwaveSettingsPage;
        }
    }
}

-(void)onChannelFunctionSetResult:(NSNotification *)notification {
    [self watchdogDeactivate];
    [self _onChannelFunctionSetResult:[SAChannelFunctionSetResult notificationToCaptionSetResult:notification]];
}

-(BOOL)timeoutResultNotDisplayedWithCode:(int) resultCode {
    if (resultCode == SUPLA_CALCFG_RESULT_TIMEOUT
        && _watchdogTimer
        && _watchdogTimer.userInfo) {
        [self showError:ERROR_TYPE_TIMEOUT withMessage:_watchdogTimer.userInfo];
        return NO;
    }
    return YES;
}

-(void)showUnexpectedResponseWithResultCode:(int) resultCode {
    
    NSString *method;
    @try {
        NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
        NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
        NSMutableArray *array = [NSMutableArray
                                 arrayWithArray:[sourceString
                                                 componentsSeparatedByCharactersInSet:separatorSet]];
        [array removeObject:@""];
        method = [array objectAtIndex:4];
    } @catch ( NSException *e ) {
        method = @"???";
    }

    NSString *errMsg = [NSString stringWithFormat:
                        NSLocalizedString(@"Device response not as expected. Method: \"%@\" Code: %i", nil),
                        method, resultCode];
    [self showError:ERROR_TYPE_OTHER withMessage:errMsg];

}

-(void)onZWaveAssignedNodeIdResult:(NSNotification *)notification {
    SAZWaveAssignedNodeIdResult *result = [SAZWaveAssignedNodeIdResult notificationToAssignedNodeIdResult:notification];
    if (result == nil
        || result.resultCode == SUPLA_CALCFG_RESULT_IN_PROGRESS) {
        return;
    }
        
    if (result.resultCode != SUPLA_CALCFG_RESULT_TRUE) {
        if ([self timeoutResultNotDisplayedWithCode:result.resultCode]) {
            [self showUnexpectedResponseWithResultCode:result.resultCode];
        }
        return;
    }
    
    [self watchdogDeactivate];
    
    _assignedNodeId = result.nodeId;
    
    if (_nodeList.count == 0) {
        [self watchdogActivateWithTime:GET_NODE_LIST_TIMEOUT_SEC
                        timeoutMessage:@"The waiting time for the list of z-wave devices has expired."
                        calCfg:YES];
        [SAApp.SuplaClient zwaveGetNodeListForDeviceId:_selectedChannel.device_id];
    } else {
        
    }
}

- (void)applyChannelFunctionChange {
    
    SAChannelBasicCfg *cfg = [self selectedChannelBasicCfg];
    if (cfg == nil) {
        return;
    }
    
    self.btnNextEnabled = NO;
    self.btnCancelOrBackEnabled = NO;
    self.preloaderVisible = YES;
    
    if (_selectedFunc == cfg.channelFunc) {
        SAChannelFunctionSetResult *result =
        [[SAChannelFunctionSetResult alloc] initWithRemoteId:cfg.channelId
         resultCode:SUPLA_RESULTCODE_TRUE function:cfg.channelFunc];
        
        [self _onChannelFunctionSetResult:result];
    } else {
        [self watchdogActivateWithTime:SET_CHANNEL_FUNCTION_TIMEOUT_SEC
                        timeoutMessage:@"The waiting time for changing the channel function has expired."
                                calCfg:NO];
        
       [SAApp.SuplaClient setFunction:_selectedFunc forChannelId:_selectedChannel.remote_id];
    }
}

-(void)onChannelCaptionSetResult:(NSNotification *)notification {
    [self watchdogDeactivate];
    
    SAChannelCaptionSetResult *result = [SAChannelCaptionSetResult notificationToCaptionSetResult:notification];
    if (result) {
        if (result.resultCode == SUPLA_RESULTCODE_TRUE) {
            [self applyChannelFunctionChange];
        } else {
            NSString *errMsg = [NSString stringWithFormat:
                                NSLocalizedString(@"The channel caption change failed. Code %i", nil),
                                result.resultCode];
            [self showError:ERROR_TYPE_OTHER withMessage: errMsg];
        }

    }
}


- (void)applyChannelCaptionChange {
    SAChannelBasicCfg *cfg = [self selectedChannelBasicCfg];
    if (cfg == nil) {
        return;
    }
    
    self.btnNextEnabled = NO;
    self.btnCancelOrBackEnabled = NO;
    self.preloaderVisible = YES;
    
    if ([self.tfCaption.text isEqual:cfg.channelCaption]) {
        [self applyChannelFunctionChange];
    } else {
        [self watchdogActivateWithTime:SET_CHANNEL_CAPTION_TIMEOUT_SEC
                        timeoutMessage:@"The waiting time for changing the channel function has expired."
                                calCfg:NO];
        
        [SAApp.SuplaClient setChannelCaption:_selectedChannel.remote_id caption:self.tfCaption.text];
    }
    
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

- (void)hideInfoMessage {
    if (_waitMessagePreloaderTimer) {
        [_waitMessagePreloaderTimer invalidate];
        _waitMessagePreloaderTimer = nil;
    }
    
    self.lInfo.hidden = YES;
}

- (void)showInfoMessage:(NSString *)msg {
    [self.lInfo setText:NSLocalizedString(msg, nil)];
    self.lInfo.hidden = NO;
}

- (void)onWaitMessagePreloaderTimer:(NSTimer*)timer {
    NSString *msg = [timer.userInfo objectAtIndex:0];
    NSNumber *progress = [timer.userInfo objectAtIndex:1];
    
    if ([progress boolValue]) {
        msg = [NSString stringWithFormat:@"%@ %i%% ", msg, _progress];
    }
    
    for(int a=0;a<PRELOADER_DOT_COUNT;a++) {
        msg = [NSString stringWithFormat:@"%@.", msg];
    }
    
    NSMutableAttributedString *attrTxt = [[NSMutableAttributedString alloc]
                                          initWithString:msg];
    
    int pos = (int)msg.length - (PRELOADER_DOT_COUNT - _preloaderVisibleDotCount);
    [attrTxt addAttribute:NSForegroundColorAttributeName
                 value:self.lInfo.backgroundColor
                 range:NSMakeRange(pos, msg.length-pos)];
    
    _preloaderVisibleDotCount++;
    if (_preloaderVisibleDotCount > PRELOADER_DOT_COUNT) {
        _preloaderVisibleDotCount = 0;
    }
    
    [self.lInfo setAttributedText:attrTxt];
    
}

- (void)showWaitMessage:(NSString*)msg withTimeout:(int)timeout
         timeoutMessage:(NSString *)timeoutMessage showProgress:(BOOL)progress {
    [self hideInfoMessage];
    [self showInfoMessage:msg];
    
    _waitMessagePreloaderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                            target:self
                                            selector:@selector(onWaitMessagePreloaderTimer:)
                                            userInfo:@[msg, [NSNumber numberWithBool:progress]]
                                            repeats:YES];
    
    [self watchdogActivateWithTime:timeout timeoutMessage:timeoutMessage calCfg:YES];
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

- (void)zwaveNodeListRequest {
    if (_selectedChannel == nil) {
        return;
    }
    
    [self showWaitMessage: @"Searching the z-wave network to build a list of devices."
          withTimeout: GET_ASSIGNED_NODE_ID_TIMEOUT_SEC
          timeoutMessage:@"The waiting time for the ID of the assigned z-wave device has expired."
          showProgress:YES];
    
    [SAApp.SuplaClient zwaveGetAssignedNodeIdForChannelId:_selectedChannel.remote_id];
}

- (void)setPage:(UIView *)page {
    [super setPage:page];
    
    self.btnNextEnabled = YES;
    self.btnCancelOrBackEnabled = YES;
    self.backButtonInsteadOfCancel = page != self.welcomePage;
    
    if (page == self.errorPage) {
        self.btnNextTitle = NSLocalizedString(@"Exit", nil) ;
    } else if (page == self.successInfoPage) {
        self.btnNextTitle = NSLocalizedString(@"OK", nil) ;
    } else {
        self.btnNextTitle = NSLocalizedString(@"Next", nil) ;
    }
    
    if (page == self.channelSelectionPage) {
        [self loadChannelList];
    } else if (page == self.channelDetailsPage) {
        [self updateChannelDetailsPageWithBasicCfg:nil];
    } else if (page == self.zwaveSettingsPage) {
        [self zwaveNodeListRequest];
    }
}

- (void)updateChannelDetailsPageWithBasicCfg:(SAChannelBasicCfg*)basicCfg {
    if (_selectedChannel == nil) {
        return;
    }
    
    [_functionList removeAllObjects];
    [_functionList addObject:[NSNumber numberWithInt:0]];
    
    if (basicCfg == nil) {
        self.tfCaption.enabled = NO;
        self.pfFunction.enabled = NO;
        [self fetchChannelBasicCfg:_selectedChannel.remote_id];
        return;
    }
    
    self.tfCaption.enabled = YES;
    self.pfFunction.enabled = YES;
    self.btnCancelOrBackEnabled = YES;
    self.btnNextEnabled = YES;
    
    NSNumber *devId = [NSNumber numberWithInt:_selectedChannel.device_id];
    
    if (![_devicesToRestart containsObject:devId]) {
        [_devicesToRestart addObject:devId];
    }
    
    [self.lDeviceName setText: basicCfg.deviceName];
    [self.lSoftwareVersion setText:basicCfg.deviceSoftVer];
    [self.lChannelNumber setText:[NSString stringWithFormat:@"%i", basicCfg.channelNumber]];
    [self.lChannelId setText:[NSString stringWithFormat:@"%i", basicCfg.channelId]];
    [self.lDeviceId setText:[NSString stringWithFormat:@"%i", basicCfg.deviceId]];
    [self.tfCaption setText:basicCfg.channelCaption];
    
    for (int a = 0; a < 32; a++) {
        int func = [SAChannelBase functionBitToFunctionNumber:basicCfg.channelFuncList & (1 << a)];
        if (func > 0) {
            [_functionList addObject:[NSNumber numberWithInt:func]];
        }
    }
    
    _selectedFunc = basicCfg.channelFunc;
    [self.pfFunction update];
}

-(SAChannelBasicCfg*)selectedChannelBasicCfg {
    if (_selectedChannel) {
        for(SAChannelBasicCfg *cfg in _channelBasicCfgList) {
            if (cfg.channelId == _selectedChannel.remote_id) {
                return cfg;
            }
        }
    }
    
    return nil;
}

- (IBAction)nextTouch:(nullable id)sender {
    [super nextTouch:sender];
    
    if (self.page == self.errorPage) {
        [[SAApp UI] showMainVC];
    } else if (self.page == self.welcomePage) {
        self.preloaderVisible = YES;
        self.page = self.channelSelectionPage;
    } else if (self.page == self.channelSelectionPage) {
        self.page = self.channelDetailsPage;
    } else if (self.page == self.channelDetailsPage) {
        [self applyChannelCaptionChange];
    } else if (self.page == self.itTakeAWhilePage) {
        self.page = self.zwaveSettingsPage;
    }
}

- (IBAction)cancelOrBackTouch:(id)sender {
    [super cancelOrBackTouch:sender];
    
    if (self.page == self.errorPage) {
        if (self.previousPage) {
            self.page = self.previousPage;
        } else {
            [[SAApp UI] showMainVC];
        }
    } else if (self.page == self.welcomePage) {
        [[SAApp UI] showMainVC];
    } else if (self.page == self.channelSelectionPage) {
        self.page = self.welcomePage;
    } else if (self.page == self.channelDetailsPage) {
        self.page = self.channelSelectionPage;
    } else if (self.page == self.itTakeAWhilePage
               || self.page == self.zwaveSettingsPage) {
        self.page = self.channelDetailsPage;
    }
}

- (NSInteger)numberOfRowsInPickerField:(SAPickerField *)pickerField {
    if (pickerField == self.pfBridge) {
        return _deviceList.count;
    } else if (pickerField == self.pfChannel) {
        return _deviceChannelList.count;
    } else if (pickerField == self.pfFunction) {
        return _functionList.count;
    }
    return 0;
}

- (NSInteger)selectedRowIndexInPickerField:(SAPickerField *)pickerField {
    

    int n=0;
    if (pickerField == self.pfBridge) {
        for(NSNumber *devId in _deviceList) {
            if ([devId isEqual:_selectedDeviceId]) {
                return n;
            }
            n++;
        }
    } else if (pickerField == self.pfChannel) {
        if (_selectedChannel != nil) {
            for(SAChannel *channel in _deviceChannelList) {
                if (channel.remote_id == _selectedChannel.remote_id) {
                    return n;
                }
                n++;
            }
        }

    } else if (pickerField == self.pfFunction) {
        if (_selectedChannel != nil) {
            for(NSNumber *func in _functionList) {
                if ([func intValue] == _selectedFunc) {
                    return n;
                }
                n++;
            }
        }
    }
    return -1;
}

- (void)pickerField:(SAPickerField *)pickerField tappedAtRow:(NSInteger)index {
    if (pickerField == self.pfBridge) {
        [_deviceChannelList removeAllObjects];
        if (index >= 0 && index < _deviceList.count) {
            _selectedDeviceId = [_deviceList objectAtIndex:index];
            int devId = [_selectedDeviceId intValue];
            for(SAChannel *channel in _channelList) {
                if (channel.device_id == devId) {
                    [_deviceChannelList addObject:channel];
                }
            }
        }
        
        if (_selectedChannel == nil
            || _selectedChannel.device_id != _selectedDeviceId.intValue) {
            [self pickerField:self.pfChannel tappedAtRow:_deviceChannelList.count ? 0 : -1];
            [self.pfChannel update];
        }
    } else if (pickerField == self.pfChannel) {
        _selectedChannel = nil;
        
        if (index >= 0 && index < _deviceChannelList.count) {
            _selectedChannel = [_deviceChannelList objectAtIndex:index];
            _selectedFunc = _selectedChannel.func;
        }
        
        [self.pfFunction update];
    } else if (pickerField == self.pfFunction) {
        if (index >= 0 && index < _functionList.count) {
            _selectedFunc = [[_functionList objectAtIndex:index] intValue];
        }
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
    } else if (pickerField == self.pfFunction) {
        if (row < _functionList.count) {
            return [SAChannelBase getFunctionName:[[_functionList objectAtIndex:row] intValue]];
        }
    }

    return result;
}

- (IBAction)btnAddTouch:(id)sender {
}

- (IBAction)btnDeleteTouch:(id)sender {
}

- (IBAction)btnResetTouch:(id)sender {
}

@end
