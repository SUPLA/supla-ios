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
@property (weak, nonatomic) IBOutlet SAUIChannelStatus *onlineStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cbPickerTopMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cbPickerBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clPickerBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vTabsWheelSliderBottomMargin;
@property (weak, nonatomic) IBOutlet UIView *vExtraButtons;
@property (weak, nonatomic) IBOutlet UIButton *btnPowerOnOff;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
@property (weak, nonatomic) IBOutlet UIView *vTabsRgbDimmer;
@property (weak, nonatomic) IBOutlet UIView *vTabsWheelSlider;
- (IBAction)onRgbTabTouch:(id)sender;
- (IBAction)onDimmerTabTouch:(id)sender;
- (IBAction)onPickerTypeTabTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *tabRGB;
@property (weak, nonatomic) IBOutlet UIButton *tabDimmer;
@property (weak, nonatomic) IBOutlet UIButton *tabWheel;
@property (weak, nonatomic) IBOutlet UIButton *tabSlider;
- (IBAction)onPowerBtnTouch:(id)sender;
- (IBAction)rgbInfoTouch:(id)sender;
- (IBAction)onSettingsTouch:(id)sender;

@end
