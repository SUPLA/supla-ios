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

#import "SettingsVC.h"
#import "SuplaApp.h"
#import "SAClassHelper.h"

@interface SASettingsVC ()

@end

@implementation SASettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.edEmail setText:[SAApp getEmailAddress]];
    [self.edServerHost setText:[SAApp getServerHostName]];
    [self.edAccessID setText:[SAApp getAccessID] ? [NSString stringWithFormat:@"%i", [SAApp getAccessID]] : @""];
    [self.edAccessIDpwd setText:[SAApp getAccessIDpwd]];


    [self.btnCreate setAttributedTitle:NSLocalizedString(@"Create an account", nil)];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:14];
    [comps setMonth:4];
    [comps setYear:2018];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    if ( [[NSDate date] timeIntervalSince1970] >= [date timeIntervalSince1970] ) {
        self.btnCreate.hidden = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ( [SAApp isAdvancedConfig] ) {
        self.view = self.vAdvanced;
    } else {
        self.view = self.vBasic;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)saveTouch:(id)sender {
    
    BOOL changed = NO;
    
    if ( [[SAApp getServerHostName] isEqualToString:self.edServerHost.text] == NO ) {
        [SAApp setServerHostName:self.edServerHost.text];
        changed = YES;
    };
    
    int aid = 0;
    
    @try {
        aid = [self.edAccessID.text intValue];
    }
    @catch ( NSException *e ) {
        aid = 0;
    };
    
    if ( [[SAApp getEmailAddress] isEqualToString:self.edEmail.text] == NO ) {
        [SAApp setEmailAddress:self.edEmail.text];
        changed = YES;
    }
    
    if ( [SAApp getAccessID] != aid ) {
        [SAApp setAccessID:aid];
        changed = YES;
    }
    
    if ( [[SAApp getAccessIDpwd] isEqualToString:self.edAccessIDpwd.text] == NO ) {
        [SAApp setAccessIDpwd:self.edAccessIDpwd.text];
        changed = YES;
    }
    
    if ( [SAApp isAdvancedConfig] != (self.view == self.vAdvanced) ) {
        [SAApp setAdvancedConfig:self.view == self.vAdvanced];
        changed = YES;
    }
    
    if (changed) {
        [SAApp revokeOAuthToken];
        [SAApp.DB deleteAllUserIcons];
    }
    
    // Show main vc before reconnect
    [[SAApp UI] showMainVC];
    
    if ( changed || [SAApp SuplaClientConnected] == NO ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSAConnectingNotification object:self userInfo:nil];
        [SAApp setPreferedProtocolVersion:SUPLA_PROTO_VERSION];
        [[SAApp SuplaClient] reconnect];
    }
    
}

- (IBAction)createTouch:(id)sender {

       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://cloud.supla.org/account/create"]];
    [SAApp.UI showCreateAccountVC];
}

- (IBAction)switchValueChanged:(id)sender {
    
    
    [self.swBasic setOn:NO];
    [self.swAdvanced setOn:YES];
    

    if ( sender == self.swBasic) {
        self.view = self.vAdvanced;
    } else {
        self.view = self.vBasic;
    }
    
    
}
- (IBAction)emailChanged:(id)sender {
    
    [self.edServerHost setText:@""];
    
}
@end
