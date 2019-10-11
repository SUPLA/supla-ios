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
#import "SuplaApp.h"

@implementation SAImpulseCounterDetailView {
    SADownloadImpulseCounterMeasurements *_task;
    NSTimer *_taskTimer;
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
}

-(void) onRestApiTaskFinished: (SARestApiClientTask*)task {
    NSLog(@"onRestApiTaskFinished");
    if (_task != nil && task == _task) {
        _task.delegate = nil;
        _task = nil;
    }
}

@end
