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

@interface SASettingsVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *edServerHost;
@property (weak, nonatomic) IBOutlet UITextField *edAccessID;
@property (weak, nonatomic) IBOutlet UITextField *edAccessIDpwd;
@property (weak, nonatomic) IBOutlet UITextField *edEmail;
- (IBAction)saveTouch:(id)sender;
- (IBAction)createTouch:(id)sender;
- (IBAction)switchValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *swAdvanced;
@property (weak, nonatomic) IBOutlet UISwitch *swBasic;
@property (strong, nonatomic) IBOutlet UIView *vBasic;
@property (strong, nonatomic) IBOutlet UIView *vAdvanced;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
- (IBAction)emailChanged:(id)sender;

@end
