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

#import "SAChannelCaptionEditor.h"
#import "SuplaApp.h"
#import "SAChannel+CoreDataClass.h"

@interface SAChannelCaptionEditor ()

@end

SAChannelCaptionEditor *_channelCaptionEditorGlobalRef = nil;

@implementation SAChannelCaptionEditor {
}

+(SAChannelCaptionEditor*)globalInstance {
    if (_channelCaptionEditorGlobalRef == nil) {
        _channelCaptionEditorGlobalRef =
        [[SAChannelCaptionEditor alloc] init];
    }
    
    return _channelCaptionEditorGlobalRef;
}

- (NSString*) getPlaceholder {
    return NSLocalizedString(@"Default", nil);
}

- (NSString*) getTitle {
    return NSLocalizedString(@"Channel name", nil);
}

- (NSString*) getCaption {
    SAChannel *channel = [[SAApp DB] fetchChannelById:self.recordId];
    return channel && channel.caption ? channel.caption : @"";
}

- (void) applyChanges:(NSString*)caption {
    SAChannel *channel = [[SAApp DB] fetchChannelById:self.recordId];
    if (channel) {
        channel.caption = caption;
        [[SAApp DB] saveContext];
        
        [SAApp.SuplaClient setChannelCaption:self.recordId caption:caption];
    }
}
@end
