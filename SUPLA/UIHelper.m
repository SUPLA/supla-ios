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


#import "UIHelper.h"
#import "SuplaApp.h"
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

+(UIColor*)circleOn {
    return [UIColor colorWithRed:0.071 green:0.655 blue:0.118 alpha:1.000];
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

+(UIColor*)rgbDetailBackground {
    return [UIColor colorWithRed:1.00 green:0.91 blue:0.02 alpha:1.0];
}

+(UIColor*)rsDetailBackground {
    return [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
}

@end

@implementation SAUIHelper {
    
    SANavigationController *_NavController;
    SASettingsVC * _SettingsVC;
    SAMainVC * _MainVC;
    SAStatusVC *_StatusVC;
    SAAboutVC *_AboutVC;
    
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
    
    if ( _NavController
         && _NavController.btnMenu.hidden != !show) {
        _NavController.btnMenu.hidden = !show;
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
    
    [[self MainVC] detailHide];
    
    [self.NavController showViewController:[self MainVC]];
    [self fadeToViewController:[self NavController]];
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
    self.rootViewController = [[SAApp getServerHostName] isEqualToString:@""] ? [self SettingsVC] :[self StatusVC];
    
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

-(void)hideVC {
    
    if ( [SAApp SuplaClientConnected] ) {
        [self showMainVC];
    } else {
        [self showStatusVC];
    }
    
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


@end
