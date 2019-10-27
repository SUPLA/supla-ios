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
#import "SADownloadTempHumidityMeasurements.h"

@implementation SADownloadTempHumidityMeasurements
- (long)getMinTimesatamp {
    return [self.DB getTimestampOfTempHumidityMeasurementItemWithChannelId:self.channelId minimum:YES];
}
- (long)getMaxTimesatamp {
    return [self.DB getTimestampOfTempHumidityMeasurementItemWithChannelId:self.channelId minimum:NO];
}

- (NSUInteger)getLocalTotalCount {
    return [self.DB getTempHumidityMeasurementItemCountForChannelId:self.channelId];
}

- (void)deleteAllMeasurements {
    [self.DB deleteAllTempHumidityMeasurementsForChannelId:self.channelId];
};

- (void)onFirstItem {
};

- (void)onLastItem {
};

- (void)createMeasurementItemEntity:(NSDictionary *)item withDate:(NSDate *)date {
    SATempHumidityMeasurementItem *mi = [self.DB newTempHumidityMeasurementItem];
    [mi assignJSONObject:item];
    mi.channel_id = self.channelId;
};

@end
