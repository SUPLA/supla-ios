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

#import "StatusVC.h"
#import "SuplaApp.h"
#import "UIColor+SUPLA.h"
#import "SUPLA-Swift.h"

@interface SAStatusVC ()

@end


@implementation SAStatusVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.button.layer.cornerRadius = 3;
    self.button.clipsToBounds = YES;
    [self.button setTitle:NSLocalizedString(@"Your account", nil) forState:UIControlStateNormal];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self GreenTheme];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)YellowTheme {
    UIColor *yellowColor = [UIColor statusYellow];
    [self.view setBackgroundColor: yellowColor];
    [self.statusBarBackgroundView setBackgroundColor: yellowColor];
    [self.progress setHidden:YES];
    [self.image setImage:nil];
    [self.label setTextColor:[UIColor blackColor]];
    [self.button setBackgroundColor:[UIColor blackColor]];
    [self.button setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    self.btnRetry.hidden = NO;
    self.cintButtonCenter.constant = -20;
    self.btnCloud.hidden = NO;
}

-(void)GreenTheme {
    UIColor *greenColor = [UIColor colorWithRed:0.071 green:0.655 blue:0.118 alpha:1.000];
    [self.view setBackgroundColor:greenColor];
    [self.statusBarBackgroundView setBackgroundColor:greenColor];
    [self.progress setHidden:NO];
    
    [self.image setImage:[UIImage imageNamed:@"logo-white"]];
    [self.label setTextColor:[UIColor whiteColor]];
    [self.button setBackgroundColor:[UIColor whiteColor]];
    [self.button setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    self.btnRetry.hidden = YES;
    self.cintButtonCenter.constant = 0;
    self.btnCloud.hidden = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)setStatusConnectingProgress:(float)value {
    if(value >= 0) {
        [self GreenTheme];
        [self.label setText:NSLocalizedString(@"Connecting...", NULL)];
    } else
        value = 0;
    [self.progress setProgress:value];
}

- (IBAction)btnCloudTouch:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: NSLocalizedString(@"https://cloud.supla.org", NULL)]];
}

-(void)setStatusError:(NSString*)message {
    [self YellowTheme];
    [self.image setImage:[UIImage imageNamed:@"error"]];
    [self.label setText:message];
}


- (IBAction)btnTouch:(id)sender {
    [[SAApp mainNavigationCoordinator] showProfilesViewWithAllowsBack: NO];
}

- (IBAction)btnRetryTouch:(id)sender {
    [[SAApp SuplaClient] reconnect];
}


@end
