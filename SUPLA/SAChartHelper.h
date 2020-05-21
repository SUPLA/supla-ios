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

#import <Foundation/Foundation.h>
#import "Database.h"
@import Charts;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ChartType) {
    Bar_Minutes,
    Bar_Hours,
    Bar_Days,
    Bar_Months,
    Bar_Years,
    Bar_Comparsion_MinMin,
    Bar_Comparsion_HourHour,
    Bar_Comparsion_DayDay,
    Bar_Comparsion_MonthMonth,
    Bar_Comparsion_YearYear,
    Pie_HourRank,
    Pie_WeekdayRank,
    Pie_MonthRank,
    Pie_PhaseRank,
    Bar_AritmeticBalance_Minutes,
    Bar_AritmeticBalance_Hours,
    Bar_AritmeticBalance_Days,
    Bar_AritmeticBalance_Months,
    Bar_AritmeticBalance_Years,
    Bar_VectorBalance_Minutes,
    Bar_VectorBalance_Hours,
    Bar_VectorBalance_Days,
    Bar_VectorBalance_Months,
    Bar_VectorBalance_Years
};

#define ChartTypeMax Bar_VectorBalance_Years
@class SABarChartDataSet;
@interface SAChartHelper : NSObject <IChartAxisValueFormatter>

- (NSNumber *)doubleValueForKey:(NSString *)key item:(NSDictionary *)i;
- (NSDateFormatter *) dateFormatterForCurrentChartType;
- (NSString *) stringForValue:(double)value axis:(nullable ChartAxisBase *)axis;
- (SABarChartDataSet *) newBarDataSetWithEntries:(NSArray *)entries;
- (id<IChartMarker>) getMarker;
- (GroupingDepth) getGroupungDepthForCurrentChartType;
- (GroupBy) getGroupByForCurrentChartType;
- (NSString *)stringRepresentationOfChartType:(ChartType)ct;
- (void) prepareBarDataSet:(SABarChartDataSet*)barDataSet;
-(BOOL)isPieChartType;
-(BOOL)isComparsionChartType;
-(BOOL)isBalanceChartType;
-(BOOL)isVectorBalanceChartType;
- (void) moveToEnd;
- (void) load;
- (void) animate;

@property (nonatomic, weak) CombinedChartView *combinedChart;
@property (nonatomic, weak) PieChartView *pieChart;
@property (nonatomic) ChartType chartType;
@property (nonatomic, strong) NSDate *dateFrom;
@property (nonatomic, strong) NSDate *dateTo;
@property (nonatomic, strong) NSString *unit;
@property (nullable, nonatomic, strong) NSNumber *downloadProgress;
@property (nonatomic) int channelId;
@property (nonatomic, readonly) long minTimestamp;
@end

NS_ASSUME_NONNULL_END
