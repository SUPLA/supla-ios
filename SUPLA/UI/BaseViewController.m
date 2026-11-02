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


#import "BaseViewController.h"
#import "SUPLA-Swift.h"

@interface BaseViewController ()

@end

@implementation BaseViewController {}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.navigationController setNavigationBarHidden: [self hidesNavigationBar]
                                             animated: animated];
}

- (BOOL)hidesNavigationBar {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait |
            UIInterfaceOrientationMaskPortraitUpsideDown;
}


- (void)addChildView:(UIView *)v {
    [self.view addSubview: v];
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    CGRect destFrame = CGRectMake(0, CGRectGetMaxY(navBarFrame),
                                  self.view.frame.size.width,
                                  self.view.frame.size.height - CGRectGetMaxY(navBarFrame));
    v.frame = destFrame;
}

- (BOOL) shouldUpdateTitleFont {
    return YES;
}
@end
