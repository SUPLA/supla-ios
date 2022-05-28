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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SAChannelValueBase+CoreDataProperties.h"
#import <UIKit/UIKit.h>
#import "proto.h"
#import "SADigiglassValue.h"

@class NSObject;

NS_ASSUME_NONNULL_BEGIN

@interface SAChannelValue : SAChannelValueBase

- (void) initWithChannelId:(int)channelId;
- (BOOL) setOnlineState:(char)online;
- (BOOL) setValueWithChannelValue:(TSuplaChannelValue_B*)value;
- (NSData *) dataValue;
- (NSData *) dataSubValue;

- (BOOL) isOnline;
- (int) hiValue;
- (int) hiSubValue;
- (int) intValue;
- (BOOL) isClosed;
- (double) doubleValue;
- (double) getTemperatureForFunction:(int)func;
- (double) humidityValue;
- (int) percentValue;
- (TDSC_RollerShutterValue) rollerShutterValue;
- (int) brightnessValue;
- (int) colorBrightnessValue;
- (UIColor *) colorValue;
- (double) totalForwardActiveEnergy;
- (double) totalForwardActiveEnergyFromSubValue;
- (double) impulseCounterCalculatedValue;
- (double) impulseCounterCalculatedValueFromSubValue;
- (double) presetTemperature;
- (double) measuredTemperature;
-(BOOL) isManuallyClosed;
-(BOOL) flooding;
-(SADigiglassValue*) digiglassValue;
-(BOOL) overcurrentRelayOff;
-(BOOL) calibrationFailed;
-(BOOL) calibrationLost;
-(BOOL) motorProblem;
@end

NS_ASSUME_NONNULL_END

#import "SAChannelValue+CoreDataProperties.h"
