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

@class SADetailView;

@interface SAMainVC : UIViewController <UITableViewDataSource, UITableViewDelegate>


- (IBAction)settingsTouched:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationBottom;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UIImageView *notificationImage;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
- (void)detailHide;

@end


@interface SAMainView : UIView 

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic, readonly) SADetailView *detailView;

- (void)detailShow:(BOOL)show animated:(BOOL)animated;
- (void)moveCenter:(float)x_offset;

@end
