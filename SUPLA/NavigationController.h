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
#import <MessageUI/MessageUI.h>

@interface SANavigationController : UIViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *menuBar;
-(void)showViewController:(UIViewController *)vc;
-(UIViewController *)currentViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBarHeight;
- (IBAction)menuTouched:(id)sender;
- (IBAction)settingsTouch:(id)sender;
- (IBAction)aboutTouch:(id)sender;
- (IBAction)helpTouch:(id)sender;
- (IBAction)wwwTouch:(id)sender;
- (IBAction)addDeviceTouch:(id)sender;
- (IBAction)donateTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnAbout;
@property (weak, nonatomic) IBOutlet UIButton *btnHelp;
@property (weak, nonatomic) IBOutlet UIView *menuItems;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuItemsTop;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnAddDevice;
@property (weak, nonatomic) IBOutlet UIButton *btnDonate;


@end
