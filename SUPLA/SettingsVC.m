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

#import "SettingsVC.h"
#import "SuplaApp.h"

@interface SASettingsVC ()

@end

@implementation SASettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.edServerHost setText:[SAApp getServerHostName]];
    [self.edAccessID setText:[SAApp getAccessID] ? [NSString stringWithFormat:@"%i", [SAApp getAccessID]] : @""];
    [self.edAccessIDpwd setText:[SAApp getAccessIDpwd]];
    
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
    
    if ( [SAApp getAccessID] != aid ) {
        [SAApp setAccessID:aid];
        changed = YES;
    }
    
    if ( [[SAApp getAccessIDpwd] isEqualToString:self.edAccessIDpwd.text] == NO ) {
        [SAApp setAccessIDpwd:self.edAccessIDpwd.text];
        changed = YES;
    }
    
    if ( changed || [SAApp SuplaClientConnected] == NO ) {
        [[SAApp SuplaClient] reconnect];
    }
    
    [[SAApp UI] hideVC];
    
}
@end
