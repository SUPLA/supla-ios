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

#import "SADownloadMeasurementLogs.h"

@implementation SADownloadMeasurementLogs

@synthesize afterTimestamp = _afterTimestamp;

- (long)getMinTimesatamp { return 0; }
- (long)getMaxTimesatamp { return 0; }
- (int)getLocalTotalCount { return 0; }
- (int)itemsPerRequest { return 1000; }
- (void)eraseMeasurements {};
- (void)noRemoteDataAvailable {};
- (void)saveMeasurementItemWithTimestamp:(long)timestamp values:(NSDictionary *)values {};

- (void)task {
    if (self.channelId <= 0) {
        return;
    }
    SAApiRequestResult *result = [self apiRequestForEndpoint:[NSString stringWithFormat:@"channels/%i/measurement-logs?order=ASC&limit=2&offset=0", self.channelId]];
    
    if (result != nil && result.responseCode == 200) {
        BOOL doErase = NO;
        if ( result.totalCount == 0) {
            doErase = YES;
        } else if (result.jsonObject && [result.jsonObject isKindOfClass:[NSArray class]]) {
            NSArray *items = (NSArray*)result.jsonObject;
            NSDictionary *item;
            NSString *str_ts;
            long min = [self getMinTimesatamp];
            bool found = NO;
            
            for(int a=0;a<items.count;a++) {
                if ( (item = [items objectAtIndex:a])
                    && [item isKindOfClass:[NSDictionary class]]
                    && (str_ts = [item valueForKey:@"date_timestamp"])
                    && min == [str_ts longLongValue]) {
        
                    found = YES;
                    break;
                }
            }
            
            doErase = !found;
        }
        
        if (doErase) {
            [self eraseMeasurements];
        }
    }
    
    _afterTimestamp = [self getMaxTimesatamp];
    int localTotalCount = [self getLocalTotalCount];
    double percent = 0.0;
    
    do {
        result = [self apiRequestForEndpoint:[NSString stringWithFormat:@"channels/%i/measurement-logs?order=ASC&limit=%i&afterTimestamp=%li", self.channelId, [self itemsPerRequest], _afterTimestamp]];
        
        if (result == nil
            || result.responseCode != 200
            || result.jsonObject == nil
            || ![result.jsonObject isKindOfClass:[NSArray class]]) {
            [self cancel];
            break;
        }
        
        NSArray *items = (NSArray*)result.jsonObject;
        if ( items.count <= 0 ) {
            [self noRemoteDataAvailable];
            [self cancel];
            break;
        }
        
        for(int a=0;a<items.count;a++) {
            
            NSDictionary *item = [items objectAtIndex:a];
            long timestamp = 0;
            
            if (item == nil
                || ![item isKindOfClass:[NSDictionary class]]
                || (timestamp = [[item valueForKey:@"date_timestamp"] longLongValue]) == 0) {
                [self cancel];
                break;
            }
            
            if (timestamp > _afterTimestamp) {
                _afterTimestamp = timestamp;
            }
            
            [self saveMeasurementItemWithTimestamp:timestamp values:item];
            
            if ([self isCancelled]) {
                break;
            }
            
            localTotalCount++;
            
            if (result.totalCount > 0) {
                double new_percent = localTotalCount*100.00/result.totalCount;
                if (new_percent - percent >= 1) {
                    percent = new_percent;
                    [self onProgressUpdate:new_percent];
                }
            }
            
            [self keepTaskAlive];
        }
        
    } while(![self isCancelled]);
    
}
@end
