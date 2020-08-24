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

@class SAColorBrightnessPicker;
@protocol SAColorBrightnessPickerDelegate <NSObject>

@required
-(void) cbPickerDataChanged:(SAColorBrightnessPicker*)picker;
-(void) cbPickerMoveEnded:(SAColorBrightnessPicker*)picker;
-(void) cbPickerPowerButtonValueChanged:(SAColorBrightnessPicker*)picker;

@end

@interface SAColorBrightnessPicker : UIView

@property(nonatomic, assign) BOOL colorWheelHidden;
@property(nonatomic, assign) BOOL circleInsteadArrow;
@property(nonatomic, assign) BOOL colorfulBrightnessWheel;
@property(nonatomic, assign) BOOL sliderHidden;
@property(nonatomic, assign) BOOL powerButtonHidden;
@property(nonatomic, assign) BOOL powerButtonEnabled;
@property(nonatomic, assign) BOOL powerButtonOn;
@property(nonatomic, assign) BOOL jumpToThePointOfTouchEnabled;
@property(nonatomic, copy) UIColor *powerButtonColorOn;
@property(nonatomic, copy) UIColor *powerButtonColorOff;
@property(nonatomic, copy) UIColor *color;
@property(nonatomic, assign) float brightness;
@property(nonatomic, assign) float minBrightness;
@property(nonatomic, readonly) BOOL moving;
@property(nonatomic, copy) NSArray *brightnessMarkers;
@property(nonatomic, copy) NSArray *colorMarkers;

@property(weak, nonatomic) id<SAColorBrightnessPickerDelegate> delegate;


@end
