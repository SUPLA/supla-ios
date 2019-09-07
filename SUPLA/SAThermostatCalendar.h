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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SAThermostatCalendarDelegate <NSObject>
@required
-(void) thermostatCalendarPragramChanged:(id)calendar day:(short)d hour:(short)h program1:(BOOL)p1;
@end

@interface SAThermostatCalendar : UIView
-(void)clear;
-(short)addOffsetToDay:(short)day;
-(BOOL)programIsSetToOneWithDay:(short)day andHour:(short)hour;
-(void)setProgramForDay:(short)day andHour:(short)hour toOne:(BOOL)one;

@property (nonatomic, weak) NSString *program0Label;
@property (nonatomic, weak) NSString *program1Label;
@property (nonatomic, assign) short firstDay;
@property (nonatomic, assign) CGFloat textSize;
@property (nonatomic, weak) UIColor *textColor;
@property (nonatomic, weak) UIColor *program0Color;
@property (nonatomic, weak) UIColor *program1Color;
@property (nonatomic, assign) BOOL readOnly;
@property (nonatomic, readonly) BOOL isTouched;
@property (weak, nonatomic) id<SAThermostatCalendarDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
