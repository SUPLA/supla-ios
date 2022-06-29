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

#import "SARateApp.h"
#import "SuplaApp.h"
#import "Database.h"

#define CFG_KEY @"rate_time"

@implementation SARateApp

-(void)moreDays:(int)days {
    
    int rt = [[NSDate dateWithTimeIntervalSinceNow:days * 86400] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setInteger:rt forKey:CFG_KEY];
    
}

-(void)showDialogWithDelay:(int)time {
 
    
    int rt = (int)[[NSUserDefaults standardUserDefaults] integerForKey:CFG_KEY];
    
    if ( rt == 0 ) {
        
        [self moreDays:1];
        
    } else if ( [[NSDate date] timeIntervalSince1970] >= rt ) {
        
        if ( [[SAApp DB] getChannelCount] > 0 ) {
            
            [self moreDays:1];
            [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(showAlertDialog:) userInfo:nil repeats:NO];
        }
        
    }
}

- (void)showAlertDialog:(NSTimer *)timer {
    
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"SUPLA"
                                 message:NSLocalizedString(@"Did you know that Supla is an open, free project developed by the community? If you like the app, spend a moment on rating it. Thank you for your support!", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* rateBtn = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"Rate Now", nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    [self moreDays: 3650];
                                    
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=996384706&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]];
                                    
                                }];
    
    UIAlertAction* laterBtn = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Later", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                         
                            }];
    
    UIAlertAction* noBtn = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"No thanks", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   
                                   [self moreDays: 3650];
                                   
                               }];
    
    [alert addAction:rateBtn];
    [alert addAction:laterBtn];
    [alert addAction:noBtn];
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:alert animated:YES completion:nil];
}


@end


