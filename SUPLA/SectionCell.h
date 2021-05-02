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

@class SASectionCell;
@protocol SASectionCellDelegate
@optional
- (void)sectionCellTouch:(SASectionCell*_Nonnull)section;
@end

@interface SASectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ivCollapsed;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic) int locationId;
@property (nonatomic) BOOL captionEditable;
@property (nonatomic, weak, nullable) id <SASectionCellDelegate> delegate;
@end
