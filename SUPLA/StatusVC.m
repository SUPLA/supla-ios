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

#import "StatusVC.h"
#import "SuplaApp.h"

@interface SAStatusVC ()

@end


@implementation SAStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.button.layer.cornerRadius = 3;
    self.button.clipsToBounds = YES;
    [self.button setTitle:NSLocalizedString(@"Settings", nil) forState:UIControlStateNormal];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)YellowTheme {
    [self.view setBackgroundColor:[UIColor statusYellow]];
    [self.progress setHidden:YES];
    [self.image setImage:nil];
    [self.label setTextColor:[UIColor blackColor]];
    [self.button setBackgroundColor:[UIColor blackColor]];
    [self.button setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];

}

-(void)GreenTheme {
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.071 green:0.655 blue:0.118 alpha:1.000]];
    [self.progress setHidden:NO];
    
    [self.image setImage:[UIImage imageNamed:@"logo-supla_white"]];
    [self.label setTextColor:[UIColor whiteColor]];
    [self.button setBackgroundColor:[UIColor whiteColor]];
    [self.button setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)setStatusConnectingProgress:(float)value {
    [self GreenTheme];
    [self.progress setProgress:value];
    [self.label setText:NSLocalizedString(@"Connecting...", NULL)];
}

-(void)setStatusError:(NSString*)message {
    [self YellowTheme];
    [self.image setImage:[UIImage imageNamed:@"error"]];
    [self.label setText:message];
}


- (IBAction)btnTouch:(id)sender {
    [[SAApp UI] showSettings];
}

@end
