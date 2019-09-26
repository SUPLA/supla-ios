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

#import "SAPreloader.h"

@implementation SAPreloader {
    NSTimer *_timer;
    int _pos;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self onTimer:nil];
    }
    return self;
}

-(void)onTimer:(NSTimer *)timer {
    CGSize dotSize = [@"•" sizeWithAttributes:@{NSFontAttributeName:self.font}];
    int count = self.frame.size.width / dotSize.width;
    
    NSString *p = @"";
    
    for(int a=0;a<count;a++) {
        p = [NSString stringWithFormat:@"%@%@", p, _pos == a ? @"o" : @"•"];
    }
    
    _pos++;
    if (_pos >= count) {
        _pos = 0;
    }
    
    [self setText:p];
    
    if (self.hidden) {
        [self stop];
    }
}

-(void)stop {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)animateWithTimeInterval:(NSTimeInterval)interval {
    if (self.hidden) {
        self.hidden = NO;
    }
    [self stop];
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                    target:self
                                                    selector:@selector(onTimer:)
                                                    userInfo:nil
                                                    repeats:YES];
}

@end
