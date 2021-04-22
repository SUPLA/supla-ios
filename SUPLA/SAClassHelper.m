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

#include "SAClassHelper.h"

@implementation NSDictionary (SUPLA)

-(NSString *)urlEncode:(id)obj {
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:@"-._*"];
    
    return [[NSString stringWithFormat:@"%@", obj]
            stringByAddingPercentEncodingWithAllowedCharacters: allowed];
}

-(NSString*) urlEncodedString {
    
    NSMutableArray *fields = [NSMutableArray array];
    
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *field = [NSString stringWithFormat: @"%@=%@", [self urlEncode:key], [self urlEncode:value]];
        [fields addObject: field];
    }
    return [fields componentsJoinedByString: @"&"];
}


@end

@implementation UIButton (SUPLA)

- (void)setTitle:(nullable NSString *)title {
    
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateDisabled];
    [self setTitle:title forState:UIControlStateSelected];
    [self setTitle:title forState:UIControlStateHighlighted];
}

- (void)setAttributedTitle:(nullable NSString *)title {
    
    NSMutableAttributedString *astr = [[NSMutableAttributedString alloc] initWithAttributedString: self.currentAttributedTitle];
    
    [astr.mutableString setString:title];
    
    [self setAttributedTitle:astr forState:UIControlStateNormal];
    [self setAttributedTitle:astr forState:UIControlStateDisabled];
    [self setAttributedTitle:astr forState:UIControlStateSelected];
    [self setAttributedTitle:astr forState:UIControlStateHighlighted];
    
}

- (void)setBackgroundImage:(UIImage *)image {
    
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:image forState:UIControlStateDisabled];
    [self setBackgroundImage:image forState:UIControlStateSelected];
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
}

- (void)setImage:(UIImage *_Nullable)image {
    
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateDisabled];
    [self setImage:image forState:UIControlStateSelected];
    [self setImage:image forState:UIControlStateHighlighted];
    
}

@end

@implementation NSNumber (SUPLA)
+(NSNumber *)notificationToNumber:(NSNotification*_Nullable)notification {
    if (notification != nil && notification.userInfo != nil) {
        id r = [notification.userInfo objectForKey:@"code"];
        if (r != nil && [r isKindOfClass:[NSNumber class]]) {
            return r;
        }
    }
    
    return nil;
}
@end
