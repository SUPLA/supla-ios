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


#import "AboutVC.h"
#import "SuplaApp.h"

@interface SAAboutVC ()

@end

@implementation SAAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.version setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"version", nil), [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]]];
    self.title = @"supla";
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ( self.textView.frame.size.height < 100 ) {
        self.textView.hidden = YES;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)wwwTouch:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.supla.org"]];
}

- (IBAction)btnTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
