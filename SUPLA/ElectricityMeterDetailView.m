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

@implementation SAElectricityMeterDetailView

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

- (void)updateView {
    
    short phase = 1;
    unsigned int measured_values = 0;
    SAChannelExtendedValue *ev = nil;
    TElectricityMeter_ExtendedValue emev;
    
    if ([self.channelBase isKindOfClass:SAChannel.class]
        && (ev = ((SAChannel*)self.channelBase).ev) != nil
        && [ev getElectricityMeterExtendedValue:&emev]
        && emev.m_count > 0 ) {
        
        measured_values = emev.measured_values;
        [self.lFrequencyValue setText:[NSString stringWithFormat:@"%0.2f Hz", emev.m[0].freq * 0.01]];
        [self.lVoltageValue setText:[NSString stringWithFormat:@"%0.2f V", emev.m[0].voltage[phase] * 0.01]];
        
        [self.lCurrentValue setText:[NSString stringWithFormat:@"%0.3f A", emev.m[0].current[phase] * 0.001]];
    } else {
        
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
}

@end
