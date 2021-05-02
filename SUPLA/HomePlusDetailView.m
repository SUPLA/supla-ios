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
#import "SADownloadThermostatMeasurements.h"
#import "SAThermostatChartHelper.h"
#import "HomePlusDetailViewGroupCell.h"
#import "SAChannelGroup+CoreDataClass.h"
#import "UIColor+SUPLA.h"

#define CFGID_TURBO_TIME 1
#define CFGID_WATER_MAX 2
#define CFGID_ECO_REDUCTION 3
#define CFGID_TEMP_COMFORT 4
#define CFGID_TEMP_ECO 5

#define PROG_ECO 1
#define PROG_COMFORT 2

typedef enum {
    kOFF = 0,
    kON = 1,
    kUNKNOWN = 2,
    kTOOGLE = 3
} _e_hpBtnApperance;

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
    SADownloadThermostatMeasurements *_task;
    SAThermostatChartHelper *_chartHelper;
    NSFetchedResultsController *_frc;
    UINib *_cell_nib;
    double _presetTempMin;
    double _presetTempMax;
    NSTimer *_refreshTimer1;
}

-(void)detailViewInit {
    if (!self.initialized) {
        self.vCalendar.program0Label = NSLocalizedString(@"ECO", nil);
        self.vCalendar.program1Label = NSLocalizedString(@"Comfort", nil);
        self.vCalendar.firstDay = 2;
        self.vCalendar.delegate = self;
        
        _chartHelper = [[SAThermostatChartHelper alloc] init];
        _chartHelper.combinedChart = self.combinedChart;
        _chartHelper.unit = @"";
        
        _cell_nib = [UINib nibWithNibName:@"HomePlusDetailViewGroupCell" bundle:nil];
        
        [self.tvChannels registerNib:_cell_nib forCellReuseIdentifier:@"HomePlusDetailViewGroupCell"];
        
        self.tvChannels.delegate = self;
        self.tvChannels.dataSource = self;
        
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
    
    _refreshTimer1 = nil;
    [super detailViewInit];
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    if (_chartHelper) {
        _chartHelper.channelId = channelBase ? channelBase.remote_id : 0;
    }
    [super setChannelBase:channelBase];
}

-(void)updateCalendarECOLabelWithCfgItem:(SAHomePlusCfgItem *)item {
    [self.vCalendar setProgram0Label:
     [NSString stringWithFormat:@"%@ %i\u00B0", NSLocalizedString(@"Lower", nil), item.value]];
}

-(void)updateCalendarComfortLabelWithCfgItem:(SAHomePlusCfgItem *)item {
    [self.vCalendar setProgram1Label:
     [NSString stringWithFormat:@"%@ %i\u00B0", NSLocalizedString(@"Higher", nil), item.value]];
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

-(void)refreshTimerCancel {
    if (_refreshTimer1) {
        [_refreshTimer1 invalidate];
        _refreshTimer1 = nil;
    }
}

-(void)onRefreshTimer:(NSTimer*)timer {
    [self updateView];
}

-(void)detailWillShow {
    _frc = nil;
    [self showMainView];
    [self showErrorMessage:nil];
    self.lPreloader.hidden = YES;
    
    [self setBtnsOffWithExclude:nil];

    if ([self isGroup]) {
        self.tvChannels.hidden = NO;
        self.vCharts.hidden = YES;
        self.btnSettings.hidden = YES;
        self.btnSchedule.hidden = YES;
    } else {
        self.tvChannels.hidden = YES;
        self.vCharts.hidden = NO;
        self.btnSettings.hidden = NO;
        self.btnSchedule.hidden = NO;
        [self runDownloadTask];
        [_chartHelper load];
        [_chartHelper moveToEnd];
    }
    
    [self updateView];
    _refreshTimer1 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onRefreshTimer:) userInfo:nil repeats:NO];
};

-(void)detailWillHide {
    [self showMainView];
    
    if (_task) {
        [_task cancel];
        _task.delegate = nil;
    }
    _frc = nil;
};

- (IBAction)calendarButtonTouched:(id)sender {
    [self showCalendar:self.vCalendar.hidden];
}

- (IBAction)settingsButtonTouched:(id)sender {
    [self showSettings:self.vSettings.hidden];
}

- (void)loadChannelList{
    _frc = nil;
    
    _e_hpBtnApperance onOffBtnApperance = kUNKNOWN;
    _e_hpBtnApperance normalBtnApperance = kUNKNOWN;
    _e_hpBtnApperance ecoBtnApperance = kUNKNOWN;
    _e_hpBtnApperance turboBtnApperance = kUNKNOWN;
    _e_hpBtnApperance autoBtnApperance = kUNKNOWN;
    
    NSArray *channels = [self.fetchedResultsController fetchedObjects];
    for(int a=0;a<channels.count;a++) {
        SAChannel *channel = [channels objectAtIndex:a];
        SAThermostatHPExtendedValue *thev = nil;

        BOOL thermostatOn = NO;
        BOOL normalOn = NO;
        BOOL ecoReductionApplied = NO;
        BOOL turboOn = NO;
        BOOL autoOn = NO;
        
        if (channel
            && [channel isKindOfClass:[SAChannel class]]
            && (thev = channel.ev.thermostatHP) != nil) {
            
            thermostatOn = [thev isThermostatOn];
            normalOn = [thev isNormalOn];
            ecoReductionApplied = [thev isEcoRecuctionApplied];
            turboOn = [thev isTurboOn];
            autoOn = [thev isAutoOn];
        }
        
        if (a == 0) {
            onOffBtnApperance = thermostatOn ? kON : kOFF;
            normalBtnApperance = normalOn ? kON : kOFF;
            ecoBtnApperance = ecoReductionApplied ? kON : kOFF;
            turboBtnApperance = turboOn ? kON : kOFF;
            autoBtnApperance = autoOn ? kON : kOFF;
        } else {
            if (onOffBtnApperance != kUNKNOWN
                && onOffBtnApperance != (thermostatOn ? kON : kOFF)) {
                onOffBtnApperance = kUNKNOWN;
            }
            
            if (normalBtnApperance != kUNKNOWN
                && normalBtnApperance != (normalOn ? kON : kOFF)) {
                normalBtnApperance = kUNKNOWN;
            }
            
            if (ecoBtnApperance != kUNKNOWN
                && ecoBtnApperance != (ecoReductionApplied ? kON : kOFF)) {
                ecoBtnApperance = kUNKNOWN;
            }
            
            if (turboBtnApperance != kUNKNOWN
                  && turboBtnApperance != (turboOn ? kON : kOFF)) {
                  turboBtnApperance = kUNKNOWN;
            }
            
            if (autoBtnApperance != kUNKNOWN
                  && autoBtnApperance != (autoOn ? kON : kOFF)) {
                  autoBtnApperance = kUNKNOWN;
            }
        }
        
    }
    
    [self setBtnApperance:onOffBtnApperance button:self.btnOnOff];
    [self setBtnApperance:normalBtnApperance button:self.btnNormal];
    [self setBtnApperance:ecoBtnApperance button:self.btnEco];
    [self setBtnApperance:turboBtnApperance button:self.btnTurbo];
    [self setBtnApperance:autoBtnApperance button:self.btnAuto];
    
    [self.tvChannels reloadData];
}

- (void)updateView {
    if ([self isGroup]) {
        [self loadChannelList];
    }
    
    if (_refreshLock > [[NSDate date] timeIntervalSince1970]) {
        return;
    }
    
    _presetTempMin = self.channelBase.presetTemperatureMin;
    _presetTempMax = self.channelBase.presetTemperatureMax;
    
    [self.lTemperature setAttributedText:[self.channelBase attrStringValueWithIndex:0 font:self.lTemperature.font]];
        
    SAThermostatHPExtendedValue *thev = nil;
    if (![self.channelBase isKindOfClass:SAChannel.class]
        || (thev = ((SAChannel*)self.channelBase).ev.thermostatHP) == nil) {
        return;
    }
    
    [self setBtnApperance:[thev isThermostatOn] ? kON : kOFF button:self.btnOnOff];
    [self setBtnApperance:[thev isNormalOn] ? kON : kOFF button:self.btnNormal];
    [self setBtnApperance:[thev isEcoRecuctionApplied] ? kON : kOFF button:self.btnEco];
    [self setBtnApperance:[thev isAutoOn] ? kON : kOFF button:self.btnAuto];
    [self setBtnApperance:[thev isTurboOn] ? kON : kOFF button:self.btnTurbo];
    
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
    return [self.channelBase isKindOfClass:[SAChannelGroup class]];
}

-(void)lockRefreshForATime:(NSTimeInterval)sec {
    _refreshLock = [[NSDate date] timeIntervalSince1970] + ([self isGroup] ? 4 : 2) + sec;
}

-(void)lockRefreshAWhile {
    [self lockRefreshForATime:[self isGroup] ? 4 : 3];
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

-(void)calCfgCommand:(int)command charValue:(char)c {
    SASuplaClient *client = [SAApp SuplaClient];
    if (client) {
        [client deviceCalCfgCommand:command cg:self.channelBase.remote_id group:[self isGroup] charValue:c];
    }
}

-(void)calCfgCommand:(int)command {
    SASuplaClient *client = [SAApp SuplaClient];
    if (client) {
        [client deviceCalCfgCommand:command cg:self.channelBase.remote_id group:[self isGroup]];
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

-(void) runDownloadTask {
    if (_task && ![_task isTaskIsAliveWithTimeout:90]) {
        [_task cancel];
        _task = nil;
    }
    
    if (!_task) {
        _task = [[SADownloadThermostatMeasurements alloc] init];
        _task.channelId = self.channelBase.remote_id;
        _task.delegate = self;
        [_task start];
    }
}

-(void) onRestApiTaskStarted: (SARestApiClientTask*)task {
    //NSLog(@"onRestApiTaskStarted");
    [self.lPreloader animateWithTimeInterval:0.05];
    _chartHelper.downloadProgress = 0;
}

-(void) onRestApiTaskFinished: (SARestApiClientTask*)task {
    //NSLog(@"onRestApiTaskFinished");
    if (_task != nil && task == _task) {
        _task.delegate = nil;
        _task = nil;
    }

    self.lPreloader.hidden = YES;
    [self updateView];
    _chartHelper.downloadProgress = nil;
    [_chartHelper load];
}

-(void) onRestApiTask: (SARestApiClientTask*)task progressUpdate:(float)progress {
    _chartHelper.downloadProgress = [NSNumber numberWithFloat:progress];
}

- (NSFetchedResultsController*)fetchedResultsController {
    if ( _frc == nil ) {
        _frc = [SAApp.DB getHomePlusGroupFrcWithGroupId:self.channelBase.remote_id];
    }
    return _frc;
}

- (NSInteger)channelCountInSection:(NSInteger)section {
    NSFetchedResultsController *frc = self.fetchedResultsController;
    if ( frc ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[frc sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    return 0;
}

- (NSInteger)sectionCount {
    NSFetchedResultsController *frc = self.fetchedResultsController;
    return frc ? [[frc sections] count] : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self channelCountInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     SAChannelBase *channel_base = [self.fetchedResultsController objectAtIndexPath:indexPath];
    HomePlusDetailViewGroupCell *cell = [tableView dequeueReusableCellWithIdentifier: @"HomePlusDetailViewGroupCell"];
    if (cell) {
        cell.channelBase = channel_base;
    }
    
    return cell;
}

- (_e_hpBtnApperance) setBtnApperance:(_e_hpBtnApperance)apperance button:(UIButton*)btn {
    
    if (apperance == kTOOGLE) {
        apperance = btn.tag == 1 ? kOFF : kON;
    }
    
    btn.tag = apperance == kON ? 1 : 0;
    switch (apperance) {
        case kON:
            btn.backgroundColor = [UIColor hpBtnOn];
            break;
        case kOFF:
            btn.backgroundColor = [UIColor hpBtnOff];
            break;
        case kUNKNOWN:
            btn.backgroundColor = [UIColor hpBtnUnknown];
            break;
        default:
            break;
    }
    
    if (btn == self.btnOnOff) {
        NSString *onOffTitle = NSLocalizedString(apperance == kON ? @"ON" : @"OFF", NULL);
        [btn setTitle:onOffTitle forState:UIControlStateNormal];
    }
    
    return apperance;
}

- (IBAction)plusMinusTouched:(id)sender {
    if (sender == self.btnPlus) {
        _presetTempMin++;
    } else {
        if (_presetTempMax > -273) {
            _presetTempMin = _presetTempMax;
            _presetTempMax = -273;
        }
        _presetTempMin--;
    }
    
    if (_presetTempMin > 30) {
        _presetTempMin = 30;
    } else if (_presetTempMin < 10) {
        _presetTempMin = 10;
    }

     NSAttributedString *attrText = [self.channelBase thermostatAttrStringWithMeasuredTempMin:self.channelBase.measuredTemperatureMin measuredTempMax:self.channelBase.measuredTemperatureMax presetTempMin:_presetTempMin presetTempMax:-273 font:self.lTemperature.font];
    
    [self.lTemperature setAttributedText:attrText];
    [self lockRefreshAWhile];
    [self calCfgSetTemperature:_presetTempMin withIndex:0];
    
}

- (void)setBtn:(UIButton *)btn offIfNotExcluded:(NSArray *)exclude {
    if (!exclude || [exclude indexOfObject:btn] == NSNotFound) {
       [self setBtnApperance:[self isGroup] ? kUNKNOWN : kOFF button:btn];
    }
}

- (void)setBtnsOffWithExclude:(NSArray *)exclude {
    [self setBtn:self.btnOnOff offIfNotExcluded:exclude];
    [self setBtn:self.btnNormal offIfNotExcluded:exclude];
    [self setBtn:self.btnEco offIfNotExcluded:exclude];
    [self setBtn:self.btnAuto offIfNotExcluded:exclude];
    [self setBtn:self.btnTurbo offIfNotExcluded:exclude];
}

- (IBAction)onOffTouched:(id)sender {
    [self lockRefreshAWhile];
    
    if ( sender == self.btnNormal) {
        [self setBtnApperance:kON button:sender];
        [self calCfgCommand:SUPLA_THERMOSTAT_CMD_SET_MODE_NORMAL];
        [self setBtnsOffWithExclude:@[sender, self.btnOnOff]];
        return;
    }
    
    int command = 0;
    char value = [self setBtnApperance:kTOOGLE button:sender] == kON ? 1 : 0;
    
    if (sender == self.btnOnOff) {
        command = SUPLA_THERMOSTAT_CMD_TURNON;
        if (value == 0) {
            [self setBtnsOffWithExclude:nil];
        }
    } else if ( sender == self.btnEco) {
        command = SUPLA_THERMOSTAT_CMD_SET_MODE_ECO;
    } else if ( sender == self.btnAuto) {
        command = SUPLA_THERMOSTAT_CMD_SET_MODE_AUTO;
    } else if ( sender == self.btnTurbo) {
        command = SUPLA_THERMOSTAT_CMD_SET_MODE_TURBO;
    }
    
    if (command) {
        [self calCfgCommand:command charValue:value];
    }
    
    if (value == 1 && sender != self.btnOnOff) {
        [self setBtnsOffWithExclude:@[sender, self.btnOnOff]];
    }
}

@end
