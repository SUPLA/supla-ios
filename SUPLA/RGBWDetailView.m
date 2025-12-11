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

#import "RGBWDetailView.h"

#import "SAChannel+CoreDataClass.h"
#import "Database.h"
#import "SuplaApp.h"
#import "SAInfoVC.h"
#import "SAVLCalibrationTool.h"
#import "SADiwCalibrationTool.h"
#import "SUPLA-Swift.h"

#define MIN_REMOTE_UPDATE_PERIOD 0.25
#define MIN_UPDATE_DELAY 3
#define DELAY_AUTO 0

#define ZAM_PRODID_DIW_01 2000
#define COM_PRODID_WDIM100 2000

@implementation SARGBWDetailView {
    BOOL _varilight;
    BOOL _zamel_diw_01;
    BOOL _comelit_wdim100;
    
    SADimmerCalibrationTool *_dimmerCalibrationTool;
}

-(void)detailViewInit {
    BOOL wasInitialized = self.initialized;
    [super detailViewInit];
    
    if (!wasInitialized) {
        self.settingsLabel.text = LegacyStrings.rgbDetailSettingsUnauthorized;
        [self.settingsButton setTitle:LegacyStrings.rgbDetailAuthorize forState:UIControlStateNormal];
        [self.settingsButton addTarget:self action:@selector(authorizeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) authorizeButtonPressed: (UIButton*) button {
    [self openCalibrationTool];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    if ( self.channelBase == nil
        || ( channelBase != nil
            && (self.channelBase.remote_id  != channelBase.remote_id
                || ![channelBase isKindOfClass:[self.channelBase class]]) ) ) {
        
        _varilight = false;
        _zamel_diw_01 = false;
        _comelit_wdim100 = false;
        
        if (channelBase != nil
            && [channelBase isKindOfClass:[SAChannel class]] ) {
            if (((SAChannel*)channelBase).manufacturer_id == SUPLA_MFR_DOYLETRATT
                && ((SAChannel*)channelBase).product_id == 1) {
                _varilight = YES;
            } else if (((SAChannel*)channelBase).manufacturer_id == SUPLA_MFR_ZAMEL) {
                if (((SAChannel*)channelBase).product_id == ZAM_PRODID_DIW_01) {
                    _zamel_diw_01 = YES;
                }
            } else if (((SAChannel*)channelBase).manufacturer_id == SUPLA_MFR_COMELIT) {
                if (((SAChannel*)channelBase).product_id == COM_PRODID_WDIM100) {
                    _comelit_wdim100 = YES;
                }
            }
        }

    }
    
    if ( channelBase != nil
        && channelBase.status.offline
        && (_dimmerCalibrationTool == nil || !_dimmerCalibrationTool.isExitLocked)) {
        [self.viewController.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    [super setChannelBase:channelBase];
}

-(void) openCalibrationTool {
    if (_dimmerCalibrationTool == nil) {
        if (_varilight) {
            _dimmerCalibrationTool = [SAVLCalibrationTool newInstance];
        } else if (_zamel_diw_01 || _comelit_wdim100) {
            _dimmerCalibrationTool = [SADiwCalibrationTool newInstance];
        }
    }

    if (_dimmerCalibrationTool != nil) {
        [_dimmerCalibrationTool startConfiguration:self];
    }
}

- (IBAction)onSettingsTouch:(id)sender {
    [self openCalibrationTool];
}

- (IBAction)rgbInfoTouch:(id)sender {
    [SAInfoVC showInformationWindowWithMessage:INFO_MESSAGE_DIMMER];
}

-(BOOL)onMenubarBackButtonPressed {
    if (_dimmerCalibrationTool && _dimmerCalibrationTool.superview) {
        return [_dimmerCalibrationTool onMenubarBackButtonPressed];
    }
    return YES;
}

-(void)detailWillShow {
    [super detailWillShow];
    [self openCalibrationTool];
}

-(void)detailWillHide {
    [super detailWillHide];
    
    if (_dimmerCalibrationTool != nil) {
        [_dimmerCalibrationTool dismiss];
        _dimmerCalibrationTool = nil;
    }
}
@end

