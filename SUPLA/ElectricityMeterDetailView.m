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
#import "SuplaApp.h"
#import "SAElectricityChartHelper.h"
#import "SAElectricityMeterExtendedValue.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIButton+SUPLA.h"
#import "SAFormatter.h"
#import "SUPLA-Swift.h"

// iPhone <=5 fix.
// Integer number as boolean method parameter does not work good in iPhone <5
#define MVAL(val_flag) ((measured_values & val_flag) ? YES : NO)

@implementation SAElectricityMeterDetailView   {
    short selectedPhase;
    NSTimer *_taskTimer;
    SADownloadElectricityMeasurements *_task;
    SAElectricityChartHelper *_chartHelper;
    SAFormatter *_formatter;
    BOOL _balanceAvailable;
    ChartSettings *_chartSettings;
}

-(void)detailViewInit {
    if (!self.initialized) {
        selectedPhase = 1;
        _chartHelper = [[SAElectricityChartHelper alloc] init];
        _chartHelper.combinedChart = self.combinedChart;
        _chartHelper.pieChart = self.pieChart;
        _chartHelper.unit = @"kWh";
        _tfChartTypeFilter.chartHelper = _chartHelper;
        _tfChartTypeFilter.dateRangeFilterField = _ftDateRangeFilter;
        _tfChartTypeFilter.ff_delegate = self;
        _ftDateRangeFilter.ff_delegate = self;
        _formatter = [[SAFormatter alloc] init];
    }
    
    [super detailViewInit];
    [self.tfChartTypeFilter resetList];
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
    
    [self.lFrequencyValue setText:[_formatter doubleToString:freq withUnit:@"Hz" maxPrecision:2]];
}

- (void)setVoltage:(double)voltage visible:(BOOL)visible {
    [self setLabel:self.lVoltage Visible:visible withConstraint:self.cVoltageTop];
    [self setLabel:self.lVoltageValue Visible:visible withConstraint:self.cVoltageValueTop];
    [self.lVoltageValue setText:[_formatter doubleToString:voltage withUnit:@"V" maxPrecision:2]];
}

- (void)setCurrent:(double)current visible:(BOOL)visible over65A:(BOOL)over65A {
    [self setLabel:self.lCurrent Visible:visible withConstraint:self.cCurrentTop];
    [self setLabel:self.lCurrentValue Visible:visible withConstraint:self.cCurrentValueTop];
    [self.lCurrentValue setText:[_formatter doubleToString:current withUnit:@"A" maxPrecision:3]];
}

- (void)setActivePower:(double)power visible:(BOOL)visible {
    [self setLabel:self.lActivePower Visible:visible withConstraint:self.cActivePowerTop];
    [self setLabel:self.lActivePowerValue Visible:visible withConstraint:self.cActivePowerValueTop];
    [self.lActivePowerValue setText:[_formatter doubleToString:power withUnit:@"W" maxPrecision:5]];
}

- (void)setReactivePower:(double)power visible:(BOOL)visible {
    [self setLabel:self.lReactivePower Visible:visible withConstraint:self.cReactivePowerTop];
    [self setLabel:self.lReactivePowerValue Visible:visible withConstraint:self.cReactivePowerValueTop];
    [self.lReactivePowerValue setText:[_formatter doubleToString:power withUnit:@"var" maxPrecision:5]];
}

- (void)setApparentPower:(double)power visible:(BOOL)visible {
    [self setLabel:self.lApparentPower Visible:visible withConstraint:self.cApparentPowerTop];
    [self setLabel:self.lApparentPowerValue Visible:visible withConstraint:self.cApparentPowerValueTop];
    [self.lApparentPowerValue setText:[_formatter doubleToString:power withUnit:@"VA" maxPrecision:5]];
}

- (void)setPowerFactor:(double)factor visible:(BOOL)visible {
    [self setLabel:self.lPowerFactor Visible:visible withConstraint:self.cPowerFactorTop];
    [self setLabel:self.lPowerFactorValue Visible:visible withConstraint:self.cPowerFactorValueTop];
    [self.lPowerFactorValue setText:[_formatter doubleToString:factor withUnit:nil maxPrecision:3]];
}

- (void)setPhaseAngle:(double)angle visible:(BOOL)visible {
    [self setLabel:self.lPhaseAngle Visible:visible withConstraint:self.cPhaseAngleTop];
    [self setLabel:self.lPhaseAngleValue Visible:visible withConstraint:self.cPhaseAngleValueTop];
    [self.lPhaseAngleValue setText:[_formatter doubleToString:angle withUnit:@"\u00B0" maxPrecision:2]];
}

- (void)setForwardActiveEnergy:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lForwardActiveEnergy Visible:visible withConstraint:self.cForwardActiveEnergyTop];
    [self setLabel:self.lForwardActiveEnergyValue Visible:visible withConstraint:self.cForwardActiveEnergyValueTop];
    [self.lForwardActiveEnergyValue setText:[_formatter doubleToString:energy withUnit:@"kWh" maxPrecision:5]];
}

- (void)setReverseActiveEnergy:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lReverseActiveEnergy Visible:visible withConstraint:self.cReverseActiveEnergyTop];
    [self setLabel:self.lReverseActiveEnergyValue Visible:visible withConstraint:self.cReverseActiveEnergyValueTop];
    [self.lReverseActiveEnergyValue setText:[_formatter doubleToString:energy withUnit:@"kWh" maxPrecision:5]];
}

- (void)setForwardReactiveEnergy:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lForwardReactiveEnergy Visible:visible withConstraint:self.cForwardReactiveEnergyTop];
    [self setLabel:self.lForwardReactiveEnergyValue Visible:visible withConstraint:self.cForwardReactiveEnergyValueTop];
    [self.lForwardReactiveEnergyValue setText:[_formatter doubleToString:energy withUnit:@"kvarh" maxPrecision:5]];
}

- (void)setReverseReactiveEnergy:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lReverseReactiveEnergy Visible:visible withConstraint:self.cReverseReactiveEnergyTop];
    [self setLabel:self.lReverseReactiveEnergyValue Visible:visible withConstraint:self.cReverseReactiveEnergyValueTop];
    [self.lReverseReactiveEnergyValue setText:[_formatter doubleToString:energy withUnit:@"kvarh" maxPrecision:5]];
}

- (void)setForwardActiveEnergyBalance:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lForwardActiveEnergyBalance Visible:visible withConstraint:self.cForwardActiveEnergyBalanceTop];
    [self setLabel:self.lForwardActiveEnergyValueBalance Visible:visible withConstraint:self.cForwardActiveEnergyValueBalanceTop];
    [self.lForwardActiveEnergyValueBalance setText:[_formatter doubleToString:energy withUnit:@"kWh" maxPrecision:5]];
}

- (void)setReverseActiveEnergyBalance:(double)energy visible:(BOOL)visible {
    [self setLabel:self.lReverseActiveEnergyBalance Visible:visible withConstraint:self.cReverseActiveEnergyBalanceTop];
    [self setLabel:self.lReverseActiveEnergyValueBalance Visible:visible withConstraint:self.cReverseActiveEnergyValueBalanceTop];
    [self.lReverseActiveEnergyValueBalance setText:[_formatter doubleToString:energy withUnit:@"kWh" maxPrecision:5]];
}

- (NSString*)totalActiveEnergyStringForValue:(double)value {
    int precision = 5;
    if (value >= 1000) {
        precision = 3;
    } else if (value >= 10000) {
        precision = 2;
    }
    
    return [_formatter doubleToString: value withUnit: @"kWh"
                         maxPrecision: precision];
}

- (void)updateView {
    
    self.warningIcon.channel = self.channelBase;
    unsigned int measured_values = 0;
    SAElectricityMeterExtendedValue *emev = nil;
    
    self.btnPhase1.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnPhase2.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnPhase3.layer.borderColor = [[UIColor blackColor] CGColor];
    self.btnPhaseSum.layer.borderColor = [[UIColor blackColor] CGColor];
    
    CGColorRef btnBorderColor = [[UIColor redColor] CGColor];
    
    NSString *empty = @"----";
    
    [self.lTotalActiveEnergyValue setText:empty];
    [self.lConsumptionProductionValue setText:empty];
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
    BOOL currentOver65A = false;
    
    if ([self.channelBase isKindOfClass:SAChannel.class]
        && ((SAChannel*)self.channelBase).ev != nil
        && (emev = ((SAChannel*)self.channelBase).ev.electricityMeter) != nil) {
        
        measured_values = emev.measuredValues;
        currentOver65A = emev.currentIsOver65A;
    
        for(unsigned char p=1;p<=3;p++) {
            
            if (selectedPhase > 0) {
                p = selectedPhase;
            }
        
            freq = [emev freqForPhase:p];
                
            if (voltage == 0) {
                voltage = [emev voltegeForPhase:p];
            }
            
            if ( voltage > 0 ) {
                btnBorderColor = [[UIColor greenColor] CGColor];
            }
                
            current = [emev currentForPhase:p];
            powerActive += [emev powerActiveForPhase:p];
            powerReactive += [emev powerReactiveForPhase:p];
            powerApparent += [emev powerApparentForPhase:p];
            powerFactor = [emev powerFactorForPhase:p];
            phaseAngle = [emev phaseAngleForPhase:p];
            
            totalFAE += [emev totalForwardActiveEnergyForPhase:p];
            totalRAE += [emev totalReverseActiveEnergyForPhase:p];
            totalFRE += [emev totalForwardReactiveEnergyForPhase:p];
            totalRRE += [emev totalReverseReactiveEnergyForPhase:p];
            
            if (selectedPhase > 0) {
                break;
            }
        }
        
        double currentConsumption = 0;
        double currentProduction = 0;
        double currentCost = 0;
        
        if ([SAApp.DB electricityMeterMeasurementsStartsWithTheCurrentMonthForChannelId:self.channelBase.remote_id]) {
            currentConsumption = emev.totalForwardActiveEnergy;
            currentProduction = emev.totalReverseActiveEnergy;
            currentCost = emev.totalCost;
        } else {
            double v0 = [SAApp.DB sumActiveEnergyForChannelId:self.channelBase.remote_id monthLimitOffset:0 forwarded:YES];
            double v1 = [SAApp.DB sumActiveEnergyForChannelId:self.channelBase.remote_id monthLimitOffset:-1 forwarded:YES];
            
            currentConsumption = v0-v1;
            currentCost = emev.pricePerUnit * currentConsumption;
            
            v0 = [SAApp.DB sumActiveEnergyForChannelId:self.channelBase.remote_id monthLimitOffset:0 forwarded:NO];
            v1 = [SAApp.DB sumActiveEnergyForChannelId:self.channelBase.remote_id monthLimitOffset:-1 forwarded:NO];
            
            currentProduction = v0-v1;
        }
        
        
        [self.lTotalActiveEnergyValue setText:[self totalActiveEnergyStringForValue:_chartHelper.productionDataSource ? emev.totalReverseActiveEnergy : emev.totalForwardActiveEnergy]];
        [self.lConsumptionProductionValue setText:[_formatter doubleToString: _chartHelper.productionDataSource ? currentProduction : currentConsumption
                                                                    withUnit: @"kWh"
                                                                maxPrecision: 2]];
        
        [self.lTotalCost setText:[_formatter doubleToString: emev.totalCost
                                                   withUnit: emev.currency
                                               maxPrecision: 2]];
        [self.lCurrentCost setText:[_formatter doubleToString: currentCost
                                                     withUnit: emev.currency
                                                 maxPrecision: 2]];
    
        _chartHelper.pricePerUnit = emev.pricePerUnit;
        _chartHelper.currency = emev.currency;
        
        if (_chartHelper.productionDataSource) {
            _chartHelper.totalActiveEnergyPhase1 = [emev totalReverseActiveEnergyForPhase:1];
            _chartHelper.totalActiveEnergyPhase2 = [emev totalReverseActiveEnergyForPhase:2];
            _chartHelper.totalActiveEnergyPhase3 = [emev totalReverseActiveEnergyForPhase:3];
        } else {
            _chartHelper.totalActiveEnergyPhase1 = [emev totalForwardActiveEnergyForPhase:1];
            _chartHelper.totalActiveEnergyPhase2 = [emev totalForwardActiveEnergyForPhase:2];
            _chartHelper.totalActiveEnergyPhase3 = [emev totalForwardActiveEnergyForPhase:3];
        }
    }
    
    self.btnDirection.hidden = !MVAL(EM_VAR_REVERSE_ACTIVE_ENERGY);
    [self setFrequency:freq visible:MVAL(EM_VAR_FREQ)];
    [self setVoltage:voltage visible:MVAL(EM_VAR_VOLTAGE) && selectedPhase > 0];
    [self setCurrent:current visible:(MVAL(EM_VAR_CURRENT) || MVAL(EM_VAR_CURRENT_OVER_65A)) && selectedPhase > 0 over65A:currentOver65A];
    [self setActivePower:powerActive visible:MVAL(EM_VAR_POWER_ACTIVE)];
    [self setReactivePower:powerReactive visible: MVAL(EM_VAR_POWER_REACTIVE)];
    [self setApparentPower:powerApparent visible:MVAL(EM_VAR_POWER_APPARENT)];
    [self setPowerFactor:powerFactor visible:MVAL(EM_VAR_POWER_FACTOR) && selectedPhase > 0];
    [self setPhaseAngle:phaseAngle visible:MVAL(EM_VAR_PHASE_ANGLE) && selectedPhase > 0];
    [self setForwardActiveEnergy:totalFAE visible:MVAL(EM_VAR_FORWARD_ACTIVE_ENERGY)];
    [self setReverseActiveEnergy:totalRAE visible:MVAL(EM_VAR_REVERSE_ACTIVE_ENERGY)];
    [self setForwardReactiveEnergy:totalFRE visible:MVAL(EM_VAR_FORWARD_REACTIVE_ENERGY)];
    [self setReverseReactiveEnergy:totalRRE visible: MVAL(EM_VAR_REVERSE_REACTIVE_ENERGY)];
    
    _balanceAvailable = (MVAL(EM_VAR_FORWARD_ACTIVE_ENERGY_BALANCED)
                         || MVAL(EM_VAR_REVERSE_ACTIVE_ENERGY_BALANCED));
    
    if (selectedPhase == 0 && _balanceAvailable) {
        [self setForwardActiveEnergyBalance:emev.totalForwardActiveEnergyBalanced visible:MVAL(EM_VAR_FORWARD_ACTIVE_ENERGY_BALANCED)];
        [self setReverseActiveEnergyBalance:emev.totalReverseActiveEnergyBalanced visible:MVAL(EM_VAR_REVERSE_ACTIVE_ENERGY_BALANCED)];
        self.vLabelsBalance.hidden = NO;
        self.vValuesBalance.hidden = NO;
        self.lPhaseToPhase.hidden = NO;
    } else {
        self.vLabelsBalance.hidden = YES;
        self.vValuesBalance.hidden = YES;
        self.lPhaseToPhase.hidden = YES;
    }
    
    [self.ivImage setImage:[self.channelBase getIcon]];
    
    switch (selectedPhase) {
        case 0:
            self.btnPhaseSum.layer.borderColor = btnBorderColor;
            break;
        case 1:
            self.btnPhase1.layer.borderColor = btnBorderColor;
            break;
        case 2:
            self.btnPhase2.layer.borderColor = btnBorderColor;
            break;
        case 3:
            self.btnPhase3.layer.borderColor = btnBorderColor;
            break;
    }
    
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    if(channelBase) {
        if(!_chartSettings) {
            _chartSettings = [[ChartSettings alloc]
                                 initWithChannelId: channelBase.remote_id
                                    chartTypeField: self.tfChartTypeFilter
                                    dateRangeField: self.ftDateRangeFilter];
            [_chartSettings restore];
        }
    } else {
        [_chartSettings persist];
    }

    if (_chartHelper) {
        _chartHelper.channelId = channelBase ? channelBase.remote_id : 0;
    }
    
    [super setChannelBase:channelBase];
}

- (IBAction)phaseBtnTouch:(id)sender {
    if (sender == self.btnPhase1) {
        selectedPhase = 1;
    } else if (sender == self.btnPhase2) {
        selectedPhase = 2;
    } else if (sender == self.btnPhase3) {
        selectedPhase = 3;
    } else if (sender == self.btnPhaseSum) {
        selectedPhase = 0;
    }
    
    [self updateView];
}

- (IBAction)directionBtnTouch:(id)sender {
    [self setProductionDataSource:!_chartHelper.productionDataSource];
    
    if (!self.vCharts.hidden) {
        [self loadChartWithAnimation:YES];
    }
}

- (void)showPhaseButtons {
    bool hidden = NO;
    
    if (self.channelBase == NULL
    || ((self.channelBase.flags & SUPLA_CHANNEL_FLAG_PHASE2_UNSUPPORTED)
        && (self.channelBase.flags & SUPLA_CHANNEL_FLAG_PHASE3_UNSUPPORTED))) {
        hidden = YES;
    }
    
    self.btnPhase1.hidden = hidden;
    self.btnPhase2.hidden = hidden;
    self.btnPhase3.hidden = hidden;
    self.btnPhaseSum.hidden = hidden;
    
    if (hidden) {
        self.cIntLabelsTop.constant = -20;
        self.cIntValuesTop.constant = -20;
        selectedPhase = 1;
    } else {
        self.cIntLabelsTop.constant = 10;
        self.cIntValuesTop.constant = 10;
    }
}


- (void)setChartsHidden:(BOOL)hidden {
    [_tfChartTypeFilter resignFirstResponder];
    
    if (hidden) {
        [self showPhaseButtons];
        self.vPhases.hidden = NO;
        self.vCharts.hidden = YES;
        [self.btnChart setImage:[UIImage imageNamed:@"graphoff.png"]];
    } else {
        if (!_balanceAvailable) {
           [self.tfChartTypeFilter excludeAllFrom:Bar_VectorBalance_Minutes];
        }
        self.vPhases.hidden = YES;
        self.vCharts.hidden = NO;
        [self.btnChart setImage:[UIImage imageNamed:@"graphon.png"]];
    }
}

- (void)setProductionDataSource:(BOOL)production {
    _chartHelper.productionDataSource = production;
    [_tfChartTypeFilter resignFirstResponder];
    
    if (production) {
        [self.btnDirection setImage:[UIImage imageNamed:@"production.png"]];
        [self.lTotalActiveEnergy setText:NSLocalizedString(@"Reverse active Energy", nil)];
        [self.lConsumptionProduction setText:NSLocalizedString(@"Production in the current month", nil)];
    } else {
        [self.btnDirection setImage:[UIImage imageNamed:@"consumption.png"]];
        [self.lTotalActiveEnergy setText:NSLocalizedString(@"Forward active Energy", nil)];
        [self.lConsumptionProduction setText:NSLocalizedString(@"Consumption in the current month", nil)];
    }
    
    [self updateView];
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
    [self setChartsHidden:self.vPhases.hidden];
    
    if (!self.vCharts.hidden) {
        [self loadChartWithAnimation:YES];
    }
}

-(void)detailWillShow {
    _balanceAvailable = false;
    self.btnDirection.hidden = YES;
    [super detailWillShow];
    [self setProductionDataSource:NO];
    [self setChartsHidden:YES];
    self.lPreloader.hidden = YES;
    
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

-(void)detailWillHide {
    [super detailWillHide];
    
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
    [self.lPreloader animateWithTimeInterval:0.1];
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
    [self loadChartWithAnimation:NO];
}

-(void) onRestApiTask: (SARestApiClientTask*)task progressUpdate:(float)progress {
    _chartHelper.downloadProgress = [NSNumber numberWithFloat:progress];
}

-(void) onFilterChanged: (SAChartFilterField*)filterField {
    [self loadChartWithAnimation:YES];
    [_chartSettings persist];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.ivImage.gestureRecognizers.firstObject == gestureRecognizer
        && (self.channelBase.func == SUPLA_CHANNELFNC_LIGHTSWITCH
        || self.channelBase.func == SUPLA_CHANNELFNC_POWERSWITCH
        || self.channelBase.func == SUPLA_CHANNELFNC_STAIRCASETIMER);
}

- (IBAction)imgTapped:(id)sender {
    [SAApp.SuplaClient turnOn:!self.channelBase.hiValue
                      remoteId:self.channelBase.remote_id
                      group:NO
                      channelFunc:self.channelBase.func
                      vibrate:YES];
}


@end
