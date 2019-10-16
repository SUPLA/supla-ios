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
#import "SuplaApp.h"

@implementation SAImpulseCounterDetailView {
    SADownloadImpulseCounterMeasurements *_task;
    SAImpulseCounterChartHelper *_chartHelper;
    NSTimer *_taskTimer;
}

-(void)detailViewInit {
    if (!self.initialized) {
        _chartHelper = [[SAImpulseCounterChartHelper alloc] init];
        _chartHelper.combinedChart = self.combinedChart;
        _chartHelper.pieChart = self.pieChart;
        _chartHelper.unit = @"kWh";
        _tfChartTypeFilter.chartHelper = _chartHelper;
        _tfChartTypeFilter.dateRangeFilterField = _ftDateRangeFilter;
        [_tfChartTypeFilter excludeElements:@[[NSNumber numberWithInt:Pie_PhaseRank]]];
        _tfChartTypeFilter.ff_delegate = self;
        _ftDateRangeFilter.ff_delegate = self;
    }
    
    [super detailViewInit];
}

-(void)onDetailShow {
    [super onDetailShow];
    
    [SAApp.instance cancelAllRestApiClientTasks];
    
    if (_taskTimer == nil) {
        _taskTimer = [NSTimer scheduledTimerWithTimeInterval:120
                                                           target:self
                                                         selector:@selector(onTaskTimer:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    [self runDownloadTask];
    [self loadChartWithAnimation:YES];
}

-(void)onDetailHide {
    [super onDetailHide];
    
    if (_taskTimer) {
        [_taskTimer invalidate];
        _taskTimer = nil;
    }
    
    if (_task) {
        [_task cancel];
        _task.delegate = nil;
    }
}

-(void)onTaskTimer:(NSTimer *)timer {
    [self runDownloadTask];
}

-(void) runDownloadTask {
    if (_task && ![_task isTaskIsAliveWithTimeout:90]) {
        [_task cancel];
        _task = nil;
    }
    
    if (!_task) {
        _task = [[SADownloadImpulseCounterMeasurements alloc] init];
        _task.channelId = self.channelBase.remote_id;
        _task.delegate = self;
        [_task start];
    }
}

-(void) onRestApiTaskStarted: (SARestApiClientTask*)task {
    NSLog(@"onRestApiTaskStarted");
    [self.lPreloader animateWithTimeInterval:0.1];
}

-(void) onRestApiTaskFinished: (SARestApiClientTask*)task {
    NSLog(@"onRestApiTaskFinished");
    if (_task != nil && task == _task) {
        _task.delegate = nil;
        _task = nil;
    }
    
    self.lPreloader.hidden = YES;
    [self updateView];
    _chartHelper.downloadProgress = nil;
    [self loadChartWithAnimation:NO];
}

- (IBAction)chartBtnTouch:(id)sender {
    if (self.lPreloader.hidden) {
        [self runDownloadTask];
    }
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    if (_chartHelper) {
        _chartHelper.channelId = channelBase ? channelBase.remote_id : 0;
    }
    [super setChannelBase:channelBase];
}

- (void)updateView {
    NSString *empty = @"----";
    
    [self.lMeterValue setText:empty];
    [self.lCurrentConsumption setText:empty];
    [self.lCurrentCost setText:empty];
    [self.lTotalCost setText:empty];
    [self.lCaption setText:[self.channelBase getChannelCaption]];
    
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
    
        _chartHelper.unit = icev.unit;
        _chartHelper.currency = icev.currency;
        _chartHelper.pricePerUnit = icev.pricePerUnit;
    }
}

- (void)loadChartWithAnimation:(BOOL)animation {
    _chartHelper.chartType = _tfChartTypeFilter.chartType;
    _chartHelper.dateFrom = _tfChartTypeFilter.dateRangeFilterField.dateFrom;
    [_chartHelper load];
    if (animation) {
        [_chartHelper animate];
    }
}
-(void) onFilterChanged: (SAChartFilterField*)filterField {
    [self loadChartWithAnimation:YES];
}
@end
