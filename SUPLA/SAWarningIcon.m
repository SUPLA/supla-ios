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

#import "SAWarningIcon.h"
#import "SAChannel+CoreDataClass.h"

@implementation SAWarningIcon {
    SAChannelBase *_channel;
    UITapGestureRecognizer *_tapGr;
}

-(void)setChannel:(SAChannelBase *)channel {

    if (channel && [channel isKindOfClass:[SAChannel class]]) {
        _channel = channel;
        self.image = ((SAChannel*) channel).warningIcon;
    } else {
        _channel = nil;
        self.image = nil;
    }
    
    if (self.image) {
        self.userInteractionEnabled = YES;
        self.hidden = NO;
        
        if (!_tapGr) {
            _tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(warningIconTapped:)];
            [self addGestureRecognizer:_tapGr];
        }
    } else {
        self.userInteractionEnabled = NO;
        self.hidden = YES;
    }

}

-(SAChannelBase*)channel {
    return _channel;
}

 - (void)warningIconTapped:(UITapGestureRecognizer *)tapRecognizer {
     if (!self.channel) {
         return;
     }

     NSString *warningMessage = ((SAChannel*)self.channel).warningMessage;
     
     if (warningMessage == nil) {
         return;
     }
     
     UIAlertController * alert = [UIAlertController
                                    alertControllerWithTitle:@"SUPLA"
                                    message:warningMessage
                                    preferredStyle:UIAlertControllerStyleAlert];
       
       UIAlertAction* btnOK = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", nil)
                               style:UIAlertActionStyleDefault
                               handler:nil];
       
       
       [alert setTitle: NSLocalizedString(@"Warning", nil)];
       [alert addAction:btnOK];
       
       UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
       [vc presentViewController:alert animated:YES completion:nil];
 }


@end
