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

#import "ChartDetailView.h"
#import "SADownloadMeasurements.h"
#import "SAChartHelper.h"
#import "SuplaApp.h"
#import "SUPLA-Swift.h"

@implementation SAChartDetailView {
    SADownloadMeasurements *_task;
    NSTimer *_taskTimer;
    ChartSettings *_chartSettings;
}

@synthesize chartHelper;

-(SAChartHelper*)newChartHelper {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

-(SADownloadMeasurements*)newDownloadTask {
    ABSTRACT_METHOD_EXCEPTION;
    return nil;
}

- (void)initChartFilters {
    self.ftDateRangeFilter.ff_delegate = self;
    self.ftDateRangeFilter.chartHelper = self.chartHelper;
    self.ftDateRangeFilter.filterType = DateRangeFilter;
}

-(void)detailViewInit {
    if (!self.initialized) {
        self.chartHelper = [self newChartHelper];
        self.chartHelper.combinedChart = self.combinedChart;
        [self initChartFilters];
    }
    
    [super detailViewInit];
}

-(void)detailWillShow {
    [super detailWillShow];
    
    [SAApp.instance cancelAllRestApiClientTasks];
    
    if (_taskTimer == nil) {
        _taskTimer = [NSTimer scheduledTimerWithTimeInterval:120
                                                           target:self
                                                         selector:@selector(onTaskTimer:)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    [self runDownloadTask];
    [self loadChartWithAnimation:YES moveToEnd:YES];
}

-(void)detailWillHide {
    [super detailWillHide];
    
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
        _task = [self newDownloadTask];
        _task.channelId = self.channelBase.remote_id;
        _task.delegate = self;
        [_task start];
    }
}

-(void) onRestApiTaskStarted: (SARestApiClientTask*)task {
    // NSLog(@"onRestApiTaskStarted");
    [self.lPreloader animateWithTimeInterval:0.1];
}

-(void) onRestApiTaskFinished: (SARestApiClientTask*)task {
    // NSLog(@"onRestApiTaskFinished");
    if (_task != nil && task == _task) {
        _task.delegate = nil;
        _task = nil;
    }
    
    self.lPreloader.hidden = YES;
    [self updateView];
    self.chartHelper.downloadProgress = nil;
    [self loadChartWithAnimation:NO];
}

- (IBAction)chartBtnTouch:(id)sender {
    if (self.lPreloader.hidden) {
        [self runDownloadTask];
    }
}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    if(channelBase) {
        if(!_chartSettings) {
            _chartSettings = [[ChartSettings alloc]
                                 initWithChannelId: channelBase.remote_id
                                    chartTypeField: nil
                                    dateRangeField: self.ftDateRangeFilter];
            [_chartSettings restore];
        }
    } else {
        [_chartSettings persist];
    }
    
    if (self.chartHelper) {
        self.chartHelper.channelId = channelBase ? channelBase.remote_id : 0;
    }
    [super setChannelBase:channelBase];
}
- (void)applyChartFilter {
    self.chartHelper.chartType = Bar_Minutes;
    self.chartHelper.dateFrom = _ftDateRangeFilter.dateFrom;
}

- (void)loadChartWithAnimation:(BOOL)animation moveToEnd:(BOOL)moveToEnd {
    [self applyChartFilter];
    [self.chartHelper load];
    
    if (moveToEnd) {
      [self.chartHelper moveToEnd];
    }
    
    if (animation) {
        [self.chartHelper animate];
    }
}

- (void)loadChartWithAnimation:(BOOL)animation {
    [self loadChartWithAnimation:animation moveToEnd:NO];
}

-(void) onRestApiTask: (SARestApiClientTask*)task progressUpdate:(float)progress {
    self.chartHelper.downloadProgress = [NSNumber numberWithFloat:progress];
}

-(void) onFilterChanged: (SAChartFilterField*)filterField {
    [self loadChartWithAnimation:YES moveToEnd:YES];
}

- (void)updateView {
    [super updateView];
    [self.ivImage setImage:[self.channelBase getIcon]];
}

@end
