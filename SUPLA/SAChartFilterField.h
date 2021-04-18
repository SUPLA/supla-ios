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

#import <UIKit/UIKit.h>
#import "SAAbstractPickerField.h"
#import "SAChartHelper.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ChartFilterFieldType) {
    TypeFilter,
    DateRangeFilter,
};

typedef NS_ENUM(NSUInteger, DateRange) {
    Last24hours,
    Last7days,
    Last30days,
    Last90days,
    AllAvailableHistory
};

#define DateRangeMax AllAvailableHistory

@class SAChartFilterField;
@protocol SAChartFilterFieldDelegate <NSObject>

@required
-(void) onFilterChanged: (SAChartFilterField*)filterField;

@end

@interface SAChartFilterField : SAAbstractPickerField

- (void)leaveOneElement:(int)el;
- (BOOL)excludeElements:(nullable NSArray*)el;
- (BOOL)excludeAllFrom:(int)el;
- (void)resetList;
- (NSUInteger)count;
+ (NSString *)stringRepresentationOfDateRange:(DateRange)dateRange;
- (void)goToToFirst;

@property (assign, nonatomic) ChartType chartType;
@property (assign, nonatomic) DateRange dateRange;
@property (readonly, nullable) NSDate *dateFrom;
@property (assign, nonatomic) ChartFilterFieldType filterType;
@property (nonatomic, weak) SAChartFilterField *dateRangeFilterField;
@property (nonatomic, weak) id<SAChartFilterFieldDelegate> ff_delegate;
@property (nonatomic, weak) SAChartHelper *chartHelper;
@end

NS_ASSUME_NONNULL_END
