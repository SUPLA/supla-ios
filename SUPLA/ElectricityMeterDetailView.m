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

#import "ElectricityMeterDetailView.h"
#import "SAClassHelper.h"
#import "SuplaApp.h"
#import "SAElectricityChartHelper.h"

// iPhone <=5 fix.
// Integer number as boolean method parameter does not work good in iPhone <5
#define MVAL(val_flag) (measured_values & val_flag) ? YES : NO

@implementation SAElectricityMeterDetailView   {
    short selectedPhase;
    NSTimer *_preloaderTimer;
    NSTimer *_taskTimer;
    SADownloadElectricityMeasurements *_task;
    SAElectricityChartHelper *_chartHelper;
    int _preloaderPos;
}

-(void)detailViewInit {
    [super detailViewInit];
    selectedPhase = 0;
    _chartHelper = [[SAElectricityChartHelper alloc] init];
    _chartHelper.combinedChart = self.combinedChart;
    _chartHelper.pieChart = self.pieChart;
    _chartHelper.unit = @"kWh";
    _tfChartTypeFilter.dateRangeFilterField = _ftDateRangeFilter;
    _tfChartTypeFilter.ff_delegate = self;
    _ftDateRangeFilter.ff_delegate = self;
}

- (void)setLabel:(UILabel*)label Visible:(BOOL)visible withConstraint:(NSLayoutConstraint*)cns {
    if (label.hidden == visible) {
        if (visible) {
            cns.constant = 0;
            label.hidden = NO;
        } else {
            label.hidden = YES;
            cns.constant = label.frame.size.height * -1;
        }
    }
}

- (void)setFrequency:(double)freq visible:(BOOL)visible {
    [self setLabel:self.lFrequency Visible:visible withConstraint:self.cFrequencyTop];
    [self setLabel:self.lFrequencyValue Visible:visible withConstraint:self.cFrequencyValueTop];
    [self.lFrequencyValue setText:[NSString stringWithFormat:@"%0.2f Hz", freq]];
}

- (void)setVoltage:(double)voltage visible:(BOOL)visible {
    [self setLabel:self.lVoltage Visible:visible withConstraint:self.cVoltageTop];
    [self setLabel:self.lVoltageValue Visible:visible withConstraint:self.cVoltageValueTop];
    [self.lVoltageValue setText:[NSString stringWithFormat:@"%0.2f V", voltage]];
}

- (void)setCurrent:(double)current visible:(BOOL)visible {
    [self setLabel:self.lCurrent Visible:visible withConstraint:self.cCurrentTop];
    [self setLabel:self.lCurrentValue Visible:visible withConstraint:self.cCurrentValueTop];
    [self.lCurrentValue setText:[NSString stringWithFormat:@"%0.3f A", current]];
}

- (void)setActivePower:(double)power visible:(BOOL)visible {
    [self setLabel:self.lActivePower Visible:visible withConstraint:self.cActivePowerTop];
    [self setLabel:self.lActivePowerValue Visible:visible withConstraint:self.cActivePowerValueTop];
    [self.lActivePowerValue setText:[NSString stringWithFormat:@"%0.5f W", power]];
}

- (void)setReactivePower:(double)power visible:(BOOL)visible {
    [self setLabel:self.lReactivePower Visible:visible withConstraint:self.cReactivePowerTop];
    [self setLabel:self.lReactivePowerValue Visible:visible withConstraint:self.cReactivePowerValueTop];
    [self.lReactivePowerValue setText:[NSString stringWithFormat:@"%0.5f var", power]];
}

- (void)setApparentPower:(double)power visible:(BOOL)visible {
    [self setLabel:self.lApparentPower Visible:visible withConstraint:self.cApparentPowerTop];
    [self setLabel:self.lApparentPowerValue Visible:visible withConstraint:self.cApparentPowerValueTop];
    [self.lApparentPowerValue setText:[NSString stringWithFormat:@"%0.5f VA", power]];
}

- (void)setPowerFactor:(double)factor visible:(BOOL)visible {
    [self setLabel:self.lPowerFactor Visible:visible withConstraint:self.cPowerFactorTop];
    [self setLabel:self.lPowerFactorValue Visible:visible withConstraint:self.cPowerFactorValueTop];
    [self.lPowerFactorValue setText:[NSString stringWithFormat:@"%0.3f", factor]];
}

- (void)setPhaseAngle:(double)angle visible:(BOOL)visible {
    [self setLabel:self.lPhaseAngle Visible:visible withConstraint:self.cPhaseAngleTop];
    [self setLabel:self.lPhaseAngleValue Visible:visible withConstraint:self.cPhaseAngleValueTop];
    [self.lPhaseAngleValue setText:[NSString stringWithFormat:@"%0.2f\u00B0", angle]];
}

- (void)setForwardActiveEnergy:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lForwardActiveEnergy Visible:visible withConstraint:self.cForwardActiveEnergyTop];
    [self setLabel:self.lForwardActiveEnergyValue Visible:visible withConstraint:self.cForwardActiveEnergyValueTop];
    [self.lForwardActiveEnergyValue setText:[NSString stringWithFormat:@"%0.5f kWh", energy]];
}

- (void)setReverseActiveEnergy:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lReverseActiveEnergy Visible:visible withConstraint:self.cReverseActiveEnergyTop];
    [self setLabel:self.lReverseActiveEnergyValue Visible:visible withConstraint:self.cReverseActiveEnergyValueTop];
    [self.lReverseActiveEnergyValue setText:[NSString stringWithFormat:@"%0.5f kWh", energy]];
}

- (void)setForwardReactiveEnergy:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lForwardReactiveEnergy Visible:visible withConstraint:self.cForwardReactiveEnergyTop];
    [self setLabel:self.lForwardReactiveEnergyValue Visible:visible withConstraint:self.cForwardReactiveEnergyValueTop];
    [self.lForwardReactiveEnergyValue setText:[NSString stringWithFormat:@"%0.5f kvarh", energy]];
}

- (void)setReverseReactiveEnergy:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lReverseReactiveEnergy Visible:visible withConstraint:self.cReverseReactiveEnergyTop];
    [self setLabel:self.lReverseReactiveEnergyValue Visible:visible withConstraint:self.cReverseReactiveEnergyValueTop];
    [self.lReverseReactiveEnergyValue setText:[NSString stringWithFormat:@"%0.5f kvarh", energy]];
}

- (NSString*)totalForwardActiveEnergyStringForValue:(double)value {
    int precision = 5;
    if (value >= 1000) {
        precision = 3;
    } else if (value >= 10000) {
        precision = 2;
    }
    
    return [NSString stringWithFormat:@"%.*f kWh", precision, value];
}

- (void)updateView {
    
    unsigned int measured_values = 0;
    SAChannelExtendedValue *ev = nil;
    TElectricityMeter_ExtendedValue emev;
    
    self.btnPhase1.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnPhase2.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnPhase3.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnPhaseSum.layer.borderColor = [[UIColor blackColor] CGColor];
    
    CGColorRef btnBorderColor = [[UIColor redColor] CGColor];
    
    NSString *empty = @"----";
    
    [self.lTotalForwardActiveEnergy setText:empty];
    [self.lCurrentConsumption setText:empty];
    [self.lCurrentCost setText:empty];
    [self.lTotalCost setText:empty];
    
    double freq = 0;
    double voltage = 0;
    double current = 0;
    double powerActive = 0;
    double powerReactive = 0;
    double powerApparent = 0;
    double powerFactor = 0;
    double phaseAngle = 0;
    double totalFAE = 0;
    double totalRAE = 0;
    double totalFRE = 0;
    double totalRRE = 0;
    
    if ([self.channelBase isKindOfClass:SAChannel.class]
        && (ev = ((SAChannel*)self.channelBase).ev) != nil
        && [ev getElectricityMeterExtendedValue:&emev]
        && selectedPhase > -1) {
        
        if (emev.m_count > 0) {
            TElectricityMeter_Measurement *m = emev.m;
            
            freq = m->freq * 0.01;
            voltage = m->voltage[selectedPhase] * 0.01;
            
            if ( voltage > 0 ) {
                btnBorderColor = [[UIColor greenColor] CGColor];
            }
            
            current = m->current[selectedPhase] * 0.001;
            powerActive = m->power_active[selectedPhase] * 0.00001;
            powerReactive = m->power_reactive[selectedPhase] * 0.00001;
            powerApparent = m->power_apparent[selectedPhase] * 0.00001;
            powerFactor = m->power_factor[selectedPhase] * 0.001;
            phaseAngle = m->phase_angle[selectedPhase] * 0.1;
        }

        totalFAE = emev.total_forward_active_energy[selectedPhase] * 0.00001;
        totalRAE = emev.total_reverse_active_energy[selectedPhase] * 0.00001;
        totalFRE = emev.total_forward_reactive_energy[selectedPhase] * 0.00001;
        totalRRE = emev.total_reverse_reactive_energy[selectedPhase] * 0.00001;
        
        measured_values = emev.measured_values;
        
        double currentConsumption = 0;
        double currentCost = 0;
        
        if ([SAApp.DB electricityMeterMeasurementsStartsWithTheCurrentMonthForChannelId:self.channelBase.remote_id]) {
            currentConsumption = [ev getTotalForwardActiveEnergyForExtendedValue:&emev];
            currentCost = emev.total_cost * 0.01;
        } else {
            double v0 = [SAApp.DB sumForwardedActiveEnergyForChannelId:self.channelBase.remote_id monthLimitOffset:0];
            double v1 = [SAApp.DB sumForwardedActiveEnergyForChannelId:self.channelBase.remote_id monthLimitOffset:-1];
            
            currentConsumption = v0-v1;
            currentCost = emev.price_per_unit * 0.0001 * currentConsumption;
        }
        
        [self.lTotalForwardActiveEnergy setText:[self totalForwardActiveEnergyStringForValue:[ev getTotalForwardActiveEnergyForExtendedValue:&emev]]];
        [self.lTotalCost setText:[NSString stringWithFormat:@"%0.2f %@", emev.total_cost * 0.01, [ev decodeCurrency:emev.currency]]];
        [self.lCurrentConsumption setText:[NSString stringWithFormat:@"%0.2f kWh", currentConsumption]];
        [self.lCurrentCost setText:[NSString stringWithFormat:@"%0.2f %@", currentCost, [ev decodeCurrency:emev.currency]]];
    
        _chartHelper.pricePerUnit = emev.price_per_unit * 0.0001;
        _chartHelper.currency = [ev decodeCurrency:emev.currency];
        
        _chartHelper.totalForwardActiveEnergyPhase1 = emev.total_forward_active_energy[0] * 0.00001;
        _chartHelper.totalForwardActiveEnergyPhase2 = emev.total_forward_active_energy[1] * 0.00001;
        _chartHelper.totalForwardActiveEnergyPhase3 = emev.total_forward_active_energy[2] * 0.00001;
    }
    
    [self setFrequency:freq visible:MVAL(EM_VAR_FREQ)];
    [self setVoltage:voltage visible:MVAL(EM_VAR_VOLTAGE)];
    [self setCurrent:current visible:MVAL(EM_VAR_CURRENT)];
    [self setActivePower:powerActive visible:MVAL(EM_VAR_POWER_ACTIVE)];
    [self setReactivePower:powerReactive visible:MVAL(EM_VAR_POWER_REACTIVE)];
    [self setApparentPower:powerApparent visible:MVAL(EM_VAR_POWER_APPARENT)];
    [self setPowerFactor:powerFactor visible:MVAL(EM_VAR_POWER_FACTOR)];
    [self setPhaseAngle:phaseAngle visible:MVAL(EM_VAR_PHASE_ANGLE)];
    [self setForwardActiveEnergy:totalFAE visible:MVAL(EM_VAR_FORWARD_ACTIVE_ENERGY)];
    [self setReverseActiveEnergy:totalRAE visible:MVAL(EM_VAR_REVERSE_ACTIVE_ENERGY)];
    [self setForwardReactiveEnergy:totalFRE visible:MVAL(EM_VAR_FORWARD_REACTIVE_ENERGY)];
    [self setReverseReactiveEnergy:totalRRE visible:MVAL(EM_VAR_REVERSE_REACTIVE_ENERGY)];
    
    [self.lCaption setText:[self.channelBase getChannelCaption]];
    
    switch (selectedPhase) {
        case -1:
            self.btnPhaseSum.layer.borderColor = btnBorderColor;
            break;
        case 0:
            self.btnPhase1.layer.borderColor = btnBorderColor;
            break;
        case 1:
            self.btnPhase2.layer.borderColor = btnBorderColor;
            break;
        case 2:
            self.btnPhase3.layer.borderColor = btnBorderColor;
            break;
    }
    
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    if (_chartHelper) {
        _chartHelper.channelId = channelBase ? channelBase.remote_id : 0;
    }
    [super setChannelBase:channelBase];
}

- (IBAction)phaseBtnTouch:(id)sender {
    if (sender == self.btnPhase1) {
        selectedPhase = 0;
    } else if (sender == self.btnPhase2) {
        selectedPhase = 1;
    } else if (sender == self.btnPhase3) {
        selectedPhase = 2;
    } else if (sender == self.btnPhaseSum) {
        selectedPhase = -1;
    }
    
    [self updateView];
}

- (void)chartsHidden:(BOOL)hidden {
    [_tfChartTypeFilter resignFirstResponder];
    
    if (hidden) {
        self.vPhases.hidden = NO;
        self.vCharts.hidden = YES;
        [self.btnChart setImage:[UIImage imageNamed:@"graphoff.png"]];
    } else {
        self.vPhases.hidden = YES;
        self.vCharts.hidden = NO;
        [self.btnChart setImage:[UIImage imageNamed:@"graphon.png"]];
    }
}

- (void)loadChartWithAnimation:(BOOL)animation {
    _chartHelper.chartType = _tfChartTypeFilter.chartType;
    _chartHelper.dateFrom = _tfChartTypeFilter.dateRangeFilterField.dateFrom;
    [_chartHelper load];
    if (animation) {
        [_chartHelper animate];
    }
}

- (IBAction)chartBtnTouch:(id)sender {
    [self chartsHidden:self.vPhases.hidden];
    
    if (!self.vCharts.hidden) {
        [self loadChartWithAnimation:YES];
    }
}

-(void)onDetailShow {
    [super onDetailShow];
    _tfChartTypeFilter.chartType = Bar_Minutely;
    [self chartsHidden:YES];
    [self setPreloaderHidden:YES];
    
    [SAApp.instance cancelAllRestApiClientTasks];
    
    if (_taskTimer == nil) {
        _taskTimer = [NSTimer scheduledTimerWithTimeInterval:120
                                                           target:self
                                                         selector:@selector(onTaskTimer:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    [self runDownloadTask];
}

-(void)onDetailHide {
    [super onDetailHide];
    
    [_tfChartTypeFilter resignFirstResponder];
    
    if (_taskTimer) {
        [_taskTimer invalidate];
        _taskTimer = nil;
    }
    
    if (_task) {
        [_task cancel];
        _task.delegate = nil;
    }
}

-(void)onTaskTimer:(NSTimer *)timer {
    [self runDownloadTask];
}

-(void)onPreloaderTimer:(NSTimer *)timer {
    
    CGSize dotSize = [@"•" sizeWithAttributes:@{NSFontAttributeName:[self.lPreloader font]}];
    int count = self.lPreloader.frame.size.width / dotSize.width;
    
    NSString *p = @"";
    
    for(int a=0;a<count;a++) {
        p = [NSString stringWithFormat:@"%@%@", p, _preloaderPos == a ? @"o" : @"•"];
    }
    
    _preloaderPos++;
    if (_preloaderPos >= count) {
        _preloaderPos = 0;
    }
    
    [self.lPreloader setText:p];
};

-(void) setPreloaderHidden:(BOOL)hidden {

    if (hidden) {
        if (_preloaderTimer) {
            [_preloaderTimer invalidate];
            _preloaderTimer = nil;
        }
    } else {
        _preloaderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(onPreloaderTimer:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    
    self.lPreloader.hidden = hidden;
}

-(void) runDownloadTask {
    if (_task && ![_task isTaskIsAliveWithTimeout:90]) {
        [_task cancel];
        _task = nil;
    }
    
    if (!_task) {
        _task = [[SADownloadElectricityMeasurements alloc] init];
        _task.channelId = self.channelBase.remote_id;
        _task.delegate = self;
        [_task start];
    }
}

-(void) onRestApiTaskStarted: (SARestApiClientTask*)task {
    //NSLog(@"onRestApiTaskStarted");
    [self setPreloaderHidden:NO];
}

-(void) onRestApiTaskFinished: (SARestApiClientTask*)task {
    //NSLog(@"onRestApiTaskFinished");
    if (_task != nil && task == _task) {
        _task.delegate = nil;
        _task = nil;
    }

    [self setPreloaderHidden:YES];
    [self updateView];
    _chartHelper.downloadProgress = nil;
    [self loadChartWithAnimation:NO];
}

-(void) onRestApiTask: (SARestApiClientTask*)task progressUpdate:(float)progress {
    _chartHelper.downloadProgress = [NSNumber numberWithFloat:progress];
}

-(void) onFilterChanged: (SAChartFilterField*)filterField {
    [self loadChartWithAnimation:YES];
}

@end
