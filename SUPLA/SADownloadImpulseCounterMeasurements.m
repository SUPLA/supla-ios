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

#import "SADownloadImpulseCounterMeasurements.h"

@implementation SADownloadImpulseCounterMeasurements

- (long)getMinTimesatamp {
    return [self.DB getTimestampOfImpulseCounterMeasurementItemWithChannelId:self.channelId minimum:YES];
}
- (long)getMaxTimesatamp {
    return [self.DB getTimestampOfImpulseCounterMeasurementItemWithChannelId:self.channelId minimum:NO];
}

-(SAIncrementalMeasurementItem *) newObjectWithManagedObjectContext:(BOOL)moc {
    return [self.DB newImpulseCounterMeasurementItemWithManagedObjectContext:moc];
}

- (void)deleteAllMeasurements {
    [self.DB deleteAllImpulseCounterMeasurementsForChannelId:self.channelId];
}

- (NSUInteger)getLocalTotalCount {
    return [self.DB getImpulseCounterMeasurementItemCountWithoutComplementForChannelId:self.channelId];
}

@end
