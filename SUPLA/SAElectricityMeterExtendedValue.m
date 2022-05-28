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

#import "SAElectricityMeterExtendedValue.h"
#import "supla-client.h"

_supla_int_t srpc_evtool_emev_v1to2(TElectricityMeter_ExtendedValue *v1,
                       TElectricityMeter_ExtendedValue_V2 *v2);

@implementation SAElectricityMeterExtendedValue {
    TElectricityMeter_ExtendedValue_V2 _emev;
}

-(id)initWithExtendedValue:(SAChannelExtendedValue *)ev {
    if ([super initWithExtendedValue:ev]
        && [self getElectricityMeterExtendedValue:&_emev]) {
        return self;
    }
    return nil;
}

- (BOOL) getElectricityMeterExtendedValue:(TElectricityMeter_ExtendedValue_V2*)emev {
    if (emev == NULL) {
        return NO;
    }
    
    __block BOOL result = NO;
    
    [self forEach:^BOOL(TSuplaChannelExtendedValue * _Nonnull ev) {
        if (srpc_evtool_v2_extended2emextended(ev, emev)) {
            result = YES;
        }
        return !result;
    }];

    return result;
}

- (NSString *) currency {
    return [self decodeCurrency:_emev.currency];
}

-(BOOL)validPhase:(unsigned char)phase {
    return phase >= 1 && phase <= 3;
}

- (TElectricityMeter_Measurement*) measurementForPhase:(unsigned char)phase {
    if ( [self validPhase:phase] && _emev.m_count > 0 ) {
        return &_emev.m[0];
    }
    return nil;
}

- (double) freqForPhase:(unsigned char)phase {
    TElectricityMeter_Measurement *m = [self measurementForPhase:phase];
    return m ? m->freq * 0.01 : 0.0;
}

- (double) voltegeForPhase:(unsigned char)phase {
    TElectricityMeter_Measurement *m = [self measurementForPhase:phase];
    return m ? m->voltage[phase-1] * 0.01 : 0.0;
}

- (double) currentForPhase:(unsigned char)phase {
    TElectricityMeter_Measurement *m = [self measurementForPhase:phase];
    if (m) {
        return m->current[phase-1] * (self.currentIsOver65A ? 0.01 : 0.001);
    }
    return 0.0;
}

- (double) powerActiveForPhase:(unsigned char)phase {
    TElectricityMeter_Measurement *m = [self measurementForPhase:phase];
    return m ? m->power_active[phase-1] * 0.00001 : 0.0;
}

- (double) powerReactiveForPhase:(unsigned char)phase {
    TElectricityMeter_Measurement *m = [self measurementForPhase:phase];
    return m ? m->power_reactive[phase-1] * 0.00001 : 0.0;
}

- (double) powerApparentForPhase:(unsigned char)phase {
    TElectricityMeter_Measurement *m = [self measurementForPhase:phase];
    return m ? m->power_apparent[phase-1] * 0.00001 : 0.0;
}

- (double) powerFactorForPhase:(unsigned char)phase {
    TElectricityMeter_Measurement *m = [self measurementForPhase:phase];
    return m ? m->power_factor[phase-1] * 0.001 : 0.0;
}

- (double) phaseAngleForPhase:(unsigned char)phase {
    TElectricityMeter_Measurement *m = [self measurementForPhase:phase];
    return m ? m->phase_angle[phase-1] * 0.1 : 0.0;
}

- (double) totalForwardActiveEnergyForPhase:(unsigned char)phase {
    return [self validPhase:phase] ? _emev.total_forward_active_energy[phase-1]*0.00001 : 0;
}

- (double) totalForwardReactiveEnergyForPhase:(unsigned char)phase {
    return [self validPhase:phase] ? _emev.total_forward_reactive_energy[phase-1]*0.00001 : 0;
}

- (double) totalReverseActiveEnergyForPhase:(unsigned char)phase {
    return [self validPhase:phase] ? _emev.total_reverse_active_energy[phase-1]*0.00001 : 0;
}

- (double) totalReverseReactiveEnergyForPhase:(unsigned char)phase {
    return [self validPhase:phase] ? _emev.total_reverse_reactive_energy[phase-1]*0.00001 : 0;
}

- (double) totalForwardActiveEnergy {
    double result = 0;
    for(short p=1;p<=3;p++) {
        result+=[self totalForwardActiveEnergyForPhase:p];
    }
    return result;
}

- (double) totalReverseActiveEnergy {
    double result = 0;
    for(short p=1;p<=3;p++) {
        result+=[self totalReverseActiveEnergyForPhase:p];
    }
    return result;
}

- (double) totalForwardActiveEnergyBalanced {
    return _emev.total_forward_active_energy_balanced * 0.00001;
}

- (double) totalReverseActiveEnergyBalanced {
    return _emev.total_reverse_active_energy_balanced * 0.00001;
}

- (double) totalCost {
   return _emev.total_cost * 0.01;
}

- (double) pricePerUnit {
    return _emev.price_per_unit * 0.0001;
}


- (unsigned int) measuredValues {
    return _emev.measured_values;
}

- (BOOL) currentIsOver65A {
    return (_emev.measured_values & EM_VAR_CURRENT) == 0
    && (_emev.measured_values & EM_VAR_CURRENT_OVER_65A) != 0;
}

@end


@implementation SAChannelExtendedValue (SAExectricityMeterExtendedValue)

- (SAElectricityMeterExtendedValue*)electricityMeter {
    return [[SAElectricityMeterExtendedValue alloc] initWithExtendedValue:self];
}

@end
