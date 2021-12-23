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

#import "DetailView.h"
#import "SAChannelGroup+CoreDataClass.h"

#import "SuplaApp.h"
#import "Database.h"

@implementation SADetailView {
    
    BOOL _initialized;
    SAChannelBase *_channelBase;
}

@synthesize main_view;

-(BOOL)initialized {
    return _initialized;
}

-(void) detailViewInit {
    
    if ( _initialized )
        return;
    
    self.channelBase = nil;    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelValueChanged:) name:kSAChannelValueChangedNotification object:nil];
    
    _initialized = YES;
    
}

- (void)onChannelValueChanged:(NSNotification *)notification {
    
    if ( notification.userInfo == nil || _channelBase == nil ) return;
    
    NSNumber *Id = (NSNumber *)[notification.userInfo objectForKey:@"remoteId"];
    NSNumber *IsGroup = (NSNumber *)[notification.userInfo objectForKey:@"isGroup"];
    
    if ( _channelBase.remote_id == [Id intValue]  ) {
        if ( [IsGroup boolValue] ) {
            if ( [_channelBase isKindOfClass:[SAChannelGroup class]] ) {
                self.channelBase = [[SAApp DB] fetchChannelGroupById:[Id intValue]];
            }
        } else {
            if ( [_channelBase isKindOfClass:[SAChannel class]] ) {
                self.channelBase = [[SAApp DB] fetchChannelById:[Id intValue]];
            }
        }
    }

};

-(SAChannelBase*)channelBase {
    return _channelBase;
}

-(void)updateView {}

-(void)detailWillShow {}

-(void)detailWillHide {}

-(void)detailDidShow {}

-(void)detailDidHide {}

-(void)setChannelBase:(SAChannelBase *)channelBase {
    
    _channelBase = channelBase;
    [self updateView];
}

-(void)removeFromSuperview {
    self.channelBase = nil;
    self.main_view = nil;
	[super removeFromSuperview];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
