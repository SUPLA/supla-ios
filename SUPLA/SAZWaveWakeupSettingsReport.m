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

#import "SAZWaveWakeupSettingsReport.h"

@implementation SAZWaveWakeupSettingsReport

@synthesize resultCode = _resultCode;
@synthesize minimumSec = _minimumSec;
@synthesize maximumSec = _maximumSec;
@synthesize valueSec = _valueSec;
@synthesize intervalStepSec = _intervalStepSec;

- (id)initWithResultCode:(int)code andReport:(TCalCfg_ZWave_WakeupSettingsReport*)report {
    if ([self init]) {
        _resultCode = code;
        if (report) {
            _minimumSec = report->MinimumSec;
            _maximumSec = report->MaximumSec;
            _valueSec = report->ValueSec;
            _intervalStepSec = report->IntervalStepSec;
        }
    }
    return self;
}

- (void)setValueSec:(int)valueSec {
    _valueSec = valueSec;
}

+ (SAZWaveWakeupSettingsReport*) reportWithResultCode:(int)code andReport:(TCalCfg_ZWave_WakeupSettingsReport*)report {
    return [[SAZWaveWakeupSettingsReport alloc] initWithResultCode:code andReport:report];
}

+ (SAZWaveWakeupSettingsReport *)notificationToProgressReport:(NSNotification *)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"report"];
        if (r != nil && [r isKindOfClass:[SAZWaveWakeupSettingsReport class]]) {
            return r;
        }
    }
    return nil;
}
@end
