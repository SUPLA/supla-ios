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

#import "DetailView.h"
#import "SAColorBrightnessPicker.h"
#import "SAColorListPicker.h"
#import "SAUIChannelStatus.h"

@interface SARGBWDetailView : SADetailView <SAColorBrightnessPickerDelegate, SAColorListPickerDelegate>
@property (weak, nonatomic) IBOutlet SAColorBrightnessPicker *cbPicker;
@property (weak, nonatomic) IBOutlet SAColorListPicker *clPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UIView *headerView;
- (IBAction)segChanged:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cintPickerTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cintHeaderHeight;
@property (weak, nonatomic) IBOutlet UILabel *labelCaption;
@property (weak, nonatomic) IBOutlet UIButton *stateBtn;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cintFooterHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cintFooterTop;
@property (weak, nonatomic) IBOutlet SAUIChannelStatus *onlineStatus;

- (IBAction)stateBtnTouch:(id)sender;

@end
