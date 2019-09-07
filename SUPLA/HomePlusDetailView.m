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

#import "HomePlusDetailView.h"
#import "SAChannelExtendedValue+CoreDataClass.h"

#define PROG_ECO 1
#define PROG_COMFORT 2

@implementation SAHomePlusDetailView {
    NSTimeInterval _refreshLock;
}

-(void)showCalendar:(BOOL)show {
    if (show) {
        self.vMain.hidden = YES;
        self.vCalendar.hidden = NO;
    } else {
        self.vMain.hidden = NO;
        self.vCalendar.hidden = YES;
    }
}

-(void)onDetailShow {
    [self showCalendar:NO];
    self.vCalendar.program0Label = NSLocalizedString(@"ECO", nil);
    self.vCalendar.program1Label = NSLocalizedString(@"Comfort", nil);
    self.vCalendar.firstDay = 2;
};

-(void)onDetailHide {
    
};

- (IBAction)calendarButtonTouched:(id)sender {
    [self showCalendar:self.vCalendar.hidden];
}

- (IBAction)settingsButtonTouched:(id)sender {
}

- (void)updateView {
    if (_refreshLock > [[NSDate date] timeIntervalSince1970]) {
        return;
    }
    
    SAChannelExtendedValue *ev = nil;
    TThermostat_ExtendedValue thev;
    
    if (![self.channelBase isKindOfClass:SAChannel.class]
    || (ev = ((SAChannel*)self.channelBase).ev) == nil
    || ![ev getThermostatExtendedValue:&thev]) {
        return;
    }

    if (!_vCalendar.isTouched) {
        [_vCalendar clear];
        if (thev.Shedule.ValueType == THERMOSTAT_SCHEDULE_HOURVALUE_TYPE_PROGRAM) {
            for(short d=0;d<7;d++) {
                 for(short h=0;h<24;h++) {
                     [self.vCalendar setProgramForDay:d+1 andHour:h toOne:thev.Shedule.HourValue[d][h] == PROG_COMFORT];
                 }
             }
        }
    }
}

@end
