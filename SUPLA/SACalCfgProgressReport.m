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

#import "SACalCfgProgressReport.h"

@implementation SACalCfgProgressReport
@synthesize channelId = _channelId;
@synthesize command = _command;
@synthesize progress = _progress;

- (id)initWithReport:(TCalCfg_ProgressReport *)report channelId:(int)channelId {
    if ([self init]) {
        if (report) {
            _command = report->Command;
            _progress = report->Progress;
        }
        _channelId = channelId;
    }
    return self;
}

+ (SACalCfgProgressReport*) reportWithReport:(TCalCfg_ProgressReport *)report channelId:(int)channelId {
    return [[SACalCfgProgressReport alloc] initWithReport:report channelId:channelId];
}

+ (SACalCfgProgressReport *)notificationToProgressReport:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"report"];
        if (r != nil && [r isKindOfClass:[SACalCfgProgressReport class]]) {
            return r;
        }
    }
    return nil;
}
@end
