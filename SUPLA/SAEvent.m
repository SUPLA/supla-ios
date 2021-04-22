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

#import "SAEvent.h"

@implementation SAEvent

@synthesize Owner;
@synthesize Event;
@synthesize ChannelID;
@synthesize DurationMS;
@synthesize SenderID;
@synthesize SenderName;

+(SAEvent*)Event:(int) event ChannelID:(int) channel_id DurationMS:(int) duration_ms SenderID:(int) sender_id SenderName:(NSString*)sender_name {
    SAEvent *e = [[SAEvent alloc] init];
    
    e.Event = event;
    e.ChannelID = channel_id;
    e.DurationMS = duration_ms;
    e.SenderID = sender_id;
    e.SenderName = sender_name;
    
    return e;
}

+(SAEvent *)notificationToEvent:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"event"];
        if (r != nil && [r isKindOfClass:[SAEvent class]]) {
            return r;
        }
    }
    return nil;
}

@end
