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
#import <UIKit/UIKit.h>
#import "SAUserIcon+CoreDataClass.h"
#import "SADigiglassValue.h"
#import "proto.h"

@class _SALocation;

NS_ASSUME_NONNULL_BEGIN

@interface SAChannelBase : NSManagedObject

- (BOOL) setChannelLocation:(_SALocation*)location;
- (BOOL) setChannelFunction:(int)function;
- (BOOL) setChannelCaption:(char*)caption;
- (BOOL) setItemVisible:(int)visible;
- (BOOL) setChannelAltIcon:(int)altIcon;
- (BOOL) setChannelFlags:(int)flags;
- (BOOL) setLocationId:(int)locationId;
- (BOOL) setRemoteId:(int)remoteId;
- (BOOL) setUserIconId:(int)userIconId;
+ (int) functionBitToFunctionNumber:(int)bit;
+ (NSString *)getFunctionName:(int)func;
+ (NSString *)getNonEmptyCaptionOfChannel:(SAChannelBase*)channel customFunc:(NSNumber*)func;
- (NSString *)getNonEmptyCaption;

- (int) imgIsActive;
- (BOOL) isOnline;
- (int) onlinePercent;
- (int) hiValue;
- (BOOL) isClosed;
- (int) hiSubValue;
- (UIImage*) getIcon;
- (UIImage*) getIconWithIndex:(short)idx;
- (BOOL) isManuallyClosed;
- (BOOL) flooding;
- (SADigiglassValue*) digiglassValue;
- (BOOL) overcurrentRelayOff;
- (BOOL) calibrationFailed;
- (BOOL) calibrationLost;
- (BOOL) motorProblem;

- (double) temperatureValue;
- (double) humidityValue;
- (double) doubleValue;
- (int) percentValue;
- (TDSC_RollerShutterValue) rollerShutterValue;
- (int) brightnessValue;
- (int) colorBrightnessValue;
- (UIColor *) colorValue;
- (double) totalForwardActiveEnergy;
- (double) impulseCounterCalculatedValue;
- (double) presetTemperature;
- (double) presetTemperatureMin;
- (double) presetTemperatureMax;
- (double) measuredTemperature;
- (double) measuredTemperatureMin;
- (double) measuredTemperatureMax;
- (NSString *) unit;
- (NSAttributedString*) thermostatAttrStringWithMeasuredTempMin:(double)mmin measuredTempMax:(double)mmax presetTempMin:(double)pmin presetTempMax:(double)pmax font:(nullable UIFont*)font;
- (NSAttributedString*) attrStringValueWithIndex:(int)idx font:(nullable UIFont*)font;
- (NSAttributedString*) attrStringValue;
@end

NS_ASSUME_NONNULL_END

#import "SAChannelBase+CoreDataProperties.h"
