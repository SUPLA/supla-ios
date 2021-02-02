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
#import "SAChannel+CoreDataClass.h"

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
    NSMutableArray *_deviceList;
    NSMutableArray *_channelList;
    NSMutableArray *_channelBasicCfgToFetch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceList = [[NSMutableArray alloc] init];
    _channelList = [[NSMutableArray alloc] init];
    _channelBasicCfgToFetch = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.page = self.welcomePage;
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

- (void)fetchChannelBasicCfg:(int)chanelId {
    
}

- (void)loadChannelList {
    self.btnNextEnabled = NO;
    self.btnCancelOrBackEnabled = NO;
    
    [_deviceList removeAllObjects];
    _channelList = [[NSMutableArray alloc] initWithArray:[SAApp.DB zwaveBridgeChannels]];
    
    for(id channel in _channelList) {
        BOOL exists = false;
        for(id fc in _channelBasicCfgToFetch) {
            if (((SAChannel*)fc).device_id == ((SAChannel*)channel).device_id) {
                exists = true;
                break;
            }
        }
        
        if (!exists) {
            [_channelBasicCfgToFetch addObject:channel];
        }
    }
    
    [self fetchChannelBasicCfg:0];
}

- (void)setPage:(UIView *)page {
    [super setPage:page];
    self.backButtonInsteadOfCancel = page != self.welcomePage;
    
    if (page == self.channelSelectionPage) {
        [self loadChannelList];
    }
}

- (IBAction)nextTouch:(nullable id)sender {
    [super nextTouch:sender];
    
    if (self.page == self.welcomePage) {
        self.page = self.channelSelectionPage;
    }
}

- (IBAction)cancelOrBackTouch:(id)sender {
    [super cancelOrBackTouch:sender];
    
    if (self.page == self.welcomePage) {
        [[SAApp UI] showMainVC];
    } else if (self.page == self.channelSelectionPage) {
        self.page = self.welcomePage;
    }
}

@end
