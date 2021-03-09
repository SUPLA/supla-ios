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

@protocol SADigiglassControllerDelegate <NSObject>

@required
-(void) digiglassSectionTouched:(id)digiglassController sectionNumber:(int)number isTransparent:(BOOL)transparent;

@end

@interface SADigiglassController : UIView

@property (nonatomic, nullable, copy) UIColor *barColor;
@property (nonatomic, nullable, copy) UIColor *lineColor;
@property (nonatomic, nullable, copy) UIColor *glassColor;
@property (nonatomic, nullable, copy) UIColor *dotColor;
@property (nonatomic, nullable, copy) UIColor *btnBackgroundColor;
@property (nonatomic, nullable, copy) UIColor *btnDotColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) int sectionCount;
@property (nonatomic) int transparentSections;
@property (nonatomic) BOOL vertical;

- (void)setAllTransparent;
- (void)setAllOpaque;
- (BOOL)isSectionTransparent:(int)number;

@property(weak, nonatomic) id<SADigiglassControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
