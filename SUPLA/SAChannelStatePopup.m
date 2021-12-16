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

#import "SAChannelStatePopup.h"
#import "SAChannelStateExtendedValue.h"

#import "SuplaApp.h"
#import "SASuperuserAuthorizationDialog.h"
#import "SALightsourceLifespanSettingsDialog.h"

#define REFRESH_INTERVAL_SEC 4

@interface SAChannelStatePopup () <SASuperuserAuthorizationDialogDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UILabel *lTitle;
@property (weak, nonatomic) IBOutlet UILabel *lChannelIdTitle;
@property (weak, nonatomic) IBOutlet UILabel *lChannelId;
@property (weak, nonatomic) IBOutlet UILabel *lIPTitle;
@property (weak, nonatomic) IBOutlet UILabel *lIP;
@property (weak, nonatomic) IBOutlet UILabel *lMACTitle;
@property (weak, nonatomic) IBOutlet UILabel *lMAC;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryLevelTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryLevel;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryPoweredTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryPowered;
@property (weak, nonatomic) IBOutlet UILabel *lWifiRSSITitle;
@property (weak, nonatomic) IBOutlet UILabel *lWifiRSSI;
@property (weak, nonatomic) IBOutlet UILabel *lWifiSignalStrengthTitle;
@property (weak, nonatomic) IBOutlet UILabel *lWifiSignalStrength;
@property (weak, nonatomic) IBOutlet UILabel *lBridgeNodeOnlineTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBridgeNodeOnline;
@property (weak, nonatomic) IBOutlet UILabel *lBridgeNodeSignalStrengthTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBridgeNodeSignalStrength;
@property (weak, nonatomic) IBOutlet UILabel *lUptimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lUptime;
@property (weak, nonatomic) IBOutlet UILabel *lConnectionUptimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lConnectionUptime;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryHealthTitle;
@property (weak, nonatomic) IBOutlet UILabel *lBatteryHealth;
@property (weak, nonatomic) IBOutlet UILabel *lConnectionResetCauseTitle;
@property (weak, nonatomic) IBOutlet UILabel *lConnectionResetCause;
@property (weak, nonatomic) IBOutlet UILabel *lLightsourceLifespanTitle;
@property (weak, nonatomic) IBOutlet UILabel *lLightsourceLifespan;
@property (weak, nonatomic) IBOutlet UILabel *lLightsourceOperatingTimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lLightsourceOperatingTime;
@property (weak, nonatomic) IBOutlet UIView *vList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actIndHeight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actInd;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnResetHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IPTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IPBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MACTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MACBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BatteryLevelTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BatteryLevelBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BatteryPoweredTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BatteryPoweredBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WiFiRSSITitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WiFiRSSIBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WiFiSignalStrengthTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WiFiSignalStrengthBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BridgeNodeOnlineTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BridgeNodeOnlineBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BridgeNodeSignalStrengthTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BridgeNodeSignalStrengthBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *UptimeTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *UptimeBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConnectionUptimeTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConnectionUptimeBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BatteryHealthTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BatteryHealthBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConnectionResetCauseTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConnectionResetCauseBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LightsourceLifespanTitleBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LightsourceLifespanBottomMargin;
- (IBAction)resetBtnTouchDown:(id)sender;

@end

static SAChannelStatePopup *_channelStatePopupGlobalRef = nil;

@implementation SAChannelStatePopup {
    SAChannel *_channel;
    CGFloat _btnResetOriginalHeight;
    CGFloat _actIndOriginalHeight;
    SAChannelStateExtendedValue *_lastState;
    NSTimer *_refreshTimer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _btnResetOriginalHeight = self.btnResetHeight.constant;
        _actIndOriginalHeight = self.actIndHeight.constant;
        [self.btnReset setTitle:NSLocalizedString(@"CHANGE THE LIGHT SOURCE LIFESPAN SETTINGS", nil) forState:UIControlStateNormal];
        return self;
    }
    
    return nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelValueChanged:)
                                                 name:kSAChannelValueChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelState:)
                                                 name:kSAOnChannelState object:nil];
}

- (void)onChannelValueChanged:(NSNotification *)notification {
    
    if ( notification.userInfo == nil
        || _channel == nil
        || ![SADialog viewControllerIsPresented:self] ) return;
    
    NSNumber *Id = (NSNumber *)[notification.userInfo objectForKey:@"remoteId"];
    NSNumber *IsGroup = (NSNumber *)[notification.userInfo objectForKey:@"isGroup"];
    
    if ( ![IsGroup boolValue] && _channel.remote_id == [Id intValue]  ) {
        [self setChannel:[[SAApp DB] fetchChannelById:[Id intValue]]];
    }
}

- (void)onChannelState:(NSNotification *)notification {
    
    if ( notification.userInfo == nil
        || _channel == nil
        || ![SADialog viewControllerIsPresented:self] ) return;
    
    SAChannelStateExtendedValue *state = (SAChannelStateExtendedValue *)[notification.userInfo objectForKey:@"state"];
    [self updateWithState:state];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self cancelRefreshTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateWithState:(SAChannelStateExtendedValue *)state {

    BOOL stopAnimating = NO;
    _lastState = state;
    
    if (state && state.channelId != nil) {
        [self.lChannelIdTitle setText:NSLocalizedString(@"Channel Id", nil)];
        [self.lChannelId setText:state.channelIdString];
        self.lChannelIdTitle.hidden = NO;
        self.lChannelId.hidden = NO;
        stopAnimating = YES;
    } else {
        [self.lChannelIdTitle setText:@""];
        [self.lChannelId setText:@""];
        self.lChannelIdTitle.hidden = YES;
        self.lChannelId.hidden = YES;
    }
    
    if (state && state.ipv4 != nil) {
        [self.lIPTitle setText:NSLocalizedString(@"IP", nil)];
        [self.lIP setText:state.ipv4String];
        self.lIPTitle.hidden = NO;
        self.lIP.hidden = NO;
        self.IPTitleBottomMargin.constant = 2;
        self.IPBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lIPTitle setText:@""];
        [self.lIP setText:@""];
        self.lIPTitle.hidden = YES;
        self.lIP.hidden = YES;
        self.IPTitleBottomMargin.constant = 0;
        self.IPBottomMargin.constant = 0;
    }

    if (state && state.macAddress != nil) {
        [self.lMACTitle setText:NSLocalizedString(@"MAC", nil)];
        [self.lMAC setText:state.macAddressString];
        self.lMACTitle.hidden = NO;
        self.lMAC.hidden = NO;
        self.MACTitleBottomMargin.constant = 2;
        self.MACBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lMACTitle setText:@""];
        [self.lMAC setText:@""];
        self.lMACTitle.hidden = YES;
        self.lMAC.hidden = YES;
        self.MACTitleBottomMargin.constant = 0;
        self.MACBottomMargin.constant = 0;
    }
    
    if (state && state.batteryLevel != nil) {
        [self.lBatteryLevelTitle setText:NSLocalizedString(@"Battery level", nil)];
        [self.lBatteryLevel setText:state.batteryLevelString];
        self.lBatteryLevelTitle.hidden = NO;
        self.lBatteryLevel.hidden = NO;
        self.BatteryLevelTitleBottomMargin.constant = 2;
        self.BatteryLevelBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lBatteryLevelTitle setText:@""];
        [self.lBatteryLevel setText:@""];
        self.lBatteryLevelTitle.hidden = YES;
        self.lBatteryLevel.hidden = YES;
        self.BatteryLevelTitleBottomMargin.constant = 0;
        self.BatteryLevelBottomMargin.constant = 0;
    }

    if (state && state.isBatteryPowered != nil) {
        [self.lBatteryPoweredTitle setText:NSLocalizedString(@"Battery powered", nil)];
        [self.lBatteryPowered setText:state.isBatteryPoweredString];
        self.lBatteryPoweredTitle.hidden = NO;
        self.lBatteryPowered.hidden = NO;
        self.BatteryPoweredTitleBottomMargin.constant = 2;
        self.BatteryPoweredBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lBatteryPoweredTitle setText:@""];
        [self.lBatteryPowered setText:@""];
        self.lBatteryPoweredTitle.hidden = YES;
        self.lBatteryPowered.hidden = YES;
        self.BatteryPoweredTitleBottomMargin.constant = 0;
        self.BatteryPoweredBottomMargin.constant = 0;
    }

    if (state && state.wiFiRSSI != nil) {
        [self.lWifiRSSITitle setText:NSLocalizedString(@"Wifi RSSI", nil)];
        [self.lWifiRSSI setText:state.wiFiRSSIString];
        self.lWifiRSSITitle.hidden = NO;
        self.lWifiRSSI.hidden = NO;
        self.WiFiRSSITitleBottomMargin.constant = 2;
        self.WiFiRSSIBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lWifiRSSITitle setText:@""];
        [self.lWifiRSSI setText:@""];
        self.lWifiRSSITitle.hidden = YES;
        self.lWifiRSSI.hidden = YES;
        self.WiFiRSSITitleBottomMargin.constant = 0;
        self.WiFiRSSIBottomMargin.constant = 0;
    }

    if (state && state.wiFiSignalStrength != nil) {
        [self.lWifiSignalStrengthTitle setText:NSLocalizedString(@"Wifi signal strength", nil)];
        [self.lWifiSignalStrength setText:state.wiFiSignalStrengthString];
        self.lWifiSignalStrengthTitle.hidden = NO;
        self.lWifiSignalStrength.hidden = NO;
        self.WiFiSignalStrengthTitleBottomMargin.constant = 2;
        self.WiFiSignalStrengthBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lWifiSignalStrengthTitle setText:@""];
        [self.lWifiSignalStrength setText:@""];
        self.lWifiSignalStrengthTitle.hidden = YES;
        self.lWifiSignalStrength.hidden = YES;
        self.WiFiSignalStrengthTitleBottomMargin.constant = 0;
        self.WiFiSignalStrengthBottomMargin.constant = 0;
    }
    
    if (state && state.isBridgeNodeOnline != nil) {
        [self.lBridgeNodeOnlineTitle setText:NSLocalizedString(@"Bridge node - online", nil)];
        [self.lBridgeNodeOnline setText:state.isBridgeNodeOnlineString];
        self.lBridgeNodeOnlineTitle.hidden = NO;
        self.lBridgeNodeOnline.hidden = NO;
        self.BridgeNodeOnlineTitleBottomMargin.constant = 2;
        self.BridgeNodeOnlineBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lBridgeNodeOnlineTitle setText:@""];
        [self.lBridgeNodeOnline setText:@""];
        self.lBridgeNodeOnlineTitle.hidden = YES;
        self.lBridgeNodeOnline.hidden = YES;
        self.BridgeNodeOnlineTitleBottomMargin.constant = 0;
        self.BridgeNodeOnlineBottomMargin.constant = 0;
    }
    
    if (state && state.bridgeNodeSignalStrength != nil) {
        [self.lBridgeNodeSignalStrengthTitle setText:NSLocalizedString(@"Bridge node - signal strength", nil)];
        [self.lBridgeNodeSignalStrength setText:state.bridgeNodeSignalStrengthString];
        self.lBridgeNodeSignalStrengthTitle.hidden = NO;
        self.lBridgeNodeSignalStrength.hidden = NO;
        self.BridgeNodeSignalStrengthTitleBottomMargin.constant = 2;
        self.BridgeNodeSignalStrengthBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lBridgeNodeSignalStrengthTitle setText:@""];
        [self.lBridgeNodeSignalStrength setText:@""];
        self.lBridgeNodeSignalStrengthTitle.hidden = YES;
        self.lBridgeNodeSignalStrength.hidden = YES;
        self.BridgeNodeSignalStrengthTitleBottomMargin.constant = 0;
        self.BridgeNodeSignalStrengthBottomMargin.constant = 0;
    }

    if (state && state.uptime != nil) {
        [self.lUptimeTitle setText:NSLocalizedString(@"Uptime", nil)];
        [self.lUptime setText:state.uptimeString];
        self.lUptimeTitle.hidden = NO;
        self.lUptime.hidden = NO;
        self.UptimeTitleBottomMargin.constant = 2;
        self.UptimeBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lUptimeTitle setText:@""];
        [self.lUptime setText:@""];
        self.lUptimeTitle.hidden = YES;
        self.lUptime.hidden = YES;
        self.UptimeTitleBottomMargin.constant = 0;
        self.UptimeBottomMargin.constant = 0;
    }
    
    if (state && state.connectionUptime != nil) {
        [self.lConnectionUptimeTitle setText:NSLocalizedString(@"Connection uptime", nil)];
        [self.lConnectionUptime setText:state.connectionUptimeString];
        self.lConnectionUptimeTitle.hidden = NO;
        self.lConnectionUptime.hidden = NO;
        self.ConnectionUptimeTitleBottomMargin.constant = 2;
        self.ConnectionUptimeBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lConnectionUptimeTitle setText:@""];
        [self.lConnectionUptime setText:@""];
        self.lConnectionUptimeTitle.hidden = YES;
        self.lConnectionUptime.hidden = YES;
        self.ConnectionUptimeTitleBottomMargin.constant = 0;
        self.ConnectionUptimeBottomMargin.constant = 0;
    }

    if (state && state.batteryHealth != nil) {
        [self.lBatteryHealthTitle setText:NSLocalizedString(@"Battery health", nil)];
        [self.lBatteryHealth setText:state.batteryHealthString];
        self.lBatteryHealthTitle.hidden = NO;
        self.lBatteryHealth.hidden = NO;
        self.BatteryHealthTitleBottomMargin.constant = 2;
        self.BatteryHealthBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lBatteryHealthTitle setText:@""];
        [self.lBatteryHealth setText:@""];
        self.lBatteryHealthTitle.hidden = YES;
        self.lBatteryHealth.hidden = YES;
        self.BatteryHealthTitleBottomMargin.constant = 0;
        self.BatteryHealthBottomMargin.constant = 0;
    }

    if (state && state.lastConnectionResetCause != nil) {
        [self.lConnectionResetCauseTitle setText:NSLocalizedString(@"Connection reset cause", nil)];
        [self.lConnectionResetCause setText:state.lastConnectionResetCauseString];
        self.lConnectionResetCauseTitle.hidden = NO;
        self.lConnectionResetCause.hidden = NO;
        self.ConnectionResetCauseTitleBottomMargin.constant = 2;
        self.ConnectionResetCauseBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lConnectionResetCauseTitle setText:@""];
        [self.lConnectionResetCause setText:@""];
        self.lConnectionResetCauseTitle.hidden = YES;
        self.lConnectionResetCause.hidden = YES;
        self.ConnectionResetCauseTitleBottomMargin.constant = 0;
        self.ConnectionResetCauseBottomMargin.constant = 0;
    }
    
    BOOL lightSwitchFunc = _channel && _channel.func & SUPLA_CHANNELFNC_LIGHTSWITCH;
 
    if (lightSwitchFunc && state && state.lightSourceLifespan != nil) {
        [self.lLightsourceLifespanTitle setText:NSLocalizedString(@"Light source lifespan", nil)];
        [self.lLightsourceLifespan setText:state.lightSourceLifespanString];
        self.lLightsourceLifespanTitle.hidden = NO;
        self.lLightsourceLifespan.hidden = NO;
        self.LightsourceLifespanTitleBottomMargin.constant = 2;
        self.LightsourceLifespanBottomMargin.constant = 2;
        stopAnimating = YES;
    } else {
        [self.lLightsourceLifespanTitle setText:@""];
        [self.lLightsourceLifespan setText:@""];
        self.lLightsourceLifespanTitle.hidden = YES;
        self.lLightsourceLifespan.hidden = YES;
        self.LightsourceLifespanTitleBottomMargin.constant = 0;
        self.LightsourceLifespanBottomMargin.constant = 0;
    }
      
    if (lightSwitchFunc && state && state.lightSourceOperatingTime != nil) {
        [self.lLightsourceOperatingTimeTitle setText:NSLocalizedString(@"Light source operating time", nil)];
        [self.lLightsourceOperatingTime setText:state.lightSourceOperatingTimeString];
        self.lLightsourceOperatingTimeTitle.hidden = NO;
        self.lLightsourceOperatingTime.hidden = NO;
        stopAnimating = YES;
    } else {
        [self.lLightsourceOperatingTimeTitle setText:@""];
        [self.lLightsourceOperatingTime setText:@""];
        self.lLightsourceOperatingTimeTitle.hidden = YES;
        self.lLightsourceOperatingTime.hidden = YES;
    }
    
    self.btnReset.hidden = !(lightSwitchFunc && state && _channel.flags & SUPLA_CHANNEL_FLAG_LIGHTSOURCELIFESPAN_SETTABLE);
    
    if (stopAnimating) {
        [self.actInd stopAnimating];
    }
    
    [self calculateHeights];
    
    if (_channel
        && _channel.flags & SUPLA_CHANNEL_FLAG_CHANNELSTATE
        && [SADialog viewControllerIsPresented:self])  {
        [self cancelRefreshTimer];
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL_SEC
                                                 target:self
                                                 selector:@selector(makeChannelStateRequest:)
                                                 userInfo:nil
                                                 repeats:NO];
    }
}

-(void)cancelRefreshTimer {
    if (_refreshTimer) {
        [_refreshTimer invalidate];
        _refreshTimer = nil;
    }
}

+(SAChannelStatePopup*)globalInstance {
    if (_channelStatePopupGlobalRef == nil) {
        _channelStatePopupGlobalRef = [[SAChannelStatePopup alloc] initWithNibName:@"SAChannelStatePopup" bundle:nil];
    }
    
    return _channelStatePopupGlobalRef;
}

-(void)makeChannelStateRequest:(NSTimer *)timer {
    [self cancelRefreshTimer];
    
    if (_channel == nil) {
        return;
    }
    [[SAApp SuplaClient] channelStateRequestWithChannelId:_channel.remote_id];
}

-(void)setChannel:(SAChannel *)channel {
    _channel = channel;
    
    if (_channel) {
        [self.lTitle setText:[_channel getNonEmptyCaption]];
        if ((_channel.flags & SUPLA_CHANNEL_FLAG_CHANNELSTATE) == 0)  {
            _lastState = channel.channelState;
        }
    } else {
        [self.lTitle setText:@""];
    }
    
    [self updateWithState:_lastState];
}

-(void)show:(SAChannel*)channel {
    _lastState = nil;
    [SADialog showModal:self];
    
    [self.actInd startAnimating];
    [self setChannel:channel];
    [self makeChannelStateRequest:nil];
}

-(void)calculateHeights {
    self.actIndHeight.constant = self.actInd.isAnimating ? _actIndOriginalHeight : 0;
    self.btnResetHeight.constant = !self.btnReset.hidden ? _btnResetOriginalHeight : 0;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self calculateHeights];
}


- (IBAction)resetBtnTouchDown:(id)sender {
    [self closeWithAnimation:YES completion:^(){
        [SASuperuserAuthorizationDialog.globalInstance authorizeWithDelegate:self];
    }];
}

-(void) superuserAuthorizationSuccess {
    [SASuperuserAuthorizationDialog.globalInstance closeWithAnimation:YES completion:^(){
        if (self->_channel && self->_lastState) {
            [SALightsourceLifespanSettingsDialog.globalInstance show:self->_channel.remote_id title:self->_lTitle.text lifesourceLifespan:[self->_lastState.lightSourceLifespan intValue]];
        }
    }];
}

@end
