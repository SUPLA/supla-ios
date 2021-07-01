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

#import "SADownloadMeasurements.h"
#import "SuplaApp.h"

@implementation SADownloadMeasurements

@synthesize afterTimestamp = _afterTimestamp;

- (long)getMinTimesatamp {
    ABSTRACT_METHOD_EXCEPTION;
    return 0;
}

- (long)getMaxTimesatamp {
    ABSTRACT_METHOD_EXCEPTION;
    return 0;
}

- (long)getMaxTimestampInitialOffset {
    return 1;
}

- (NSUInteger)getLocalTotalCount {
    ABSTRACT_METHOD_EXCEPTION;
    return 0;
}

- (int)itemsPerRequest {
    return 10000;
}

- (void)deleteAllMeasurements {
    ABSTRACT_METHOD_EXCEPTION;
};

- (void)onFirstItem {
    ABSTRACT_METHOD_EXCEPTION;
};

- (void)onLastItem {
    ABSTRACT_METHOD_EXCEPTION;
};

- (void)createMeasurementItemEntity:(NSDictionary *)item withDate:(NSDate *)date {
    ABSTRACT_METHOD_EXCEPTION;
};

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
            //NSLog(@"Min: %li", min);
            bool found = NO;
            
            for(int a=0;a<items.count;a++) {
                if ( (item = [items objectAtIndex:a])
                    && [item isKindOfClass:[NSDictionary class]]
                    && (str_ts = [item valueForKey:@"date_timestamp"])
                    && llabs(min-[str_ts longLongValue]) < 1800) {
    
                    found = YES;
                    break;
                }
            }
            
            doErase = !found;
        }
        
        if (doErase) {
            [self deleteAllMeasurements];
        }
    }
    
    _afterTimestamp = [self getMaxTimesatamp] + [self getMaxTimestampInitialOffset];
    if (_afterTimestamp <= 0) {
        _afterTimestamp = 1;
    }
    
    //NSLog(@"Max: %ld", _afterTimestamp);
    NSUInteger localTotalCount = [self getLocalTotalCount];
    double percent = 0.0;
    
    do {
        result = [self apiRequestForEndpoint:[NSString stringWithFormat:@"channels/%i/measurement-logs?order=ASC&limit=%i&afterTimestamp=%lli", self.channelId, [self itemsPerRequest], _afterTimestamp]];
        
        if (result == nil
            || result.responseCode != 200
            || result.jsonObject == nil
            || ![result.jsonObject isKindOfClass:[NSArray class]]) {
            [self cancel];
            break;
        }
        
        NSArray *items = (NSArray*)result.jsonObject;
        
        if (!items || items.count <=0) {
            break;
        }
        
        for(int a=0;a<items.count;a++) {
            
            if ([self isCancelled]) {
                break;
            }
            
            NSDictionary *item = [items objectAtIndex:a];
            long long timestamp = 0;
            
            if (item == nil
                || ![item isKindOfClass:[NSDictionary class]]
                || (timestamp = [[item valueForKey:@"date_timestamp"] longLongValue]) == 0) {
                [self cancel];
                break;
            }
            
            if (timestamp > _afterTimestamp) {
                _afterTimestamp = timestamp;
            }
            
            if (a == 0) {
                [self onFirstItem];
            }
            
            [self createMeasurementItemEntity:item withDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
            
            if (a == items.count-1) {
                [self onLastItem];
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
        
        [self.DB saveContext];
        
    } while(![self isCancelled]);
}
@end
