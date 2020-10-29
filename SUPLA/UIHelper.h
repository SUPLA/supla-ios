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
#import "SettingsVC.h"
#import "MainVC.h"
#import "StatusVC.h"
#import "AboutVC.h"
#import "AddWizardVC.h"
#import "CreateAccountVC.h"

@interface UIView (SUPLA)

- (nullable UIImageView*)snapshot;

@end

@interface UIColor (SUPLA)

+(nonnull UIColor*)btnTouched;
+(nonnull UIColor*)onLine;
+(nonnull UIColor*)offLine;
+(nonnull UIColor*)colorPickerDefault;
+(nonnull UIColor*)statusYellow;
+(nonnull UIColor*)cellBackground;
+(nonnull UIColor*)rgbwDetailBackground;
+(nonnull UIColor*)rgbwSelectedTabColor;
+(nonnull UIColor*)rgbwNormalTabColor;
+(nonnull UIColor*)rsDetailBackground;
+(nonnull UIColor*)statusBorder;
+(nonnull UIColor*)rsMarkerColor;
+(nonnull UIColor*)phase1Color;
+(nonnull UIColor*)phase2Color;
+(nonnull UIColor*)phase3Color;
+(nonnull UIColor*)chartValuePositiveColor;
+(nonnull UIColor*)chartValueNegativeColor;
+(nonnull UIColor*)chartFilterPickerViewColor;
+(nonnull UIColor*)chartRoomTemperature;
+(nonnull UIColor*)hpBtnOn;
+(nonnull UIColor*)hpBtnOff;
+(nonnull UIColor*)hpBtnUnknown;
+(nonnull UIColor*)chartTemperatureFillColor;
+(nonnull UIColor*)chartTemperatureLineColor;
+(nonnull UIColor*)chartHumidityColor;
+(nonnull UIColor*)chartIncrementalValueColor;
+(nonnull UIColor*)menuSeparatorColor;
+(nonnull UIColor*)mainMenuColor;
@end

@interface SAUIHelper : NSObject

-(void)fadeToViewController:(nullable UIViewController*)vc;

-(void)showMainVC;

-(nonnull SASettingsVC *) SettingsVC;
-(void)showSettings;

-(nonnull SAMainVC *) MainVC;

-(nonnull SAStatusVC*) StatusVC;
-(void)showStatusVC;

-(nonnull SAAboutVC*)AboutVC;
-(void)showAbout;

-(nonnull SAAddWizardVC*)AddWizardVC;
-(void)showAddWizard;

-(nonnull SACreateAccountVC*)CreateAccountVC;
-(void)showCreateAccountVC;

-(void)showStatusConnectingProgress:(float)value;
-(void)showStatusError:(nonnull NSString*)message;

-(void)showStarterVC;

-(void)showMenuBtn:(BOOL)show;
-(void)showMenubarSettingsBtn;
-(void)showMenubarBackBtn;
-(void)setMenubarDetailTitle:(nonnull NSString *)title;
-(void)showGroupBtn:(BOOL)show;

-(BOOL)addWizardIsVisible;
-(BOOL)createAccountVCisVisible;
-(BOOL)settingsVCisVisible;

@property (nullable, nonatomic, strong) UIViewController *rootViewController;

@end


