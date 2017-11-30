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

#import "RSDetailView.h"
#import "DetailView.h"
#import "UIHelper.h"
#import "SuplaApp.h"

@implementation SARSDetailView


-(void)detailViewInit {
    
    if ( self.initialized == NO ) {
        
        self.backgroundColor = [UIColor rsDetailBackground];
        self.rsView.gestureEnabled = YES;
        self.rsView.delegate = self;
    }
    
    
    [super detailViewInit];
    
}

-(void)dataToView {
    
    if ( self.channel != nil ) {
        
        [self.labelCaption setText:[self.channel getChannelCaption]];
        
        int percent = self.channel.percentValue;
        
        if ( percent < 100 && self.channel.isClosed ) {
            percent = 100;
        }
        
        self.rsView.percent = percent;
        
        if ( percent < 0 ) {
            [self.labelPercent setText:NSLocalizedString(@"[Calibration]", NULL)];
        } else {
            [self.labelPercent setText:[NSString stringWithFormat:@"%i%%", (int)percent]];
        }
        
    }
    
}

-(void)updateView {
    [super updateView];
    [self dataToView];
};

-(void)setChannel:(SAChannel *)channel {
    [super setChannel:channel];
    
    if ( channel != nil && channel.isOnline == NO ) {
        [self.main_view detailShow:NO animated:NO];
    }
};

- (void)open:(int)value {
    SASuplaClient *client = [SAApp SuplaClient];
    if ( client != nil && self.channel != nil )  {
        [[SAApp SuplaClient] channel:[self.channel.channel_id intValue] Open:value];
    }
    
}

- (IBAction)upTouch:(id)sender {
    [self open:2];
}

- (IBAction)downTouch:(id)sender {
    [self open:1];
}

- (IBAction)stopTouch:(id)sender {
    [self open:0];
}

- (IBAction)openTouch:(id)sender {
    [self open:10];
}

- (IBAction)closeTouch:(id)sender {
    [self open:110];
}

-(void) rsChangeing:(id)rs withPercent:(float)percent {
    [self.labelPercent setText:[NSString stringWithFormat:@"%i%%", (int)percent]];
}

-(void) rsChanged:(id)rs withPercent:(float)percent {
    [self dataToView];
    [self open:percent+10];
}


@end
