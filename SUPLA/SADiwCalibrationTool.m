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

#import "SADiwCalibrationTool.h"
#import "SuplaClient.h"
#import "SAInfoVC.h"

#import "SACalCfgResult.h"
#import "UIColor+SUPLA.h"

#define DIW_CMD_ENTER_CFG_MODE 0x1
#define DIW_CMD_CONFIGURATION_REPORT 0x2
#define DIW_CMD_CONFIG_COMPLETE 0x3
#define DIW_CMD_SET_MINIMUM 0x4
#define DIW_CMD_SET_MAXIMUM 0x5
#define DIW_CMD_SET_LEDCONFIG 0x6
#define DIW_CMD_SET_INPUT_BEHAVIOR 0x7
#define DIW_CMD_SET_INPUT_MODE 0x8
#define DIW_CMD_SET_INPUT_BI_MODE 0x9

#define INPUT_MODE_UNKNOWN -1
#define INPUT_MODE_MONOSTABLE 0
#define INPUT_MODE_BISTABLE 1

#define BEHAVIOR_NORMAL 0
#define BEHAVIOR_LOOP 1

#define BISTABLE_MODE_100P 0
#define BISTABLE_MODE_RESTORE 1

#pragma pack(push, 1)
typedef struct {
    unsigned char cfg_version;
    unsigned char stm_version_major;
    unsigned char stm_version_minor;
    unsigned char stm_version_build;
    unsigned char stm_version_revision;

    unsigned short min;
    unsigned short max;
    unsigned char dimming_time;
    unsigned char lighteening_time;
    unsigned char input_time;
    unsigned char input_behavior;
    unsigned char state_after_power_return;
    unsigned char input_mode;
    unsigned char input_bi_mode;

    unsigned char led;
    unsigned char zero[50];  // For future development
} _diw_configuration_t;
#pragma pack(pop)

@implementation SADiwCalibrationTool {
    _diw_configuration_t _config;
}

-(void)deviceCalCfgCommand:(int)command {
    switch (command) {
        case DIW_CMD_SET_MINIMUM:
            [self deviceCalCfgCommand:command shortValue:self.rangeCalibrationWheel.minimum];
            break;
        case DIW_CMD_SET_MAXIMUM:
            [self deviceCalCfgCommand:command shortValue:self.rangeCalibrationWheel.maximum];
            break;
        default:
            [super deviceCalCfgCommand:command];
            break;
    }
}

-(void) calibrationWheelRangeChanged:(SARangeCalibrationWheel *)wheel minimum:(BOOL)min {
    [self deviceCalCfgCommandWithDelay:min ? DIW_CMD_SET_MINIMUM : DIW_CMD_SET_MAXIMUM];
}

-(void) calibrationWheelBoostChanged:(SARangeCalibrationWheel *)wheel {}

-(void)setLedCfg:(char)cfg {
    [self deviceCalCfgCommand:DIW_CMD_SET_LEDCONFIG charValue:&cfg shortValue:NULL];
}

- (char)getLedCfg {
    return _config.led;
}

-(void)onCalCfgResult:(SACalCfgResult *)result {
    switch (result.command) {
        case DIW_CMD_ENTER_CFG_MODE:
            [self setConfigurationStarted];
            break;
        case DIW_CMD_CONFIGURATION_REPORT:
            if (result.data.length == sizeof(_diw_configuration_t)) {
                [result.data getBytes:&_config length:result.data.length];
            }
            [self cfgToUIWithDelay:YES];
        default:
            break;
    }
}

- (void)beforeConfigurationStart {
    memset(&_config, 0, sizeof(_diw_configuration_t));
    self.rangeCalibrationWheel.delegate = self;
    self.rangeCalibrationWheel.maximumValue = 500;
    
    [self initGestureRecognizerForView:self.imgOption action:@selector(inputOptionTapped:)];
    [self initGestureRecognizerForView:self.imgBgOption action:@selector(inputOptionTapped:)];
}

- (void)onDismiss {
    if (self.isConfigurationStarted) {
        [self deviceCalCfgCommand:DIW_CMD_CONFIG_COMPLETE charValue:0];
    }
}

- (void)saveChanges {
    [self deviceCalCfgCommand:DIW_CMD_CONFIG_COMPLETE charValue:1];
}

- (void)cfgToUI {
    [self.rangeCalibrationWheel setMinimum:_config.min andMaximum:_config.max];
    [self inputModeToUI];
    if (_config.stm_version_major
        || _config.stm_version_minor
        || _config.stm_version_build
        || _config.stm_version_revision) {
        self.lSTMFirmwareVersion.text = [NSString stringWithFormat:@"%i.%i.%i.%i",
                                    _config.stm_version_major,
                                    _config.stm_version_minor,
                                    _config.stm_version_build,
                                    _config.stm_version_revision];
    } else {
        self.lSTMFirmwareVersion.text = @"";
    }
}

- (void)showInformationDialog {
    [SAInfoVC showInformationWindowWithMessage:INFO_MESSAGE_DIW_CONFIG];
}

- (void)onSuperuserAuthorizationSuccess {
    [self deviceCalCfgCommand:DIW_CMD_ENTER_CFG_MODE];
}

-(BOOL)isLedConfigAvailable {
    return YES;
}

+(SADimmerCalibrationTool*)newInstance {
    return [[[NSBundle mainBundle] loadNibNamed:@"SADiwCalibrationTool" owner:nil options:nil] objectAtIndex:0];
}

- (void)inputOptionToUI {
    switch(_config.input_mode) {
        case INPUT_MODE_BISTABLE:
            if (_config.input_bi_mode == BISTABLE_MODE_100P) {
                self.imgOption.image = [UIImage imageNamed:@"p100white"];
                self.imgBgOption.backgroundColor = [UIColor diwInputOptionSelected];
            } else {
                self.imgOption.image = [UIImage imageNamed:@"p100"];
                self.imgBgOption.backgroundColor = [UIColor whiteColor];
            }
   
            break;
        case INPUT_MODE_MONOSTABLE:
            if (_config.input_behavior == BEHAVIOR_LOOP) {
                self.imgOption.image = [UIImage imageNamed:@"infinitywhite"];
                self.imgBgOption.backgroundColor = [UIColor diwInputOptionSelected];
            } else {
                self.imgOption.image = [UIImage imageNamed:@"infinity"];
                self.imgBgOption.backgroundColor = [UIColor whiteColor];
            }

            break;
    }
}

- (void)inputModeToUI {
    self.btnMonostable.backgroundColor = [UIColor whiteColor];
    self.btnMonostable.selected = NO;
    
    self.btnBistable.backgroundColor = [UIColor whiteColor];
    self.btnBistable.selected = NO;
    
    switch(_config.input_mode) {
        case INPUT_MODE_BISTABLE:
            self.btnBistable.backgroundColor = [UIColor rgbwSelectedTabColor];
            self.btnBistable.selected = YES;
            break;
        case INPUT_MODE_MONOSTABLE:
            self.btnMonostable.backgroundColor = [UIColor rgbwSelectedTabColor];
            self.btnMonostable.selected = YES;
            break;
    }
    
    [self inputOptionToUI];
}

- (IBAction)inputModeTouch:(id)sender {
    if (sender == self.btnBistable) {
        _config.input_mode = INPUT_MODE_BISTABLE;
    } else if (sender == self.btnMonostable) {
        _config.input_mode = INPUT_MODE_MONOSTABLE;
    } else {
        return;
    }
    
    [self inputModeToUI];
    [self deviceCalCfgCommand:DIW_CMD_SET_INPUT_MODE charValue:_config.input_mode];
}

- (void)inputOptionTapped:(UITapGestureRecognizer *)tapRecognizer {
    switch(_config.input_mode) {
        case INPUT_MODE_BISTABLE:
            _config.input_bi_mode =
            _config.input_bi_mode == BISTABLE_MODE_100P
            ? BISTABLE_MODE_RESTORE : BISTABLE_MODE_100P;
            
            [self deviceCalCfgCommand:DIW_CMD_SET_INPUT_BI_MODE charValue:_config.input_bi_mode];
            break;
        case INPUT_MODE_MONOSTABLE:
            _config.input_behavior =
            _config.input_behavior == BEHAVIOR_LOOP
            ? BEHAVIOR_NORMAL : BEHAVIOR_LOOP;
            
            [self deviceCalCfgCommand:DIW_CMD_SET_INPUT_BEHAVIOR charValue:_config.input_behavior];
            break;
        default:
            return;
    }
    
    [self inputOptionToUI];
}

@end
