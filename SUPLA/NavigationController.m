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


#import "NavigationController.h"
#import "SuplaApp.h"
#import "SAClassHelper.h"

@interface SANavigationController ()
@end

@implementation SANavigationController {
    UIViewController *_vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems.hidden = YES;
    
    [self.btnSettings setTitle:NSLocalizedString(@"Settings", nil)];
    [self.btnAddDevice setTitle:NSLocalizedString(@"Add I/O device", nil)];
    [self.btnAbout setTitle:NSLocalizedString(@"About", nil)];
    //[self.btnDonate setTitle:NSLocalizedString(@"Donate", nil)];
    [self.btnHelp setTitle:NSLocalizedString(@"Help", nil)];
   
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateFrame {
    if ( _vc ) {
        _vc.view.frame = CGRectMake(0, self.menuBarHeight.constant, self.view.frame.size.width, self.view.frame.size.height-self.menuBarHeight.constant);
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self setNeedsStatusBarAppearanceUpdate];
    [super viewWillAppear:animated];
    [self updateFrame];
    
}


-(void)showViewController:(UIViewController *)vc {
    
    self.btnMenu.hidden = vc != [[SAApp UI] MainVC];
    UIView *snapShot = nil;
    
    if ( _vc != nil ) {
        
        snapShot = [_vc.view snapshot];
        
        [_vc removeFromParentViewController];
        [_vc.view removeFromSuperview];
        _vc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    _vc = vc;
    
    if ( vc ) {
        
        if ( snapShot )
           [vc.view addSubview:snapShot];
        
        
        [self updateFrame];
        
        [self addChildViewController: vc];
        [self.view addSubview: vc.view];
        
        if ( snapShot ) {
            
            [UIView animateWithDuration:0.25 animations:^{
                snapShot.alpha = 0.0;
            } completion:^(BOOL finished) {
                [snapShot removeFromSuperview];
            }];
            
        }
    }
    
    
}

-(UIViewController *)currentViewController {
    return _vc;
}

- (void) showMenu:(BOOL)show withAction:(void (^)(void))action {
    
    self.menuBar.layer.zPosition = 2;
    self.menuItems.layer.zPosition = 1;
    self.menuItemsTop.constant = show ? self.menuItems.frame.size.height * -1 : 0;
    self.menuItems.hidden = NO;
    
    [self.view layoutIfNeeded];
    
    self.menuItemsTop.constant = show ? 0 : self.menuItems.frame.size.height * -1;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if ( show ) {
            [self.view bringSubviewToFront:self.menuItems];
        } else {
            self.menuItems.hidden = YES;
        }
        
        if ( action != nil )
            action();
    }];
    
}

- (void)hideMenuWithAction:(void (^)(void))action {
    [self showMenu:NO withAction:action];
}

- (IBAction)menuTouched:(id)sender {
    
    if ( self.btnMenu.tag == 1 ) {
        [[SAApp UI] showSettings];
        return;
    }
    
    if ( self.menuItems.hidden ) {
        [self showMenu:YES withAction:nil];
    } else {
        [self showMenu:NO withAction:nil];
    }
}

- (IBAction)settingsTouch:(id)sender {
    
    [self hideMenuWithAction:nil];
    [[SAApp UI] showSettings];

}

- (IBAction)aboutTouch:(id)sender {
    
    [self hideMenuWithAction:nil];
    [[SAApp UI] showAbout];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (IBAction)helpTouch:(id)sender {
    
    [self hideMenuWithAction:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://forum.supla.org"]];
    
}

- (IBAction)wwwTouch:(id)sender {
    
    [self hideMenuWithAction:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.supla.org"]];
        
}

- (IBAction)addDeviceTouch:(id)sender {
    [self hideMenuWithAction:nil];
    [[SAApp UI] showAddWizard];
}

- (IBAction)donateTouch:(id)sender {
    
    [self hideMenuWithAction:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: NSLocalizedString(@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=L4N7RSWME6LG2", NULL)]];
    
}

- (IBAction)groupsTouch:(id)sender {
    
    if ( !self.menuItems.hidden ) {
        [self showMenu:NO withAction:nil];
    }
    
    SAMainVC *MainVC = [[SAApp UI] MainVC];
    
    if ( self.btnGroups.tag == 1 ) {
        [self.btnGroups setImage:[UIImage imageNamed:@"groupsoff.png"]];
        self.btnGroups.tag = 0;
        MainVC.cTableView.hidden = NO;
        MainVC.gTableView.hidden = YES;
    } else {
        [self.btnGroups setImage:[UIImage imageNamed:@"groupson.png"]];
        self.btnGroups.tag = 1;
        MainVC.cTableView.hidden = YES;
        MainVC.gTableView.hidden = NO;
    }

}

@end
