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

#import "SAZWaveConfigurationWizardVC.h"
#import "SuplaApp.h"

static SAZWaveConfigurationWizardVC *_zwaveConfigurationWizardGlobalRef = nil;

@interface SAZWaveConfigurationWizardVC ()
@property (strong, nonatomic) IBOutlet UIView *welcomePage;
@property (strong, nonatomic) IBOutlet UIView *errorPage;
@property (strong, nonatomic) IBOutlet UIView *channelSelectionPage;
@property (strong, nonatomic) IBOutlet UIView *channelDetailsPage;
@property (strong, nonatomic) IBOutlet UIView *itTakeAWhilePage;
@property (strong, nonatomic) IBOutlet UIView *settingsPage;
@property (strong, nonatomic) IBOutlet UIView *successInfoPage;

@end

@implementation SAZWaveConfigurationWizardVC {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showPageView:self.welcomePage];
}

-(IBAction)cancelTouch:(id)sender {
    [SAApp.UI showMainVC];
}

-(void) superuserAuthorizationSuccess {
    [SASuperuserAuthorizationDialog.globalInstance close];
    [SAApp.UI showViewController:self];
}

-(void)show {
    [SASuperuserAuthorizationDialog.globalInstance authorizeWithDelegate:self];
}

+(SAZWaveConfigurationWizardVC*)globalInstance {
    if ( _zwaveConfigurationWizardGlobalRef == nil ) {
        _zwaveConfigurationWizardGlobalRef = [[SAZWaveConfigurationWizardVC alloc]
                                              initWithNibName:@"SAZWaveConfigurationWizardVC" bundle:nil];
    }
    
    return _zwaveConfigurationWizardGlobalRef;
}

@end
