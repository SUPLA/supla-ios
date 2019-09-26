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

#import "HomePlusDetailView.h"
#import "SAThermostatHPExtendedValue.h"
#import "SAThermostatScheduleCfg.h"
#import "SuplaApp.h"

#define CFGID_TURBO_TIME 1
#define CFGID_WATER_MAX 2
#define CFGID_ECO_REDUCTION 3
#define CFGID_TEMP_COMFORT 4
#define CFGID_TEMP_ECO 5

#define PROG_ECO 1
#define PROG_COMFORT 2

@implementation SAHomePlusCfgItem {
    UIButton *_btnMinus;
    UIButton *_btnPlus;
    UILabel *_label;
    short _min;
    short _max;
    short _value;
    short _cfgId;
}

@synthesize delegate;

-(void)setValue:(short)value {
    _value = value;
    
    if (_label) {
        NSString *unit;
        if (_cfgId == CFGID_TURBO_TIME) {
            unit = [NSString stringWithFormat:@" %@", NSLocalizedString(@"h", nil)];
        } else {
            unit = @"\u00B0";
        }
        [_label setText: [NSString stringWithFormat:@"%i%@", value, unit]];
    }
}

-(id)initWithButtonMinus:(UIButton *)btnMinus buttonPlus:(UIButton*)btnPlus valueLabel:(UILabel*)label valueMin:(short)min valueMax:(short)max valueDefault:(short)def cfgId:(short)cfgId delegate:(id<SAHomePlusCfgItemDelegate>)delegate{
    if ((self = [super init]) != nil) {
        _btnMinus = btnMinus;
        _btnPlus = btnPlus;
        _label = label;
        _min = min;
        _max = max;
        _cfgId = cfgId;
        self.delegate = delegate;
        
        if (_btnPlus!=nil) {
          [_btnPlus addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchDown];
        }
         
        if (_btnMinus!=nil) {
          [_btnMinus addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchDown];
        }
        
        [self setValue:def];
        return self;
    }
    return nil;
}

-(short)cfgId {
    return _cfgId;
}

-(short)value {
    return _value;
}

-(IBAction)btnTouched:(id)btn {
    if (btn == _btnPlus && _value < _max) {
        [self setValue:_value+1];
    } else if (btn == _btnMinus && _value > _min) {
        [self setValue:_value-1];
    } else {
        return;
    }
    
    if (delegate) {
        [delegate cfgItemChanged:self];
    }
}
@end

@implementation SAHomePlusDetailView {
    NSTimeInterval _refreshLock;
    NSMutableArray *_cfgItems;
}

-(void)detailViewInit {
    if (!self.initialized) {
        self.vCalendar.program0Label = NSLocalizedString(@"ECO", nil);
        self.vCalendar.program1Label = NSLocalizedString(@"Comfort", nil);
        self.vCalendar.firstDay = 2;
        self.vCalendar.delegate = self;
        _cfgItems = [[NSMutableArray alloc] init];
 
        [_cfgItems addObject:[[SAHomePlusCfgItem alloc]
                              initWithButtonMinus:self.btnTurboMinus
                              buttonPlus:self.btnTurboPlus
                              valueLabel:self.lCfgTurbo
                              valueMin:1
                              valueMax:3
                              valueDefault:1
                              cfgId:CFGID_TURBO_TIME
                              delegate:self]];
        
        [_cfgItems addObject:[[SAHomePlusCfgItem alloc]
                              initWithButtonMinus:self.btnWaterMaxMinus
                              buttonPlus:self.btnWaterMaxPlus
                              valueLabel:self.lCfgWaterMax
                              valueMin:30
                              valueMax:70
                              valueDefault:70
                              cfgId:CFGID_WATER_MAX
                              delegate:self]];
        
        [_cfgItems addObject:[[SAHomePlusCfgItem alloc]
                              initWithButtonMinus:self.btnEcoRecuctionMinus
                              buttonPlus:self.btnEcoReductionPlus
                              valueLabel:self.lCfgEcoReduction
                              valueMin:1
                              valueMax:5
                              valueDefault:3
                              cfgId:CFGID_ECO_REDUCTION
                              delegate:self]];
        
        [_cfgItems addObject:[[SAHomePlusCfgItem alloc]
                              initWithButtonMinus:self.btnComfortMinus
                              buttonPlus:self.btnComfortPlus
                              valueLabel:self.lCfgComfort
                              valueMin:10
                              valueMax:30
                              valueDefault:22
                              cfgId:CFGID_TEMP_COMFORT
                              delegate:self]];
        
        [_cfgItems addObject:[[SAHomePlusCfgItem alloc]
                              initWithButtonMinus:self.btnEcoMinus
                              buttonPlus:self.btnEcoPlus
                              valueLabel:self.lCfgEco
                              valueMin:10
                              valueMax:30
                              valueDefault:19
                              cfgId:CFGID_TEMP_ECO
                              delegate:self]];
    }
    [super detailViewInit];
}

-(void)updateCalendarECOLabelWithCfgItem:(SAHomePlusCfgItem *)item {
    [self.vCalendar setProgram0Label:
     [NSString stringWithFormat:@"%@ %i\u00B0", NSLocalizedString(@"ECO", nil), item.value]];
}

-(void)updateCalendarComfortLabelWithCfgItem:(SAHomePlusCfgItem *)item {
    [self.vCalendar setProgram1Label:
     [NSString stringWithFormat:@"%@ %i\u00B0", NSLocalizedString(@"Comfort", nil), item.value]];
}

-(void)setCfgValue:(short)value cfgId:(short)cfgId {
    for(int a=0;a<_cfgItems.count;a++) {
        SAHomePlusCfgItem *item = [_cfgItems objectAtIndex:a];
        if (item.cfgId == cfgId) {
            item.value = value;
            
            if (cfgId == CFGID_TEMP_ECO) {
                [self updateCalendarECOLabelWithCfgItem:item];
            } else if (cfgId == CFGID_TEMP_COMFORT) {
                [self updateCalendarComfortLabelWithCfgItem:item];
            }
            break;
        }
    }
}

-(void)showErrorMessage:(NSString *)msg {
    if (msg == nil || [msg isEqualToString:@""]) {
        self.vError.hidden = YES;
        self.cErrorHeight.constant = 0;
        [self.lErrorMessage setText:@""];
    } else {
        self.vError.hidden = NO;
        self.cErrorHeight.constant = 20;
        [self.lErrorMessage setText:msg];
    }
}

-(void)showMainView {
    self.vMain.hidden = NO;
    self.vCalendar.hidden = YES;
    self.vSettings.hidden = YES;
}

-(void)showCalendar:(BOOL)show {
    self.vSettings.hidden = YES;
    
    if (show) {
        self.vMain.hidden = YES;
        self.vCalendar.hidden = NO;
    } else {
        self.vMain.hidden = NO;
        self.vCalendar.hidden = YES;
    }
}

-(void)showSettings:(BOOL)show {
    self.vCalendar.hidden = YES;
    
    if (show) {
        self.vMain.hidden = YES;
        self.vSettings.hidden = NO;
    } else {
        self.vMain.hidden = NO;
        self.vSettings.hidden = YES;
    }
}

-(void)onDetailShow {
    [self showMainView];
    [self showErrorMessage:nil];
    [self.lPreloader animateWithTimeInterval:0.05];
};

-(void)onDetailHide {
    [self showMainView];
};

- (IBAction)calendarButtonTouched:(id)sender {
    [self showCalendar:self.vCalendar.hidden];
}

- (IBAction)settingsButtonTouched:(id)sender {
    [self showSettings:self.vSettings.hidden];
}

- (void)updateView {
    if (_refreshLock > [[NSDate date] timeIntervalSince1970]) {
        return;
    }
    
    [self.lCaption setText:[self.channelBase getChannelCaption]];

    SAThermostatHPExtendedValue *thev = nil;
    if (![self.channelBase isKindOfClass:SAChannel.class]
        || (thev = ((SAChannel*)self.channelBase).ev.thermostatHP) == nil) {
        return;
    }

    [self setCfgValue:thev.turboTime cfgId:CFGID_TURBO_TIME];
    [self setCfgValue:thev.waterMax cfgId:CFGID_WATER_MAX];
    [self setCfgValue:thev.ecoReductionTemperature cfgId:CFGID_ECO_REDUCTION];
    [self setCfgValue:thev.comfortTemp cfgId:CFGID_TEMP_COMFORT];
    [self setCfgValue:thev.ecoTemp cfgId:CFGID_TEMP_ECO];
    
    [self showErrorMessage:thev.errorMessage];
    
    if (!_vCalendar.isTouched) {
        [_vCalendar clear];
        
        if ([thev isSheludeProgramValueType]) {
            for(short d=1;d<=7;d++) {
                 for(short h=0;h<24;h++) {
                     [self.vCalendar setProgramForDay:d andHour:h toOne:[thev sheduledComfortProgramForDay:d andHour:h]];
                 }
             }
        }
    }
    
}

-(BOOL)isGroup {
    return NO;
}

-(void)lockRefreshForATime:(NSTimeInterval)sec {
    _refreshLock = [[NSDate date] timeIntervalSince1970] + ([self isGroup] ? 4 : 2) + sec;
}

-(void)lockRefreshAWhile {
    [self lockRefreshForATime:[self isGroup] ? 4 : 2];
}

-(void)calCfgSetTemperature:(double)t withIndex:(short)idx {
    
    if (idx < 0 || idx >= 10) {
          return;
      }
    
    SASuplaClient *client = [SAApp SuplaClient];
    if (client) {
        TThermostatTemperatureCfg tcfg;
        memset(&tcfg, 0, sizeof(TThermostatTemperatureCfg));
        
        tcfg.Index = 1;
        tcfg.Index <<= idx;
        tcfg.Temperature[idx] = t * 100.0;
       
        [client deviceCalCfgCommand:SUPLA_THERMOSTAT_CMD_SET_TEMPERATURE cg:self.channelBase.remote_id group:[self isGroup] data:(char*)&tcfg dataSize:sizeof(TThermostatTemperatureCfg)];
    }
}

-(void)calCfgSetTurboTime:(char)t {
    SASuplaClient *client = [SAApp SuplaClient];
    if (client) {
       [client deviceCalCfgCommand:SUPLA_THERMOSTAT_CMD_SET_TIME
               cg:self.channelBase.remote_id
               group:[self isGroup]
               charValue:t];
    }
}

-(void)cfgItemChanged:(SAHomePlusCfgItem*)item {
    if (item == nil) {
        return;
    }
    [self lockRefreshAWhile];
    
    short idx = 0;
    
    switch (item.cfgId) {
        case CFGID_WATER_MAX:
            idx = 2;
            break;
        case CFGID_TEMP_COMFORT:
            [self updateCalendarComfortLabelWithCfgItem:item];
            idx = 3;
            break;
        case CFGID_TEMP_ECO:
            [self updateCalendarECOLabelWithCfgItem:item];
            idx = 4;
            break;
        case CFGID_ECO_REDUCTION:
            idx = 5;
            break;
        case CFGID_TURBO_TIME:
            [self calCfgSetTurboTime:item.value];
            break;
    }
    
    if (idx > 0) {
       [self calCfgSetTemperature:item.value withIndex:idx];
    }
}

-(void)sendScheduleValues {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendScheduleValues)object:nil];
    
    SASuplaClient *client = [SAApp SuplaClient];
    if (client) {
        SAThermostatScheduleCfg *cfg = [[SAThermostatScheduleCfg alloc] init];
        for(short d=1;d<=7;d++) {
            for(short h=0;h<24;h++) {
                [cfg setProgram:[_vCalendar programIsSetToOneWithDay:d andHour:h] ? PROG_COMFORT : PROG_ECO forHour:h weekday:[cfg weekDayByIndex: d]];
            }
        }
        
        [client thermostatScheduleCfgRequest:cfg cg:self.channelBase.remote_id group:[self isGroup]];
    }
}

-(void)thermostatCalendarPragramChanged:(id)calendar day:(short)d hour:(short)h program1:(BOOL)p1 {
    [self lockRefreshForATime:4];
    
    SEL selector = @selector(sendScheduleValues);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
    [self performSelector:selector withObject:nil afterDelay:2];
}

@end
