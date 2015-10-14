/*
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
 
 Author: Przemyslaw Zygmunt p.zygmunt@acsoftware.pl [AC SOFTWARE]
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#include "proto.h"

@class SALocation;

NS_ASSUME_NONNULL_BEGIN

@interface SAChannel : NSManagedObject

- (BOOL) setChannelLocation:(SALocation*)location;
- (BOOL) setChannelFunction:(int)function;
- (BOOL) setChannelOnline:(char)online;
- (BOOL) setChannelValue:(TSuplaChannelValue*)value;
- (BOOL) setChannelCaption:(char*)caption;
- (BOOL) setChannelVisible:(int)visible;
- (BOOL) isOnline;
- (BOOL) isClosed;
- (BOOL) isOn;
- (BOOL) hiValue;
- (double) doubleValue;
- (NSString *)getChannelCaption;

- (UIImage *) channelIcon;

@end

NS_ASSUME_NONNULL_END

#import "SAChannel+CoreDataProperties.h"
