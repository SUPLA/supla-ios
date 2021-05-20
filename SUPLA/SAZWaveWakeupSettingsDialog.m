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

#import "SAZWaveWakeupSettingsDialog.h"
#import "SAPickerField.h"
#import "SuplaApp.h"
#import "SAZWaveWakeupSettingsReport.h"
#import "NSNumber+SUPLA.h"

static SAZWaveWakeupSettingsDialog *_zwaveWakeupSettingsDialogGlobalRef = nil;

@interface SAZWaveWakeupSettingsDialog () <SAPickerFieldDelegate>
@property (weak, nonatomic) IBOutlet SAPickerField *pfHours;
@property (weak, nonatomic) IBOutlet SAPickerField *pfMinutes;
@property (weak, nonatomic) IBOutlet SAPickerField *pfSeconds;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actInd;
@property (weak, nonatomic) IBOutlet UILabel *lError;
@end

@implementation SAZWaveWakeupSettingsDialog {
    SAZWaveNode *_node;
    NSTimer *_timeoutTimer;
    SAZWaveWakeupSettingsReport *_settingsReport;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pfHours.pf_delegate = self;
    self.pfMinutes.pf_delegate = self;
    self.pfSeconds.pf_delegate = self;
}

+(SAZWaveWakeupSettingsDialog*)globalInstance {
    if (_zwaveWakeupSettingsDialogGlobalRef == nil) {
        _zwaveWakeupSettingsDialogGlobalRef =
        [[SAZWaveWakeupSettingsDialog alloc]
         initWithNibName:@"SAZWaveWakeupSettingsDialog" bundle:nil];
    }
    
    return _zwaveWakeupSettingsDialogGlobalRef;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onZWaveWakeupSettingsReport:)
     name:kSAOnZWaveWakeupSettingsReport object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(onZWaveSetWakeupTimeResult:)
     name:kSAOnZWaveSetWakeUpTimeResult object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopTimeoutTimer];
}

-(void)onZWaveWakeupSettingsReport:(NSNotification *)notification {
    SAZWaveWakeupSettingsReport *report = [SAZWaveWakeupSettingsReport notificationToProgressReport:notification];
    if (report == nil) {
        return;
    }
    
    [self stopTimeoutTimer];
    
    if (report.resultCode == SUPLA_CALCFG_RESULT_TRUE) {
        _settingsReport = report;
        
        self.actInd.hidden = YES;
        [self.actInd stopAnimating];
        self.btnOK.hidden = NO;
        self.pfSeconds.enabled = YES;
        self.pfMinutes.enabled = YES;
        self.pfHours.enabled = YES;
        
        [self.pfSeconds update];
        [self.pfMinutes update];
        [self.pfHours update];
    } else {
        [self showError:[NSString stringWithFormat:
                         NSLocalizedString(@"Unexpected bridge response. Code: %i", nil), report.resultCode]];
    }
}

- (void)onZWaveSetWakeupTimeResult:(NSNotification *)notification {
    NSNumber *result = [NSNumber resultNotificationToNumber:notification];
    if (!result) {
        return;
    }
    
    if ([result intValue] == SUPLA_CALCFG_RESULT_TRUE) {
        [self close];
    } else {
        [self showError:[NSString stringWithFormat:
                         NSLocalizedString(@"Unexpected bridge response. Code: %i", nil), [result intValue]]];
    }
}

- (void)showError:(NSString *)error {
    
    self.lError.hidden = NO;
    self.lError.text = NSLocalizedString(error, nil);
    self.actInd.hidden = YES;
    [self.actInd stopAnimating];
    self.btnOK.hidden = NO;
}

- (void)onTimeoutTimer:(NSTimer *)timer {
    [self stopTimeoutTimer];
    [self showError:@"Timeout waiting for z-wave bridge response."];
}

- (void)stopTimeoutTimer {
    if (_timeoutTimer) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
}

- (void)startTimeoutTimer {
    [self stopTimeoutTimer];
    
    self.pfHours.enabled = NO;
    self.pfMinutes.enabled = NO;
    self.pfSeconds.enabled = NO;
    
    self.lError.hidden = YES;
    self.actInd.hidden = NO;
    [self.actInd startAnimating];
    self.btnOK.hidden = YES;
    self.btnOK.enabled = NO;
    
    _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                            target:self
                                            selector:@selector(onTimeoutTimer:)
                                            userInfo:nil
                                            repeats:NO];
}

-(void)showWithNode:(SAZWaveNode *)node {
    _node = node;
    _settingsReport = nil;

    [self startTimeoutTimer];
    [SADialog showModal:self];
    
    [SAApp.SuplaClient zwaveGetWakeUpSettingsForChannelId:_node.channelId];
}

- (NSInteger)hourMax {
    return _settingsReport ? _settingsReport.maximumSec/3600 : 0;
}

- (NSInteger)hours {
    return _settingsReport ? _settingsReport.valueSec/3600 : 0;
}

- (NSInteger)minutes {
    return _settingsReport ? _settingsReport.valueSec%3600/60 : 0;
}

- (NSInteger)seconds {
    return _settingsReport ? _settingsReport.valueSec%3600%60 : 0;
}

- (NSInteger)numberOfRowsInPickerField:(SAPickerField *)pickerField {
    if (pickerField == self.pfSeconds || pickerField == self.pfMinutes) {
        return 60;
    }
    
    return [self hourMax]+1;
}

- (NSInteger)selectedRowIndexInPickerField:(SAPickerField *)pickerField {
    if (pickerField == self.pfSeconds) {
        return [self seconds];
    } else if (pickerField == self.pfMinutes) {
        return [self minutes];
    }
    
    return [self hours];
}

- (void)pickerField:(SAPickerField *)pickerField tappedAtRow:(NSInteger*)row {
    if (!_settingsReport) {
        return;
    }
    
    int valueSec = 0;
    
    if (pickerField == self.pfSeconds) {
        valueSec = (int)((*row) + [self minutes] * 60 + [self hours] * 3600);
    } else if (pickerField == self.pfMinutes) {
        valueSec = (int)([self seconds] + (int)(*row) * 60 + [self hours] * 3600);
    } else {
        valueSec = (int)([self seconds] + [self minutes] * 60 + (int)(*row) * 3600);
    }

    if (valueSec < _settingsReport.minimumSec) {
        valueSec = _settingsReport.minimumSec;
    } else if (valueSec > _settingsReport.maximumSec) {
        valueSec = _settingsReport.maximumSec;
    }
    
    if (_settingsReport.intervalStepSec) {
        valueSec -= _settingsReport.minimumSec;
        int n = valueSec / _settingsReport.intervalStepSec;
        if (valueSec % _settingsReport.intervalStepSec >= _settingsReport.intervalStepSec/2) {
            n+=1;
        }
        
        valueSec = _settingsReport.minimumSec + n * _settingsReport.intervalStepSec;
    }
    
    [_settingsReport setValueSec:valueSec];
    
    if (pickerField == self.pfSeconds) {
        *row = [self seconds];
        [self.pfMinutes update];
        [self.pfHours update];
    } else if (pickerField == self.pfMinutes) {
        *row = [self minutes];
        [self.pfSeconds update];
        [self.pfHours update];
    } else {
        *row = [self hours];
        [self.pfSeconds update];
        [self.pfMinutes update];
    }
    
    self.btnOK.enabled = YES;
}

- (NSString *)pickerField:(SAPickerField *)pickerField titleForRow:(NSInteger)row {
    return [NSString stringWithFormat:@"%li", (long)row];
}

- (IBAction)bntOkTouch:(id)sender {
    [self startTimeoutTimer];
    [SAApp.SuplaClient zwaveSetWakeUpTime:_settingsReport.valueSec forChannelId:_node.channelId];
}

@end
