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

#ifndef SAClassHelper_h
#define SAClassHelper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDictionary (SUPLA)
-(NSString*_Nullable) urlEncodedString;
@end

@interface UIButton (SUPLA)
- (void)setTitle:(nullable NSString *)title;
- (void)setAttributedTitle:(nullable NSString *)title;
- (void)setBackgroundImage:(UIImage *_Nullable)image;
- (void)setImage:(UIImage *_Nullable)image;
@end

@interface NSNumber (SUPLA)
+(NSNumber *_Nullable)codeNotificationToNumber:(NSNotification*_Nullable)notification;
+(NSNumber *_Nullable)resultNotificationToNumber:(NSNotification*_Nullable)notification;
@end

#endif /* SAClassHelper_h */
