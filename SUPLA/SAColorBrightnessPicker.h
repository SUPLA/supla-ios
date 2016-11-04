/*
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
 
 Author: Przemyslaw Zygmunt przemek@supla.org
 */

#import <UIKit/UIKit.h>

@protocol SAColorBrightnessPickerDelegate <NSObject>

@required
-(void) cbPickerDataChanged;
-(void) cbPickerMoveEnded;

@end

@interface SAColorBrightnessPicker : UIView

@property(nonatomic, assign) BOOL colorBrightnessWheelVisible;
@property(nonatomic, assign) BOOL bwBrightnessWheelVisible;

@property(weak, nonatomic) IBOutlet UIColor *color;
@property(nonatomic, assign) float brightness;
@property(nonatomic, readonly) BOOL moving;

@property(weak, nonatomic) id<SAColorBrightnessPickerDelegate> delegate;


@end
