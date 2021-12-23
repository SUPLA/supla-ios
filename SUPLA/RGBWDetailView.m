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
#import "SAColorListItem+CoreDataClass.h"
#import "Database.h"
#import "SuplaApp.h"
#import "SAInfoVC.h"
#import "SAVLCalibrationTool.h"
#import "SADiwCalibrationTool.h"
#import "UIColor+SUPLA.h"

#define MIN_REMOTE_UPDATE_PERIOD 0.25
#define MIN_UPDATE_DELAY 3
#define DELAY_AUTO 0

#define ZAM_PRODID_DIW_01 2000
#define COM_PRODID_WDIM100 2000

@implementation SARGBWDetailView {
    int _brightness;
    int _colorBrightness;
    BOOL _varilight;
    BOOL _zamel_diw_01;
    BOOL _comelit_wdim100;
    BOOL isGroup;
    UIColor *_color;
    NSArray *_colorMarkers;
    NSArray *_brightnessMarkers;
    NSArray *_colorBrightnessMarkers;
    
    NSTimer *delayTimer1;
    NSTimer *delayTimer2;
    
    NSDate *_moveEndTime;
    NSDate *_remoteUpdateTime;
    SADimmerCalibrationTool *_dimmerCalibrationTool;
}

-(void)detailViewInit {
    
    if ( self.initialized == NO ) {
        
        delayTimer1 = nil;
        delayTimer2 = nil;
        
        _moveEndTime = [NSDate dateWithTimeIntervalSince1970:0];
        _remoteUpdateTime = _moveEndTime;
        
        if (_color==nil) {
            _color = [UIColor colorPickerDefault];
        }
        
        self.cbPicker.delegate = self;
        
        [self.clPicker addItemWithColor:[UIColor whiteColor] andPercent:100];
        [self.clPicker addItem];
        [self.clPicker addItem];
        [self.clPicker addItem];
        [self.clPicker addItem];
        [self.clPicker addItem];
        self.clPicker.delegate = self;
        
        self.backgroundColor = [UIColor rgbwDetailBackground];
        
        self.onlineStatus.onlineColor = [UIColor onLine];
        self.onlineStatus.offlineColor = [UIColor offLine];
        self.onlineStatus.borderColor = [UIColor statusBorder];
        
    }
    
    
    [super detailViewInit];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_cbPicker setNeedsDisplay];
}

- (void)showValues {
    if ( self.cbPicker.colorWheelHidden == NO ) {
        
        if (!isGroup) {
            if ((int)self.cbPicker.brightness != (int)_colorBrightness ) {
                self.cbPicker.brightness = (int)_colorBrightness;
            };
            
            self.cbPicker.color = _color;
        }
        
        self.cbPicker.brightnessMarkers = _colorBrightnessMarkers;
        self.cbPicker.colorMarkers = _colorMarkers;
        
    } else {
        if ( !isGroup && (int)self.cbPicker.brightness != (int)_brightness ) {
            self.cbPicker.brightness = (int)_brightness;
        }
        
        self.cbPicker.brightnessMarkers = _brightnessMarkers;
    }
    
    [self pickerToExtraButton];
}

- (void)sendNewValuesWithTurnOnOff:(BOOL)turnOnOff {
    
    if ( delayTimer1 != nil ) {
        [delayTimer1 invalidate];
        delayTimer1 = nil;
    }
    
    SASuplaClient *client = [SAApp SuplaClient];
    if ( client == nil || self.channelBase == nil ) return;
    
    double time = [_remoteUpdateTime timeIntervalSinceNow] * -1;
    
    int brightness = _brightness;
    int colorBrightness = _colorBrightness;
    UIColor *color = _color;
    
    if ( self.cbPicker.colorWheelHidden == NO ) {
        colorBrightness = self.cbPicker.brightness;
        color = self.cbPicker.color;
    } else {
        brightness = self.cbPicker.brightness;
    }
    
    if ( (turnOnOff || time >= MIN_REMOTE_UPDATE_PERIOD)
        && [client cg:self.channelBase.remote_id setRGB:color
      colorBrightness:colorBrightness brightness:brightness group:isGroup turnOnOff:turnOnOff] ) {
        
        _remoteUpdateTime = [NSDate date];
        [self showValuesWithDelay:MIN_UPDATE_DELAY];
        
    } else {
        
        if ( time < MIN_REMOTE_UPDATE_PERIOD )
            time = MIN_REMOTE_UPDATE_PERIOD-time+0.001;
        else
            time = 0.001;
        
        delayTimer1 = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timer1FireMethod:) userInfo:nil repeats:NO];
    }
    
}

- (void)sendNewValues {
    [self sendNewValuesWithTurnOnOff:NO];
}

- (void)showValuesWithDelay:(double)time {
    
    if ( delayTimer2 != nil ) {
        [delayTimer2 invalidate];
        delayTimer2 = nil;
    }
    
    if ( self.cbPicker.moving == YES )
        return;
    
    double timeDiffSec = [_moveEndTime timeIntervalSinceNow] * -1;
    
    if ( time == 0 && timeDiffSec >= MIN_UPDATE_DELAY ) {
        [self showValues];
    } else {
        
        if (time == 0) {
            time = timeDiffSec;
            
            if ( time < MIN_UPDATE_DELAY )
                time = MIN_UPDATE_DELAY-time+0.001;
            else
                time = 0.001;
        }
        
        delayTimer2 = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timer2FireMethod:) userInfo:nil repeats:NO];
        
    }
}

- (void)showValuesWithDelay {
    [self showValuesWithDelay: DELAY_AUTO];
}

- (void)timer1FireMethod:(NSTimer *)timer {
    [self sendNewValues];
}

- (void)timer2FireMethod:(NSTimer *)timer {
    [self showValuesWithDelay];
}

-(void)setRgbDimmerTabsHidden:(BOOL)hidden {
    self.vTabsRgbDimmer.hidden = hidden;
    self.cbPickerTopMargin.constant = hidden ? -31 : 15;
}

-(void)setClPickerHidden:(BOOL)hidden {
    self.clPicker.hidden = hidden;
    self.clPickerBottomMargin.constant = hidden ? -31 : 35;
}

-(void)setWheelSliderTabsHidden:(BOOL)hidden {
    self.vTabsWheelSlider.hidden = hidden;
    self.vTabsWheelSliderBottomMargin.constant = hidden ? -31 : 35;
}

-(void)setExtraButtonsHidden:(BOOL)hidden {
    self.vExtraButtons.hidden = hidden;
    self.cbPickerBottomMargin.constant = hidden ? -60 : 5;
}

-(void)showDimmer {
    [self setClPickerHidden:YES];
    self.cbPicker.colorWheelHidden = YES;
    
    if (SAApp.isBrightnessPickerTypeSet) {
        [self onPickerTypeTabTouch:SAApp.isBrightnessPickerTypeSlider ? self.tabSlider : self.tabWheel];
    } else {
        [self onPickerTypeTabTouch:_varilight ? self.tabSlider : self.tabWheel];
    }
    
    [self setExtraButtonsHidden:!_varilight && !_zamel_diw_01 && !_comelit_wdim100];
    [self setWheelSliderTabsHidden:NO];
    self.tabRGB.selected = NO;
    self.tabRGB.backgroundColor = [UIColor rgbwNormalTabColor];
    self.tabDimmer.selected = YES;
    self.tabDimmer.backgroundColor = [UIColor rgbwSelectedTabColor];
    self.cbPicker.brightness = _brightness;
    [self pickerToExtraButton];
}

-(void)showRGB {
    [self setClPickerHidden:NO];
    [self setWheelSliderTabsHidden:YES];
    self.cbPicker.colorWheelHidden = NO;
    self.cbPicker.sliderHidden = YES;
    [self setExtraButtonsHidden: YES];
    self.btnPowerOnOff.hidden = YES;
    self.tabRGB.selected = YES;
    self.tabRGB.backgroundColor = [UIColor rgbwSelectedTabColor];
    self.tabDimmer.selected = NO;
    self.tabDimmer.backgroundColor = [UIColor rgbwNormalTabColor];
    self.cbPicker.brightness = _colorBrightness;
}

-(void)updateView {
    
    [super updateView];
    
    if (_dimmerCalibrationTool != nil && !_dimmerCalibrationTool.isExitLocked) {
        [_dimmerCalibrationTool dismiss];
        _dimmerCalibrationTool = nil;
    }
    
    if (isGroup) {
        self.onlineStatus.hidden = NO;
    } else {
        self.onlineStatus.hidden = YES;
    }
    
    if ( self.channelBase != nil ) {

        switch(self.channelBase.func) {
                
            case SUPLA_CHANNELFNC_DIMMER:
            case SUPLA_CHANNELFNC_RGBLIGHTING:
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                
                if (isGroup) {
                    SAChannelGroup *cgroup = (SAChannelGroup*)self.channelBase;
                    
                    _colorMarkers = cgroup.colors;
                    _colorBrightnessMarkers = cgroup.colorBrightness;
                    _brightnessMarkers = cgroup.brightness;
                    self.onlineStatus.percent = cgroup.onlinePercent;
                    
                    [self showValues];
                    
                } else {
                    _brightness = self.channelBase.brightnessValue;
                    _colorBrightness = self.channelBase.colorBrightnessValue;
                    _color = self.channelBase.colorValue;
                    
                    [self showValuesWithDelay];
                }
                
                break;
        };
    }
    
    for(int a=1;a<self.clPicker.count;a++) {
        
        SAColorListItem *item = [[SAApp DB] getColorListItemForRemoteId:self.channelBase.remote_id andIndex:a forGroup:NO];
        
        if ( item == nil ) {
            [self.clPicker itemAtIndex:a setColor:[UIColor clearColor]];
            [self.clPicker itemAtIndex:a setPercent:0];
        } else {
            
            [self.clPicker itemAtIndex:a setColor:item.color == nil ? [UIColor clearColor] : [UIColor transformToColor:item.color]];
            [self.clPicker itemAtIndex:a setPercent:[item.brightness floatValue]];
        }
    }
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    isGroup = channelBase != nil && [channelBase isKindOfClass:[SAChannelGroup class]];
    
    if ( self.channelBase == nil
        || ( channelBase != nil
            && (self.channelBase.remote_id  != channelBase.remote_id
                || ![channelBase isKindOfClass:[self.channelBase class]]) ) ) {
        
        _moveEndTime = [NSDate dateWithTimeIntervalSince1970:0];
        _brightnessMarkers = nil;
        _colorBrightnessMarkers = nil;
        _colorMarkers = nil;
        _varilight = false;
        _zamel_diw_01 = false;
        _comelit_wdim100 = false;
        self.cbPicker.minBrightness = 0.0;
        
        if (channelBase != nil
            && [channelBase isKindOfClass:[SAChannel class]] ) {
            if (((SAChannel*)channelBase).manufacturer_id == SUPLA_MFR_DOYLETRATT
                && ((SAChannel*)channelBase).product_id == 1) {
                _varilight = YES;
                self.cbPicker.minBrightness = 1.0;
            } else if (((SAChannel*)channelBase).manufacturer_id == SUPLA_MFR_ZAMEL) {
                self.cbPicker.minBrightness = 1.0;
                if (((SAChannel*)channelBase).product_id == ZAM_PRODID_DIW_01) {
                    _zamel_diw_01 = YES;
                }
            } else if (((SAChannel*)channelBase).manufacturer_id == SUPLA_MFR_COMELIT) {
                self.cbPicker.minBrightness = 1.0;
                if (((SAChannel*)channelBase).product_id == COM_PRODID_WDIM100) {
                    _comelit_wdim100 = YES;
                }
            }
        }

        switch(channelBase.func) {
            case SUPLA_CHANNELFNC_DIMMER:
                self.cbPicker.colorWheelHidden = YES;
                [self setRgbDimmerTabsHidden:YES];
                [self showDimmer];
                break;
            case SUPLA_CHANNELFNC_RGBLIGHTING:
                self.cbPicker.colorWheelHidden = NO;
                [self setRgbDimmerTabsHidden:YES];
                [self showRGB];
                break;
            case SUPLA_CHANNELFNC_DIMMERANDRGBLIGHTING:
                self.cbPicker.colorWheelHidden = NO;
                [self setRgbDimmerTabsHidden:NO];
                [self showRGB];
                break;
        };
    }
    
    if ( channelBase != nil
        && channelBase.isOnline == NO
        && (_dimmerCalibrationTool == nil || !_dimmerCalibrationTool.isExitLocked)) {
        [self.viewController.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    [super setChannelBase:channelBase];
}

-(void) cbPickerDataChanged:(SAColorBrightnessPicker*)picker {
    [self sendNewValues];
    [self pickerToExtraButton];
}

-(void) cbPickerMoveEnded:(SAColorBrightnessPicker*)picker {
    _moveEndTime = [NSDate date];
    [self showValuesWithDelay];
}

-(void) cbPickerPowerButtonValueChanged:(SAColorBrightnessPicker*)picker {
    self.cbPicker.brightness = picker.powerButtonOn ? 100 : 0;
    [self pickerToExtraButton];
    [self sendNewValuesWithTurnOnOff:YES];
}

-(void)itemTouchedWithColor:(UIColor*)color andPercent:(float)percent {
    
    if ( self.cbPicker.colorWheelHidden == YES
        || self.channelBase == nil
        || color == nil
        || [color isEqual: [UIColor clearColor]]) return;
    
    _colorBrightness = percent;
    _color = color;
    
    if (isGroup) {
        self.cbPicker.color = _color;
        self.cbPicker.brightness = _colorBrightness;
    }
    
    [self showValues];
    [self sendNewValues];
    
}

-(void)itemEditAtIndex:(int)index {
    
    if ( index <= 0 ) return;
    
    [self.clPicker itemAtIndex:index setColor:self.cbPicker.color];
    [self.clPicker itemAtIndex:index setPercent:self.cbPicker.brightness];
    
    SAColorListItem *item = [[SAApp DB] getColorListItemForRemoteId:self.channelBase.remote_id andIndex:index forGroup:NO];
    
    if ( item != nil ) {
        item.brightness = [NSNumber numberWithFloat:self.cbPicker.brightness];
        item.color = [UIColor transformToDictionary:self.cbPicker.color];
        
        [[SAApp DB] updateColorListItem:item];
    }
}

- (IBAction)onPickerTypeTabTouch:(id)sender {
    
    self.cbPicker.sliderHidden = sender != self.tabSlider;
    [SAApp setBrightnessPickerTypeToSlider:!self.cbPicker.sliderHidden];
    
    if (self.cbPicker.sliderHidden) {
        self.tabWheel.selected = YES;
        self.tabWheel.backgroundColor = [UIColor rgbwSelectedTabColor];
        self.tabSlider.selected = NO;
        self.tabSlider.backgroundColor = [UIColor rgbwNormalTabColor];
    } else {
        self.tabWheel.selected = NO;
        self.tabWheel.backgroundColor = [UIColor rgbwNormalTabColor];
        self.tabSlider.selected = YES;
        self.tabSlider.backgroundColor = [UIColor rgbwSelectedTabColor];
    }
    
    self.btnPowerOnOff.hidden = self.cbPicker.sliderHidden;
}

- (IBAction)onDimmerTabTouch:(id)sender {
    [self showDimmer];
}

- (IBAction)onRgbTabTouch:(id)sender {
    [self showRGB];
}

- (void)pickerToExtraButton {
    [self setPowerButtonOn:self.cbPicker.brightness > 0];
}

- (void)setPowerButtonOn:(BOOL)on {
    [self.btnPowerOnOff setImage:[UIImage imageNamed:on ? @"rgbwpoweron.png" : @"rgbwpoweroff.png"] forState:UIControlStateNormal];
    self.cbPicker.powerButtonOn = on;
}
- (IBAction)onSettingsTouch:(id)sender {
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

- (IBAction)rgbInfoTouch:(id)sender {
    [SAInfoVC showInformationWindowWithMessage:INFO_MESSAGE_DIMMER];
}

- (IBAction)onPowerBtnTouch:(id)sender {
    self.cbPicker.powerButtonOn = !self.cbPicker.powerButtonOn;
    [self cbPickerPowerButtonValueChanged:self.cbPicker];
}

-(BOOL)onMenubarBackButtonPressed {
    if (_dimmerCalibrationTool && _dimmerCalibrationTool.superview) {
        return [_dimmerCalibrationTool onMenubarBackButtonPressed];
    }
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)gr {
    if (_dimmerCalibrationTool == nil || _dimmerCalibrationTool.superview == nil) {
        [super handlePan:gr];
    }
}

-(void)detailWillHide {
    [super detailWillHide];
    
    if (_dimmerCalibrationTool != nil) {
        [_dimmerCalibrationTool dismiss];
        _dimmerCalibrationTool = nil;
    }
}
@end
