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


@implementation SAElectricityMeterDetailView   {
    short selectedPhase;
}

-(void)detailViewInit {
    [super detailViewInit];
    selectedPhase = 0;
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

- (void)frequencyVisible:(BOOL)visible {
    [self setLabel:self.lFrequency Visible:visible withConstraint:self.cFrequencyTop];
    [self setLabel:self.lFrequencyValue Visible:visible withConstraint:self.cFrequencyValueTop];
}

- (void)voltageVisible:(BOOL)visible {
    [self setLabel:self.lVoltage Visible:visible withConstraint:self.cVoltageTop];
    [self setLabel:self.lVoltageValue Visible:visible withConstraint:self.cVoltageValueTop];
}

- (void)currentVisible:(BOOL)visible {
    [self setLabel:self.lCurrent Visible:visible withConstraint:self.cCurrentTop];
    [self setLabel:self.lCurrentValue Visible:visible withConstraint:self.cCurrentValueTop];
}

- (void)activePowerVisible:(BOOL)visible {
    [self setLabel:self.lActivePower Visible:visible withConstraint:self.cActivePowerTop];
    [self setLabel:self.lActivePowerValue Visible:visible withConstraint:self.cActivePowerValueTop];
}

- (void)reactivePowerVisible:(BOOL)visible {
    [self setLabel:self.lReactivePower Visible:visible withConstraint:self.cReactivePowerTop];
    [self setLabel:self.lReactivePowerValue Visible:visible withConstraint:self.cReactivePowerValueTop];
}

- (void)apparentPowerVisible:(BOOL)visible {
    [self setLabel:self.lApparentPower Visible:visible withConstraint:self.cApparentPowerTop];
    [self setLabel:self.lApparentPowerValue Visible:visible withConstraint:self.cApparentPowerValueTop];
}

- (void)powerFactorVisible:(BOOL)visible {
    [self setLabel:self.lPowerFactor Visible:visible withConstraint:self.cPowerFactorTop];
    [self setLabel:self.lPowerFactorValue Visible:visible withConstraint:self.cPowerFactorValueTop];
}

- (void)phaseAngleVisible:(BOOL)visible {
    [self setLabel:self.lPhaseAngle Visible:visible withConstraint:self.cPhaseAngleTop];
    [self setLabel:self.lPhaseAngleValue Visible:visible withConstraint:self.cPhaseAngleValueTop];
}

- (void)forwardActiveEnergyVisible:(BOOL)visible {
    [self setLabel:self.lForwardActiveEnergy Visible:visible withConstraint:self.cForwardActiveEnergyTop];
    [self setLabel:self.lForwardActiveEnergyValue Visible:visible withConstraint:self.cForwardActiveEnergyValueTop];
}

- (void)reverseActiveEnergyVisible:(BOOL)visible {
    [self setLabel:self.lReverseActiveEnergy Visible:visible withConstraint:self.cReverseActiveEnergyTop];
    [self setLabel:self.lReverseActiveEnergyValue Visible:visible withConstraint:self.cReverseActiveEnergyValueTop];
}

- (void)forwardReactiveEnergyVisible:(BOOL)visible {
    [self setLabel:self.lForwardReactiveEnergy Visible:visible withConstraint:self.cForwardReactiveEnergyTop];
    [self setLabel:self.lForwardReactiveEnergyValue Visible:visible withConstraint:self.cForwardReactiveEnergyValueTop];
}

- (void)reverseReactiveEnergyVisible:(BOOL)visible {
    [self setLabel:self.lReverseReactiveEnergy Visible:visible withConstraint:self.cReverseReactiveEnergyTop];
    [self setLabel:self.lReverseReactiveEnergyValue Visible:visible withConstraint:self.cReverseReactiveEnergyValueTop];
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
    
    CGColorRef btnBorderColor = [[UIColor redColor] CGColor];
    
    NSString *empty = @"----";
    
    [self.lTotalForwardActiveEnergy setText:empty];
    [self.lCurrentConsumption setText:empty];
    [self.lCurrentCost setText:empty];
    [self.lTotalCost setText:empty];
    
    [self.lFrequencyValue setText:empty];
    [self.lVoltageValue setText:empty];
    [self.lCurrentValue setText:empty];
    [self.lActivePowerValue setText:empty];
    [self.lReactivePowerValue setText:empty];
    [self.lApparentPowerValue setText:empty];
    [self.lPowerFactorValue setText:empty];
    [self.lPhaseAngleValue setText:empty];
    [self.lForwardActiveEnergyValue setText:empty];
    [self.lReverseActiveEnergyValue setText:empty];
    [self.lForwardReactiveEnergyValue setText:empty];
    [self.lReverseReactiveEnergyValue setText:empty];
    
    if ([self.channelBase isKindOfClass:SAChannel.class]
        && (ev = ((SAChannel*)self.channelBase).ev) != nil
        && [ev getElectricityMeterExtendedValue:&emev]) {
        
        [self.lTotalForwardActiveEnergy setText:[self totalForwardActiveEnergyStringForValue:[ev getTotalForwardActiveEnergyForExtendedValue:&emev]]];
        
        [self.lTotalCost setText:[NSString stringWithFormat:@"%0.2f %@", emev.total_cost * 0.01, [ev decodeCurrency:emev.currency]]];
    
        if (emev.m_count > 0) {
            TElectricityMeter_Measurement *m = emev.m;
            
            [self.lFrequencyValue setText:[NSString stringWithFormat:@"%0.2f Hz", m->freq * 0.01]];
            [self.lVoltageValue setText:[NSString stringWithFormat:@"%0.2f V", m->voltage[selectedPhase] * 0.01]];
            
            if ( m->voltage[selectedPhase] > 0 ) {
                btnBorderColor = [[UIColor greenColor] CGColor];
            }
            
            [self.lCurrentValue setText:[NSString stringWithFormat:@"%0.3f A", m->current[selectedPhase] * 0.001]];
            
            [self.lActivePowerValue setText:[NSString stringWithFormat:@"%0.5f W", m->power_active[selectedPhase] * 0.00001]];
            
            [self.lReactivePowerValue setText:[NSString stringWithFormat:@"%0.5f var", m->power_reactive[selectedPhase] * 0.00001]];
            
            [self.lApparentPowerValue setText:[NSString stringWithFormat:@"%0.5f VA", m->power_apparent[selectedPhase] * 0.00001]];
            
            [self.lPowerFactorValue setText:[NSString stringWithFormat:@"%0.3f", m->power_factor[selectedPhase] * 0.001]];
            
            [self.lPhaseAngleValue setText:[NSString stringWithFormat:@"%0.2f\u00B0", m->phase_angle[selectedPhase] * 0.1]];
        }

        [self.lForwardActiveEnergyValue setText:[NSString stringWithFormat:@"%0.5f kWh", emev.total_forward_active_energy[selectedPhase] * 0.00001]];
        
        [self.lReverseActiveEnergyValue setText:[NSString stringWithFormat:@"%0.5f kWh", emev.total_reverse_active_energy[selectedPhase] * 0.00001]];
        
        [self.lForwardReactiveEnergyValue setText:[NSString stringWithFormat:@"%0.5f kvarh", emev.total_forward_reactive_energy[selectedPhase] * 0.00001]];
        
        [self.lReverseReactiveEnergyValue setText:[NSString stringWithFormat:@"%0.5f kvarh", emev.total_reverse_reactive_energy[selectedPhase] * 0.00001]];
        
        measured_values = emev.measured_values;

    }
    
    [self frequencyVisible:measured_values & EM_VAR_FREQ];
    [self voltageVisible:measured_values & EM_VAR_VOLTAGE];
    [self currentVisible:measured_values & EM_VAR_CURRENT];
    [self activePowerVisible:measured_values & EM_VAR_POWER_ACTIVE];
    [self reactivePowerVisible:measured_values & EM_VAR_POWER_REACTIVE];
    [self apparentPowerVisible:measured_values & EM_VAR_POWER_APPARENT];
    [self powerFactorVisible:measured_values & EM_VAR_POWER_FACTOR];
    [self phaseAngleVisible:measured_values & EM_VAR_PHASE_ANGLE];
    [self forwardActiveEnergyVisible:measured_values & EM_VAR_FORWARD_ACTIVE_ENERGY];
    [self reverseActiveEnergyVisible:measured_values & EM_VAR_REVERSE_ACTIVE_ENERGY];
    [self forwardReactiveEnergyVisible:measured_values & EM_VAR_FORWARD_REACTIVE_ENERGY];
    [self reverseReactiveEnergyVisible:measured_values & EM_VAR_REVERSE_REACTIVE_ENERGY];
    
    [self.lCaption setText:[self.channelBase getChannelCaption]];
    
    switch (selectedPhase) {
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

- (IBAction)phaseBtnTouch:(id)sender {
    if (sender == self.btnPhase1) {
        selectedPhase = 0;
    } else if (sender == self.btnPhase2) {
        selectedPhase = 1;
    } else if (sender == self.btnPhase3) {
        selectedPhase = 2;
    }
    
    [self updateView];
}
- (IBAction)chartBtnTouch:(id)sender {
    if (self.vPhases.hidden) {
        self.vPhases.hidden = NO;
        [self.btnChart setImage:[UIImage imageNamed:@"graphoff.png"]];
    } else {
        self.vPhases.hidden = YES;
        [self.btnChart setImage:[UIImage imageNamed:@"graphon.png"]];
    }
}

-(void)onDetailShow {
    [super onDetailShow];
    SADownloadElectricityMeasurements *task = [[SADownloadElectricityMeasurements alloc] init];
    task.channelId = self.channelBase.remote_id;
    task.delegate = self;
    [task start];
}

-(void) onRestApiTaskStarted: (SARestApiClientTask*)task {
    NSLog(@"onRestApiTaskStarted");
}

-(void) onRestApiTaskFinished: (SARestApiClientTask*)task {
    NSLog(@"onRestApiTaskFinished");
}

-(void) onRestApiTask: (SARestApiClientTask*)task progressUpdate:(float)progress {
    NSLog(@"onRestApiTaskProgressUpdate %f", progress);
}

@end
