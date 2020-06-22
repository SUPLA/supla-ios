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

@class SARangeCalibrationWheel;
@protocol SARangeCalibrationWheelDelegate <NSObject>

@required
-(void) calibrationWheelRangeChanged:(SARangeCalibrationWheel *)wheel minimum:(BOOL)min;
-(void) calibrationWheelBoostChanged:(SARangeCalibrationWheel *)wheel;

@end

@interface SARangeCalibrationWheel : UIView

@property (nonatomic, nullable, copy) UIColor *wheelColor;
@property (nonatomic, nullable, copy) UIColor *borderColor;
@property (nonatomic, nullable, copy) UIColor *btnColor;
@property (nonatomic, nullable, copy) UIColor *rangeColor;
@property (nonatomic, nullable, copy) UIColor *insideBtnColor;
@property (nonatomic, nullable, copy) UIColor *boostLineColor;
@property (nonatomic) float boostLineHeightFactor;
@property (nonatomic) CGFloat borderLineWidth;
@property (nonatomic) double maximumValue;
@property (nonatomic) double minimumRange;
@property (nonatomic) double numerOfTurns;
@property (nonatomic) double minimum;
@property (nonatomic) double maximum;
@property (nonatomic) double leftEdge;
@property (nonatomic) double rightEdge;
@property (nonatomic) double boostLevel;
@property (nonatomic) BOOL boostHidden;
@property(weak, nonatomic) id<SARangeCalibrationWheelDelegate> delegate;

-(void) setMinimum:(double)minimum andMaximum:(double)maximum;

@end

NS_ASSUME_NONNULL_END
