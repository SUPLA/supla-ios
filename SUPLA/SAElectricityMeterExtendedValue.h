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

#import "SAIncrementalMeterExtendedValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAElectricityMeterExtendedValue : SAIncrementalMeterExtendedValue
- (double) freqForPhase:(unsigned char)phase;
- (double) voltegeForPhase:(unsigned char)phase;
- (double) currentForPhase:(unsigned char)phase;
- (double) powerActiveForPhase:(unsigned char)phase;
- (double) powerReactiveForPhase:(unsigned char)phase;
- (double) powerApparentForPhase:(unsigned char)phase;
- (double) powerFactorForPhase:(unsigned char)phase;
- (double) phaseAngleForPhase:(unsigned char)phase;

- (double) totalForwardActiveEnergyForPhase:(unsigned char)phase;
- (double) totalForwardReactiveEnergyForPhase:(unsigned char)phase;
- (double) totalReverseActiveEnergyForPhase:(unsigned char)phase;
- (double) totalReverseReactiveEnergyForPhase:(unsigned char)phase;

- (double) totalForwardActiveEnergy;
- (double) totalReverseActiveEnergy;
- (double) totalForwardActiveEnergyBalanced;
- (double) totalReverseActiveEnergyBalanced;
- (unsigned int) measuredValues;
- (BOOL) currentIsOver65A;
@end

@interface SAChannelExtendedValue (SAExectricityMeterExtendedValue)
- (SAElectricityMeterExtendedValue*)electricityMeter;
@end
   
NS_ASSUME_NONNULL_END
