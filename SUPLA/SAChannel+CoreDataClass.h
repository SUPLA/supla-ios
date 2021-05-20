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
#import "SAChannelValue+CoreDataClass.h"
#import "SAChannelBase+CoreDataProperties.h"
#import "SAChannelExtendedValue+CoreDataProperties.h"
#import "SAChannelStateExtendedValue.h"
#import "proto.h"

@class NSObject, _SALocation;

NS_ASSUME_NONNULL_BEGIN

@interface SAChannel : SAChannelBase

- (void) initWithRemoteId:(int)remoteId;
- (BOOL) setChannelProtocolVersion:(int)protocolVersion;
- (BOOL) setDeviceId:(int)deviceId;
- (BOOL) setManufacturerId:(int)manufacturerId;
- (BOOL) setProductId:(int)productId;
- (BOOL) setChannelType:(int)type;
- (double) totalForwardActiveEnergy;
- (double) totalForwardActiveEnergyFromSubValue;
- (NSNumber *) lightSourceLifespanLeft;
- (int) warningLevel;
- (UIImage *) stateIcon;
- (UIImage *) warningIcon;
- (NSString *) warningMessage;
- (SAChannelStateExtendedValue *)channelState;
@end

NS_ASSUME_NONNULL_END

#import "SAChannel+CoreDataProperties.h"
