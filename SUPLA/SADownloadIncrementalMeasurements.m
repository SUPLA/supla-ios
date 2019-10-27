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

#import "SADownloadIncrementalMeasurements.h"
#import "SAIncrementalMeasurementItem+CoreDataClass.h"
#import "SuplaApp.h"

@implementation SADownloadIncrementalMeasurements {
    SAIncrementalMeasurementItem *older_item;
    SAIncrementalMeasurementItem *younger_item;
    BOOL createdWithMOC;
}

-(SAIncrementalMeasurementItem *) newObjectWithManagedObjectContext:(BOOL)moc {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
};

-(SAIncrementalMeasurementItem *) getUncalculatedIncrementalMeasurementItemOlderThanDate:(NSDate*)date {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

- (void) deleteUncalculatedIncrementalMeasurementsWithChannelID:(int)channelId {
    ABSTRACT_METHOD_EXCEPTION;
};

- (void)createMeasurementItemEntity:(SAIncrementalMeasurementItem *)item {
    SAIncrementalMeasurementItem *mi = [self newObjectWithManagedObjectContext:YES];
    [mi assignMeasurementItem:item];
    createdWithMOC = YES;
}

- (void)createMeasurementItemEntity:(NSDictionary *)item withDate:(NSDate *)date {
    younger_item = [self newObjectWithManagedObjectContext:NO];
    
    if (younger_item == nil) {
        @throw [NSException exceptionWithName:@"NullPointerException" reason:@"younger_item cannot be null" userInfo:nil];
    }
    
    [younger_item assignJSONObject:item];
    younger_item.channel_id = self.channelId;
    
    if (older_item == nil) {
        older_item = [self getUncalculatedIncrementalMeasurementItemOlderThanDate:younger_item.date];
        if (older_item != nil) {
            [self deleteUncalculatedIncrementalMeasurementsWithChannelID:self.channelId];
        }
    }
    
    bool correctDateOrder = older_item == nil
    || [younger_item.date timeIntervalSince1970] > [older_item.date timeIntervalSince1970];
    
    if (older_item!=nil
        && correctDateOrder) {
        
        SAIncrementalMeasurementItem *calculatedItem = [self newObjectWithManagedObjectContext:NO];
        [calculatedItem assignMeasurementItem:younger_item];
        
        if (!calculatedItem.calculated) {
            [calculatedItem calculateWithSource:older_item];
        }
        
        long diff = [calculatedItem.date timeIntervalSince1970] - [older_item.date timeIntervalSince1970];
        
        if (diff >= 1200) {
            long n = diff / 600;
            if (!calculatedItem.divided) {
                [calculatedItem divideBy: n];
            }
            
            for(int a=0;a<n;a++) {
                if (a<n-1) {
                    calculatedItem.complement = YES;
                }
                [self createMeasurementItemEntity:calculatedItem];
                calculatedItem.date = [NSDate dateWithTimeIntervalSince1970:[calculatedItem.date timeIntervalSince1970]-600];
            }
        } else {
            [self createMeasurementItemEntity: calculatedItem];
        }
    
    }
    
    if (correctDateOrder) {
       older_item = younger_item;
    }

};

- (void)onFirstItem {
    createdWithMOC = NO;
    older_item = nil;
};

- (void)onLastItem {
    if (createdWithMOC && older_item) {
        [self createMeasurementItemEntity:older_item];
        older_item = nil;
    }
};


- (void)onFinish  {

};

@end
