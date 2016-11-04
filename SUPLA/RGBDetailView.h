/*
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
 
 Author: Przemyslaw Zygmunt przemek@supla.org
 */

#import "DetailView.h"
#import "SAColorBrightnessPicker.h"

@interface SARGBDetailView : SADetailView <SAColorBrightnessPickerDelegate>
@property (weak, nonatomic) IBOutlet SAColorBrightnessPicker *cbPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UIView *headerView;
- (IBAction)segChanged:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cintPickerTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cintHeaderHeight;
@property (weak, nonatomic) IBOutlet UILabel *labelCaption;
@property (weak, nonatomic) IBOutlet UILabel *labelPercent;
@property (weak, nonatomic) IBOutlet UILabel *labelColorHEX;
@property (weak, nonatomic) IBOutlet UILabel *labelColor;
@property (weak, nonatomic) IBOutlet UIButton *stateBtn;
@property (weak, nonatomic) IBOutlet UIView *vLine3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cintLine3Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cintFooterHeight;
- (IBAction)stateBtnTouch:(id)sender;

@end
