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
#import "DetailView.h"
#import "SARangeCalibrationWheel.h"
#import "SASuperuserAuthorizationDialog.h"

NS_ASSUME_NONNULL_BEGIN

@interface SAVLCalibrationTool : UIView <SARangeCalibrationWheelDelegate, SASuperuserAuthorizationDialogDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnRestore;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIButton *tabMode1;
@property (weak, nonatomic) IBOutlet UIButton *tabMode2;
@property (weak, nonatomic) IBOutlet UIButton *tabMode3;
@property (weak, nonatomic) IBOutlet UIButton *tabBoostYes;
@property (weak, nonatomic) IBOutlet UIButton *tabBoostNo;
@property (weak, nonatomic) IBOutlet UIButton *tabOpRange;
@property (weak, nonatomic) IBOutlet UIButton *tabBoost;
@property (weak, nonatomic) IBOutlet SARangeCalibrationWheel *rangeCalibrationWheel;
- (IBAction)btnInfoTouch:(id)sender;
- (IBAction)btnRestoreTouch:(id)sender;
- (IBAction)btnOKTouch:(id)sender;
- (IBAction)tabMode123Touch:(id)sender;
- (IBAction)tabBoostYesNoTouch:(id)sender;
- (IBAction)tabOpRangeTouch:(id)sender;
- (IBAction)tabBoostTouch:(id)sender;

-(void)startConfiguration:(SADetailView*)detailView;
-(void)dismiss;
-(BOOL)exitLocked;
-(BOOL)onMenubarBackButtonPressed;
+(SAVLCalibrationTool*)newInstance;
@end

NS_ASSUME_NONNULL_END
