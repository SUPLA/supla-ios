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

#import "ImpulseCounterDetailView.h"
#import "SAImpulseCounterExtendedValue.h"
#import "SAImpulseCounterChartHelper.h"
#import "SADownloadImpulseCounterMeasurements.h"
#import "SuplaApp.h"

@implementation SAImpulseCounterDetailView

-(SAChartHelper*)newChartHelper {
    SAChartHelper *chartHelper = [[SAImpulseCounterChartHelper alloc] init];
    chartHelper.pieChart = self.pieChart;
    chartHelper.unit = @"kWh";
    return chartHelper;
}

-(SADownloadMeasurements*)newDownloadTask {
    return [[SADownloadImpulseCounterMeasurements alloc] init];
}

- (void)initChartFilters {
    self.tfChartTypeFilter.chartHelper = self.chartHelper;
    self.tfChartTypeFilter.dateRangeFilterField = self.ftDateRangeFilter;
    [self.tfChartTypeFilter excludeAllFrom: Pie_PhaseRank];
    self.tfChartTypeFilter.ff_delegate = self;
    self.ftDateRangeFilter.ff_delegate = self;
}

- (void)applyChartFilter {
    self.chartHelper.chartType = self.tfChartTypeFilter.chartType;
    self.chartHelper.dateFrom = self.ftDateRangeFilter.dateFrom;
}

- (void)updateView {
    [super updateView];
    
    NSString *empty = @"----";
    
    [self.lMeterValue setText:empty];
    [self.lCurrentConsumption setText:empty];
    [self.lCurrentCost setText:empty];
    [self.lTotalCost setText:empty];
    [self.ivImage setImage:[self.channelBase getIcon]];
    
    SAImpulseCounterExtendedValue *icev = nil;
    
    if ([self.channelBase isKindOfClass:SAChannel.class]
        && ((SAChannel*)self.channelBase).ev != nil
        && (icev = ((SAChannel*)self.channelBase).ev.impulseCounter) != nil) {
        
        double currentConsumption = 0;
        double currentCost = 0;
        
        if ([SAApp.DB impulseCounterMeasurementsStartsWithTheCurrentMonthForChannelId:self.channelBase.remote_id]) {
            currentConsumption = icev.calculatedValue;
            currentCost = icev.totalCost;
        } else {
            double v0 = [SAApp.DB calculatedValueSumForChannelId:self.channelBase.remote_id monthLimitOffset:0];
            double v1 = [SAApp.DB calculatedValueSumForChannelId:self.channelBase.remote_id monthLimitOffset:-1];
            
            currentConsumption = v0-v1;
            currentCost = icev.pricePerUnit * currentConsumption;
        }
        
        [self.lMeterValue setText:[NSString stringWithFormat:@"%0.2f %@", icev.calculatedValue, icev.unit]];
        [self.lTotalCost setText:[NSString stringWithFormat:@"%0.2f %@", icev.totalCost, icev.currency]];
        [self.lCurrentConsumption setText:[NSString stringWithFormat:@"%0.2f %@", currentConsumption,  icev.unit]];
        [self.lCurrentCost setText:[NSString stringWithFormat:@"%0.2f %@", currentCost, icev.currency]];
    
        SAImpulseCounterChartHelper *chartHelper = (SAImpulseCounterChartHelper*)self.chartHelper;
        chartHelper.unit = icev.unit;
        chartHelper.currency = icev.currency;
        chartHelper.pricePerUnit = icev.pricePerUnit;
    }
}

- (void)loadChartWithAnimation:(BOOL)animation {
    SAImpulseCounterChartHelper *chartHelper = (SAImpulseCounterChartHelper*)self.chartHelper;
    chartHelper.chartType = _tfChartTypeFilter.chartType;
    chartHelper.dateFrom = _tfChartTypeFilter.dateRangeFilterField.dateFrom;
    [chartHelper load];
    if (animation) {
        [chartHelper animate];
    }
}
@end
