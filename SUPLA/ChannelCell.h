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
 
 Author: Przemyslaw Zygmunt p.zygmunt@acsoftware.pl [AC SOFTWARE]
 */

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

@interface MGSwipeTableCell (SUPLA)

-(void) prepareForReuse;

@end

@interface MGSwipeButton (SUPLA)

-(void) setBackgroundColor:(UIColor *)backgroundColor withDelay:(NSTimeInterval) delay;

@end

@class SAChannel;
@interface SAChannelCell : MGSwipeTableCell


@property (strong, nonatomic) SAChannel *channel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *caption;
@property (weak, nonatomic) IBOutlet UIView *rightDot;
@property (weak, nonatomic) IBOutlet UIView *leftDot;
@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *humidity;
@property (weak, nonatomic) IBOutlet UILabel *distance;


@end
