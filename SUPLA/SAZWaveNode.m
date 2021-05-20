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

#import "SAZWaveNode.h"

@implementation SAZWaveNode
@synthesize nodeId = _nodeId;
@synthesize flags = _flags;
@synthesize channelId = _channelId;
@synthesize screenType = _screenType;
@synthesize name = _name;

- (id)initWithNode:(TCalCfg_ZWave_Node * _Nullable)node {
    if ([self init]) {
        if (node) {
            _nodeId = node->Id;
            _flags = node->Flags;
            _channelId = node->ChannelID;
            _screenType = node->ScreenType;
            _name = [NSString stringWithUTF8String:node->Name];
        } else {
            _name = @"";
        }
    }
    return self;
}

- (id)initWithId:(unsigned char)nodeId channelId:(int)channelId name:(NSString*)name {
    if ([self init]) {
        _nodeId = nodeId;
        _channelId = channelId;
        _name = name ? name : @"";
    }
    return self;
}

- (void)setChannelId:(int)channelId {
    _channelId = channelId;
}

+ (SAZWaveNode*) nodeWithNode:(TCalCfg_ZWave_Node *)node {
    return [[SAZWaveNode alloc] initWithNode:node];
}

+ (SAZWaveNode*) emptyNode {
    return [[SAZWaveNode alloc] initWithNode:NULL];
}
@end
