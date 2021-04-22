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

#import "SARegResult.h"

@implementation SARegResult

@synthesize ClientID;
@synthesize LocationCount;
@synthesize ChannelCount;
@synthesize ChannelGroupCount;
@synthesize Flags;
@synthesize Version;

+ (SARegResult*) RegResultClientID:(int) clientID locationCount:(int) location_count channelCount:(int) channel_count channelGroupCount:(int) cgroup_count flags:(int) flags version:(int)version {
    SARegResult *rr = [[SARegResult alloc] init];
    
    rr.ClientID = clientID;
    rr.LocationCount = location_count;
    rr.ChannelCount = channel_count;
    rr.ChannelGroupCount = cgroup_count;
    rr.Flags = flags;
    rr.Version = version;
    
    return rr;
}

@end
