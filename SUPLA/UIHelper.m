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


#import "UIHelper.h"
#import "SuplaApp.h"
#import "SAClassHelper.h"
#import "NavigationController.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (SUPLA)

- (UIImageView*)snapshot {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, self.window.screen.scale);
    
    /* iOS 7 */
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    else /* iOS 6 */
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [[UIImageView alloc] initWithImage:img];
}

@end

@implementation UIColor (SUPLA)

+(UIColor*)onLine {
    return [UIColor colorWithRed:0.071 green:0.655 blue:0.118 alpha:1.000];
}

+(UIColor*)offLine {
    return [UIColor redColor];
}

+(UIColor*)btnTouched {
    return [UIColor colorWithRed:0.35 green:0.91 blue:0.40 alpha:1.0];
}

+(UIColor*)colorPickerDefault {
    return [UIColor colorWithRed:0 green:255 blue:0 alpha:1];
}

+(UIColor*)statusYellow {
    return [UIColor colorWithRed:0.996 green:0.906 blue:0.000 alpha:1.000];
}

+(UIColor*)cellBackground {
    return [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
}

+(UIColor*)rgbwDetailBackground {
    return [UIColor colorWithRed: 0.93 green: 0.93 blue: 0.93 alpha: 1.00];
}

+(UIColor*)rgbwSelectedTabColor {
    return [UIColor colorWithRed: 0.07 green: 0.65 blue: 0.12 alpha: 1.00];
}

+(UIColor*)diwInputOptionSelected {
    return [UIColor colorWithRed: 1.00 green: 0.60 blue: 0.00 alpha: 1.00];
}

+(UIColor*)rgbwNormalTabColor {
    return [UIColor whiteColor];
}

+(UIColor*)rsDetailBackground {
    return [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
}

+(nonnull UIColor*)statusBorder {
    return [UIColor blackColor];
}

+(nonnull UIColor*)rsMarkerColor {
    return [UIColor colorWithRed:0.07 green:0.65 blue:0.12 alpha:1.0];
}

+(nonnull UIColor*)phase1Color {
    return [UIColor colorWithRed:0.56 green:0.92 blue:1.00 alpha:1.0];
}

+(nonnull UIColor*)phase2Color {
    return [UIColor colorWithRed:0.59 green:0.57 blue:1.00 alpha:1.0];
}

+(nonnull UIColor*)phase3Color {
    return [UIColor colorWithRed:1.00 green:0.82 blue:0.57 alpha:1.0];
}

+(nonnull UIColor*)chartValuePositiveColor {
    return [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];
}

+(nonnull UIColor*)chartValueNegativeColor {
    return [UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0];
}

+(nonnull UIColor*)chartFilterPickerViewColor {
    return [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
}

+(nonnull UIColor*)chartRoomTemperature {
    return [UIColor colorWithRed:0.00 green:0.76 blue:0.99 alpha:1.0];
}

+(nonnull UIColor*)hpBtnOn {
    return [UIColor colorWithRed:0.14 green:0.75 blue:0.13 alpha:1.0];
}

+(nonnull UIColor*)hpBtnOff {
    return [UIColor colorWithRed:0.94 green:0.27 blue:0.29 alpha:1.0];
}

+(nonnull UIColor*)hpBtnUnknown {
    return [UIColor colorWithRed:0.90 green:0.74 blue:0.49 alpha:1.0];
}

+(nonnull UIColor*)chartTemperatureFillColor {
    return [UIColor colorWithRed:0.99 green:0.97 blue:0.79 alpha:1.0];
}

+(nonnull UIColor*)chartTemperatureLineColor {
    return [UIColor colorWithRed:0.99 green:0.29 blue:0.30 alpha:1.0];
}

+(nonnull UIColor*)chartHumidityColor {
    return [UIColor colorWithRed:0.00 green:0.63 blue:0.99 alpha:1.0];
}

+(nonnull UIColor*)chartIncrementalValueColor {
    return [UIColor colorWithRed:0.00 green:0.63 blue:0.99 alpha:1.0];
}

+(nonnull UIColor*)menuSeparatorColor {
    return [UIColor colorWithRed: 0.98 green: 0.98 blue: 0.99 alpha: 0.4];
}

+(nonnull UIColor*)mainMenuColor {
    return [UIColor colorWithRed: 0.07 green: 0.65 blue: 0.12 alpha: 1.00];
}

+(nonnull UIColor*)vlCfgButtonColor {
    return [UIColor colorWithRed: 0.07 green: 0.65 blue: 0.12 alpha: 1.00];
}
@end

@implementation SAUIHelper {
    
    SANavigationController *_NavController;
    SASettingsVC * _SettingsVC;
    SAMainVC * _MainVC;
    SAStatusVC *_StatusVC;
    SAAboutVC *_AboutVC;
    SAAddWizardVC *_AddWizardVC;
    SACreateAccountVC *_CreateAccountVC;
    
    UIViewController *_nextWaiting;
    BOOL _fading;
}

-(UIViewController*)rootViewController {
    return [[UIApplication sharedApplication] keyWindow].rootViewController;
}

-(void)setRootViewController:(UIViewController *)rootViewController {
    [[UIApplication sharedApplication] keyWindow].rootViewController = rootViewController;
}

-(SANavigationController *) NavController {
    if ( _NavController == nil ) {
        _NavController = [[SANavigationController alloc] initWithNibName:@"NavigationController" bundle:nil];
    }
    
    return _NavController;
}

-(void)showMenuBtn:(BOOL)show {
    if (_NavController) {
        [_NavController showMenuBtn:show];
    }
}

-(void)showGroupBtn:(BOOL)show {
    if (_NavController) {
        [_NavController showGroupBtn:show];
    }
}

-(void)showMenubarSettingsBtn {
    if (_NavController) {
        [_NavController showMenubarSettingsBtn];
    }
}

-(void)showMenubarBackBtn {
    if (_NavController) {
        [_NavController showMenubarBackBtn];
    }
}

-(void)setMenubarDetailTitle:(NSString *)title {
    if (_NavController) {
        [_NavController setMenubarDetailTitle:title];
    }
}

-(SASettingsVC *) SettingsVC {
    
    if ( _SettingsVC == nil ) {
        _SettingsVC = [[SASettingsVC alloc] initWithNibName:@"SettingsVC" bundle:nil];
    }
    
    return _SettingsVC;
}

-(void)showSettings {
    
    if ( [SAApp SuplaClientConnected] ) {
        
        [self.NavController showViewController:[self SettingsVC]];
        [self fadeToViewController:[self NavController]];
        
    } else {
        
        [self.NavController showViewController:nil];
        [self fadeToViewController:[self SettingsVC]];
        
    }
    
}


-(SAMainVC *) MainVC {
    if ( _MainVC == nil ) {
        _MainVC = [[SAMainVC alloc] initWithNibName:@"MainVC" bundle:nil];
    }
    
    return _MainVC;
}

-(void)showMainVC {
    if ( [SAApp SuplaClientConnected] ) {
        [[self MainVC] detailHide];
        
        [self.NavController showViewController:[self MainVC]];
        [self fadeToViewController:[self NavController]];
    } else {
        [self showStatusVC];
    }
}

-(SAStatusVC*) StatusVC {
    
    if ( _StatusVC == nil ) {
        _StatusVC = [[SAStatusVC alloc] initWithNibName:@"StatusVC" bundle:nil];
    }
    
    return _StatusVC;
    
}

-(void)showStatusVC {
    [self fadeToViewController:self.StatusVC];
}

-(void)showStatusConnectingProgress:(float)value {
    
    
    [[self StatusVC] setStatusConnectingProgress:value];
    [self showStatusVC];
    
}

-(void)showStatusError:(NSString*)message {
    
    
    [[self StatusVC] setStatusError:message];
    [self showStatusVC];
}


-(void)showStarterVC {
    
    [[self StatusVC] setStatusConnectingProgress:0];
    self.rootViewController = [SAApp configIsSet] ? [self StatusVC] : [self SettingsVC];
    
}

-(SAAboutVC*)AboutVC {
    
    if ( _AboutVC == nil ) {
        _AboutVC = [[SAAboutVC alloc] initWithNibName:@"AboutVC" bundle:nil];
    }
    
    return _AboutVC;
    
}

-(void)showAbout {
    
    [self.NavController showViewController:[self AboutVC]];
    [self fadeToViewController:[self NavController]];
    
}

-(SAAddWizardVC*)AddWizardVC {
    
    if ( _AddWizardVC == nil ) {
        _AddWizardVC = [[SAAddWizardVC alloc] initWithNibName:@"AddWizardVC" bundle:nil];
    }
    
    return _AddWizardVC;
    
}

-(void)showAddWizard {
    
    [self.NavController showViewController:[self AddWizardVC]];
    [self fadeToViewController:[self NavController]];
    
}

-(SACreateAccountVC*)CreateAccountVC {
    
    if ( _CreateAccountVC == nil ) {
        _CreateAccountVC = [[SACreateAccountVC alloc] initWithNibName:@"CreateAccountVC" bundle:nil];
    }
    
    return _CreateAccountVC;
    
}

-(void)showCreateAccountVC {
    
    [self.NavController showViewController:[self CreateAccountVC]];
    [self fadeToViewController:[self NavController]];
    
}

-(void)fadeToViewController:(UIViewController*)vc {
    
    if ( vc == self.rootViewController ) {
        return;
    }
    
    if ( _fading ) {
        _nextWaiting = vc;
        return;
    }
    
    if ( _nextWaiting == vc ) {
        _nextWaiting = nil;
    }
    
    _fading = YES;
    
    
    
    UIView *snapShot = nil;
    
    if ( self.rootViewController
        && self.rootViewController.view ) {
        snapShot = [self.rootViewController.view snapshot];
    }
    
    
    if ( snapShot ) {
        [vc.view addSubview:snapShot];
    }
    
    self.rootViewController = vc;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        if ( snapShot )
            snapShot.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        if (snapShot )
            [snapShot removeFromSuperview];
        
        _fading = NO;
        
        if ( _nextWaiting ) {
            [self fadeToViewController:_nextWaiting];
        }
    }];
    
}

-(BOOL)addWizardIsVisible {
    return _AddWizardVC != nil && self.NavController.currentViewController == _AddWizardVC;
}

-(BOOL)createAccountVCisVisible {
    return _CreateAccountVC != nil && self.NavController.currentViewController == _CreateAccountVC;
}

-(BOOL)settingsVCisVisible {
    return _SettingsVC != nil
    && (self.NavController.currentViewController == _SettingsVC || self.rootViewController == _SettingsVC);
}

@end
