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

@interface SADimmerCalibrationTool : UIView <UIGestureRecognizerDelegate, SASuperuserAuthorizationDialogDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnRestore;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIView *tabBgLedOn;
@property (weak, nonatomic) IBOutlet UIImageView *tabLedOn;
@property (weak, nonatomic) IBOutlet UIView *tabBgLedOff;
@property (weak, nonatomic) IBOutlet UIImageView *tabLedOff;
@property (weak, nonatomic) IBOutlet UIView *tabBgLedAlwaysOff;
@property (weak, nonatomic) IBOutlet UIImageView *tabLedAlwaysOff;

- (void)initGestureRecognizerForView:(UIView *)view action:(SEL)action;
- (IBAction)btnInfoTouch:(id)sender;
- (IBAction)btnRestoreTouch:(id)sender;
- (IBAction)btnOKTouch:(id)sender;

- (void) deviceCalCfgCommand:(int)command charValue:(nullable char*)charValue shortValue:(nullable short*)shortValue;
- (void) deviceCalCfgCommand:(int)command charValue:(char)charValue;
- (void) deviceCalCfgCommand:(int)command shortValue:(short)shortValue;
- (void) deviceCalCfgCommand:(int)command;
- (void) deviceCalCfgCommandWithDelay:(int)command;

-(void)startConfiguration:(SADetailView*)detailView;
-(void)setConfigurationStarted;
-(void)cfgToUIWithDelay:(BOOL)delay;
-(void)dismiss;
-(BOOL)isExitLocked;
-(BOOL)onMenubarBackButtonPressed;
-(BOOL)isConfigurationStarted;
-(void)showPreloaderWithText:(NSString *)text;

+(SADimmerCalibrationTool*)newInstance;
@end

NS_ASSUME_NONNULL_END
