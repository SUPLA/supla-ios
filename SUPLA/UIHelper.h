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
 
 Author: Przemyslaw Zygmunt p.zygmunt@acsoftware.pl [AC SOFTWARE]
 */


#import <UIKit/UIKit.h>
#import "SettingsVC.h"
#import "MainVC.h"
#import "StatusVC.h"
#import "AboutVC.h"

@interface UIView (SUPLA)

- (UIImageView*)snapshot;

@end

@interface UIColor (SUPLA)

+(UIColor*)btnTouched;
+(UIColor*)circleOn;
+(UIColor*)colorPickerDefault;
+(UIColor*)statusYellow;
+(UIColor*)cellBackground;
+(UIColor*)rgbDetailBackground;
+(UIColor*)rsDetailBackground;

@end

@interface SAUIHelper : NSObject

-(void)fadeToViewController:(UIViewController*)vc;

-(void)hideVC;

-(SASettingsVC *) SettingsVC;
-(void)showSettings;

-(SAMainVC *) MainVC;
-(void)showMainVC;

-(SAStatusVC*) StatusVC;
-(void)showStatusVC;

-(SAAboutVC*)AboutVC;
-(void)showAbout;

-(void)showStatusConnectingProgress:(float)value;
-(void)showStatusError:(NSString*)message;

-(void)showStarterVC;

-(void)showMenuBtn:(BOOL)show;

@property (nonatomic, strong) UIViewController *rootViewController;

@end


