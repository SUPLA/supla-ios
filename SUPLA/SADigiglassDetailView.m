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

#import "SADigiglassDetailView.h"
#import "SuplaApp.h"

#define REFRESH_HOLD_TIME_SEC 3.0

@implementation SADigiglassDetailView {
    NSTimer *_delayTimer1;
    NSDate *_remoteUpdateTime;
}

-(void)detailViewInit {
    if (!self.initialized) {
        self.controller.delegate = self;
    }
    
    [super detailViewInit];
}

-(void)updateView:(NSTimer *)timer {
    self.controller.vertical = self.channelBase.func == SUPLA_CHANNELFNC_DIGIGLASS_VERTICAL;
    SADigiglassValue *value = self.channelBase.digiglassValue;
    self.controller.sectionCount = value.sectionCount;
    self.controller.transparentSections = value.mask;
}

-(void)updateView {
    [super updateView];
    
    if ( self.channelBase == nil ) {
        return;
    }
    
    if (_delayTimer1!=nil) {
        [_delayTimer1 invalidate];
        _delayTimer1 = nil;
    }
    
    double timeDiff = 0;
    if (_remoteUpdateTime != nil
        && (timeDiff = [[NSDate date] timeIntervalSinceDate: _remoteUpdateTime]) < REFRESH_HOLD_TIME_SEC) {
        _delayTimer1 = [NSTimer scheduledTimerWithTimeInterval:REFRESH_HOLD_TIME_SEC - timeDiff
                                                     target:self
                                                     selector:@selector(updateView:)
                                                     userInfo:nil repeats:NO];
        return;
    }
 
    [self updateView:nil];
    
}

- (void)setDgfTransparencyMask:(short)mask activeBits:(short)active_bits {
    SASuplaClient *client = [SAApp SuplaClient];
    if ( client != nil && self.channelBase != nil ) {
        
        if (_delayTimer1!=nil) {
            [_delayTimer1 invalidate];
            _delayTimer1 = nil;
        }
        
        _remoteUpdateTime = [NSDate date];
        [client setDgfTransparencyMask:mask activeBits:active_bits channelId:self.channelBase.remote_id];
    }
}

- (IBAction)btnOpaqueTouched:(id)sender {
    [self.controller setAllOpaque];
    [self setDgfTransparencyMask:self.controller.transparentSections activeBits:0xFFFF];
}

- (IBAction)btnTransparentTouched:(id)sender {
    [self.controller setAllTransparent];
    [self setDgfTransparencyMask:self.controller.transparentSections activeBits:0xFFFF];
}

-(void) digiglassSectionTouched:(id)digiglassController sectionNumber:(int)number isTransparent:(BOOL)transparent {
    short bit = (short)(1 << number);
    [self setDgfTransparencyMask:transparent ? bit : 0 activeBits:bit];
}
@end
