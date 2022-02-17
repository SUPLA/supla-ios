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

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "SAChannelBase+CoreDataClass.h"
#import "SAUIChannelStatus.h"

#import "SAWarningIcon.h"

@interface MGSwipeTableCell (SUPLA)

-(void) prepareForReuse;

@end

@interface MGSwipeButton (SUPLA)

-(void) setBackgroundColor:(UIColor *)backgroundColor withDelay:(NSTimeInterval) delay;

@end

@class SAChannel;
@interface SAChannelCell : MGSwipeTableCell


@property (strong, nonatomic) SAChannelBase *channelBase;
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet SAUIChannelStatus *right_OnlineStatus;
@property (weak, nonatomic) IBOutlet SAUIChannelStatus *left_OnlineStatus;
@property (weak, nonatomic) IBOutlet SAUIChannelStatus *right_ActiveStatus;
@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *humidity;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cint_LeftStatusWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cint_RightStatusWidth;
@property (weak, nonatomic) IBOutlet UILabel *measuredValue;
@property (weak, nonatomic) IBOutlet UIImageView *channelStateIcon;
@property (weak, nonatomic) IBOutlet SAWarningIcon *channelWarningIcon;
@property (copy, nonatomic) NSIndexPath *currentIndexPath;
/**
 Collection of layout constraints which should be subject to scaling with respect to Channel Height adjustment.
 */
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray<NSLayoutConstraint *> *channelIconScalableConstraints;
@property (nonatomic) BOOL captionTouched;
@property (nonatomic) BOOL captionEditable;

@end
