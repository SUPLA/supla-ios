/*
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
 
 Author: Przemyslaw Zygmunt przemek@supla.org
 */

#import "DetailView.h"
#import "UIHelper.h"
#import "SuplaApp.h"
#import "Database.h"

@implementation SADetailView {
    
    BOOL _initialized;
    SAChannel *_channel;
    UIPanGestureRecognizer *_panRecognizer;
    float last_touched_x;
    
}

@synthesize main_view;

-(BOOL)initialized {
    return _initialized;
}

-(void) detailViewInit {
    
    if ( _initialized )
        return;
    
    self.channel = nil;
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:_panRecognizer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelValueChanged:) name:kSAChannelValueChangedNotification object:nil];
    
    _initialized = YES;
    
}

- (void)onChannelValueChanged:(NSNotification *)notification {
    
    if ( notification.userInfo == nil || _channel == nil ) return;
    
    NSNumber *Id = (NSNumber *)[notification.userInfo objectForKey:@"channelId"];
    
    if ( Id && [Id isKindOfClass:[NSNumber class]]
         && [_channel.channel_id isEqual:Id] ) {
        
        self.channel = [[SAApp DB] fetchChannelById:[Id intValue]];
        
    }
};

-(SAChannel*)channel {
    return _channel;
}

-(void)updateView {
    
}

-(void)setChannel:(SAChannel *)channel {
    
    _channel = channel;
    [self updateView];
}

-(void)removeFromSuperview {
    self.channel = nil;
    self.main_view = nil;
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    last_touched_x = point.x;
    return [super hitTest:point withEvent:event];
}

- (void)handlePan:(UIPanGestureRecognizer *)gr {
    
    if ( self.main_view == nil || self.main_view.detailView != self )
        return;
    
    if ( gr.state == UIGestureRecognizerStateEnded) {
        
        [self.main_view detailShow:self.frame.origin.x > self.frame.size.width/3.5 ? NO : YES animated:YES];
        return;
    }
    
    CGPoint touch_point = [gr locationInView:self];
    
    float offset = touch_point.x-last_touched_x;
    
    if ( self.frame.origin.x+offset < 0 )
        offset -= self.frame.origin.x+offset;
    
    [self.main_view moveCenter:offset];

    
    last_touched_x = touch_point.x - offset;
    
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
