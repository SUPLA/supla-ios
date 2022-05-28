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
#import "SAWizardVC.h"

@interface SAConfigResult : NSObject

@property(nonatomic) int resultCode;
@property(copy, nonatomic) NSString *extendedResultError;
@property(nonatomic) long extendedResultCode;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *state;
@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *guid;
@property (copy, nonatomic) NSString *mac;
@property (assign, nonatomic) BOOL needsCloudConfig;
@end


@protocol SASetConfOpDelegate <NSObject>

@required
-(void)configResult:(SAConfigResult*)result;
@end

@interface SASetConfigOperation : NSOperation

@property (copy, nonatomic) NSString *SSID;
@property (copy, nonatomic) NSString *PWD;
@property (copy, nonatomic) NSString *Server;
@property (copy, nonatomic) NSString *Email;

@property(weak, nonatomic) id<SASetConfOpDelegate> delegate;
@end

@interface SAAddWizardVC : SAWizardVC <SASetConfOpDelegate>
@property (strong, nonatomic) IBOutlet UIView *vStep1;
@property (strong, nonatomic) IBOutlet UIView *vStep2;
@property (strong, nonatomic) IBOutlet UIView *vStep3;
@property (strong, nonatomic) IBOutlet UIView *vStep4;
@property (strong, nonatomic) IBOutlet UIView *vError;
@property (strong, nonatomic) IBOutlet UIView *vDone;
@property (weak, nonatomic) IBOutlet UILabel *txtErrorMEssage;
@property (weak, nonatomic) IBOutlet UITextField *edSSID;
@property (weak, nonatomic) IBOutlet UITextField *edPassword;
@property (weak, nonatomic) IBOutlet UISwitch *cbSavePassword;
- (IBAction)pwdViewTouchDown:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *vDot;
- (IBAction)wifiSettingsTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lName;
@property (weak, nonatomic) IBOutlet UILabel *lFirmware;
@property (weak, nonatomic) IBOutlet UILabel *lMAC;
@property (weak, nonatomic) IBOutlet UILabel *lLastState;
@property (weak, nonatomic) IBOutlet UIButton *btnSystemSettings;
@property (weak, nonatomic) IBOutlet UILabel *lStep3Text2;
@property (weak, nonatomic) IBOutlet UISwitch *swAutoMode;
@property (weak, nonatomic) IBOutlet UILabel *lAutoMode;
@property (weak, nonatomic) IBOutlet UILabel *lAutoModeWarning;
- (IBAction)swAutoModeChanged:(id)sender;

@end
