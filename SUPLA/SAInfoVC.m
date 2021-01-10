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

#import "SAInfoVC.h"

@interface SAInfoVC ()
@property (strong, nonatomic) IBOutlet UIView *vDimmer;
@property (strong, nonatomic) IBOutlet UIView *vVarilightConfig;
@property (strong, nonatomic) IBOutlet UIView *vDiwConfig;
@end

@implementation SAInfoVC {
    UIView *_rootView;
}

- (UIView*)rootView {
    return _rootView;
}

- (void)setRootView:(UIView*)view {
    if (_rootView) {
        [_rootView removeFromSuperview];
    }
    _rootView = view;
    if (_rootView) {
        [self.view addSubview:_rootView];
    }
}

+(void)showInformationWindowWithMessage:(int)msg {
    
    SAInfoVC *vc = [[SAInfoVC alloc] initWithNibName:@"SAInfoVC" bundle:nil];
    switch (msg) {
        case INFO_MESSAGE_DIMMER:
            [vc setRootView:vc.vDimmer];
            break;
        
        case INFO_MESSAGE_VARILIGHT_CONFIG:
            [vc setRootView:vc.vVarilightConfig];
            break;
            
        case INFO_MESSAGE_DIW_CONFIG:
            [vc setRootView:vc.vDiwConfig];
            break;
        default:
            vc.view = nil;
            break;
    }
    

    [SADialog showModal:vc];
    
}

- (IBAction)varlilightUrlButtonTouch:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        [self close];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: ((UIButton*)sender).titleLabel.text]];
    }
}

@end
