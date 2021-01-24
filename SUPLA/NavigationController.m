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
#import "SAMenuItems.h"
#import "SAZWaveConfigurationWizardVC.h"

#define TAG_BTN_MENU 0
#define TAG_BTN_SETTINGS 1
#define TAG_BTN_BACK 2

#define TAG_NOTSELECTED 0
#define TAG_SELECTED 1

@interface SANavigationController () <SAMenuItemsDelegate>
@property (weak, nonatomic) IBOutlet UIView *menuBar;
@property (weak, nonatomic) IBOutlet UILabel *vTitle;
@property (weak, nonatomic) IBOutlet UILabel *vDetailTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBarHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnGroups;
@end

@implementation SANavigationController {
    UIViewController *_vc;
    SAMenuItems *_menuItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menuItems = [[SAMenuItems alloc] init];
    _menuItems.hidden = YES;
    _menuItems.delegate = self;
    _menuItems.menuBarHeight = self.menuBarHeight;
    [self.view addSubview:_menuItems];
    self.menuBar.layer.zPosition = 2;
    _menuItems.layer.zPosition = 1;
       
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
    self.btnGroups.hidden = self.btnMenu.hidden;
    
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
    if (show) {
        _menuItems.buttonsAvailable
        = SAApp.DB.zwaveBridgeChannelAvailable ? SAMenuItemIdAll : SAMenuItemIdAll ^ SAMenuItemIdZWave;
    }
    [_menuItems slideDown:show withAction:action];
}

- (void)hideMenuWithAction:(void (^)(void))action {
    [self showMenu:NO withAction:action];
}

- (IBAction)menuTouched:(id)sender {
    
    if ( self.btnMenu.tag == TAG_BTN_SETTINGS ) {
        [[SAApp UI] showSettings];
        return;
    } else if ( self.btnMenu.tag == TAG_BTN_BACK ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSAMenubarBackButtonPressed object:self userInfo:nil];
        return;
    }
    
    if ( _menuItems.hidden ) {
        [self showMenu:YES withAction:nil];
    } else {
        [self showMenu:NO withAction:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion: nil];
}

- (IBAction)groupsTouch:(id)sender {
    
    if ( !_menuItems.hidden ) {
        [self showMenu:NO withAction:nil];
    }
    
    SAMainVC *MainVC = [[SAApp UI] MainVC];
    
    if ( self.btnGroups.tag == TAG_SELECTED ) {
        [self.btnGroups setImage:[UIImage imageNamed:@"groupsoff.png"]];
        self.btnGroups.tag =  TAG_NOTSELECTED;
        [MainVC groupTableHidden: YES];
    } else {
        [self.btnGroups setImage:[UIImage imageNamed:@"groupson.png"]];
        self.btnGroups.tag = TAG_SELECTED;
        [MainVC groupTableHidden: NO];
    }

}

-(void)showMenuButton:(BOOL)show withImage:(UIImage *)image tag:(int)tag hideDetailTitle:(BOOL)hideDetailTitle {
    self.btnMenu.hidden = !show;
    self.btnMenu.tag = tag;
    [self.btnMenu setImage:image];
    if (show && hideDetailTitle) {
        self.vTitle.hidden = NO;
        self.vDetailTitle.hidden = YES;
    }
}

-(void)showMenuBtn:(BOOL)show {
    [self showMenuButton:show withImage:[UIImage imageNamed:@"menu.png"] tag:TAG_BTN_MENU hideDetailTitle:YES];
}

-(void)showGroupBtn:(BOOL)show {
    self.btnGroups.hidden = !show;
}

-(void)showMenubarSettingsBtn {
    [self showMenuButton:YES withImage:[UIImage imageNamed:@"settings.png"] tag:TAG_BTN_SETTINGS hideDetailTitle:YES];
}

-(void)showMenubarBackBtn {
    [self showMenuButton:YES withImage:[UIImage imageNamed:@"backbtn.png"] tag:TAG_BTN_BACK hideDetailTitle:NO];
}

-(void)setMenubarDetailTitle:(NSString *)title {
    self.vTitle.hidden = YES;
    self.vDetailTitle.hidden = NO;
    self.vDetailTitle.text = title;
}

-(void)menuItemTouched:(SAMenuItemIds)btnId {
    [self hideMenuWithAction:nil];
    
    switch (btnId) {
        case SAMenuItemIdSettings:
            [[SAApp UI] showSettings];
            break;
        case SAMenuItemIdAddDevice:
            [[SAApp UI] showAddWizard];
            break;
        case SAMenuItemIdZWave:
            [SAZWaveConfigurationWizardVC.globalInstance show];
            break;
        case SAMenuItemIdAbout:
            [[SAApp UI] showAbout];
            break;
        case SAMenuItemIdDonate:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: NSLocalizedString(@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=L4N7RSWME6LG2", NULL)]];
            break;
        case SAMenuItemIdHelp:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: NSLocalizedString(@"https://en-forum.supla.org", NULL)]];
            break;
        case SAMenuItemIdHomepage:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: _menuItems.homepageUrl]];
            break;
        default:
            break;
    }
}

@end
