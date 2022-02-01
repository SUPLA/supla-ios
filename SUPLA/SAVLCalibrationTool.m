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

#import "SAVLCalibrationTool.h"
#import "SAInfoVC.h"

#import "SuplaClient.h"
#import "SACalCfgResult.h"
#import "UIColor+SUPLA.h"

#define PIC_HEX_VER_MAX_SIZE 20

#pragma pack(push, 1)
typedef struct {
    unsigned short edge_minimum;       // 0 - 1000 (default 0)
    unsigned short edge_maximum;       // 0 - 1000 (default 1000)
    unsigned short operating_minimum;  // 0 - 1000 >= edge_minimum
    unsigned short operating_maximum;  // 0 - 1000 <= operating_maximum
    unsigned char mode;                // 0: AUTO, 1, 2, 3
    unsigned char boost;               // 0: AUTO, 1: YES, 2: NO
    unsigned short boost_level;        // 0 – 1000
    unsigned char child_lock;          // 0: NO, 1: YES
    unsigned char mode_mask;           // VL_MASK_MODE_DISABLED*
    unsigned char boost_mask;          // VL_MASK_BOOST_DIABLED*
} vl_configuration_t;

typedef struct {
    vl_configuration_t vl_main_config;
    unsigned char cfg_version;
    unsigned char led;
    char pic_hex_ver[PIC_HEX_VER_MAX_SIZE];
} vl_supla_configuration_t;

#pragma pack(pop)

#define VL_MASK_MODE_AUTO_DISABLED 0x1
#define VL_MASK_MODE_1_DISABLED 0x2
#define VL_MASK_MODE_2_DISABLED 0x4
#define VL_MASK_MODE_3_DISABLED 0x8

#define VL_MASK_BOOST_AUTO_DISABLED 0x1
#define VL_MASK_BOOST_YES_DISABLED 0x2
#define VL_MASK_BOOST_NO_DISABLED 0x4

#define BOOST_UNKNOWN -1
#define BOOST_AUTO 0
#define BOOST_YES 1
#define BOOST_NO 2

#define MODE_UNKNOWN -1
#define MODE_AUTO 0
#define MODE_1 1
#define MODE_2 2
#define MODE_3 3

#define VL_MSG_RESTORE_DEFAULTS 0x4E
#define VL_MSG_CONFIGURATION_MODE 0x44
#define VL_MSG_CONFIGURATION_ACK 0x45
#define VL_MSG_CONFIGURATION_QUERY 0x15
#define VL_MSG_CONFIGURATION_REPORT 0x51
#define VL_MSG_CONFIG_COMPLETE 0x46
#define VL_MSG_SET_MODE 0x58
#define VL_MSG_SET_MINIMUM 0x59
#define VL_MSG_SET_MAXIMUM 0x5A
#define VL_MSG_SET_BOOST 0x5B
#define VL_MSG_SET_BOOST_LEVEL 0x5C
#define VL_MSG_SET_CHILD_LOCK 0x18
#define VL_CALCFG_MSG_SET_LED_CONFIG 0x01FF

@implementation SAVLCalibrationTool {    
    vl_supla_configuration_t _config;
    NSTimer *_startConfigurationRetryTimer;
    BOOL _restoringDefaults;
}

-(void)setRoundedTopCorners:(UIButton*)btn {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:btn.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = btn.bounds;
    maskLayer.path = maskPath.CGPath;
    btn.layer.mask = maskLayer;
}

- (void)startConfigurationRetryTimerFireMethod:(NSTimer *)timer {
    if (_startConfigurationRetryTimer != nil) {
      [self superuserAuthorizationSuccess];
    }
}

-(void)startConfigurationAgainWithRetry {
    [self stopConfigurationRetryTimer];
    
    _startConfigurationRetryTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                   target:self
                                                                   selector:@selector(startConfigurationRetryTimerFireMethod:)
                                                                   userInfo:nil
                                                                    repeats:YES];
}

-(void)stopConfigurationRetryTimer {
    if (_startConfigurationRetryTimer) {
        [_startConfigurationRetryTimer invalidate];
        _startConfigurationRetryTimer = nil;
    }
}

- (void)modeToUI {
    self.tabMode1.backgroundColor = [UIColor whiteColor];
    self.tabMode1.selected = NO;
    self.tabMode1.enabled = (_config.vl_main_config.mode_mask & VL_MASK_MODE_1_DISABLED) == 0;
    self.tabMode2.backgroundColor = [UIColor whiteColor];
    self.tabMode2.selected = NO;
    self.tabMode2.enabled = (_config.vl_main_config.mode_mask & VL_MASK_MODE_2_DISABLED) == 0;
    self.tabMode3.backgroundColor = [UIColor whiteColor];
    self.tabMode3.selected = NO;
    self.tabMode3.enabled = (_config.vl_main_config.mode_mask & VL_MASK_MODE_3_DISABLED) == 0;
    
    switch(_config.vl_main_config.mode) {
        case MODE_1:
            self.tabMode1.backgroundColor = [UIColor rgbwSelectedTabColor];
            self.tabMode1.selected = YES;
            break;
        case MODE_2:
            self.tabMode2.backgroundColor = [UIColor rgbwSelectedTabColor];
            self.tabMode2.selected = YES;
            break;
        case MODE_3:
            self.tabMode3.backgroundColor = [UIColor rgbwSelectedTabColor];
            self.tabMode3.selected = YES;
            break;
    }
}

- (void)boostToUI {
    self.tabBoostYes.backgroundColor = [UIColor whiteColor];
    self.tabBoostYes.selected = NO;
    self.tabBoostYes.enabled = (_config.vl_main_config.boost_mask & VL_MASK_BOOST_YES_DISABLED) == 0;
    self.tabBoostNo.backgroundColor = [UIColor whiteColor];
    self.tabBoostNo.selected = NO;
    self.tabBoostNo.enabled = (_config.vl_main_config.boost_mask & VL_MASK_BOOST_NO_DISABLED) == 0;
    self.tabBoost.hidden = YES;
    
    switch(_config.vl_main_config.boost) {
        case BOOST_YES:
            self.tabBoostYes.backgroundColor = [UIColor rgbwSelectedTabColor];
            self.tabBoostYes.selected = YES;
            self.tabBoost.hidden = NO;
            break;
        case BOOST_NO:
            self.tabBoostNo.backgroundColor = [UIColor rgbwSelectedTabColor];
            self.tabBoostNo.selected = YES;
            break;
    }
    
    if (self.tabBoost.hidden) {
        self.rangeCalibrationWheel.boostHidden = YES;
        [self tabOpRangeTouch:self.tabOpRange];
    }
}

- (IBAction)tabBoostTouch:(id)sender {
    self.tabBoost.backgroundColor = [UIColor whiteColor];
    self.tabOpRange.backgroundColor = [UIColor clearColor];
    self.rangeCalibrationWheel.boostHidden = NO;
}

- (IBAction)tabOpRangeTouch:(id)sender {
    self.tabBoost.backgroundColor = [UIColor clearColor];
    self.tabOpRange.backgroundColor = [UIColor whiteColor];
    self.rangeCalibrationWheel.boostHidden = YES;
}

- (IBAction)tabBoostYesNoTouch:(id)sender {
    _config.vl_main_config.boost = sender == self.tabBoostYes ? BOOST_YES : BOOST_NO;
    [self boostToUI];
    [self deviceCalCfgCommand:VL_MSG_SET_BOOST charValue:_config.vl_main_config.boost];
    
    if (sender == self.tabBoostYes) {
        [self calibrationWheelBoostChanged:self.rangeCalibrationWheel];
        [self tabBoostTouch:self.tabBoost];
    }
}

- (IBAction)tabMode123Touch:(id)sender {
    if (sender == self.tabMode1) {
        _config.vl_main_config.mode = MODE_1;
    } else if (sender == self.tabMode2) {
        _config.vl_main_config.mode = MODE_2;
    } else if (sender == self.tabMode3) {
        _config.vl_main_config.mode = MODE_3;
    }
    
    [self modeToUI];
    [self deviceCalCfgCommand:VL_MSG_SET_MODE charValue:_config.vl_main_config.mode];
    
    [self showPreloaderWithText:NSLocalizedString(@"Mode change in progress", nil)];
    [self startConfigurationAgainWithRetry];
}

+(SADimmerCalibrationTool*)newInstance {
    return [[[NSBundle mainBundle] loadNibNamed:@"SAVLCalibrationTool" owner:nil options:nil] objectAtIndex:0];
}

-(void) calibrationWheelRangeChanged:(SARangeCalibrationWheel *)wheel minimum:(BOOL)min {
    [self deviceCalCfgCommandWithDelay:min ? VL_MSG_SET_MINIMUM : VL_MSG_SET_MAXIMUM];
}

-(void) calibrationWheelBoostChanged:(SARangeCalibrationWheel *)wheel {
    [self deviceCalCfgCommandWithDelay:VL_MSG_SET_BOOST_LEVEL];
}

-(void)deviceCalCfgCommand:(int)command {
    switch (command) {
        case VL_MSG_SET_MINIMUM:
            [self deviceCalCfgCommand:command shortValue:self.rangeCalibrationWheel.minimum];
            break;
        case VL_MSG_SET_MAXIMUM:
            [self deviceCalCfgCommand:command shortValue:self.rangeCalibrationWheel.maximum];
            break;
        case VL_MSG_SET_BOOST_LEVEL:
            [self deviceCalCfgCommand:command shortValue:self.rangeCalibrationWheel.boostLevel];
            break;
        default:
            [super deviceCalCfgCommand:command];
            break;
    }
}

-(void)onCalCfgResult:(SACalCfgResult *)result {
    switch (result.command) {
        case VL_MSG_CONFIGURATION_ACK:
            if (result.result == SUPLA_RESULTCODE_TRUE && !_restoringDefaults) {
                [self setConfigurationStarted];
                [self stopConfigurationRetryTimer];
            } else if (_restoringDefaults) {
                _restoringDefaults = NO;
                [self startConfigurationAgainWithRetry];
            }
            break;
        case VL_MSG_CONFIGURATION_REPORT:
            if (result.data.length == sizeof(vl_configuration_t)) {
                [result.data getBytes:&_config.vl_main_config length:result.data.length];
            } else if (result.data.length == sizeof(vl_supla_configuration_t)) {
                [result.data getBytes:&_config length:result.data.length];
            }
            [self cfgToUIWithDelay:YES];
            break;
            
        default:
            break;
    }
}

-(void)beforeConfigurationStart {
    memset(&_config, 0, sizeof(vl_supla_configuration_t));
    
    _config.vl_main_config.mode = MODE_UNKNOWN;
    _config.vl_main_config.mode_mask = 0xFF;
    _config.vl_main_config.boost = MODE_UNKNOWN;
    _config.vl_main_config.boost_mask = 0xFF;
    
    self.rangeCalibrationWheel.delegate = self;
}

-(void)onDismiss {
    [self stopConfigurationRetryTimer];
    
    if (self.isConfigurationStarted) {
        [self deviceCalCfgCommand:VL_MSG_CONFIG_COMPLETE charValue:0];
    }
}

- (void)setLedCfg:(char)cfg {
    [self deviceCalCfgCommand:VL_CALCFG_MSG_SET_LED_CONFIG charValue:&cfg shortValue:NULL];
}

- (char)getLedCfg {
    return _config.led;
}

-(void)saveChanges {
    [self deviceCalCfgCommand:VL_MSG_CONFIG_COMPLETE charValue:1];
}

- (void)cfgToUI {
    [self boostToUI];
    [self modeToUI];
    self.rangeCalibrationWheel.rightEdge = _config.vl_main_config.edge_maximum;
    self.rangeCalibrationWheel.leftEdge = _config.vl_main_config.edge_minimum;
    [self.rangeCalibrationWheel setMinimum:_config.vl_main_config.operating_minimum andMaximum:_config.vl_main_config.operating_maximum];
    self.rangeCalibrationWheel.boostLevel = _config.vl_main_config.boost_level;
    
    self.lPicFirmwareVersion.text = [NSString stringWithCString:_config.pic_hex_ver encoding:NSASCIIStringEncoding];
}

- (void)showInformationDialog {
    [SAInfoVC showInformationWindowWithMessage:INFO_MESSAGE_VARILIGHT_CONFIG];
}

-(BOOL)isLedConfigAvailable {
    return _config.cfg_version >= 2;
}

- (void)onSuperuserAuthorizationSuccess {
    [self deviceCalCfgCommand:VL_MSG_CONFIGURATION_MODE charValue:NULL shortValue:NULL];
}

- (void)doRestore {
    [self showPreloaderWithText:NSLocalizedString(@"Restoring default settings", nil)];
  
    self->_restoringDefaults = YES;
    [self startConfigurationAgainWithRetry];
    [self deviceCalCfgCommand:VL_MSG_RESTORE_DEFAULTS charValue:NULL shortValue:NULL];
}

@end
