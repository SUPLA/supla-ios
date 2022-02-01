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

#import "DetailView.h"
#import "SARollerShutter.h"
#import "SARoofWindowController.h"
#import "SAUIChannelStatus.h"
#import "SASuperuserAuthorizationDialog.h"
#import "SAWarningIcon.h"

@interface SARSDetailView : SADetailView <SARollerShutterDelegate, SARoofWindowControllerDelegate, SASuperuserAuthorizationDialogDelegate>
- (IBAction)upTouch:(id)sender;
- (IBAction)downTouch:(id)sender;
- (IBAction)stopTouch:(id)sender;
- (IBAction)openTouch:(id)sender;
- (IBAction)closeTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRecalibrate;
@property (weak, nonatomic) IBOutlet UILabel *labelPercent;
@property (weak, nonatomic) IBOutlet SARollerShutter *rollerShutter;
@property (weak, nonatomic) IBOutlet SARoofWindowController *roofWindow;
@property (weak, nonatomic) IBOutlet SAUIChannelStatus *onlineStatus;
- (IBAction)recalibrateTouch:(id)sender;
@property (weak, nonatomic) IBOutlet SAWarningIcon *warningIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelBtnPressTime;
@property (weak, nonatomic) IBOutlet UILabel *labelPercentCaption;

@end
