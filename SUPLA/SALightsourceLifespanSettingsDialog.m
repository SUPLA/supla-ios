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

#import "SALightsourceLifespanSettingsDialog.h"
#import "SuplaApp.h"

@interface SALightsourceLifespanSettingsDialog ()
@property (weak, nonatomic) IBOutlet UILabel *lTitle;
@property (weak, nonatomic) IBOutlet UISwitch *resetCheckBox;
@property (weak, nonatomic) IBOutlet UITextField *tfLifespan;

@end

static SALightsourceLifespanSettingsDialog *_lifespanSettingsDialogGlobalRef = nil;

@implementation SALightsourceLifespanSettingsDialog {
    int _remoteId;
    int _lifespan;
}

-(void)show:(int)remoteId title:(NSString *)title lifesourceLifespan:(int)lifespan {
    _remoteId = remoteId;
    _lifespan = lifespan;
    self.resetCheckBox.on = NO;
    [self.lTitle setText:title];
    [self.tfLifespan setText:[NSString stringWithFormat:@"%i", _lifespan]];
    [SADialog showModal:self];
}

+(SALightsourceLifespanSettingsDialog*)globalInstance {
    if (_lifespanSettingsDialogGlobalRef == nil) {
        _lifespanSettingsDialogGlobalRef =
        [[SALightsourceLifespanSettingsDialog alloc]
         initWithNibName:@"SALightsourceLifespanSettingsDialog" bundle:nil];
    }
    
    return _lifespanSettingsDialogGlobalRef;
}

- (IBAction)okTouched:(id)sender {
    int lifespan = [self.tfLifespan.text intValue];
    
    if (lifespan < 0) {
        lifespan = 0;
    } else if (lifespan > 65535) {
        lifespan = 65535;
    }
    
    if (lifespan != _lifespan || self.resetCheckBox.on) {
        [SAApp.SuplaClient setLightsourceLifespanWithChannelId:_remoteId
                                                resetCounter:self.resetCheckBox.on
                                                setTime:lifespan != _lifespan
                                                lifespan:lifespan];
    }
    
    [self close];
}
@end
