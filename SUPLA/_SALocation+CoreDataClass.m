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


#import "_SALocation+CoreDataClass.h"

@implementation _SALocation

- (BOOL) setLocationCaption:(char*)caption {
    
    NSString *_caption = [NSString stringWithUTF8String:caption];
    
    if ( [self.caption isEqualToString:_caption] == NO  ) {
        self.caption = _caption;
        return YES;
    }
    
    return NO;
}

- (BOOL) setLocationVisible:(int)visible {
    
    if ( [self.visible isEqualToNumber:[NSNumber numberWithInt:visible]] == NO ) {
        self.visible = [NSNumber numberWithInt:visible];
        return YES;
    }
    
    return NO;
}

@end
