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
#import "UIHelper.h"
#import "SuplaApp.h"

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


//#define UI_REFRESH_LOCK_TIME 2000;
//#define MIN_SEND_DELAY_TIME 500;
//#define DISPLAY_DELAY_TIME 1000;

@implementation SAVLCalibrationTool {
    SADetailView *_detailView;
    BOOL _configStarted;
    vl_configuration_t _vlconfig;
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

-(void)startConfiguration:(SADetailView*)detailView {
    if (detailView == nil) {
        return;
    }
    
    memset(&_vlconfig, 0, sizeof(vl_configuration_t));

    _vlconfig.mode = MODE_UNKNOWN;
    _vlconfig.mode_mask = 0xFF;
    _vlconfig.boost = MODE_UNKNOWN;
    _vlconfig.boost_mask = 0xFF;
    
    _configStarted = NO;
    [self modeToUI];
    [self boostToUI];
    
    [self removeFromSuperview];
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.frame = CGRectMake(0, 0, detailView.frame.size.width, detailView.frame.size.height);
    _detailView = detailView;
  
  //  Incorrect frame width
  //  [self setRoundedTopCorners:self.tabOpRange];
  //  [self setRoundedTopCorners:self.tabBoost];
    
    [SASuperuserAuthorizationDialog.globalInstance authorizeWithDelegate:self];
}

- (void) deviceCalCfgCommand:(int)command {
    if (_detailView && _detailView.channelBase) {
        [SAApp.SuplaClient deviceCalCfgCommand:command cg:_detailView.channelBase.remote_id group:NO];
    }
}

-(void)onCalCfgResult:(NSNotification *)notification {
    if (_detailView == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        return;
    }
    
    if (notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"result"];
        if ([r isKindOfClass:[SACalCfgResult class]]) {
            SACalCfgResult *result = (SACalCfgResult*)r;
            if (result.channelID == _detailView.channelBase.remote_id) {
                switch (result.command) {
                    case VL_MSG_CONFIGURATION_ACK:
                        if (result.result == SUPLA_RESULTCODE_TRUE) {
                            [SASuperuserAuthorizationDialog.globalInstance close];
                            [_detailView addSubview:self];
                            [_detailView bringSubviewToFront:self];
                            _configStarted = YES;
                        }
                        break;
                    case VL_MSG_CONFIGURATION_REPORT:
                        if (result.data.length == sizeof(vl_configuration_t)) {
                            [result.data getBytes:&_vlconfig length:result.data.length];
                        }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
}

-(void) superuserAuthorizationSuccess {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onCalCfgResult:)
     name:kSACalCfgResult object:nil];
    
    [self deviceCalCfgCommand:VL_MSG_CONFIGURATION_MODE];
}

- (void)modeToUI {
    self.tabMode1.backgroundColor = [UIColor whiteColor];
    self.tabMode1.selected = NO;
    self.tabMode1.enabled = (_vlconfig.mode_mask & VL_MASK_MODE_1_DISABLED) == 0;
    self.tabMode2.backgroundColor = [UIColor whiteColor];
    self.tabMode2.selected = NO;
    self.tabMode2.enabled = (_vlconfig.mode_mask & VL_MASK_MODE_2_DISABLED) == 0;
    self.tabMode3.backgroundColor = [UIColor whiteColor];
    self.tabMode3.selected = NO;
    self.tabMode3.enabled = (_vlconfig.mode_mask & VL_MASK_MODE_3_DISABLED) == 0;
    
    switch(_vlconfig.mode) {
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
    self.tabBoostYes.enabled = (_vlconfig.boost_mask & VL_MASK_BOOST_YES_DISABLED) == 0;
    self.tabBoostNo.backgroundColor = [UIColor whiteColor];
    self.tabBoostNo.selected = NO;
    self.tabBoostNo.enabled = (_vlconfig.boost_mask & VL_MASK_BOOST_NO_DISABLED) == 0;
    self.tabBoost.hidden = YES;
    
    switch(_vlconfig.boost) {
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
        [self tabOpRange:self.tabOpRange];
    }
}

- (IBAction)tabBoost:(id)sender {
    self.tabBoost.backgroundColor = [UIColor whiteColor];
    self.tabOpRange.backgroundColor = [UIColor clearColor];
    self.rangeCalibrationWheel.boostHidden = NO;
}

- (IBAction)tabOpRange:(id)sender {
    self.tabBoost.backgroundColor = [UIColor clearColor];
    self.tabOpRange.backgroundColor = [UIColor whiteColor];
    self.rangeCalibrationWheel.boostHidden = YES;
}

- (IBAction)tabBoostNoTouch:(id)sender {
    _vlconfig.boost = BOOST_NO;
    [self boostToUI];
}

- (IBAction)tabBoostYesTouch:(id)sender {
    _vlconfig.boost = BOOST_YES;
    [self boostToUI];
}

- (IBAction)tabMode3Touch:(id)sender {
    _vlconfig.mode = MODE_3;
    [self modeToUI];
}

- (IBAction)tabMode2Touch:(id)sender {
    _vlconfig.mode = MODE_2;
    [self modeToUI];
}

- (IBAction)tabMode1Touch:(id)sender {
    _vlconfig.mode = MODE_1;
    [self modeToUI];
}

- (IBAction)btnOKTouch:(id)sender {
}

- (IBAction)btnRestoreTouch:(id)sender {
}

- (IBAction)btnInfoTouch:(id)sender {
    [SAInfoVC showInformationWindowWithMessage:INFO_MESSAGE_VARILIGHT_CONFIG];
}

-(void)dismiss {
    [self removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _detailView = nil;
}

+(SAVLCalibrationTool*)newInstance {
    return [[[NSBundle mainBundle] loadNibNamed:@"SAVLCalibrationTool" owner:nil options:nil] objectAtIndex:0];
}

@end
